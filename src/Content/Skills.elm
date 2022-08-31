module Content.Skills exposing (basicSkill)

import Engine.Skill as Skill exposing (Skill)


basicSkill : Skill
basicSkill =
    Skill.new "Attack" "Example skill" 1000
