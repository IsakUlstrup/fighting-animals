module Content.Animals exposing (enemySloth, playerPanda)

import Content.Skills as Skills
import Engine.Animal as Animal exposing (Animal)


playerPanda : Animal
playerPanda =
    Animal.init
        |> Animal.withName "Panda"
        |> Animal.withSkill Skills.debuffSkill
        |> Animal.withSkill Skills.buffSkill
        |> Animal.withSkill Skills.basicSkill


enemySloth : Animal
enemySloth =
    Animal.init
        |> Animal.withName "Sloth"
        |> Animal.withSkill Skills.enemyBasicSkill
