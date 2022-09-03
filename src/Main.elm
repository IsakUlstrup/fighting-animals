module Main exposing (ModalState, Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Content.Skills as Skills
import Engine.Skill as Skill exposing (Skill, SkillEffect)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import View.ElmHtml



-- MODEL


type ModalState
    = Visible String (Html Msg)
    | Hidden


type alias Model =
    { skills : List Skill
    , skillEffects : List SkillEffect
    , modal : ModalState
    }


init : () -> ( Model, Cmd msg )
init _ =
    ( Model
        [ Skills.debuffSkill
        , Skills.slowSkill
        , Skills.buffSkill
        , Skills.basicSkill
        ]
        []
        Hidden
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Int
    | UseSkill Int
    | ShowModal
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
            ( { model | skills = skills, skillEffects = effects ++ model.skillEffects |> List.take 10 }, Cmd.none )

        ShowModal ->
            ( { model | modal = Visible "Test" (Html.text "hei") }, Cmd.none )

        HideModal ->
            ( { model | modal = Hidden }, Cmd.none )



-- VIEW


viewModal : ModalState -> Html Msg
viewModal state =
    case state of
        Visible title content ->
            Html.aside [ Html.Attributes.classList [ ( "modal", True ), ( "visible", True ) ] ]
                [ Html.div [ Html.Attributes.class "modal-body" ]
                    [ Html.div [ Html.Attributes.class "modal-header" ]
                        [ Html.h5 [] [ Html.text title ]
                        , Html.button [ Html.Events.onClick HideModal ] [ Html.text "Close" ]
                        ]
                    , Html.div [ Html.Attributes.class "modal-content" ] [ content ]
                    ]
                , Html.div [ Html.Attributes.class "modal-background", Html.Events.onClick HideModal ] []
                ]

        Hidden ->
            Html.aside [ Html.Attributes.classList [ ( "modal", True ), ( "visible", False ) ] ]
                [ Html.div [ Html.Attributes.class "modal-body" ]
                    [ Html.div [ Html.Attributes.class "modal-header" ]
                        [ Html.h5 [] [ Html.text "Modal header" ]
                        , Html.button [ Html.Events.onClick HideModal ] [ Html.text "Close" ]
                        ]
                    , Html.div [ Html.Attributes.class "modal-content" ] [ Html.text "modal content" ]
                    ]
                , Html.div [ Html.Attributes.class "modal-background", Html.Events.onClick HideModal ] []
                ]


view : Model -> Document Msg
view model =
    { title = "Fighting Animals"
    , body =
        [ viewModal model.modal
        , Html.button [ Html.Attributes.class "show-qr-button", Html.Events.onClick ShowModal ] [ Html.text "qr" ]
        , View.ElmHtml.view { skills = model.skills, skillEffects = model.skillEffects } UseSkill
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


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
