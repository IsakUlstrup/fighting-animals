module Skill exposing (newSkillTests, skillInteractionTests)

import Engine.Skill
import Expect
import Fuzz exposing (int, string)
import Test exposing (Test, describe, fuzz, fuzz2, test)



---- HELPERS ----


intPercentage : Int -> Int -> Int
intPercentage i1 i2 =
    if max 0 i2 == 0 then
        100

    else
        ((max 0 i1 |> toFloat) / toFloat i2) * 100 |> round



---- TESTS ----


newSkillTests : Test
newSkillTests =
    describe "New skill"
        [ fuzz string "new skill with random name " <|
            \radnomString ->
                Engine.Skill.new radnomString "Description" 1000
                    |> .name
                    |> Expect.equal
                        radnomString
        , fuzz string "new skill with random description " <|
            \randomString ->
                Engine.Skill.new "Name" randomString 1000
                    |> .description
                    |> Expect.equal
                        randomString
        , fuzz int "new skill with random cooldown, should be (0, > 0)" <|
            \randomInt ->
                Engine.Skill.new "Name" "Description" randomInt
                    |> .state
                    |> Expect.equal
                        (if randomInt < 0 then
                            Engine.Skill.Cooling ( 0, 0 )

                         else
                            Engine.Skill.Cooling ( 0, randomInt )
                        )
        , test "new skill, state should be cooling" <|
            \_ ->
                Engine.Skill.new "Name" "Description" 1000
                    |> .state
                    |> Expect.equal
                        (Engine.Skill.Cooling ( 0, 1000 ))
        ]


skillInteractionTests : Test
skillInteractionTests =
    describe "Skill interaction"
        [ fuzz int "Tick skill by random delta time" <|
            \randomInt ->
                Engine.Skill.new "Name" "Description" 1000
                    |> Engine.Skill.tick randomInt
                    |> .state
                    |> Expect.equal
                        (if randomInt < 0 then
                            Engine.Skill.Cooling ( 0, 1000 )

                         else if randomInt > 1000 then
                            Engine.Skill.Ready

                         else
                            Engine.Skill.Cooling ( randomInt, 1000 )
                        )
        , fuzz2 int int "Tick skill by random delta time twice" <|
            \randomInt1 randomInt2 ->
                Engine.Skill.new "Name" "Description" 1000
                    |> Engine.Skill.tick randomInt1
                    |> Engine.Skill.tick randomInt2
                    |> .state
                    |> Expect.equal
                        (if clamp 0 1000 randomInt1 + clamp 0 1000 randomInt2 < 0 then
                            Engine.Skill.Cooling ( 0, 1000 )

                         else if clamp 0 1000 randomInt1 + clamp 0 1000 randomInt2 >= 1000 then
                            Engine.Skill.Ready

                         else
                            Engine.Skill.Cooling ( clamp 0 1000 randomInt1 + clamp 0 1000 randomInt2, 1000 )
                        )
        , test "Tick skill by half of cd time, then get cooldown progress, should be 50" <|
            \_ ->
                Engine.Skill.new "Name" "Description" 1000
                    |> Engine.Skill.tick 500
                    |> Engine.Skill.cooldownPercentage
                    |> Expect.equal
                        50
        , fuzz2 int int "Tick skill by random delta time, then get cooldown progress" <|
            \randomInt int2 ->
                Engine.Skill.new "Name" "Description" int2
                    |> Engine.Skill.tick randomInt
                    |> Engine.Skill.cooldownPercentage
                    |> Expect.equal
                        (if randomInt >= max 0 int2 then
                            100

                         else
                            intPercentage randomInt int2
                        )
        , fuzz int "Is skill ready?" <|
            \randomInt ->
                Engine.Skill.new "Name" "Description" 1000
                    |> Engine.Skill.tick randomInt
                    |> Engine.Skill.isReady
                    |> Expect.equal
                        (randomInt >= 1000)
        , fuzz int "Tick skill by random delta time, then attempt to use it" <|
            \randomInt ->
                Engine.Skill.new "Name" "Description" 1000
                    |> Engine.Skill.tick randomInt
                    |> Engine.Skill.use
                    |> .state
                    |> Expect.equal
                        (if randomInt >= 1000 then
                            Engine.Skill.Active ( 0, 200 )

                         else
                            Engine.Skill.Cooling ( clamp 0 1000 randomInt, 1000 )
                        )
        ]
