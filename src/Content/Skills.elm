module Content.Skills exposing
    ( basicSkill
    , buffSkill
    , debuffSkill
    )

import Engine.Skill as Skill exposing (Skill)


basicSkill : Skill
basicSkill =
    Skill.initHit 12
        |> Skill.withName "Basic skill"
        |> Skill.withDescription "A basic skill, nothing special"
        |> Skill.withUseTime 1500
        |> Skill.withUseTime 300


buffSkill : Skill
buffSkill =
    Skill.initBuff 25
        |> Skill.withName "Buff"
        |> Skill.withDescription "Applies a buff"
        |> Skill.withUseTime 3000
        |> Skill.withUseTime 500


debuffSkill : Skill
debuffSkill =
    Skill.initDebuff 50
        |> Skill.withName "Debuff"
        |> Skill.withDescription "Applies a debuff"
