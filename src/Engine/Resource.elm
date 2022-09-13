module Engine.Resource exposing (Resource, new)


type alias Resource =
    { condition : Int
    , health : ( Int, Int )
    }


{-| Create new resource with default values
-}
new : Resource
new =
    Resource 0 ( 100, 100 )
