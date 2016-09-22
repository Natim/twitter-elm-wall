module App exposing (..)

import Date exposing (Date)
import Html
import Html.Attributes
import Html.Events
import Time exposing (Time, hour, second)
import Utils


-- import Html.Attributes

import Http
import HttpBuilder
import Json.Decode as Json
import Task


type Msg
    = FetchSucceed (HttpBuilder.Response (List Tweet))
    | FetchFail (HttpBuilder.Error String)
    | Tick Time
    | Refresh Time
    | NewSearch String


twitterBearerToken : String
twitterBearerToken =
    "AAAAAAAAAAAAAAAAAAAAAJc9xAAAAAAAEqIw9D7P%2FVH3tw3WZyFcIyhmUv4%3D5eWCMgEwC4YSfnMzkH7PZ0HeN4ql6i0hfZQ9EZ6KYXPsoXqGPy"


twitterApiUrl : String
twitterApiUrl =
    "https://cors-anywhere.herokuapp.com/https://api.twitter.com/1.1/search/tweets.json?q="



-- MODEL


type alias Author =
    String


type alias Text =
    String


type alias Tweet =
    { author : Author, text : Text, date : Date }


type alias Model =
    { tweets : List Tweet
    , error : Maybe String
    , currentTime : Time
    , currentSearch : String
    }


init : ( Model, Cmd Msg )
init =
    ( { tweets = []
      , error = Nothing
      , currentTime = 0
      , currentSearch = "#elm"
      }
    , ( getTweets "#elm")
    )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div
        []
        [ Html.h1 [] [ Html.text "Tweet Elm Wall" ]
        , Html.text (Maybe.withDefault "" model.error)
        , Html.br [] []
        , Html.ul [] (List.map (displayTweet model.currentTime) model.tweets)
        , Html.input [ Html.Events.onInput NewSearch, Html.Attributes.value model.currentSearch ] []
        , Html.button [ Html.Events.onClick (Refresh model.currentTime) ] [ Html.text "Refresh" ]
        ]


displayTweet : Time -> Tweet -> Html.Html Msg
displayTweet currentTime tweet =
    let
        author =
            "Author: " ++ tweet.author
    in
        Html.li []
            [ Html.text tweet.text
            , Html.br [] []
            , Html.text author
            , Html.text " — "
            , Html.text (Utils.timeAgo (Date.toTime tweet.date) currentTime)
            ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | currentTime = newTime }, Cmd.none )

        Refresh _ ->
            ( model, ( getTweets model.currentSearch ) )

        NewSearch query ->
            ( { model | currentSearch = query }, Cmd.none )

        FetchSucceed response ->
            ( { model | tweets = response.data }, Cmd.none )

        FetchFail error ->
            ( { model | error = Just (toString error) }, Cmd.none )


getTweets : String -> Cmd Msg
getTweets query =
    Task.perform
        FetchFail
        FetchSucceed
        (HttpBuilder.get (twitterApiUrl ++ (Http.uriEncode query))
            |> HttpBuilder.withHeader "Authorization" ("Bearer " ++ twitterBearerToken)
            |> HttpBuilder.send (HttpBuilder.jsonReader decodeTweet) HttpBuilder.stringReader
        )


decodeTweet : Json.Decoder (List Tweet)
decodeTweet =
    Json.at [ "statuses" ] (Json.list getTweet)


getTweet : Json.Decoder Tweet
getTweet =
    Json.object3 Tweet getAuthor getText getDate


getAuthor : Json.Decoder Author
getAuthor =
    Json.at [ "user", "name" ] Json.string


getText : Json.Decoder Text
getText =
    Json.at [ "text" ] Json.string


getDate : Json.Decoder Date
getDate =
    Json.at [ "created_at" ] normalizeDate


normalizeDate : Json.Decoder Date
normalizeDate =
    Json.map (\d -> Result.withDefault (Date.fromTime 0) (Date.fromString d)) Json.string



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every second Tick
        , Time.every hour Refresh
        ]
