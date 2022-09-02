module View.ElmHtml exposing (view)

import Engine.Skill as Skill exposing (Skill, SkillEffect)
import Html exposing (Html, div, h5, main_, p, text)
import Html.Attributes exposing (class, id)
import Html.Events
import View.Svg


viewSkillButton : msg -> Skill -> Html msg
viewSkillButton clickMsg skill =
    Html.button
        [ Html.Events.onClick clickMsg
        , class "skill-button"
        , class <|
            case skill.state of
                Skill.Cooling _ ->
                    "skill-cooling"

                Skill.Active _ ->
                    "skill-active"

                Skill.Ready ->
                    "skill-ready"
        ]
        [ View.Svg.viewSpinner (Skill.cooldownPercentage skill) '★'
        , div [ class "skill-meta" ]
            [ h5 [] [ text skill.name ]
            , p [] [ text skill.description ]
            ]
        ]


viewSkillEffect : SkillEffect -> Html msg
viewSkillEffect effect =
    p [] [ text <| Skill.effectToString effect ]


view :
    { skills : List Skill
    , skillEffects : List SkillEffect
    }
    -> (Int -> msg)
    -> Html msg
view model useSkill =
    main_ [ id "app" ]
        [ div [ class "skill-effects" ] (List.map viewSkillEffect model.skillEffects)
        , div [ class "skill-buttons" ] (List.indexedMap (\i -> viewSkillButton (useSkill i)) model.skills)
        ]
