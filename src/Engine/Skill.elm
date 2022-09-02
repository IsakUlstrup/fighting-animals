module Engine.Skill exposing
    ( Skill
    , SkillEffect(..)
    , SkillState(..)
    , cooldownPercentage
    , effectToString
    , isActive
    , isReady
    , newBuff
    , newDebuff
    , newHit
    , tick
    , use
    )


type alias Skill =
    { name : String
    , description : String
    , cooldownTime : Int
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


{-| Skill use time constant
-}
useTime : Int
useTime =
    500


{-| Create new skill

cooldownTime is intended to be milliseconds

useTime is set to 100 ms for now

-}
new : String -> String -> Int -> SkillEffect -> Skill
new name description cooldownTime effect =
    Skill
        name
        description
        (max 0 cooldownTime)
        (Cooling ( 0, max 0 cooldownTime ))
        effect


{-| Create new skill with hit effect
-}
newHit : String -> String -> Int -> Int -> Skill
newHit name description cooldownTime power =
    new
        name
        description
        (max 0 cooldownTime)
        (Hit <| max 0 power)


{-| Create new skill with buff effect
-}
newBuff : String -> String -> Int -> Int -> Skill
newBuff name description cooldownTime power =
    new
        name
        description
        (max 0 cooldownTime)
        (Buff <| max 0 power)


{-| Create new skill with debuff effect
-}
newDebuff : String -> String -> Int -> Int -> Skill
newDebuff name description cooldownTime power =
    new
        name
        description
        (max 0 cooldownTime)
        (Debuff <| max 0 power)


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
    { skill | state = Active ( 0, useTime ) }


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
tick : Int -> Skill -> Skill
tick dt skill =
    case skill.state of
        Ready ->
            skill

        Cooling ( current, max ) ->
            if current + dt >= max then
                setReady skill

            else
                tickState dt skill

        Active ( current, max ) ->
            if current + dt >= max then
                setCooling skill

            else
                tickState dt skill


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


{-| Is skill active?
-}
isActive : Skill -> Bool
isActive skill =
    case skill.state of
        Ready ->
            False

        Active _ ->
            True

        Cooling _ ->
            False


{-| Use skill if ready
-}
use : Skill -> ( Skill, Maybe SkillEffect )
use skill =
    if isReady skill then
        ( setActive skill, Just skill.effect )

    else
        ( skill, Nothing )
