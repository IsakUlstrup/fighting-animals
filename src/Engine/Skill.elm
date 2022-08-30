module Engine.Skill exposing (Skill, new)


type alias Skill =
    { name : String
    , description : String
    }


new : String -> String -> Skill
new name description =
    Skill name description
