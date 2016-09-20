module Main exposing (..)

import Html
import Html.App
import Html.Attributes
import Http
import Json.Decode as Json
import Json.Decode exposing ((:=))
import String
import Task


kintoUrl : String
kintoUrl =
    "https://kinto-ota.dev.mozaws.net/v1/buckets/dadounets/collections/wall/records?attachment.mimetype=image/jpeg"


attachmentUrl : String
attachmentUrl =
    "https://kinto-ota.dev.mozaws.net/attachments/"


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = Foo
    | FetchSucceed (List Image)
    | FetchFail Http.Error



-- MODEL


type alias Url =
    String


type alias Title =
    String


type alias Image =
    { title : Title, url : Url }


type alias Model =
    { images : List Image
    , error : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { images = []
      , error = Nothing
      }
    , getImages
    )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div
        []
        [ Html.text (Maybe.withDefault "" model.error)
        , Html.br [] []
        , Html.ul [] (List.map displayImage model.images)
        ]


displayImage : Image -> Html.Html Msg
displayImage image =
    let
        author =
            "Author: " ++ image.title

        fullUrl =
            attachmentUrl ++ image.url
    in
        Html.li []
            [ Html.img
                [ Html.Attributes.src fullUrl
                , Html.Attributes.title author
                ]
                []
            ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Foo ->
            ( model, Cmd.none )

        FetchSucceed data ->
            ( { model | images = data }, Cmd.none )

        FetchFail error ->
            ( { model | error = Just (toString error) }, Cmd.none )


getImages : Cmd Msg
getImages =
    Task.perform FetchFail FetchSucceed (Http.get decodeImageUrl kintoUrl)


decodeImageUrl : Json.Decoder (List Image)
decodeImageUrl =
    Json.at [ "data" ] (Json.list getImage)


getImage : Json.Decoder Image
getImage =
    Json.object2 Image getTitle getLocation


getTitle : Json.Decoder Title
getTitle =
    Json.at [ "from", "first_name" ] Json.string


getLocation : Json.Decoder Url
getLocation =
    Json.at [ "attachment", "location" ] normalizeUrl


normalizeUrl : Json.Decoder Url
normalizeUrl =
    Json.map stripAbsolute Json.string


stripAbsolute : String -> Url
stripAbsolute str =
    if String.startsWith attachmentUrl str then
        String.dropLeft (String.length attachmentUrl) str
    else
        str



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
