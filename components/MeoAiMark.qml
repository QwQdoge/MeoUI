import QtQuick

/// Canonical Meo AI identity mark.
///
/// This fixed brand mark intentionally does not inherit a dynamic scheme: the
/// supplied lavender field, filled monogram, and curved sparkle are the AI
/// identity itself rather than a generic Material icon.
Item {
    id: root

    property color containerColor: "#A289ED"
    property color markColor: "#FFFFFF"
    // Units are relative to the 64-by-64 canonical drawing grid.
    property real cornerRadius: 14.5

    implicitWidth: 48
    implicitHeight: 48

    Accessible.role: Accessible.Graphic
    Accessible.name: qsTr("AI")

    onContainerColorChanged: canvas.requestPaint()
    onMarkColorChanged: canvas.requestPaint()
    onCornerRadiusChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            const sx = width / 64
            const sy = height / 64
            const s = Math.min(sx, sy)
            const ox = (width - 64 * s) / 2
            const oy = (height - 64 * s) / 2

            function x(value) { return ox + value * s }
            function y(value) { return oy + value * s }

            function roundedRect(left, top, rectWidth, rectHeight, radius) {
                const right = left + rectWidth
                const bottom = top + rectHeight
                ctx.beginPath()
                ctx.moveTo(left + radius, top)
                ctx.lineTo(right - radius, top)
                ctx.quadraticCurveTo(right, top, right, top + radius)
                ctx.lineTo(right, bottom - radius)
                ctx.quadraticCurveTo(right, bottom, right - radius, bottom)
                ctx.lineTo(left + radius, bottom)
                ctx.quadraticCurveTo(left, bottom, left, bottom - radius)
                ctx.lineTo(left, top + radius)
                ctx.quadraticCurveTo(left, top, left + radius, top)
                ctx.closePath()
            }

            ctx.fillStyle = root.containerColor.toString()
            const radius = Math.min(root.cornerRadius * s, 30 * s)
            roundedRect(ox, oy, 64 * s, 64 * s, radius)
            ctx.fill()

            // Filled A contour: it deliberately has the substantial, rounded
            // lower bar of the canonical artwork instead of a thin type glyph.
            ctx.fillStyle = root.markColor.toString()
            ctx.beginPath()
            ctx.moveTo(x(10.8), y(43.6))
            ctx.lineTo(x(20.8), y(24.1))
            ctx.bezierCurveTo(x(21.9), y(22.0), x(23.5), y(21.5), x(25.5), y(21.5))
            ctx.bezierCurveTo(x(27.5), y(21.5), x(29.1), y(22.1), x(30.2), y(24.1))
            ctx.lineTo(x(40.2), y(43.7))
            ctx.bezierCurveTo(x(41.7), y(46.7), x(40.5), y(49.3), x(37.9), y(49.3))
            ctx.bezierCurveTo(x(36.2), y(49.3), x(35.0), y(48.4), x(34.2), y(46.8))
            ctx.lineTo(x(25.5), y(29.8))
            ctx.lineTo(x(18.6), y(43.2))
            ctx.lineTo(x(25.2), y(43.2))
            ctx.bezierCurveTo(x(27.8), y(43.2), x(29.6), y(44.5), x(29.6), y(46.25))
            ctx.bezierCurveTo(x(29.6), y(48.0), x(27.8), y(49.3), x(25.2), y(49.3))
            ctx.lineTo(x(15.2), y(49.3))
            ctx.bezierCurveTo(x(12.0), y(49.3), x(9.4), y(46.7), x(10.8), y(43.6))
            ctx.closePath()
            ctx.fill()

            roundedRect(x(41.85), y(21.5), 6.9 * s, 27.8 * s, 3.45 * s)
            ctx.fill()

            // Curved four-point star, matching the supplied identity artwork.
            ctx.beginPath()
            ctx.moveTo(x(51.9), y(8.6))
            ctx.bezierCurveTo(x(52.55), y(11.35), x(53.55), y(12.85), x(56.9), y(13.65))
            ctx.bezierCurveTo(x(53.55), y(14.45), x(52.55), y(15.95), x(51.9), y(18.55))
            ctx.bezierCurveTo(x(51.25), y(15.95), x(50.25), y(14.45), x(46.9), y(13.65))
            ctx.bezierCurveTo(x(50.25), y(12.85), x(51.25), y(11.35), x(51.9), y(8.6))
            ctx.closePath()
            ctx.fill()
        }
    }
}
