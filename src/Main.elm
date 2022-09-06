module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Content.Skills as Skills
import Engine.Skill as Skill exposing (Skill, SkillEffect)
import Html
import Html.Attributes
import View.ElmHtml
import View.Modal exposing (Modal)
import View.Svg



-- MODEL


type alias Model =
    { skills : List Skill
    , enemySkills : List Skill
    , combatLog : List ( Bool, SkillEffect )
    , modal : Modal Msg
    , pageUrl : String
    }


init : String -> ( Model, Cmd msg )
init pageUrl =
    ( Model
        [ Skills.debuffSkill
        , Skills.buffSkill
        , Skills.basicSkill
        ]
        [ Skills.enemyBasicSkill
        ]
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
                ( skills, effects ) =
                    model.skills |> Skill.tickList dt

                ( enemySkills, enemyEffects ) =
                    model.enemySkills |> Skill.tickList dt
            in
            ( { model
                | skills = skills
                , enemySkills = enemySkills |> List.map Skill.use
                , combatLog = List.map (\e -> ( True, e )) effects ++ List.map (\e -> ( False, e )) enemyEffects ++ model.combatLog |> List.take 50
              }
            , Cmd.none
            )

        UseSkill index ->
            ( { model | skills = model.skills |> Skill.useAtIndex index }, Cmd.none )

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
            , View.ElmHtml.viewSmallSkills model.enemySkills
            , View.ElmHtml.viewCombatLog model.combatLog
            , View.ElmHtml.viewSkills model.skills UseSkill
            ]
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if List.all Skill.isReady model.skills && List.all Skill.isReady model.enemySkills then
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
