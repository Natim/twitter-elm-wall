module Tests exposing (..)

import Html
import Html.Attributes
import Test exposing (..)
import Expect
import String
import Html
import App exposing (displayImage, attachmentUrl)


all : Test
all =
    describe "Test display Image"
        [ test "Image should display the Author" <|
            \() ->
                Expect.equal (displayImage { title = "Rémy", url = "file.jpg" })
                    (Html.li
                        []
                        [ Html.img
                            [ Html.Attributes.src (attachmentUrl ++ "file.jpg")
                            , Html.Attributes.title "Author: Rémy"
                            ]
                            []
                        ]
                    )
        ]
