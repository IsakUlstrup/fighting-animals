module Skill exposing (suite)

import Engine.Skill
import Expect
import Fuzz exposing (string)
import Test exposing (Test, describe, fuzz2)


suite : Test
suite =
    describe "Skill module"
        [ describe "New skill"
            [ fuzz2 string string "new skill with fuzz name and description" <|
                \randomName randomDescription ->
                    Engine.Skill.new randomName randomDescription
                        |> Expect.equal
                            { name = randomName
                            , description = randomDescription
                            }
            ]
        ]
