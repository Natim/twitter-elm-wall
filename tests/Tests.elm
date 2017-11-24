module Tests exposing (..)

import Test exposing (..)
import Expect
import Utils exposing (timeAgo)


timeAgoTest : String -> Float -> String -> Test
timeAgoTest description diff result =
    let
        now =
            1473870908000

        current =
            now - diff

        subject =
            timeAgo current now
    in
        test description <| \() -> Expect.equal subject result


all : Test
all =
    describe "Date.TimeAgo"
        [ timeAgoTest "<10s diff" (seconds 4) "a few seconds ago"
        , timeAgoTest "<1mn diff" (seconds 12) "12 seconds ago"
        , timeAgoTest "55 seconds" (seconds 55) "about a minute ago"
        , timeAgoTest "58 seconds" (seconds 58) "about a minute ago"
        , timeAgoTest "60 seconds" (seconds 60) "about a minute ago"
        , timeAgoTest "62 seconds" (seconds 62) "about a minute ago"
        , timeAgoTest "65 seconds" (seconds 65) "about a minute ago"
        , timeAgoTest "12 minutes" (minutes 12) "12 minutes ago"
        , timeAgoTest "30 minutes" (minutes 30) "30 minutes ago"
        , timeAgoTest "48 minutes" (minutes 48) "48 minutes ago"
        , timeAgoTest "50 minutes" (minutes 50) "50 minutes ago"
        , timeAgoTest "58 minutes" (minutes 58) "about an hour ago"
        , timeAgoTest "60 minutes" (minutes 60) "about an hour ago"
        , timeAgoTest "62 minutes" (minutes 62) "about an hour ago"
        , timeAgoTest "12 hours" (hours 12) "12 hours ago"
        , timeAgoTest "23 hours" (hours 23) "about a day ago"
        , timeAgoTest "24 hours" (hours 24) "about a day ago"
        , timeAgoTest "25 hours" (hours 25) "about a day ago"
        , timeAgoTest "~=1week diff" (days 7) "about a week ago"
        , timeAgoTest "~=2weeks diff" (days 14) "about 2 weeks ago"
        , timeAgoTest "~=3weeks diff" (days 21) "about 3 weeks ago"
        , timeAgoTest "<1month diff" (days 12) "12 days ago"
        , timeAgoTest "=1month= diff" (days 31) "about a month ago"
        , timeAgoTest "<1month diff, week match" (days 14) "about 2 weeks ago"
        , timeAgoTest "<1year diff (6 months)" (months 6) "6 months ago"
        , timeAgoTest "<1year diff (10 months)" (months 10) "10 months ago"
        , timeAgoTest "=1year- diff (350 days)" (days 350) "about a year ago"
        , timeAgoTest "=1year= diff (365 days)" (days 365) "about a year ago"
        , timeAgoTest "=1year+ diff (380 days)" (days 380) "about a year ago"
        , timeAgoTest ">1 year" (years 12) "12 years ago"
        ]


seconds : Float -> Float
seconds x =
    x * 1000


minutes : Float -> Float
minutes x =
    x * (seconds 60)


hours : Float -> Float
hours x =
    x * (minutes 60)


days : Float -> Float
days x =
    x * (hours 24)


months : Float -> Float
months x =
    x * (days (365.25 / 12))


years : Float -> Float
years x =
    x * (days 365.25)
