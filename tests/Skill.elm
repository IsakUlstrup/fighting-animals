module Skill exposing (suite)

import Engine.Skill
import Expect
import Fuzz exposing (int, string)
import Test exposing (Test, describe, fuzz)


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
            , fuzz int "new skill with fuzz cooldown, should be (0, > 0)" <|
                \randomInt ->
                    Engine.Skill.new "Name" "Description" randomInt
                        |> .cooldown
                        |> Expect.equal
                            (if randomInt < 0 then
                                ( 0, 0 )

                             else
                                ( 0, randomInt )
                            )
            ]
        ]
