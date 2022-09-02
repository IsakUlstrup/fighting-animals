module View.Experimental exposing (viewSkillButton)

import Element exposing (Attribute, Element, el, fill, pointer, px, rgb255, rgba255, scale, text)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font as Font
import Engine.Skill as Skill exposing (Skill)
import View.Svg


viewSkillButton : msg -> Skill -> Element msg
viewSkillButton clickMsg skill =
    let
        readyState : Skill -> List (Attribute msg)
        readyState s =
            if Skill.isReady s then
                [ Element.Events.onClick clickMsg
                , pointer
                , Background.color <| rgba255 255 255 255 0.7
                , Border.shadow
                    { offset = ( 0.5, 0.5 )
                    , size = 2
                    , blur = 8
                    , color = rgba255 50 50 50 0.2
                    }
                ]

            else if Skill.isActive s then
                [ Background.color <| rgba255 255 255 255 0.7
                , scale 1.05
                , Border.shadow
                    { offset = ( 0.5, 0.5 )
                    , size = 3
                    , blur = 8
                    , color = rgba255 255 120 211 0.8
                    }
                ]

            else
                [ Background.color <| rgba255 255 255 255 0.5
                , Border.shadow
                    { offset = ( 0.5, 0.5 )
                    , size = 2
                    , blur = 8
                    , color = rgba255 50 50 50 0.2
                    }
                ]
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
               ]
        )
        [ el [ Element.width <| px 40 ] <|
            Element.html <|
                View.Svg.viewSpinner (Skill.cooldownPercentage skill) '★'
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
