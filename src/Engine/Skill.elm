module Engine.Skill exposing
    ( Skill
    , SkillEffect(..)
    , SkillState(..)
    , cooldownPercentage
    , effectToString
    , initBuff
    , initDebuff
    , initHit
    , isReady
    , tick
    , use
    , withCooldown
    , withDescription
    , withName
    , withUseTime
    )


type alias Skill =
    { name : String
    , description : String
    , cooldownTime : Int
    , useTime : Int
    , state : SkillState
    , effect : SkillEffect
    }


type SkillState
    = Ready
    | Cooling Int
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
new name description cooldownTime effect useTime =
    Skill
        name
        description
        (max 0 cooldownTime)
        useTime
        (Cooling (max 0 cooldownTime))
        effect


{-| Initial hit skill with provided power
-}
initHit : Int -> Skill
initHit power =
    new "Unnamed Skill" "Hit type" 2000 (Hit <| max 0 power) 500


{-| Initial hit skill with provided power
-}
initBuff : Int -> Skill
initBuff power =
    new "Unnamed Skill" "Buff type" 2000 (Buff <| max 0 power) 500


{-| Initial debuff skill with provided power
-}
initDebuff : Int -> Skill
initDebuff power =
    new "Unnamed Skill" "Debuff type" 2000 (Debuff <| max 0 power) 500


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


{-| Set skill cooldown

Resets cooldown time if skill is cooling

-}
withCooldown : Int -> Skill -> Skill
withCooldown cooldown skill =
    case skill.state of
        Cooling _ ->
            { skill
                | cooldownTime = max 0 cooldown
                , state = Cooling <| max 0 cooldown
            }

        _ ->
            { skill | cooldownTime = max 0 cooldown }


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


{-| Set skill state to cooling with timer at 0
-}
setCooling : Skill -> Skill
setCooling skill =
    { skill | state = Cooling skill.cooldownTime }


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

        Cooling current ->
            { skill | state = Cooling <| max 0 <| current - time }

        Active current ->
            { skill | state = Active <| max 0 <| current - time }


{-| Tick skill with delta time in ms and advance state if neccesary
-}
tick : Int -> Skill -> ( Skill, Maybe SkillEffect )
tick dt skill =
    case skill.state of
        Ready ->
            ( skill, Nothing )

        Cooling current ->
            if current - max 0 dt <= 0 then
                ( setReady skill, Nothing )

            else
                ( tickState (max 0 dt) skill, Nothing )

        Active current ->
            if current - max 0 dt <= 0 then
                ( setCooling skill, Just skill.effect )

            else
                ( tickState (max 0 dt) skill, Nothing )


{-| Get skill cooldown progress in percentage 0-100

returns 100 for ready and active state

useful for rendering

-}
cooldownPercentage : Skill -> Int
cooldownPercentage skill =
    case skill.state of
        Cooling current ->
            if skill.cooldownTime == 0 then
                100

            else
                (toFloat (skill.cooldownTime - current) / toFloat skill.cooldownTime) * 100 |> round

        Active _ ->
            100

        Ready ->
            100


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

        Cooling _ ->
            False


{-| Use skill if ready
-}
use : Skill -> Skill
use skill =
    if isReady skill then
        setActive skill

    else
        skill
