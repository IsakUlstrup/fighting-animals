module Engine.Resource exposing (Resource, applySkillEffect, applySkillEffects, isAlive, new)

import Engine.Skill exposing (SkillEffect(..))


type alias Resource =
    { condition : Int
    , health : ( Int, Int )
    }


{-| Create new resource with default values
-}
new : Resource
new =
    Resource 0 ( 100, 100 )



---- GENERAL STATE STUFF ----


{-| apply hit
-}
hit : Int -> Resource -> Resource
hit hitPwr resource =
    { resource | health = Tuple.mapFirst ((\h -> h - max 0 hitPwr) >> max 0) resource.health }


{-| Is animal alive, current health above 0
-}
isAlive : Resource -> Bool
isAlive resource =
    Tuple.first resource.health > 0



---- SKILL EFFECTS ----


{-| Apply skill effect, only works with hits for now
-}
applySkillEffect : SkillEffect -> Resource -> Resource
applySkillEffect effect resource =
    case effect of
        Hit pwr ->
            hit pwr resource

        _ ->
            resource


{-| Apply a list of skill effects, only works with hits for now
-}
applySkillEffects : List SkillEffect -> Resource -> Resource
applySkillEffects effects resource =
    List.foldl applySkillEffect resource effects
