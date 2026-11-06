import QtQuick
import QtQuick.Shapes
import MeoUI
import "MeoMaterialShapes.js" as ShapesEngine

Item {
    id: control

    // 🌟 M3E Continuous Shape Morph Engine API
    property string fromShape: "SoftBurst"
    property string toShape: "Cookie9Sided"
    property real morphProgress: 0.0 // 0.0 ~ 1.0 (clamped for path topology)
    property real rawSpringProgress: 0.0 // Raw spring with overshoot for scale bounce
    property color color: MeoTheme.primary
    property color strokeColor: "transparent"
    property real strokeWidth: 0
    property real rotationAngle: 0.0

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool reduceMotion: MeoTheme.reduceMotion
    // Morph topology is always clamped independently below.  Clamp the
    // optional raw spring too, so an unbounded animation value cannot invert
    // the shape through a negative scale.
    readonly property real clampedRawSpringProgress: Math.max(-1, Math.min(2, rawSpringProgress))

    // Normalized morph geometry; recomputed only when the topology inputs
    // change. Rotation is a scene-graph transform on the Shape below, so a
    // spinning indicator no longer rebuilds or re-rasterizes the path.
    readonly property var _morphPoints: ShapesEngine.interpolateShapes(
                                            fromShape, toShape,
                                            Math.max(0.0, Math.min(1.0, morphProgress)))
    readonly property bool _hasFill: color.a > 0
    readonly property bool _hasStroke: strokeWidth > 0 && strokeColor.a > 0

    function _pathPoints(inset, close) {
        var pts = control._morphPoints
        var out = []
        if (!pts || pts.length === 0)
            return out
        var w = Math.max(0, width - inset * 2)
        var h = Math.max(0, height - inset * 2)
        for (var i = 0; i < pts.length; i++)
            out.push(Qt.point(inset + pts[i].x * w, inset + pts[i].y * h))
        if (close)
            out.push(out[0])
        return out
    }

    // GPU-tessellated path (QtQuick.Shapes curve renderer) instead of a
    // Canvas raster that was re-uploaded as a texture on every frame.
    Shape {
        id: canvas
        objectName: "meoShapeMorphCanvas"
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        rotation: control.rotationAngle

        // Scale bounce is deliberately restrained and disabled with reduced
        // motion.  It is a visual flourish only; the path itself is never
        // allowed to overshoot or self-intersect.
        scale: {
            if (control.reduceMotion)
                return 1.0;
            if (control.clampedRawSpringProgress > 1.0) {
                return 1.0 + 0.12 * (control.clampedRawSpringProgress - 1.0);
            } else if (control.clampedRawSpringProgress < 0.0) {
                return 1.0 + 0.08 * control.clampedRawSpringProgress;
            }
            return 1.0;
        }

        ShapePath {
            fillColor: control._hasFill ? control.color : "transparent"
            strokeColor: "transparent"
            strokeWidth: -1
            PathPolyline { path: control._hasFill ? control._pathPoints(0, false) : [] }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: control._hasStroke ? control.strokeColor : "transparent"
            strokeWidth: control._hasStroke ? control.strokeWidth : -1
            joinStyle: ShapePath.MiterJoin
            capStyle: ShapePath.FlatCap
            PathPolyline { path: control._hasStroke ? control._pathPoints(control.strokeWidth / 2, true) : [] }
        }
    }
}
