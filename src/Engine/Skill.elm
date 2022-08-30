module Engine.Skill exposing (Skill, cooldown, new)


type alias Skill =
    { name : String
    , description : String
    , cooldownTime : ( Int, Int )
    }


{-| Create new skill

cooldownTime is intended to be milliseconds

-}
new : String -> String -> Int -> Skill
new name description cooldownTime =
    Skill name description ( 0, max 0 cooldownTime )


{-| Reduce cooldown by amount
-}
cooldown : Int -> Skill -> Skill
cooldown amount skill =
    let
        updateRemaining i =
            (+) i >> clamp 0 (Tuple.second skill.cooldownTime)
    in
    { skill | cooldownTime = Tuple.mapFirst (updateRemaining amount) skill.cooldownTime }
