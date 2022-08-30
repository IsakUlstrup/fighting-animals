module Engine.Animal exposing (Animal, new)


type alias Animal =
    { name : String
    }


new : String -> Animal
new name =
    Animal name
