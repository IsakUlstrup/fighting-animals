module Skill exposing (suite)

import Engine.Skill
import Expect
import Fuzz exposing (string)
import Test exposing (Test, describe, fuzz)


suite : Test
suite =
    describe "Skill module"
        [ describe "New skill"
            [ fuzz string "new skill with fuzz name." <|
                \randomName ->
                    randomName
                        |> Engine.Skill.new
                        |> Expect.equal { name = randomName }
            ]
        ]
