module View.ElmHtml exposing (view, viewCombatLog)

import Engine.Skill as Skill exposing (Skill, SkillEffect)
import Html exposing (Attribute, Html, div, h5, li, main_, p, text, ul)
import Html.Attributes exposing (class, id)
import Html.Events
import Svg exposing (Svg)
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
        icon : Svg msg
        icon =
            case skill.effect of
                Skill.Hit _ ->
                    View.Svg.fist

                Skill.Buff _ ->
                    View.Svg.arrowUp

                Skill.Debuff _ ->
                    View.Svg.arrowDown
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
    li [] [ text <| Skill.effectToString effect ]


viewCombatLog : List SkillEffect -> Html msg
viewCombatLog skillEffects =
    ul [ class "combat-log" ] (List.map viewSkillEffect skillEffects)


view : List Skill -> List Skill -> List SkillEffect -> (Int -> msg) -> Html msg
view skills enemySkills combatLog useSkill =
    main_ [ id "app" ]
        [ div [ class "small-skill-buttons enemy" ] (List.map viewSmallSkill enemySkills)
        , viewCombatLog combatLog
        , div [ class "skill-buttons" ] (List.indexedMap (\i -> viewSkillButton (useSkill i)) skills)
        ]
