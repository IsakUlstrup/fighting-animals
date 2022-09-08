module Animal exposing (animalBuilder, animalSkillsTests, animalView)

import Content.Skills
import Engine.Animal exposing (Animal)
import Engine.Skill
import Expect
import Fuzz exposing (int, string)
import Test exposing (Test, describe, fuzz, test)


animalBuilder : Test
animalBuilder =
    describe "Animal builder"
        [ fuzz string "new animal with fuzz name. Verify name" <|
            \randomString ->
                Engine.Animal.init
                    |> Engine.Animal.withName randomString
                    |> .name
                    |> Expect.equal
                        (if randomString == "" then
                            "Unnamed animal"

                         else
                            randomString
                        )
        , test "New animal, with no skills" <|
            \_ ->
                Engine.Animal.init
                    |> .skills
                    |> Expect.equal []
        , test "New animal, with skills. Order should be chronological" <|
            \_ ->
                Engine.Animal.init
                    |> Engine.Animal.withSkill Content.Skills.basicSkill
                    |> Engine.Animal.withSkill Content.Skills.buffSkill
                    |> .skills
                    |> Expect.equal
                        [ Content.Skills.basicSkill
                        , Content.Skills.buffSkill
                        ]
        , fuzz int "New animal with random health, only max health should be changed, current health should stay at the default 100. min allowed is 1" <|
            \randomInt ->
                Engine.Animal.init
                    |> Engine.Animal.withHealth randomInt
                    |> .health
                    |> Expect.equal
                        (if randomInt <= 0 then
                            ( 100, 1 )

                         else
                            ( 100, randomInt )
                        )
        ]


animalWithSkills : Animal
animalWithSkills =
    Engine.Animal.init
        |> Engine.Animal.withSkill Content.Skills.basicSkill
        |> Engine.Animal.withSkill Content.Skills.buffSkill


animalSkillsTests : Test
animalSkillsTests =
    describe "Animal skills"
        [ test "Add a skill" <|
            \_ ->
                Engine.Animal.init
                    |> Engine.Animal.withSkill Content.Skills.basicSkill
                    |> .skills
                    |> Expect.equal [ Content.Skills.basicSkill ]
        , test "Add multiple skills, latest addition should be last" <|
            \_ ->
                Engine.Animal.init
                    |> Engine.Animal.withSkill Content.Skills.basicSkill
                    |> Engine.Animal.withSkill Content.Skills.buffSkill
                    |> .skills
                    |> Expect.equal
                        [ Content.Skills.basicSkill
                        , Content.Skills.buffSkill
                        ]
        , test "Use skill at index 1 in a list of ready skills" <|
            \_ ->
                animalWithSkills
                    |> Engine.Animal.tickSkills 5000
                    |> Tuple.first
                    |> Engine.Animal.useSkillAtIndex 1
                    |> .skills
                    |> List.map .state
                    |> Expect.equal
                        [ Engine.Skill.Ready
                        , Engine.Skill.Active ( 0, Content.Skills.buffSkill.useTime )
                        ]
        , test "Use all skills in a list of ready skills" <|
            \_ ->
                animalWithSkills
                    |> Engine.Animal.tickSkills 5000
                    |> Tuple.first
                    |> Engine.Animal.useAllSkills
                    |> .skills
                    |> List.map .state
                    |> Expect.equal
                        [ Engine.Skill.Active ( 0, Content.Skills.basicSkill.useTime )
                        , Engine.Skill.Active ( 0, Content.Skills.buffSkill.useTime )
                        ]
        , test "Use skill at index 5 (out of bounds) in a list of ready skills, should return unchanged list" <|
            \_ ->
                animalWithSkills
                    |> Engine.Animal.tickSkills 9000
                    |> Tuple.first
                    |> Engine.Animal.useSkillAtIndex 5
                    |> .skills
                    |> List.map .state
                    |> Expect.equal
                        [ Engine.Skill.Ready
                        , Engine.Skill.Ready
                        ]
        , test "Tick a list of active skills, check returned skill effects" <|
            \_ ->
                animalWithSkills
                    |> Engine.Animal.tickSkills 5000
                    |> Tuple.first
                    |> Engine.Animal.useSkillAtIndex 0
                    |> Engine.Animal.useSkillAtIndex 1
                    |> Engine.Animal.tickSkills 1000
                    |> Tuple.second
                    |> Expect.equal
                        [ Engine.Skill.Hit 12
                        , Engine.Skill.Buff 25
                        ]
        ]


animalView : Test
animalView =
    describe "View helpers"
        [ test "Health percentage" <|
            \_ ->
                Engine.Animal.init
                    |> Engine.Animal.healthPercentage
                    |> Expect.equal
                        100
        ]
