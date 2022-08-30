module Animal exposing (suite)

import Engine.Animal
import Expect
import Fuzz exposing (string)
import Test exposing (Test, describe, fuzz)


suite : Test
suite =
    describe "Animal module"
        [ describe "New animal"
            [ -- fuzz runs the test 100 times with randomly-generated inputs!
              fuzz string "new animal with fuzz name." <|
                \randomlyGeneratedString ->
                    randomlyGeneratedString
                        |> Engine.Animal.new
                        |> Expect.equal { name = randomlyGeneratedString }
            ]
        ]
