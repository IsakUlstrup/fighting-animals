module Content.ResourceType exposing (ResourceType(..), toString)


type ResourceType
    = OakTree
    | Rock


toString : ResourceType -> String
toString rescourceType =
    case rescourceType of
        OakTree ->
            "Oak Tree"

        Rock ->
            "Rock"
