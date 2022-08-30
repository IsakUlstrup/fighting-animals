module Engine.Skill exposing (Skill, cooldown, new)


type alias Skill =
    { name : String
    , description : String
    , cooldownTime : ( Int, Int )
    }


{-| Create new skill
-}
new : String -> String -> Int -> Skill
new name description cooldownTime =
    Skill name description ( 0, max 0 cooldownTime )


cooldown : Int -> Skill -> Skill
cooldown amount skill =
    { skill | cooldownTime = Tuple.mapFirst ((+) amount) skill.cooldownTime }
