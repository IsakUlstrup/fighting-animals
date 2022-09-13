module Resource exposing (newResource)

import Engine.Resource
import Expect
import Test exposing (Test, describe, test)


newResource : Test
newResource =
    describe "New resource tests"
        [ test "new resource, condition should be 0" <|
            \_ ->
                Engine.Resource.new
                    |> .condition
                    |> Expect.equal
                        0
        , test "new resource, health should be (100, 100)" <|
            \_ ->
                Engine.Resource.new
                    |> .health
                    |> Expect.equal
                        ( 100, 100 )
        ]
