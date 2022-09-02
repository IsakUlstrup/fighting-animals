module View.ElmHtml exposing (view)

import Engine.Skill exposing (Skill, SkillEffect)
import Html exposing (Html, div)



-- viewSkillButton : msg -> Skill -> Html msg
-- viewSkillButton clickMsg skill =
--     Html.div [] []


view :
    { skills : List Skill
    , skillEffects : List SkillEffect
    }
    -> (Int -> msg)
    -> Html msg
view _ _ =
    div [] []
