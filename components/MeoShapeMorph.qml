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
    property color color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    property color strokeColor: "transparent"
    property real strokeWidth: 0
    property real rotationAngle: 0.0

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    onMorphProgressChanged: canvas.requestPaint()
    onFromShapeChanged: canvas.requestPaint()
    onToShapeChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onRotationAngleChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent

        // Scale bounce for spring overshoot (when rawSpringProgress > 1.0 or < 0.0)
        scale: {
            if (control.rawSpringProgress > 1.0) {
                return 1.0 + 0.15 * (control.rawSpringProgress - 1.0);
            } else if (control.rawSpringProgress < 0.0) {
                return 1.0 + 0.15 * control.rawSpringProgress;
            }
            return 1.0;
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var w = width;
            var h = height;
            var cx = w / 2;
            var cy = h / 2;
            var rad = (control.rotationAngle * Math.PI) / 180;

            // Clamped morph progress to prevent path self-intersection / folding
            var clampedT = Math.max(0.0, Math.min(1.0, control.morphProgress));
            var interpolatedPts = ShapesEngine.interpolateShapes(control.fromShape, control.toShape, clampedT);

            if (!interpolatedPts || interpolatedPts.length === 0) return;

            ctx.beginPath();
            for (var i = 0; i < interpolatedPts.length; i++) {
                var rawX = interpolatedPts[i].x * w - cx;
                var rawY = interpolatedPts[i].y * h - cy;

                var rx = cx + rawX * Math.cos(rad) - rawY * Math.sin(rad);
                var ry = cy + rawX * Math.sin(rad) + rawY * Math.cos(rad);

                if (i === 0) ctx.moveTo(rx, ry);
                else ctx.lineTo(rx, ry);
            }
            ctx.closePath();

            if (control.color !== "transparent" && control.color.a > 0) {
                ctx.fillStyle = control.color;
                ctx.fill();
            }

            if (control.strokeColor !== "transparent" && control.strokeWidth > 0 && control.strokeColor.a > 0) {
                ctx.strokeStyle = control.strokeColor;
                ctx.lineWidth = control.strokeWidth;
                ctx.stroke();
            }
        }
    }
}
