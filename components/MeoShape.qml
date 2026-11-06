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

    // rect/round/squircle/circle are drawn with native scene-graph rectangles:
    // no JS paint pass, no per-instance raster texture, crisp at any scale and
    // resized in the same frame as their content. Only the expressive
    // Material shape catalog needs the Canvas path renderer.
    readonly property string _normalizedType: String(type).toLowerCase()
    readonly property bool _circle: _normalizedType === "circle"
    readonly property bool _native: _circle || _normalizedType === "rect"
                                    || _normalizedType === "round"
                                    || _normalizedType === "squircle"
    readonly property real _nativeWidth: _circle ? Math.min(width, height) : width
    readonly property real _nativeHeight: _circle ? Math.min(width, height) : height
    readonly property real _nativeRadius: _circle
                                          ? _nativeWidth / 2
                                          : Math.max(0, Math.min(radius, Math.min(width, height) / 2))
    readonly property bool _hasFill: color.a > 0
    readonly property bool _hasStroke: strokeWidth > 0 && strokeColor.a > 0

    // Canvas.requestPaint() already coalesces any number of property changes
    // into one paint on the next frame. A separate 16 ms debounce timer only
    // added a frame of latency, so the shape visibly trailed its content
    // during resize/morph animations.
    function _requestRepaint() {
        if (canvasLoader.item)
            canvasLoader.item.requestPaint()
    }
    onRadiusChanged: _requestRepaint()
    onTypeChanged: _requestRepaint()
    onColorChanged: _requestRepaint()
    onStrokeColorChanged: _requestRepaint()
    onStrokeWidthChanged: _requestRepaint()
    onRotationAngleChanged: _requestRepaint()
    onWidthChanged: _requestRepaint()
    onHeightChanged: _requestRepaint()

    // Fill and stroke are separate rectangles so a translucent stroke blends
    // over the fill exactly like the Canvas renderer (fill, then an inset
    // stroke on top).
    Rectangle {
        visible: control._native && control._hasFill
        anchors.centerIn: parent
        width: control._nativeWidth
        height: control._nativeHeight
        radius: control._nativeRadius
        color: control.color
        antialiasing: true
    }

    Rectangle {
        visible: control._native && control._hasStroke
        anchors.centerIn: parent
        width: control._nativeWidth
        height: control._nativeHeight
        radius: control._nativeRadius
        color: "transparent"
        border.width: control.strokeWidth
        border.color: control.strokeColor
        antialiasing: true
    }

    Loader {
        id: canvasLoader
        anchors.fill: parent
        active: !control._native
        sourceComponent: Canvas {
            id: canvas
            antialiasing: true

            function tracePath(ctx, inset) {
                var w = Math.max(0, width - inset * 2);
                var h = Math.max(0, height - inset * 2);
                var ox = inset;
                var oy = inset;

                ctx.beginPath();

                // Render from M3E 35 Normalized Geometry Vector Engine
                var pts = ShapesEngine.getNormalizedPathPoints(control.type);
                if (pts && pts.length > 0) {
                    var cx = ox + w / 2;
                    var cy = oy + h / 2;
                    var rad = (control.rotationAngle * Math.PI) / 180;
                    var cos = Math.cos(rad);
                    var sin = Math.sin(rad);

                    for (var i = 0; i < pts.length; i++) {
                        // Normalize 0..1 to bounds
                        var rawX = ox + pts[i].x * w - cx;
                        var rawY = oy + pts[i].y * h - cy;

                        // Apply Rotation
                        var rx = cx + rawX * cos - rawY * sin;
                        var ry = cy + rawX * sin + rawY * cos;

                        if (i === 0) ctx.moveTo(rx, ry);
                        else ctx.lineTo(rx, ry);
                    }
                    ctx.closePath();
                } else {
                    ctx.roundedRect(ox, oy, w, h, Math.min(w, h) / 2, Math.min(w, h) / 2);
                }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                if (control._hasFill) {
                    ctx.fillStyle = control.color;
                    tracePath(ctx, 0);
                    ctx.fill();
                }

                if (control._hasStroke) {
                    ctx.strokeStyle = control.strokeColor;
                    ctx.lineWidth = control.strokeWidth;
                    tracePath(ctx, control.strokeWidth / 2);
                    ctx.stroke();
                }
            }
        }
    }
}
