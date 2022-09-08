module Content.Animals exposing (enemySloth, playerPanda)

import Content.Skills as Skills
import Engine.Animal as Animal exposing (Animal)


playerPanda : Animal
playerPanda =
    Animal.new "Panda"
        |> Animal.addSkill Skills.debuffSkill
        |> Animal.addSkill Skills.buffSkill
        |> Animal.addSkill Skills.basicSkill


enemySloth : Animal
enemySloth =
    Animal.new "Sloth"
        |> Animal.addSkill Skills.enemyBasicSkill
