module Engine.Animal exposing (Animal, addSkill, new, tickSkills, useAllSkills, useSkillAtIndex)

import Engine.Skill as Skill exposing (Skill, SkillEffect)


type alias Animal =
    { name : String
    , skills : List Skill
    }


{-| Create a new animal with given name
-}
new : String -> Animal
new name =
    Animal name []


{-| Add a skill to animal skills
-}
addSkill : Skill -> Animal -> Animal
addSkill skill animal =
    { animal | skills = animal.skills ++ [ skill ] }



---- SKILLS ----


{-| Use all skills, useful for Ai
-}
useAllSkills : Animal -> Animal
useAllSkills animal =
    { animal | skills = List.map Skill.use animal.skills }


{-| use skill at index in animal skills, return unchanged list if index is out of bounds
-}
useSkillAtIndex : Int -> Animal -> Animal
useSkillAtIndex index animal =
    let
        updateAtIndex : Int -> (Skill -> Skill) -> Int -> Skill -> Skill
        updateAtIndex target f i skill =
            if i == target then
                f skill

            else
                skill
    in
    { animal | skills = List.indexedMap (updateAtIndex index Skill.use) animal.skills }


{-| tick all animal skills by given delta time
-}
tickSkills : Int -> Animal -> ( Animal, List SkillEffect )
tickSkills dt animal =
    let
        ( skills, effects ) =
            List.map (Skill.tick dt) animal.skills
                |> List.unzip
                |> Tuple.mapSecond (List.filterMap identity)
    in
    ( { animal | skills = skills }, effects )
