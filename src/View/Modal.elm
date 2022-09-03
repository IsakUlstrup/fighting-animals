module View.Modal exposing (Modal, hide, new, setContent, setTitle, show, viewModal)

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


setContent : Html msg -> Modal msg -> Modal msg
setContent content modal =
    { modal | content = content }


setTitle : String -> Modal msg -> Modal msg
setTitle title modal =
    { modal | title = title }


hide : Modal msg -> Modal msg
hide modal =
    { modal | visible = False }


show : Modal msg -> Modal msg
show modal =
    { modal | visible = True }


viewModal : msg -> Modal msg -> Html msg
viewModal hideMsg modal =
    Html.aside [ Html.Attributes.classList [ ( "modal", True ), ( "visible", modal.visible ) ] ]
        [ Html.div [ Html.Attributes.class "modal-body" ]
            [ Html.div [ Html.Attributes.class "modal-header" ]
                [ Html.h5 [] [ Html.text modal.title ]
                , Html.button [ Html.Events.onClick hideMsg ] [ Html.text "Close" ]
                ]
            , Html.div [ Html.Attributes.class "modal-content" ] [ modal.content ]
            ]
        , Html.div [ Html.Attributes.class "modal-background", Html.Events.onClick hideMsg ] []
        ]
