module Skill exposing (suite)

import Engine.Skill
import Expect
import Fuzz exposing (int, string)
import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "Skill module"
        [ describe "New skill"
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
        , describe "Skill interaction"
            [ fuzz int "Reduce cooldown on skill by random amount" <|
                \randomInt ->
                    Engine.Skill.new "Name" "Description" 1000
                        |> Engine.Skill.cooldown randomInt
                        |> .cooldownTime
                        |> Expect.equal
                            (if randomInt < 0 then
                                ( 0, 1000 )

                             else if randomInt > 1000 then
                                ( 1000, 1000 )

                             else
                                ( randomInt, 1000 )
                            )
            ]
        ]
