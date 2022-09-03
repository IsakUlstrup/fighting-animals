module View.Svg exposing (viewSpinner)

import Svg exposing (Svg, svg)
import Svg.Attributes


viewSpinner : Int -> Char -> Svg msg
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
        , Svg.text_
            [ Svg.Attributes.x "16"
            , Svg.Attributes.y "16"
            , Svg.Attributes.textAnchor "middle"
            , Svg.Attributes.dominantBaseline "middle"
            , Svg.Attributes.fill "#262626"
            , Svg.Attributes.fontFamily "sans-serif"
            , Svg.Attributes.fontSize "18px"
            ]
            [ Svg.text <| String.fromChar icon ]
        ]
