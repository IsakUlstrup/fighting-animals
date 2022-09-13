module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Events
import Content.Animals as Animals
import Content.ResourceType exposing (ResourceType)
import Content.Resources
import Engine.Animal as Animal exposing (Animal)
import Engine.Resource as Resource exposing (Resource)
import Engine.Skill as Skill exposing (SkillEffect)
import Html
import Html.Attributes
import View.ElmHtml



-- MODEL


type alias Model =
    { playerAnimal : Animal
    , resource : Resource ResourceType
    , combatLog : List ( Bool, SkillEffect )
    , pageUrl : String
    }


init : String -> ( Model, Cmd msg )
init pageUrl =
    ( Model
        Animals.playerPanda
        Content.Resources.oakTree
        []
        pageUrl
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Int
    | UseSkill Int


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
            , Cmd.none
            )

        UseSkill index ->
            ( { model | playerAnimal = model.playerAnimal |> Animal.useSkillAtIndex index }, Cmd.none )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Fighting Animals"
    , body =
        [ Html.main_ [ Html.Attributes.id "app" ]
            [ View.ElmHtml.viewStatusBar
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
