module Main exposing (..)

import Html
import App exposing (Model, Msg, init, view, update, subscriptions)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
