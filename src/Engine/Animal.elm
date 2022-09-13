module Engine.Animal exposing (Animal, energyPercentage, init, tickSkills, useAllSkills, useSkillAtIndex, withEnergy, withName, withSkill)

import Engine.Skill as Skill exposing (Skill, SkillEffect)


type alias Animal =
    { name : String
    , skills : List Skill
    , energy : ( Int, Int )
    }



---- BUILDER ----


{-| Create a new animal with default values
-}
init : Animal
init =
    Animal "Unnamed animal" [] ( 100, 100 )


{-| Set animal name

Providing an empty name return unchanged animal with default name

-}
withName : String -> Animal -> Animal
withName name animal =
    if String.isEmpty name then
        animal

    else
        { animal | name = name }


{-| Add a skill to animal skills
-}
withSkill : Skill -> Animal -> Animal
withSkill skill animal =
    { animal | skills = animal.skills ++ [ skill ] }


{-| Set animal max energy

only energy max is changed, this means reducing max below the default of 100
will result in "overheal" ie. (100, 50)

values are clamped to 1 or higher

-}
withEnergy : Int -> Animal -> Animal
withEnergy maxEnergy animal =
    { animal | energy = ( Tuple.first animal.energy, max 1 maxEnergy ) }



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



---- VIEW HELPERS ----


{-| Get energy percentage (0-100)
-}
energyPercentage : Animal -> Int
energyPercentage animal =
    (toFloat (Tuple.first animal.energy) / toFloat (Tuple.second animal.energy)) * 100 |> round
