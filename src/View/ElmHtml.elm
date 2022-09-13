module View.ElmHtml exposing (viewAnimal, viewResource, viewStatusBar)

import Content.ResourceType exposing (ResourceType)
import Engine.Animal exposing (Animal)
import Engine.Resource exposing (Resource)
import Engine.Skill as Skill exposing (Skill)
import Html exposing (Attribute, Html, button, div, h1, h2, meter, p, strong, text)
import Html.Attributes exposing (class)
import Html.Events


skillEffectClass : Skill -> Attribute msg
skillEffectClass skill =
    class <|
        case skill.state of
            Skill.Active _ ->
                "active"

            Skill.Ready ->
                "ready"


skillStateClass : Skill -> Attribute msg
skillStateClass skill =
    class <|
        case skill.effect of
            Skill.Hit _ ->
                "hit"

            Skill.Buff _ ->
                "buff"

            Skill.Debuff _ ->
                "debuff"


percentageMeter : String -> Int -> Html msg
percentageMeter title percentage =
    meter
        [ Html.Attributes.max "100"
        , Html.Attributes.value (percentage |> String.fromInt)
        , Html.Attributes.title (title ++ " (" ++ String.fromInt percentage ++ ")")
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
        [ percentageMeter "Skill use time" (Skill.useTimePercentage skill)
        , div
            [ class "skill-meta" ]
            [ strong [] [ text skill.name ]
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


viewStatusBar : Html msg
viewStatusBar =
    div [ class "status-bar" ]
        [ button
            [ Html.Attributes.class "button"
            , Html.Attributes.title "Previous area"
            ]
            [ text "<" ]
        , h1 [] [ text "Area name" ]
        ]


viewSkills : List Skill -> (Int -> msg) -> Html msg
viewSkills skills useSkill =
    div [ class "skill-buttons" ] (List.indexedMap (\i -> viewSkillButton (useSkill i)) skills)


viewResource : Resource ResourceType -> Html msg
viewResource resource =
    div [ class "resource" ]
        [ h2 [] [ text (Content.ResourceType.toString resource.type_) ]
        , percentageMeter "Resource condition" resource.condition
        , percentageMeter "Resource health" (Engine.Resource.healthPercentage resource)
        ]


viewAnimal : Animal -> (Int -> msg) -> Html msg
viewAnimal animal useSkillMsg =
    div [ class "animal" ]
        [ div [ class "status" ]
            [ h2 [] [ text animal.name ]
            , percentageMeter "Player energy" (Engine.Animal.energyPercentage animal)
            ]
        , viewSkills animal.skills useSkillMsg
        ]
