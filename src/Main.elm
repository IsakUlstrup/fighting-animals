module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Engine.Animal as Animal exposing (Animal)
import Html exposing (Html, h3, text)



-- MODEL


type alias Model =
    Animal


init : () -> ( Model, Cmd Msg )
init _ =
    ( Animal.new "panda", Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


viewAnimal : Animal -> Html msg
viewAnimal animal =
    Html.div [] [ text animal.name ]


view : Model -> Document Msg
view model =
    { title = "Fighting Animals"
    , body =
        [ h3 [] [ text "Fighting animals" ]
        , viewAnimal model
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
