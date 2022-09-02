module Content.Skills exposing (basicSkill, buffSkill, debuffSkill, slowSkill)

import Engine.Skill as Skill exposing (Skill)


basicSkill : Skill
basicSkill =
    Skill.newHit "Basic Hit Skill" "Just a basic skill, nothing special" 1000 12


slowSkill : Skill
slowSkill =
    Skill.newHit "Slow Hit Skill" "This skill is super slow, hopefully it hits hard" 6000 30


buffSkill : Skill
buffSkill =
    Skill.newBuff "Buff Skill" "This is a buff skill" 2000 25


debuffSkill : Skill
debuffSkill =
    Skill.newDebuff "Debuff Skill" "This is a debuff skill" 5000 50
