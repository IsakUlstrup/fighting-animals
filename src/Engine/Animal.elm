module Engine.Animal exposing (Animal, applySkillEffect, applySkillEffects, healthPercentage, init, isAlive, tickSkills, useAllSkills, useSkillAtIndex, withHealth, withName, withSkill)

import Engine.Skill as Skill exposing (Skill, SkillEffect(..))


type alias Animal =
    { name : String
    , skills : List Skill
    , health : ( Int, Int )
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


{-| Set animal max health

only health max is changed, this means reducing max below the default of 100
will result in "overheal" ie. (100, 50)

values are clamped to 1 or higher

-}
withHealth : Int -> Animal -> Animal
withHealth maxHealth animal =
    { animal | health = ( Tuple.first animal.health, max 1 maxHealth ) }



---- GENERAL STATE STUFF ----


{-| apply hit
-}
hit : Int -> Animal -> Animal
hit hitPwr animal =
    { animal | health = Tuple.mapFirst ((\h -> h - max 0 hitPwr) >> max 0) animal.health }


{-| Is animal alive, current health above 0
-}
isAlive : Animal -> Bool
isAlive animal =
    Tuple.first animal.health > 0



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



---- SKILL EFFECTS ----


{-| Apply skill effect, only works with hits for now
-}
applySkillEffect : SkillEffect -> Animal -> Animal
applySkillEffect effect animal =
    case effect of
        Hit pwr ->
            hit pwr animal

        _ ->
            animal


{-| Apply a list of skill effects, only works with hits for now
-}
applySkillEffects : List SkillEffect -> Animal -> Animal
applySkillEffects effects animal =
    List.foldl applySkillEffect animal effects



---- VIEW HELPERS ----


healthPercentage : Animal -> Int
healthPercentage animal =
    (toFloat (Tuple.first animal.health) / toFloat (Tuple.second animal.health)) * 100 |> round
