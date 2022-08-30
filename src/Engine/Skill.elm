module Engine.Skill exposing (Skill, new)


type alias Skill =
    { name : String
    , description : String
    , cooldown : ( Int, Int )
    }


new : String -> String -> Int -> Skill
new name description cooldown =
    Skill name description ( 0, cooldown )
