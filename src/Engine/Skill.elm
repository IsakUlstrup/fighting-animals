module Engine.Skill exposing (Skill, SkillState(..), currentCooldown, isReady, new, tick, use)


type alias Skill =
    { name : String
    , description : String
    , cooldownTime : Int
    , useTime : Int
    , state : SkillState
    }


type SkillState
    = Ready
    | Cooling ( Int, Int )
    | Active ( Int, Int )


{-| Create new skill

cooldownTime is intended to be milliseconds

useTime is set to 100 ms for now

-}
new : String -> String -> Int -> Skill
new name description cooldownTime =
    Skill
        name
        description
        (max 0 cooldownTime)
        100
        (Cooling ( 0, max 0 cooldownTime ))


{-| Reduce timer by amount
-}
tickTime : Int -> ( Int, Int ) -> ( Int, Int )
tickTime amount time =
    let
        -- Update remaining time, negative numbers are ignored, result is capped at max time
        updateRemaining : Int -> Int -> Int
        updateRemaining i =
            (+) (max 0 i) >> min (Tuple.second time)
    in
    Tuple.mapFirst (updateRemaining amount) time


{-| Tick skill with delta time in ms and advance state.
-}
tick : Int -> Skill -> Skill
tick dt skill =
    case skill.state of
        Ready ->
            skill

        Cooling ( current, max ) ->
            if current + dt >= max then
                { skill | state = Ready }

            else
                { skill | state = Cooling <| tickTime dt ( current, max ) }

        Active ( current, max ) ->
            if current + dt >= max then
                { skill | state = Cooling ( 0, skill.cooldownTime ) }

            else
                { skill | state = Active <| tickTime dt ( current, max ) }


{-| Get current cooldown time
-}
currentCooldown : Skill -> Int
currentCooldown skill =
    case skill.state of
        Cooling ( current, _ ) ->
            current

        _ ->
            0


{-| Is skill ready (off cooldown)?
-}
isReady : Skill -> Bool
isReady skill =
    case skill.state of
        Ready ->
            True

        _ ->
            False


{-| Use skill if ready
-}
use : Skill -> Skill
use skill =
    if isReady skill then
        { skill | state = Active ( 0, skill.useTime ) }

    else
        skill
