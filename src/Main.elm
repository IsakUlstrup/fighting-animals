module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Content.Animals as Animals
import Engine.Animal as Animal exposing (Animal)
import Engine.Skill as Skill exposing (SkillEffect)
import Html
import Html.Attributes
import View.ElmHtml
import View.Modal exposing (Modal)
import View.Svg



-- MODEL


type alias Model =
    { playerAnimal : Animal
    , enemyAnimal : Animal
    , combatLog : List ( Bool, SkillEffect )
    , modal : Modal Msg
    , pageUrl : String
    }


init : String -> ( Model, Cmd msg )
init pageUrl =
    ( Model
        Animals.playerPanda
        Animals.enemySloth
        []
        View.Modal.new
        pageUrl
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Int
    | UseSkill Int
    | ShowQrModal
    | HideModal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            let
                ( player, effects ) =
                    model.playerAnimal |> Animal.tickSkills dt

                ( enemy, enemyEffects ) =
                    model.enemyAnimal |> Animal.tickSkills dt
            in
            ( { model
                | playerAnimal = player
                , enemyAnimal = enemy |> Animal.useAllSkills
                , combatLog = List.map (\e -> ( True, e )) effects ++ List.map (\e -> ( False, e )) enemyEffects ++ model.combatLog |> List.take 50
              }
            , Cmd.none
            )

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


view : Model -> Document Msg
view model =
    { title = "Fighting Animals"
    , body =
        [ View.Modal.viewModal HideModal model.modal
        , Html.main_ [ Html.Attributes.id "app" ]
            [ View.ElmHtml.viewStatusBar ShowQrModal
            , View.ElmHtml.viewSmallSkills model.enemyAnimal.skills
            , View.ElmHtml.viewCombatLog model.combatLog
            , View.ElmHtml.viewAnimal model.playerAnimal UseSkill
            ]
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if List.all Skill.isReady model.playerAnimal.skills && List.all Skill.isReady model.enemyAnimal.skills then
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
