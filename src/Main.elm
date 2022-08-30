module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Engine.Skill as Skill exposing (Skill)
import Html exposing (Html, h3, text)
import Html.Attributes
import Html.Events



-- MODEL


type alias Model =
    Skill


init : () -> ( Model, Cmd msg )
init _ =
    ( Skill.new "Attack" "Example skill" 1000 |> Skill.cooldown 100, Cmd.none )



-- UPDATE


type Msg
    = Tick Float
    | UseSkill


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            ( model |> Skill.cooldown (round dt), Cmd.none )

        UseSkill ->
            ( model |> Skill.use, Cmd.none )



-- VIEW


viewSkill : Skill -> Html Msg
viewSkill skill =
    Html.div []
        [ Html.h5 [] [ text skill.name ]
        , Html.p [] [ text skill.description ]
        , Html.meter
            [ Html.Attributes.max (Tuple.second skill.cooldownTime |> String.fromInt)
            , Html.Attributes.value (Skill.currentCooldown skill |> String.fromInt)
            ]
            []
        , Html.br [] []
        , Html.button
            [ Html.Events.onClick UseSkill
            , Html.Attributes.disabled (Skill.isReady skill |> not)
            ]
            [ text "Use Skill" ]
        ]


view : Model -> Document Msg
view model =
    { title = "Fighting Animals"
    , body =
        [ h3 [] [ text "Fighting animals" ]
        , viewSkill model
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if Skill.isReady model then
        Sub.none

    else
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
