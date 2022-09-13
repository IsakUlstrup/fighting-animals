module Content.Resources exposing (oakTree, rock)

import Content.ResourceType exposing (ResourceType(..))
import Engine.Resource as Resource exposing (Resource)


oakTree : Resource ResourceType
oakTree =
    Resource.new OakTree


rock : Resource ResourceType
rock =
    Resource.new Rock
