module Skill exposing (newSkillTests, skillInteractionTests)

import Engine.Skill
import Expect
import Fuzz exposing (int, string)
import Test exposing (Test, describe, fuzz, fuzz2)


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
                    |> .cooldownTime
                    |> Expect.equal
                        (if randomInt < 0 then
                            ( 0, 0 )

                         else
                            ( 0, randomInt )
                        )
        ]


skillInteractionTests : Test
skillInteractionTests =
    describe "Skill interaction"
        [ fuzz int "Reduce cooldown on skill by random amount" <|
            \randomInt ->
                Engine.Skill.new "Name" "Description" 1000
                    |> Engine.Skill.cooldown randomInt
                    |> Engine.Skill.currentCooldown
                    |> Expect.equal
                        (if randomInt < 0 then
                            0

                         else if randomInt > 1000 then
                            1000

                         else
                            randomInt
                        )
        , fuzz2 int int "Reduce cooldown on skill by random amount twice" <|
            \randomInt1 randomInt2 ->
                Engine.Skill.new "Name" "Description" 1000
                    |> Engine.Skill.cooldown randomInt1
                    |> Engine.Skill.cooldown randomInt2
                    |> Engine.Skill.currentCooldown
                    |> Expect.equal
                        (if clamp 0 1000 randomInt1 + clamp 0 1000 randomInt2 < 0 then
                            0

                         else if clamp 0 1000 randomInt1 + clamp 0 1000 randomInt2 > 1000 then
                            1000

                         else
                            clamp 0 1000 randomInt1 + clamp 0 1000 randomInt2
                        )
        , fuzz int "Is skill ready (off cooldown)?" <|
            \randomInt ->
                Engine.Skill.new "Name" "Description" 1000
                    |> Engine.Skill.cooldown randomInt
                    |> Engine.Skill.isReady
                    |> Expect.equal
                        (randomInt >= 1000)
        , fuzz int "Cooldown skill by random amount, then attempt to use it" <|
            \randomInt ->
                Engine.Skill.new "Name" "Description" 1000
                    |> Engine.Skill.cooldown randomInt
                    |> Engine.Skill.use
                    |> Engine.Skill.currentCooldown
                    |> Expect.equal
                        (if randomInt >= 1000 then
                            0

                         else
                            clamp 0 1000 randomInt
                        )
        ]
