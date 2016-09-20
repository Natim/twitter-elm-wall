module Main exposing (..)

import Html.App
import String
import App exposing (init, view, update, subscriptions)


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
