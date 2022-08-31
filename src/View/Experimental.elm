module View.Experimental exposing (viewSkillButton)

import Element exposing (Attribute, Element, el, fill, pointer, px, rgb255, rgba255, text)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font as Font
import Engine.Skill as Skill exposing (Skill)
import Svg exposing (svg)
import Svg.Attributes


viewSpinner : Int -> Char -> Element msg
viewSpinner percentage icon =
    el [ Element.width <| px 40 ] <|
        Element.html <|
            svg
                [ Svg.Attributes.viewBox "-1 -1 34 34" ]
                [ Svg.circle
                    [ Svg.Attributes.stroke "magenta"
                    , Svg.Attributes.fill "none"
                    , Svg.Attributes.transform "rotate(90, 16, 16)"
                    , Svg.Attributes.strokeWidth "2"
                    , Svg.Attributes.strokeLinecap "round"
                    , Svg.Attributes.cx "16"
                    , Svg.Attributes.cy "16"
                    , Svg.Attributes.r "15.9155"
                    , Svg.Attributes.shapeRendering "geometricPrecision"
                    , Svg.Attributes.strokeDasharray ((clamp 0 100 percentage |> String.fromInt) ++ ", 100")
                    ]
                    []
                , Svg.text_
                    [ Svg.Attributes.x "16"
                    , Svg.Attributes.y "16"
                    , Svg.Attributes.textAnchor "middle"
                    , Svg.Attributes.dominantBaseline "middle"
                    , Svg.Attributes.fill "#262626"
                    , Svg.Attributes.fontFamily "sans-serif"
                    ]
                    [ Svg.text <| String.fromChar icon ]
                ]


viewSkillButton : Skill -> msg -> Element msg
viewSkillButton skill clickMsg =
    let
        readyState : Skill -> List (Attribute msg)
        readyState s =
            if Skill.isReady s then
                [ Element.Events.onClick clickMsg
                , pointer
                , Background.color <| rgba255 255 255 255 0.7
                ]

            else
                [ Background.color <| rgba255 255 255 255 0.5 ]
    in
    Element.row
        (readyState skill
            ++ [ Border.rounded 9999
               , Element.paddingEach
                    { top = 5
                    , right = 25
                    , bottom = 5
                    , left = 5
                    }
               , Element.spacing 15
               , Font.color <| rgb255 50 50 50
               , Element.width fill
               , Border.shadow
                    { offset = ( 0.5, 0.5 )
                    , size = 2
                    , blur = 8
                    , color = rgba255 50 50 50 0.2
                    }
               ]
        )
        [ viewSpinner (((Skill.currentCooldown skill |> toFloat) / (Tuple.second skill.cooldownTime |> toFloat)) * 100 |> round) '★'
        , Element.column [ Element.spacing 3 ]
            [ el [ Font.size 16 ] (text skill.name)
            , el
                [ Font.size 12
                , Font.extraLight
                , Font.color <| rgb255 110 110 110
                ]
                (text skill.description)
            ]
        ]
