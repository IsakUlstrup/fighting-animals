module Content.Skills exposing (basicSkill, slowSkill)

import Engine.Skill as Skill exposing (Skill)


basicSkill : Skill
basicSkill =
    Skill.newHit "Basic Hit Skill" "Just a basic skill, nothing special" 1000 12


slowSkill : Skill
slowSkill =
    Skill.newHit "Slow Hit Skill" "This skill is super slow, hopefully it hits hard" 6000 30
