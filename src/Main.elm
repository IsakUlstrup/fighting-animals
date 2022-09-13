module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Content.Animals as Animals
import Engine.Animal as Animal exposing (Animal)
import Engine.Resource as Resource exposing (Resource)
import Engine.Skill as Skill exposing (SkillEffect)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import View.ElmHtml
import View.Modal exposing (Modal)
import View.Svg



-- MODEL


type alias Model =
    { playerAnimal : Animal
    , resource : Resource
    , combatLog : List ( Bool, SkillEffect )
    , modal : Modal Msg
    , pageUrl : String
    }


init : String -> ( Model, Cmd msg )
init pageUrl =
    ( Model
        Animals.playerPanda
        Resource.new
        []
        View.Modal.new
        pageUrl
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Int
    | Restart
    | UseSkill Int
    | ShowQrModal
    | HideModal


gameOverCheck : Model -> Model
gameOverCheck model =
    if Resource.isAlive model.resource |> not then
        -- player win
        { model
            | modal =
                model.modal
                    |> View.Modal.show "Game over" (gameOverModal True)
        }

    else
        model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            let
                ( player, effects ) =
                    model.playerAnimal |> Animal.tickSkills dt
            in
            ( { model
                | playerAnimal = player
                , resource = model.resource |> Resource.applySkillEffects effects
                , combatLog = List.map (\e -> ( True, e )) effects ++ model.combatLog |> List.take 50
              }
                |> gameOverCheck
            , Cmd.none
            )

        Restart ->
            init model.pageUrl

        UseSkill index ->
            ( { model | playerAnimal = model.playerAnimal |> Animal.useSkillAtIndex index }, Cmd.none )

        ShowQrModal ->
            ( { model
                | modal =
                    model.modal
                        |> View.Modal.show "Link QR code" (View.Svg.qrCodeView model.pageUrl)
              }
            , Cmd.none
            )

        HideModal ->
            ( { model | modal = View.Modal.hide model.modal }, Cmd.none )



-- VIEW


gameOverModal : Bool -> Html Msg
gameOverModal win =
    let
        modalBody : String
        modalBody =
            if win then
                "You won!"

            else
                "You lost :("
    in
    Html.p []
        [ Html.text modalBody
        , Html.br [] []
        , Html.button [ Html.Events.onClick Restart ] [ Html.text "Restart" ]
        ]


view : Model -> Document Msg
view model =
    { title = "Fighting Animals"
    , body =
        [ View.Modal.viewModal HideModal model.modal
        , Html.main_ [ Html.Attributes.id "app" ]
            [ View.ElmHtml.viewStatusBar ShowQrModal
            , View.ElmHtml.viewResource model.resource
            , View.ElmHtml.viewAnimal model.playerAnimal UseSkill
            ]
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if List.all Skill.isReady model.playerAnimal.skills then
        Sub.none

    else
        Browser.Events.onAnimationFrameDelta (round >> Tick)



-- MAIN


main : Program String Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
