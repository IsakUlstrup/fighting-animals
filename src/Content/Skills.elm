module Content.Skills exposing (basicSkill, slowSkill)

import Engine.Skill as Skill exposing (Skill)


basicSkill : Skill
basicSkill =
    Skill.new "Basic Skill" "Just a basic skill, nothing special" 1000


slowSkill : Skill
slowSkill =
    Skill.new "Slow Skill" "This skill is super slow, hopefully it hits hard" 6000
