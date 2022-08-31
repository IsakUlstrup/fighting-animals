module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Content.Skills exposing (basicSkill)
import Element
import Element.Background
import Engine.Skill as Skill exposing (Skill)
import View.Experimental



-- MODEL


type alias Model =
    Skill


init : () -> ( Model, Cmd msg )
init _ =
    ( basicSkill, Cmd.none )



-- UPDATE


type Msg
    = Tick Int
    | UseSkill


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            ( model |> Skill.tick dt, Cmd.none )

        UseSkill ->
            ( model |> Skill.use, Cmd.none )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Fighting Animals"
    , body =
        [ Element.layout
            [ Element.padding 30
            , Element.Background.gradient
                { angle = 2.8
                , steps =
                    [ Element.rgb255 204 149 192
                    , Element.rgb255 219 212 180
                    , Element.rgb255 122 161 210
                    ]
                }
            ]
            (Element.column [ Element.width (Element.fill |> Element.maximum 500), Element.height Element.fill, Element.centerX ]
                [ Element.column [ Element.alignBottom, Element.width Element.fill, Element.spacing 15 ]
                    [ View.Experimental.viewSkillButton model UseSkill
                    , View.Experimental.viewSkillButton model UseSkill
                    , View.Experimental.viewSkillButton model UseSkill
                    ]
                ]
            )
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if Skill.isReady model then
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
