module View.Modal exposing (Modal, hide, new, show, viewModal)

import Html exposing (Html)
import Html.Attributes
import Html.Events


type alias Modal msg =
    { title : String
    , content : Html msg
    , visible : Bool
    }


new : Modal msg
new =
    Modal "Modal Title" (Html.text "modal content") False


hide : Modal msg -> Modal msg
hide modal =
    { modal | visible = False }


show : String -> Html msg -> Modal msg -> Modal msg
show title content modal =
    { modal | title = title, content = content, visible = True }


viewModal : msg -> Modal msg -> Html msg
viewModal hideMsg modal =
    Html.aside [ Html.Attributes.classList [ ( "modal", True ), ( "visible", modal.visible ) ] ]
        [ Html.div [ Html.Attributes.class "modal-body" ]
            [ Html.div [ Html.Attributes.class "modal-header" ]
                [ Html.h5 [] [ Html.text modal.title ]
                , Html.button [ Html.Events.onClick hideMsg ] [ Html.text "X" ]
                ]
            , Html.div [ Html.Attributes.class "modal-content" ] [ modal.content ]
            ]
        , Html.div [ Html.Attributes.class "modal-background", Html.Events.onClick hideMsg ] []
        ]
