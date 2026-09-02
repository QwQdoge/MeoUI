import QtQuick
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
    // the Canvas through a negative scale.
    readonly property real clampedRawSpringProgress: Math.max(-1, Math.min(2, rawSpringProgress))

    onMorphProgressChanged: canvas.requestPaint()
    onFromShapeChanged: canvas.requestPaint()
    onToShapeChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onStrokeColorChanged: canvas.requestPaint()
    onStrokeWidthChanged: canvas.requestPaint()
    onRotationAngleChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        objectName: "meoShapeMorphCanvas"
        anchors.fill: parent
        antialiasing: true

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

        function tracePath(ctx, inset, interpolatedPts) {
            var w = Math.max(0, width - inset * 2);
            var h = Math.max(0, height - inset * 2);
            var cx = inset + w / 2;
            var cy = inset + h / 2;
            var rad = (control.rotationAngle * Math.PI) / 180;

            ctx.beginPath();
            for (var i = 0; i < interpolatedPts.length; i++) {
                var rawX = inset + interpolatedPts[i].x * w - cx;
                var rawY = inset + interpolatedPts[i].y * h - cy;
                var rx = cx + rawX * Math.cos(rad) - rawY * Math.sin(rad);
                var ry = cy + rawX * Math.sin(rad) + rawY * Math.cos(rad);

                if (i === 0) ctx.moveTo(rx, ry);
                else ctx.lineTo(rx, ry);
            }
            ctx.closePath();
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            // Clamped morph progress to prevent path self-intersection / folding
            var clampedT = Math.max(0.0, Math.min(1.0, control.morphProgress));
            var interpolatedPts = ShapesEngine.interpolateShapes(control.fromShape, control.toShape, clampedT);

            if (!interpolatedPts || interpolatedPts.length === 0) return;

            if (control.color !== "transparent" && control.color.a > 0) {
                ctx.fillStyle = control.color;
                tracePath(ctx, 0, interpolatedPts);
                ctx.fill();
            }

            if (control.strokeColor !== "transparent" && control.strokeWidth > 0 && control.strokeColor.a > 0) {
                ctx.strokeStyle = control.strokeColor;
                ctx.lineWidth = control.strokeWidth;
                tracePath(ctx, control.strokeWidth / 2, interpolatedPts);
                ctx.stroke();
            }
        }
    }
}
