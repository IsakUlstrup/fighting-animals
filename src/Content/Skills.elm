module Content.Skills exposing
    ( basicSkill
    , buffSkill
    , debuffSkill
    , enemyBasicSkill
    )

import Engine.Skill as Skill exposing (Skill)


basicSkill : Skill
basicSkill =
    Skill.initHit 12
        |> Skill.withName "Basic skill"
        |> Skill.withDescription "A basic skill, nothing special"
        |> Skill.withCooldown 1500
        |> Skill.withUseTime 300


buffSkill : Skill
buffSkill =
    Skill.initBuff 25
        |> Skill.withName "Buff"
        |> Skill.withDescription "Applies a buff"
        |> Skill.withCooldown 3000


debuffSkill : Skill
debuffSkill =
    Skill.initDebuff 50
        |> Skill.withName "Debuff"
        |> Skill.withDescription "Applies a debuff"


enemyBasicSkill : Skill
enemyBasicSkill =
    Skill.initHit 5
        |> Skill.withCooldown 4000
        |> Skill.withUseTime 1000
