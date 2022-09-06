module Content.Skills exposing (basicSkill, buffSkill, debuffSkill, enemyBasicSkill)

import Engine.Skill as Skill exposing (Skill)


basicSkill : Skill
basicSkill =
    Skill.newHit "Basic Hit Skill" "Just a basic skill, nothing special" 1000 12 200


buffSkill : Skill
buffSkill =
    Skill.newBuff "Buff Skill" "This is a buff skill" 2000 25 200


debuffSkill : Skill
debuffSkill =
    Skill.newDebuff "Debuff Skill" "This is a debuff skill" 5000 50 200


enemyBasicSkill : Skill
enemyBasicSkill =
    Skill.newHit "Basic Hit Skill" "Just a basic skill, nothing special" 1000 12 800
