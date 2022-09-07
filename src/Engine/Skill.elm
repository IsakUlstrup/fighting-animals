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
    | Cooling ( Int, Int )
    | Active ( Int, Int )


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
        (Cooling ( 0, max 0 cooldownTime ))
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
-}
withCooldown : Int -> Skill -> Skill
withCooldown cooldown skill =
    case skill.state of
        Cooling ( current, _ ) ->
            { skill
                | cooldownTime = max 0 cooldown
                , state = Cooling ( current, max 0 cooldown )
            }

        _ ->
            { skill
                | cooldownTime = max 0 cooldown
            }


{-| Set skill use time
-}
withUseTime : Int -> Skill -> Skill
withUseTime useTime skill =
    case skill.state of
        Active ( current, _ ) ->
            { skill
                | useTime = max 0 useTime
                , state = Active ( current, max 0 useTime )
            }

        _ ->
            { skill
                | useTime = max 0 useTime
            }



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
    { skill | state = Cooling ( 0, skill.cooldownTime ) }


{-| Set skill state to active with timer at 0
-}
setActive : Skill -> Skill
setActive skill =
    { skill | state = Active ( 0, skill.useTime ) }


{-| tick skill state timers, does not advance state
-}
tickState : Int -> Skill -> Skill
tickState time skill =
    let
        -- Update remaining time, negative numbers are ignored, result is capped at max time
        updateRemaining : Int -> Int -> Int -> Int
        updateRemaining remaining amount cap =
            remaining + max 0 amount |> min cap
    in
    case skill.state of
        Ready ->
            skill

        Cooling ( current, max ) ->
            { skill | state = Cooling <| ( updateRemaining current time max, max ) }

        Active ( current, max ) ->
            { skill | state = Active <| ( updateRemaining current time max, max ) }


{-| Tick skill with delta time in ms and advance state if neccesary
-}
tick : Int -> Skill -> ( Skill, Maybe SkillEffect )
tick dt skill =
    case skill.state of
        Ready ->
            ( skill, Nothing )

        Cooling ( current, max ) ->
            if current + dt >= max then
                ( setReady skill, Nothing )

            else
                ( tickState dt skill, Nothing )

        Active ( current, max ) ->
            if current + dt >= max then
                ( setCooling skill, Just skill.effect )

            else
                ( tickState dt skill, Nothing )


{-| Get skill cooldown progress in percentage 0-100

returns 100 for ready and active state

useful for rendering

-}
cooldownPercentage : Skill -> Int
cooldownPercentage skill =
    case skill.state of
        Cooling ( current, max ) ->
            if max == 0 then
                100

            else
                (toFloat current / toFloat max) * 100 |> round

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
