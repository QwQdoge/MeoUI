import QtQuick
import MeoUI
import "MeoMaterialShapes.js" as ShapesEngine

Item {
    id: control

    // 🌟 M3E Expressive 35 Shape API & Semantic Radius Support
    property string type: "squircle"
    property color color: "transparent"
    property real radius: 12 * themeGlobalScale
    property color strokeColor: "transparent"
    property real strokeWidth: 0
    property real rotationAngle: 0.0

    readonly property real themeGlobalScale: MeoTheme.globalScale

    // Debounce repaint to avoid excessive canvas updates when many shapes change
    Timer {
        id: repaintTimer
        interval: 16 // ~60fps
        repeat: false
        onTriggered: canvas.requestPaint()
    }
    onRadiusChanged: repaintTimer.restart()
    onTypeChanged: repaintTimer.restart()
    onColorChanged: repaintTimer.restart()
    onStrokeColorChanged: repaintTimer.restart()
    onStrokeWidthChanged: repaintTimer.restart()
    onRotationAngleChanged: repaintTimer.restart()
    onWidthChanged: repaintTimer.restart()
    onHeightChanged: repaintTimer.restart()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        function tracePath(ctx, inset) {
            var w = Math.max(0, width - inset * 2);
            var h = Math.max(0, height - inset * 2);
            var ox = inset;
            var oy = inset;

            ctx.beginPath();

            var simpleType = String(control.type).toLowerCase();
            if (simpleType === "rect" || simpleType === "round" || simpleType === "squircle") {
                // Semantic Radius Calculation: min(radius, w/2, h/2)
                var r = Math.max(0, Math.min(control.radius - inset, Math.min(w, h) / 2));
                ctx.roundedRect(ox, oy, w, h, r, r);
            } else if (simpleType === "circle") {
                var circleRadius = Math.min(w, h) / 2;
                ctx.arc(ox + w / 2, oy + h / 2, circleRadius, 0, 2 * Math.PI);
            } else {
                // Render from M3E 35 Normalized Geometry Vector Engine
                var pts = ShapesEngine.getNormalizedPathPoints(control.type);
                if (pts && pts.length > 0) {
                    var cx = ox + w / 2;
                    var cy = oy + h / 2;
                    var rad = (control.rotationAngle * Math.PI) / 180;

                    for (var i = 0; i < pts.length; i++) {
                        // Normalize 0..1 to bounds
                        var rawX = ox + pts[i].x * w - cx;
                        var rawY = oy + pts[i].y * h - cy;

                        // Apply Rotation
                        var rx = cx + rawX * Math.cos(rad) - rawY * Math.sin(rad);
                        var ry = cy + rawX * Math.sin(rad) + rawY * Math.cos(rad);

                        if (i === 0) ctx.moveTo(rx, ry);
                        else ctx.lineTo(rx, ry);
                    }
                    ctx.closePath();
                } else {
                    ctx.roundedRect(ox, oy, w, h, Math.min(w, h) / 2, Math.min(w, h) / 2);
                }
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            if (control.color !== "transparent" && control.color.a > 0) {
                ctx.fillStyle = control.color;
                tracePath(ctx, 0);
                ctx.fill();
            }

            if (control.strokeColor !== "transparent" && control.strokeWidth > 0 && control.strokeColor.a > 0) {
                ctx.strokeStyle = control.strokeColor;
                ctx.lineWidth = control.strokeWidth;
                tracePath(ctx, control.strokeWidth / 2);
                ctx.stroke();
            }
        }
    }
}
