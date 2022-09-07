module Skill exposing (newSkillTests, skillInteractionTests, skillListTests, skillViewtests)

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
                Engine.Skill.initHit 100
                    |> Engine.Skill.withName radnomString
                    |> .name
                    |> Expect.equal
                        radnomString
        , fuzz string "new skill with random description " <|
            \randomString ->
                Engine.Skill.initHit 100
                    |> Engine.Skill.withDescription randomString
                    |> .description
                    |> Expect.equal
                        randomString
        , fuzz int "new skill with random cooldown, should be (0, > 0)" <|
            \randomInt ->
                Engine.Skill.initBuff 10
                    |> Engine.Skill.withCooldown randomInt
                    |> .state
                    |> Expect.equal
                        (if randomInt < 0 then
                            Engine.Skill.Cooling ( 0, 0 )

                         else
                            Engine.Skill.Cooling ( 0, randomInt )
                        )
        , fuzz int "new hit skill with random power, negative numbers should be clamped" <|
            \randomInt ->
                Engine.Skill.initHit randomInt
                    |> .effect
                    |> Expect.equal
                        (if randomInt < 0 then
                            Engine.Skill.Hit 0

                         else
                            Engine.Skill.Hit randomInt
                        )
        , test "new skill, state should be cooling" <|
            \_ ->
                Engine.Skill.initDebuff 20
                    |> Engine.Skill.withCooldown 1000
                    |> .state
                    |> Expect.equal
                        (Engine.Skill.Cooling ( 0, 1000 ))
        , test "new hit skill, check for correct effect" <|
            \_ ->
                Engine.Skill.initHit 20
                    |> .effect
                    |> Expect.equal
                        (Engine.Skill.Hit 20)
        , test "new buff skill, check for correct effect" <|
            \_ ->
                Engine.Skill.initBuff 20
                    |> .effect
                    |> Expect.equal
                        (Engine.Skill.Buff 20)
        , test "new debuff skill, check for correct effect" <|
            \_ ->
                Engine.Skill.initDebuff 20
                    |> .effect
                    |> Expect.equal
                        (Engine.Skill.Debuff 20)
        ]


skillInteractionTests : Test
skillInteractionTests =
    describe "Skill interaction"
        [ fuzz int "Tick skill by random delta time, verify skill state" <|
            \randomInt ->
                Engine.Skill.initBuff 20
                    |> Engine.Skill.withCooldown 1000
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
                Engine.Skill.initBuff 25
                    |> Engine.Skill.tick 2000
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
                Engine.Skill.initDebuff 3
                    |> Engine.Skill.withCooldown 1000
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
        , fuzz int "Is skill ready?" <|
            \randomInt ->
                Engine.Skill.initDebuff 32
                    |> Engine.Skill.tick randomInt
                    |> Tuple.first
                    |> Engine.Skill.isReady
                    |> Expect.equal
                        (randomInt >= 2000)
        , fuzz int "Tick skill by random delta time, then attempt to use it. Check is state is correct" <|
            \randomInt ->
                Engine.Skill.initHit 12
                    |> Engine.Skill.withUseTime 2000
                    |> Engine.Skill.tick randomInt
                    |> Tuple.first
                    |> Engine.Skill.use
                    |> .state
                    |> Expect.equal
                        (if randomInt >= 2000 then
                            Engine.Skill.Active ( 0, 2000 )

                         else
                            Engine.Skill.Cooling ( clamp 0 2000 randomInt, 2000 )
                        )
        ]


skillViewtests : Test
skillViewtests =
    describe "View helpers"
        [ fuzz2 int int "Tick skill with random cooldown time by random delta time, then get cooldown progress" <|
            \randomInt randomInt2 ->
                Engine.Skill.initBuff 50
                    |> Engine.Skill.withCooldown randomInt2
                    |> Engine.Skill.tick randomInt
                    |> Tuple.first
                    |> Engine.Skill.cooldownPercentage
                    |> Expect.equal
                        (if randomInt >= max 0 randomInt2 then
                            100

                         else
                            intPercentage randomInt randomInt2
                        )
        , test "Skill effect to string" <|
            \_ ->
                Engine.Skill.initBuff 53
                    |> .effect
                    |> Engine.Skill.effectToString
                    |> Expect.equal
                        "Buff 53"
        , test "Tick skill by half of cd time, then get cooldown progress, should be 50" <|
            \_ ->
                Engine.Skill.initHit 50
                    |> Engine.Skill.tick 1000
                    |> Tuple.first
                    |> Engine.Skill.cooldownPercentage
                    |> Expect.equal
                        50
        ]


skillListTests : Test
skillListTests =
    describe "Skill lists"
        [ test "Use skill at index 1 in a list of ready skills" <|
            \_ ->
                [ Engine.Skill.initHit 25
                , Engine.Skill.initBuff 10 |> Engine.Skill.withUseTime 500
                , Engine.Skill.initDebuff 5
                ]
                    |> Engine.Skill.tickList 2000
                    |> Tuple.first
                    |> Engine.Skill.useAtIndex 1
                    |> List.map .state
                    |> Expect.equal
                        [ Engine.Skill.Ready
                        , Engine.Skill.Active ( 0, 500 )
                        , Engine.Skill.Ready
                        ]
        , test "Use skill at index 5 (out of bounds) in a list of ready skills, should return unchanged list" <|
            \_ ->
                [ Engine.Skill.initHit 20
                , Engine.Skill.initBuff 10
                , Engine.Skill.initDebuff 45
                ]
                    |> Engine.Skill.tickList 2000
                    |> Tuple.first
                    |> Engine.Skill.useAtIndex 5
                    |> List.map .state
                    |> Expect.equal
                        [ Engine.Skill.Ready
                        , Engine.Skill.Ready
                        , Engine.Skill.Ready
                        ]
        , test "Tick a list of active skills, check returned skill effects" <|
            \_ ->
                [ Engine.Skill.initHit 20
                , Engine.Skill.initBuff 10
                ]
                    |> Engine.Skill.tickList 2000
                    |> Tuple.first
                    |> Engine.Skill.useAtIndex 0
                    |> Engine.Skill.useAtIndex 1
                    |> Engine.Skill.tickList 500
                    |> Tuple.second
                    |> Expect.equal
                        [ Engine.Skill.Hit 20
                        , Engine.Skill.Buff 10
                        ]
        ]
