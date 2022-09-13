module Resource exposing (interaction, newResource)

import Engine.Resource
import Engine.Skill
import Expect
import Fuzz exposing (int)
import Test exposing (Test, describe, fuzz, test)


newResource : Test
newResource =
    describe "New resource tests"
        [ test "new resource, condition should be 0" <|
            \_ ->
                Engine.Resource.new
                    |> .condition
                    |> Expect.equal
                        0
        , test "new resource, health should be (100, 100)" <|
            \_ ->
                Engine.Resource.new
                    |> .health
                    |> Expect.equal
                        ( 100, 100 )
        ]


interaction : Test
interaction =
    describe "Interaction tests"
        [ fuzz int "apply random hit" <|
            \randomInt ->
                Engine.Resource.new
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
        ]
