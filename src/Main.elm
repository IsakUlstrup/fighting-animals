module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Content.Skills as Skills
import Element exposing (Element)
import Element.Background
import Engine.Skill as Skill exposing (Skill, SkillEffect)
import View.ElmUI



-- MODEL


type alias Model =
    { skills : List Skill
    , skillEffects : List SkillEffect
    }


init : () -> ( Model, Cmd msg )
init _ =
    ( Model [ Skills.basicSkill, Skills.slowSkill, Skills.buffSkill ] [], Cmd.none )



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


viewSkillEffect : SkillEffect -> Element msg
viewSkillEffect effect =
    Element.el [] (Element.text <| Skill.effectToString effect)


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
                [ Element.column [] (List.map viewSkillEffect model.skillEffects)
                , Element.column [ Element.alignBottom, Element.width Element.fill, Element.spacing 15 ]
                    (List.indexedMap (\i -> View.ElmUI.viewSkillButton (UseSkill i)) model.skills)
                ]
            )
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
