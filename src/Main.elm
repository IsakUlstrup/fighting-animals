module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Content.Skills as Skills
import Engine.Skill as Skill exposing (Skill, SkillEffect)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import QRCode
import Svg.Attributes as SvgA
import View.ElmHtml
import View.Modal exposing (Modal)



-- MODEL


type alias Model =
    { skills : List Skill
    , combatLog : List SkillEffect
    , modal : Modal Msg
    , pageUrl : String
    }


init : String -> ( Model, Cmd msg )
init pageUrl =
    ( Model
        [ Skills.debuffSkill
        , Skills.slowSkill
        , Skills.buffSkill
        , Skills.basicSkill
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
    | ShowCombatLog
    | HideModal


useSkill : Int -> List Skill -> ( List Skill, List SkillEffect )
useSkill index skills =
    let
        useAtIndex : Int -> (Skill -> ( Skill, Maybe SkillEffect )) -> Int -> Skill -> ( Skill, Maybe SkillEffect )
        useAtIndex target f i skill =
            if i == target then
                f skill

            else
                ( skill, Nothing )
    in
    List.indexedMap (useAtIndex index Skill.use) skills
        |> List.unzip
        |> Tuple.mapSecond (List.filterMap identity)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            ( { model | skills = model.skills |> List.map (Skill.tick dt) }, Cmd.none )

        UseSkill index ->
            let
                ( skills, effects ) =
                    model.skills |> useSkill index
            in
            ( { model | skills = skills, combatLog = effects ++ model.combatLog |> List.take 50 }, Cmd.none )

        ShowQrModal ->
            ( { model
                | modal =
                    model.modal
                        |> View.Modal.show "Link QR code" (qrCodeView model.pageUrl)
              }
            , Cmd.none
            )

        ShowCombatLog ->
            ( { model
                | modal =
                    model.modal
                        |> View.Modal.show "Combat Log" (View.ElmHtml.viewCombatLog model.combatLog)
              }
            , Cmd.none
            )

        HideModal ->
            ( { model | modal = View.Modal.hide model.modal }, Cmd.none )



-- VIEW


qrCodeView : String -> Html msg
qrCodeView message =
    QRCode.fromString message
        |> Result.map
            (QRCode.toSvg
                [ SvgA.width "300px"
                , SvgA.height "300px"
                , SvgA.shapeRendering "crispEdges"
                ]
            )
        |> Result.withDefault (Html.text "Error while encoding to QRCode.")


viewDebugBar : Html Msg
viewDebugBar =
    Html.div [ Html.Attributes.class "debug-bar" ]
        [ Html.button [ Html.Events.onClick ShowQrModal ] [ Html.text "share" ]
        , Html.button [ Html.Events.onClick ShowCombatLog ] [ Html.text "log" ]
        ]


view : Model -> Document Msg
view model =
    { title = "Fighting Animals"
    , body =
        [ View.Modal.viewModal HideModal model.modal
        , viewDebugBar
        , View.ElmHtml.view { skills = model.skills, skillEffects = model.combatLog } UseSkill
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if List.all Skill.isReady model.skills then
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
