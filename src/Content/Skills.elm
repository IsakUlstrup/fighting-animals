module Content.Skills exposing (basicSkill, slowSkill)

import Engine.Skill as Skill exposing (Skill)


basicSkill : Skill
basicSkill =
    Skill.new "Basic Skill" "Example skill" 1000


slowSkill : Skill
slowSkill =
    Skill.new "Slow Skill" "Slow skill, hopefully it hits hard" 6000
