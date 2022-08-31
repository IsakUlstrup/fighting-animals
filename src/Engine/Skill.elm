module Engine.Skill exposing (Skill, SkillState(..), cooldown, currentCooldown, isReady, new, use)


type alias Skill =
    { name : String
    , description : String
    , cooldownTime : ( Int, Int )
    , state : SkillState
    }


type SkillState
    = Cooling
    | Ready


{-| Create new skill

cooldownTime is intended to be milliseconds

-}
new : String -> String -> Int -> Skill
new name description cooldownTime =
    Skill name description ( 0, max 0 cooldownTime ) Cooling


{-| Reduce cooldown by amount
-}
cooldown : Int -> Skill -> Skill
cooldown amount skill =
    let
        -- Update remaining time, negative numbers are ignored, result is capped at max skill cooldown
        updateRemaining : Int -> Int -> Int
        updateRemaining i =
            (+) (max 0 i) >> min (Tuple.second skill.cooldownTime)
    in
    { skill | cooldownTime = Tuple.mapFirst (updateRemaining amount) skill.cooldownTime }


{-| Reset skill cooldown
-}
resetCooldown : Skill -> Skill
resetCooldown skill =
    { skill | cooldownTime = Tuple.mapFirst (always 0) skill.cooldownTime }


{-| Get current cooldown time
-}
currentCooldown : Skill -> Int
currentCooldown skill =
    Tuple.first skill.cooldownTime


{-| Is skill ready (off cooldown)?
-}
isReady : Skill -> Bool
isReady skill =
    Tuple.first skill.cooldownTime == Tuple.second skill.cooldownTime


{-| Use skill if ready
-}
use : Skill -> Skill
use skill =
    if isReady skill then
        resetCooldown skill

    else
        skill
