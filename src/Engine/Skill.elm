module Engine.Skill exposing (Skill, new)


type alias Skill =
    { name : String }


new : String -> Skill
new name =
    Skill name
