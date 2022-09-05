module Skill exposing (newSkillTests, skillInteractionTests, skillViewtests)

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
                Engine.Skill.newHit radnomString "Description" 1000 0
                    |> .name
                    |> Expect.equal
                        radnomString
        , fuzz string "new skill with random description " <|
            \randomString ->
                Engine.Skill.newHit "Name" randomString 1000 2
                    |> .description
                    |> Expect.equal
                        randomString
        , fuzz int "new skill with random cooldown, should be (0, > 0)" <|
            \randomInt ->
                Engine.Skill.newHit "Name" "Description" randomInt 45
                    |> .state
                    |> Expect.equal
                        (if randomInt < 0 then
                            Engine.Skill.Cooling ( 0, 0 )

                         else
                            Engine.Skill.Cooling ( 0, randomInt )
                        )
        , fuzz int "new hit skill with random power, negative numbers should be clamped" <|
            \randomInt ->
                Engine.Skill.newHit "Name" "Description" 3050 randomInt
                    |> .effect
                    |> Expect.equal
                        (if randomInt < 0 then
                            Engine.Skill.Hit 0

                         else
                            Engine.Skill.Hit randomInt
                        )
        , test "new skill, state should be cooling" <|
            \_ ->
                Engine.Skill.newHit "Name" "Description" 1000 15
                    |> .state
                    |> Expect.equal
                        (Engine.Skill.Cooling ( 0, 1000 ))
        , test "new hit skill" <|
            \_ ->
                Engine.Skill.newHit "Name" "Description" 2000 10
                    |> .effect
                    |> Expect.equal
                        (Engine.Skill.Hit 10)
        ]


skillInteractionTests : Test
skillInteractionTests =
    describe "Skill interaction"
        [ fuzz int "Tick skill by random delta time, verify skill state" <|
            \randomInt ->
                Engine.Skill.newBuff "Name" "Description" 1000 25
                    |> Engine.Skill.tick randomInt
                    |> Tuple.first
                    |> .state
                    |> Expect.equal
                        (if randomInt < 0 then
                            Engine.Skill.Cooling ( 0, 1000 )

                         else if randomInt > 1000 then
                            Engine.Skill.Ready

                         else
                            Engine.Skill.Cooling ( randomInt, 1000 )
                        )
        , fuzz int "Tick active skill by random delta time, verify skill effect" <|
            \randomInt ->
                Engine.Skill.newBuff "Name" "Description" 1000 25
                    |> Engine.Skill.tick 1000
                    |> Tuple.first
                    |> Engine.Skill.use
                    |> Engine.Skill.tick randomInt
                    |> Tuple.second
                    |> Expect.equal
                        (if randomInt > 400 then
                            Just <| Engine.Skill.Buff 25

                         else
                            Nothing
                        )
        , fuzz2 int int "Tick skill by random delta time twice" <|
            \randomInt1 randomInt2 ->
                Engine.Skill.newDebuff "Name" "Description" 1000 3
                    |> Engine.Skill.tick randomInt1
                    |> Tuple.first
                    |> Engine.Skill.tick randomInt2
                    |> Tuple.first
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
                Engine.Skill.newHit "Name" "Description" 1000 200
                    |> Engine.Skill.tick 500
                    |> Tuple.first
                    |> Engine.Skill.cooldownPercentage
                    |> Expect.equal
                        50
        , fuzz int "Is skill ready?" <|
            \randomInt ->
                Engine.Skill.newDebuff "Name" "Description" 1000 32
                    |> Engine.Skill.tick randomInt
                    |> Tuple.first
                    |> Engine.Skill.isReady
                    |> Expect.equal
                        (randomInt >= 1000)
        , fuzz int "Tick skill by random delta time, then attempt to use it. Check is state is correct" <|
            \randomInt ->
                Engine.Skill.newHit "Name" "Description" 1000 12
                    |> Engine.Skill.tick randomInt
                    |> Tuple.first
                    |> Engine.Skill.use
                    |> .state
                    |> Expect.equal
                        (if randomInt >= 1000 then
                            Engine.Skill.Active ( 0, 500 )

                         else
                            Engine.Skill.Cooling ( clamp 0 1000 randomInt, 1000 )
                        )
        ]


skillViewtests : Test
skillViewtests =
    describe "View helpers"
        [ fuzz2 int int "Tick skill by random delta time, then get cooldown progress" <|
            \randomInt int2 ->
                Engine.Skill.newBuff "Name" "Description" int2 53
                    |> Engine.Skill.tick randomInt
                    |> Tuple.first
                    |> Engine.Skill.cooldownPercentage
                    |> Expect.equal
                        (if randomInt >= max 0 int2 then
                            100

                         else
                            intPercentage randomInt int2
                        )
        , test "Skill effect to string" <|
            \_ ->
                Engine.Skill.newBuff "Name" "Description" 500 53
                    |> .effect
                    |> Engine.Skill.effectToString
                    |> Expect.equal
                        "Buff 53"
        ]
