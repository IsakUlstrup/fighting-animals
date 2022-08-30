module Skill exposing (suite)

import Engine.Skill
import Expect
import Fuzz exposing (int, string)
import Test exposing (Test, describe, fuzz, fuzz2)


suite : Test
suite =
    describe "Skill module"
        [ describe "New skill"
            [ fuzz2 string string "new skill with fuzz name and description" <|
                \randomName randomDescription ->
                    Engine.Skill.new randomName randomDescription 1000
                        |> Expect.equal
                            { name = randomName
                            , description = randomDescription
                            , cooldown = ( 0, 1000 )
                            }
            , fuzz int "new skill with fuzz cooldown" <|
                \randomCooldown ->
                    Engine.Skill.new "Name" "Description" randomCooldown
                        |> Expect.equal
                            { name = "Name"
                            , description = "Description"
                            , cooldown = ( 0, randomCooldown )
                            }
            ]
        ]
