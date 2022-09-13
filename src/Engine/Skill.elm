module Engine.Skill exposing
    ( Skill
    , SkillEffect(..)
    , SkillState(..)
    , effectToString
    , initBuff
    , initDebuff
    , initHit
    , isReady
    , tick
    , use
    , useTimePercentage
    , withDescription
    , withEnergyCost
    , withName
    , withUseTime
    )


type alias Skill =
    { name : String
    , description : String
    , energyCost : Int
    , useTime : Int
    , state : SkillState
    , effect : SkillEffect
    }


type SkillState
    = Ready
    | Active Int


type SkillEffect
    = Hit Int
    | Buff Int
    | Debuff Int



---- BUILDER ----


{-| Create new skill

cooldownTime is intended to be milliseconds

-}
new : String -> String -> Int -> SkillEffect -> Int -> Skill
new name description energyCost effect useTime =
    Skill
        name
        description
        energyCost
        useTime
        Ready
        effect


{-| Initial hit skill with provided power
-}
initHit : Int -> Skill
initHit power =
    new "Unnamed Skill" "Hit type" 0 (Hit <| max 0 power) 500


{-| Initial hit skill with provided power
-}
initBuff : Int -> Skill
initBuff power =
    new "Unnamed Skill" "Buff type" 0 (Buff <| max 0 power) 500


{-| Initial debuff skill with provided power
-}
initDebuff : Int -> Skill
initDebuff power =
    new "Unnamed Skill" "Debuff type" 0 (Debuff <| max 0 power) 500


{-| Set skill name
-}
withName : String -> Skill -> Skill
withName name skill =
    { skill | name = name }


{-| Set skill description
-}
withDescription : String -> Skill -> Skill
withDescription description skill =
    { skill | description = description }


{-| Set skill energy cost
-}
withEnergyCost : Int -> Skill -> Skill
withEnergyCost cost skill =
    { skill | energyCost = max 0 cost }


{-| Set skill use time

Resets use time if skill is active

-}
withUseTime : Int -> Skill -> Skill
withUseTime useTime skill =
    case skill.state of
        Active _ ->
            { skill
                | useTime = max 0 useTime
                , state = Active <| max 0 useTime
            }

        _ ->
            { skill | useTime = max 0 useTime }



---- STATE ----


{-| Set skill state to ready
-}
setReady : Skill -> Skill
setReady skill =
    { skill | state = Ready }


{-| Set skill state to active with timer at 0
-}
setActive : Skill -> Skill
setActive skill =
    { skill | state = Active skill.useTime }


{-| tick skill state timers, does not advance state
-}
tickState : Int -> Skill -> Skill
tickState time skill =
    case skill.state of
        Ready ->
            skill

        Active current ->
            { skill | state = Active <| max 0 <| current - time }


{-| Tick skill with delta time in ms and advance state if neccesary
-}
tick : Int -> Skill -> ( Skill, Maybe SkillEffect )
tick dt skill =
    case skill.state of
        Ready ->
            ( skill, Nothing )

        Active current ->
            if current - max 0 dt <= 0 then
                ( setReady skill, Just skill.effect )

            else
                ( tickState (max 0 dt) skill, Nothing )


{-| Get skill use time progress in percentage 0-100

returns 100 for ready state

useful for rendering

-}
useTimePercentage : Skill -> Int
useTimePercentage skill =
    case skill.state of
        Active current ->
            if skill.useTime == 0 then
                100

            else
                (toFloat (skill.useTime - current) / toFloat skill.useTime) * 100 |> round

        Ready ->
            0


{-| Skill effect to string, for debug rendering
-}
effectToString : SkillEffect -> String
effectToString effect =
    case effect of
        Hit pwr ->
            "Hit " ++ String.fromInt pwr

        Buff pwr ->
            "Buff " ++ String.fromInt pwr

        Debuff pwr ->
            "Debuff " ++ String.fromInt pwr


{-| Is skill ready (off cooldown)?
-}
isReady : Skill -> Bool
isReady skill =
    case skill.state of
        Ready ->
            True

        Active _ ->
            False


{-| Use skill if ready
-}
use : Skill -> Skill
use skill =
    if isReady skill then
        setActive skill

    else
        skill
