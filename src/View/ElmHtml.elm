module View.ElmHtml exposing (viewAnimal, viewResource, viewStatusBar)

import Content.ResourceType exposing (ResourceType)
import Engine.Animal exposing (Animal)
import Engine.Resource exposing (Resource)
import Engine.Skill as Skill exposing (Skill)
import Html exposing (Attribute, Html, button, div, h5, meter, p, text)
import Html.Attributes exposing (class)
import Html.Events


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



-- viewSmallSkill : Skill -> Html msg
-- viewSmallSkill skill =
--     div
--         [ class "small-skill"
--         , skillStateClass skill
--         , skillEffectClass skill
--         ]
--         []


percentageMeter : Int -> Html msg
percentageMeter percentage =
    meter
        [ Html.Attributes.max "100"
        , Html.Attributes.value (percentage |> String.fromInt)
        ]
        []


viewSkillButton : msg -> Skill -> Html msg
viewSkillButton clickMsg skill =
    Html.button
        [ Html.Events.onClick clickMsg
        , class "skill-button"
        , skillStateClass skill
        , skillEffectClass skill
        ]
        [ percentageMeter (Skill.cooldownPercentage skill)
        , div
            [ class "skill-meta" ]
            [ h5 [] [ text skill.name ]
            , p [] [ text skill.description ]
            ]
        ]



-- viewSkillEffect : ( Bool, SkillEffect ) -> Html msg
-- viewSkillEffect ( player, effect ) =
--     li
--         [ class <|
--             if player then
--                 "player-effect"
--             else
--                 "enemy-effect"
--         ]
--         [ text <| Skill.effectToString effect ]
-- viewCombatLog : List ( Bool, SkillEffect ) -> Html msg
-- viewCombatLog combatLog =
--     ul [ class "combat-log" ] (List.map viewSkillEffect combatLog)


viewStatusBar : msg -> Html msg
viewStatusBar showQrMsg =
    div [ class "status-bar" ]
        [ button [ Html.Attributes.class "button" ] [ text "<" ]
        , h5 [] [ text "Area name" ]
        , Html.button [ Html.Events.onClick showQrMsg, Html.Attributes.class "button" ] [ Html.text "share" ]
        ]



-- viewSmallSkills : List Skill -> Html msg
-- viewSmallSkills skills =
--     div [ class "skill-buttons small enemy" ] (List.map viewSmallSkill skills)


viewSkills : List Skill -> (Int -> msg) -> Html msg
viewSkills skills useSkill =
    div [ class "skill-buttons" ] (List.indexedMap (\i -> viewSkillButton (useSkill i)) skills)



-- viewOpposingAnimal : Animal -> Html msg
-- viewOpposingAnimal animal =
--     div [ class "animal opposing" ]
--         [ viewSmallSkills animal.skills
--         , View.Svg.viewSpinner (Engine.Animal.healthPercentage animal) (View.Svg.char '🌲')
--         ]


viewResource : Resource ResourceType -> Html msg
viewResource resource =
    div []
        [ text (Content.ResourceType.toString resource.type_)
        , percentageMeter resource.condition
        , percentageMeter (Engine.Resource.healthPercentage resource)
        ]


viewAnimal : Animal -> (Int -> msg) -> Html msg
viewAnimal animal useSkillMsg =
    div [ class "animal" ]
        [ div [ class "status" ]
            [ h5 [] [ text animal.name ]
            , meter
                [ Html.Attributes.max (Tuple.second animal.health |> String.fromInt)
                , Html.Attributes.value (Tuple.first animal.health |> String.fromInt)
                ]
                []
            ]
        , viewSkills animal.skills useSkillMsg
        ]
