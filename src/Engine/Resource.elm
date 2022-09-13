module Engine.Resource exposing (Resource, applySkillEffect, applySkillEffects, healthPercentage, isAlive, new)

import Engine.Skill exposing (SkillEffect(..))


type alias Resource t =
    { condition : Int
    , health : ( Int, Int )
    , type_ : t
    }


{-| Create new resource with default values
-}
new : t -> Resource t
new type_ =
    Resource 0 ( 100, 100 ) type_



---- GENERAL STATE STUFF ----


{-| apply hit
-}
hit : Int -> Resource t -> Resource t
hit hitPwr resource =
    { resource | health = Tuple.mapFirst ((\h -> h - max 0 hitPwr) >> max 0) resource.health }


{-| Is animal alive, current health above 0
-}
isAlive : Resource t -> Bool
isAlive resource =
    Tuple.first resource.health > 0



---- SKILL EFFECTS ----


{-| Apply skill effect, only works with hits for now
-}
applySkillEffect : SkillEffect -> Resource t -> Resource t
applySkillEffect effect resource =
    case effect of
        Hit pwr ->
            hit pwr resource

        _ ->
            resource


{-| Apply a list of skill effects, only works with hits for now
-}
applySkillEffects : List SkillEffect -> Resource t -> Resource t
applySkillEffects effects resource =
    List.foldl applySkillEffect resource effects



---- VIEW HELPERS ----


healthPercentage : Resource t -> Int
healthPercentage resource =
    (toFloat (Tuple.first resource.health) / toFloat (Tuple.second resource.health)) * 100 |> round
