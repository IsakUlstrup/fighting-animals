module View.ElmHtml exposing (viewAnimal, viewCombatLog, viewSmallSkills, viewStatusBar)

import Engine.Animal exposing (Animal)
import Engine.Skill as Skill exposing (Skill, SkillEffect)
import Html exposing (Attribute, Html, button, div, h5, li, p, text, ul)
import Html.Attributes exposing (class)
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


viewSkillEffect : ( Bool, SkillEffect ) -> Html msg
viewSkillEffect ( player, effect ) =
    li
        [ class <|
            if player then
                "player-effect"

            else
                "enemy-effect"
        ]
        [ text <| Skill.effectToString effect ]


viewCombatLog : List ( Bool, SkillEffect ) -> Html msg
viewCombatLog combatLog =
    ul [ class "combat-log" ] (List.map viewSkillEffect combatLog)


viewStatusBar : msg -> Html msg
viewStatusBar showQrMsg =
    div [ class "status-bar" ]
        [ button [] [ text "<" ]
        , h5 [] [ text "Area name" ]
        , Html.button [ Html.Events.onClick showQrMsg ] [ Html.text "share" ]
        ]


viewSmallSkills : List Skill -> Html msg
viewSmallSkills skills =
    div [ class "skill-buttons small enemy" ] (List.map viewSmallSkill skills)


viewSkills : List Skill -> (Int -> msg) -> Html msg
viewSkills skills useSkill =
    div [ class "skill-buttons" ] (List.indexedMap (\i -> viewSkillButton (useSkill i)) skills)


viewAnimal : Animal -> (Int -> msg) -> Html msg
viewAnimal animal useSkillMsg =
    div [ class "animal" ]
        [ div [ class "status" ]
            [ View.Svg.viewSpinner 100 (View.Svg.char '🐼')
            , h5 [] [ text animal.name ]
            ]
        , viewSkills animal.skills useSkillMsg
        ]
