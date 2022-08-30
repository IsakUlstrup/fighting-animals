module Main exposing (Model, main)

import Browser exposing (Document)
import Engine.Animal as Animal exposing (Animal)
import Html exposing (Html, h3, text)



-- MODEL


type alias Model =
    Animal


init : () -> ( Model, Cmd msg )
init _ =
    ( Animal.new "panda", Cmd.none )



-- UPDATE


update : msg -> Model -> ( Model, Cmd msg )
update _ model =
    ( model, Cmd.none )



-- VIEW


viewAnimal : Animal -> Html msg
viewAnimal animal =
    Html.div [] [ text animal.name ]


view : Model -> Document msg
view model =
    { title = "Fighting Animals"
    , body =
        [ h3 [] [ text "Fighting animals" ]
        , viewAnimal model
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none



-- MAIN


main : Program () Model msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
