module Main exposing (Model, main)

import Browser exposing (Document)
import Browser.Events
import Engine.Skill as Skill exposing (Skill)
import Html exposing (Html, h3, text)
import Html.Attributes



-- MODEL


type alias Model =
    Skill


init : () -> ( Model, Cmd msg )
init _ =
    ( Skill.new "Attack" "Example skill" 1000 |> Skill.cooldown 100, Cmd.none )



-- UPDATE


type Msg
    = Tick Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            ( model |> Skill.cooldown (round dt), Cmd.none )



-- VIEW


viewSkill : Skill -> Html msg
viewSkill skill =
    Html.div []
        [ Html.h5 [] [ text skill.name ]
        , Html.p [] [ text skill.description ]
        , Html.meter
            [ Html.Attributes.max (Tuple.second skill.cooldownTime |> String.fromInt)
            , Html.Attributes.value (Tuple.first skill.cooldownTime |> String.fromInt)
            ]
            []
        ]


view : Model -> Document msg
view model =
    { title = "Fighting Animals"
    , body =
        [ h3 [] [ text "Fighting animals" ]
        , viewSkill model
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onAnimationFrameDelta Tick



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
