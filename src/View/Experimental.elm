module View.Experimental exposing (viewSkillButton, viewSpinner)

import Engine.Skill as Skill exposing (Skill)
import Html exposing (Html, button, div, h3, p, strong, text)
import Html.Attributes
import Html.Events
import Svg exposing (svg)
import Svg.Attributes


viewSpinner : Int -> Char -> Html msg
viewSpinner percentage icon =
    svg
        [ Svg.Attributes.viewBox "-1 -1 34 34"
        , Svg.Attributes.width "50px"
        ]
        [ Svg.circle
            [ Svg.Attributes.stroke "grey"
            , Svg.Attributes.fill "none"
            , Svg.Attributes.strokeWidth "2"
            , Svg.Attributes.cx "16"
            , Svg.Attributes.cy "16"
            , Svg.Attributes.r "15.9155"
            ]
            []
        , Svg.circle
            [ Svg.Attributes.stroke "magenta"
            , Svg.Attributes.fill "none"
            , Svg.Attributes.transform "rotate(90, 16, 16)"
            , Svg.Attributes.strokeWidth "2"
            , Svg.Attributes.strokeLinecap "round"
            , Svg.Attributes.cx "16"
            , Svg.Attributes.cy "16"
            , Svg.Attributes.r "15.9155"
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


viewSkillButton : Skill -> msg -> Html msg
viewSkillButton skill clickMsg =
    button
        [ Html.Attributes.style "display" "flex"
        , Html.Events.onClick clickMsg
        , Html.Attributes.disabled (Skill.isReady skill |> not)
        ]
        [ viewSpinner (((Skill.currentCooldown skill |> toFloat) / (Tuple.second skill.cooldownTime |> toFloat)) * 100 |> round) 'x'
        , div []
            [ h3 [] [ text skill.name ]
            , p [] [ text skill.description ]
            ]
        ]
