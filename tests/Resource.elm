module Resource exposing (interaction, newResource)

import Content.ResourceType
import Content.Resources
import Engine.Resource
import Engine.Skill
import Expect
import Fuzz exposing (int)
import Test exposing (Test, describe, fuzz, fuzz2, test)


newResource : Test
newResource =
    describe "New resource tests"
        [ test "new resource, condition should be 0" <|
            \_ ->
                Content.Resources.rock
                    |> .condition
                    |> Expect.equal
                        0
        , test "new resource, health should be (100, 100)" <|
            \_ ->
                Content.Resources.oakTree
                    |> .health
                    |> Expect.equal
                        ( 100, 100 )
        ]


interaction : Test
interaction =
    describe "Interaction tests"
        [ fuzz int "apply random hit" <|
            \randomInt ->
                Engine.Resource.new Content.ResourceType.OakTree
                    |> Engine.Resource.applySkillEffect (Engine.Skill.Hit randomInt)
                    |> .health
                    |> Expect.equal
                        (if randomInt >= 100 then
                            ( 0, 100 )

                         else if randomInt <= 0 then
                            ( 100, 100 )

                         else
                            ( 100 - randomInt, 100 )
                        )
        , fuzz2 int int "Apply list of hit skill effects with random power, check health" <|
            \randomInt randomInt2 ->
                Engine.Resource.new Content.ResourceType.OakTree
                    |> Engine.Resource.applySkillEffects [ Engine.Skill.Hit randomInt, Engine.Skill.Hit randomInt2 ]
                    |> .health
                    |> Expect.equal
                        (if max 0 randomInt + max 0 randomInt2 >= 100 then
                            ( 0, 100 )

                         else if max 0 randomInt + max 0 randomInt2 < 0 then
                            ( 100, 100 )

                         else
                            ( 100 - (max 0 randomInt + max 0 randomInt2), 100 )
                        )
        , fuzz2 int int "Apply list of hit skill effects with random power, check alive predicate" <|
            \randomInt randomInt2 ->
                Engine.Resource.new Content.ResourceType.OakTree
                    |> Engine.Resource.applySkillEffects [ Engine.Skill.Hit randomInt, Engine.Skill.Hit randomInt2 ]
                    |> Engine.Resource.isAlive
                    |> Expect.equal
                        (max 0 randomInt + max 0 randomInt2 < 100)
        ]
