module View.Svg exposing
    ( arrowDown
    , arrowUp
    , fist
    , qrCodeView
    , viewSpinner
    )

import Html exposing (Html)
import QRCode
import Svg exposing (Svg, svg)
import Svg.Attributes


arrowUp : Svg msg
arrowUp =
    Svg.path [ Svg.Attributes.d "M 7.254 19.286 L 7.609 7.509 L 2.211 7.374 L 9.957 0.549 L 17.789 7.798 L 11.713 7.531 L 12.114 19.45 L 7.254 19.286 Z" ] []


arrowDown : Svg msg
arrowDown =
    Svg.path [ Svg.Attributes.d "M 7.254 0.713 L 7.609 12.49 L 2.211 12.625 L 9.957 19.45 L 17.789 12.201 L 11.713 12.468 L 12.114 0.549 L 7.254 0.713 Z" ] []


fist : Svg msg
fist =
    Svg.path [ Svg.Attributes.d "M 5.192 19.296 L 15.278 19.266 L 15.025 10.462 L 17.702 2.93 L 16 2.185 L 13.884 7.77 L 13.549 7.676 L 15.49 1.845 L 13.207 1.145 L 11.666 7.506 L 12.722 1.003 L 10.568 0.705 L 9.763 7.371 L 9.3 7.362 L 9.895 0.723 L 6.972 0.812 L 7.202 7.555 L 6.426 7.761 L 4.919 6.032 L 6.887 4.042 L 5.885 2.695 L 2.298 6.329 L 5.237 11.337 L 5.192 19.296 Z" ] []


viewSpinner : Int -> Svg msg -> Svg msg
viewSpinner percentage icon =
    svg
        [ Svg.Attributes.viewBox "-1 -1 34 34"
        , Svg.Attributes.class "radial-progress"
        ]
        [ Svg.circle
            [ Svg.Attributes.stroke "magenta"
            , Svg.Attributes.fill "none"
            , Svg.Attributes.transform "rotate(90, 16, 16)"
            , Svg.Attributes.strokeWidth "2.4"
            , Svg.Attributes.strokeLinecap "round"
            , Svg.Attributes.cx "16"
            , Svg.Attributes.cy "16"
            , Svg.Attributes.r "15.9155"
            , Svg.Attributes.shapeRendering "geometricPrecision"
            , Svg.Attributes.strokeDasharray ((clamp 0 100 percentage |> String.fromInt) ++ ", 100")
            ]
            []
        , Svg.g
            [ Svg.Attributes.transform "translate(6, 6)"
            , Svg.Attributes.class "radial-progress-icon"
            ]
            [ icon ]
        ]


qrCodeView : String -> Html msg
qrCodeView message =
    QRCode.fromString message
        |> Result.map
            (QRCode.toSvg
                [ Svg.Attributes.width "300px"
                , Svg.Attributes.height "300px"
                , Svg.Attributes.shapeRendering "crispEdges"
                ]
            )
        |> Result.withDefault (Html.text "Error while encoding to QRCode.")
