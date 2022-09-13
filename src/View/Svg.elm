module View.Svg exposing (qrCodeView)

import Html exposing (Html)
import QRCode
import Svg.Attributes


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
