module View.ElmHtml exposing (view)

import Engine.Skill as Skill exposing (Skill, SkillEffect)
import Html exposing (Attribute, Html, div, h5, main_, p, text)
import Html.Attributes exposing (class, id)
import Html.Events
import View.Svg


skillEffectClass : Skill -> Attribute msg
skillEffectClass skill =
    class <|
        case skill.state of
            Skill.Cooling _ ->
                "skill-cooling"

            Skill.Active _ ->
                "skill-active"

            Skill.Ready ->
                "skill-ready"


skillStateClass : Skill -> Attribute msg
skillStateClass skill =
    class <|
        case skill.effect of
            Skill.Hit _ ->
                "skill-hit"

            Skill.Buff _ ->
                "skill-buff"

            Skill.Debuff _ ->
                "skill-debuff"


viewSmallSkill : Skill -> Html msg
viewSmallSkill skill =
    div
        [ class "small-skill"
        , skillStateClass skill
        , skillEffectClass skill
        ]
        []


viewSkillButton : msg -> Skill -> Html msg
viewSkillButton clickMsg skill =
    let
        icon : Char
        icon =
            case skill.effect of
                Skill.Hit _ ->
                    '➹'

                Skill.Buff _ ->
                    '⬆'

                Skill.Debuff _ ->
                    '⬇'
    in
    Html.button
        [ Html.Events.onClick clickMsg
        , class "skill-button"
        , skillStateClass skill
        , skillEffectClass skill
        ]
        [ View.Svg.viewSpinner (Skill.cooldownPercentage skill) icon
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
        , div [ class "small-skill-buttons" ] (List.map viewSmallSkill model.skills)
        , div [ class "skill-buttons" ] (List.indexedMap (\i -> viewSkillButton (useSkill i)) model.skills)
        ]
