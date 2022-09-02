module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Content.Skills as Skills
import Engine.Skill as Skill exposing (Skill, SkillEffect)
import View.ElmHtml



-- MODEL


type alias Model =
    { skills : List Skill
    , skillEffects : List SkillEffect
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
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Int
    | UseSkill Int


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



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Fighting Animals"
    , body =
        [ View.ElmHtml.view { skills = model.skills, skillEffects = model.skillEffects } UseSkill ]
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
