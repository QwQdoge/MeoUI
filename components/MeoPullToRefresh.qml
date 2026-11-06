import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import MeoUI

Control {
    id: control

    // AndroidX PullToRefresh.kt models nested-scroll ownership at the container
    // level. Qt callers retain that ownership and bind their scroll gesture to
    // this reusable indicator's pullDistance.
    property bool refreshing: false
    property real pullDistance: 0.0
    property real positionalThreshold: 80 * themeGlobalScale
    property bool pullEnabled: true

    signal refreshRequested()

    readonly property color themeSurfaceContainerHigh: MeoTheme.surfaceContainerHigh
    readonly property color themeIndicatorColor: MeoTheme.contentOnSurfaceVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real distanceFraction: Math.max(0, pullDistance)
    readonly property real visibleFraction: Math.min(1, distanceFraction)
    readonly property bool indicatorVisible: refreshing || (pullEnabled && distanceFraction > 0)
    readonly property bool animationActive: refreshing && visible && width > 0 && height > 0 && !MeoTheme.reduceMotion
    readonly property int indeterminateCycleDuration: MeoTheme.motionDurationIndeterminateCycle

    implicitWidth: 40 * themeGlobalScale
    implicitHeight: 40 * themeGlobalScale
    Accessible.role: Accessible.ProgressBar
    Accessible.name: refreshing
                     ? qsTr("Refreshing")
                     : qsTr("Pull to refresh %1 percent").arg(Math.round(visibleFraction * 100))

    function release() {
        if (pullEnabled && !refreshing && distanceFraction >= 1)
            refreshRequested()
    }

    // MD3 Pull-to-refresh container: circular elevated surface
    background: Item {
        // Elevation Shadow (Standard MD3 Level 2 for pull-to-refresh). The
        // caster owns the blur layer; the spinning indicator lives on the
        // surface above it, so the blur is not recomputed every frame.
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: control.themeSurfaceContainerHigh
            visible: control.indicatorVisible && control.opacity > 0
            layer.enabled: visible
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.2
                shadowVerticalOffset: 2 * control.themeGlobalScale
                shadowColor: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b, 0.2)
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: control.themeSurfaceContainerHigh

            // Indeterminate Progress (using the logic from MeoProgressBar circular type)
            // GPU-tessellated arc (QtQuick.Shapes curve renderer) instead of a
            // Canvas, so the refresh spinner does not rasterize on the CPU and
            // upload a texture every frame.
            Shape {
                id: indicatorCanvas
                anchors.fill: parent
                anchors.margins: 8 * control.themeGlobalScale
                preferredRendererType: Shape.CurveRenderer
                opacity: control.refreshing ? 1 : Math.max(0.3, control.visibleFraction)

                property real startAngle: 0
                property real endAngle: control.refreshing ? 0.2 : (control.pullDistance * 0.8)
                property real rotationAngle: 0

                // Internal state to avoid binding destruction
                property real animStartAngle: 0
                property real animEndAngle: 0
                property real animRotationAngle: 0

                readonly property real strokeWidth: 2.5 * control.themeGlobalScale
                readonly property real arcRadius: Math.max(0, (width - strokeWidth) / 2)
                readonly property real resolvedStart: control.refreshing ? animStartAngle : startAngle
                readonly property real resolvedEnd: control.refreshing ? animEndAngle : endAngle
                readonly property real resolvedRotation: control.refreshing ? animRotationAngle : rotationAngle
                // Turns -> degrees, 0 at 12 o'clock, clockwise.
                readonly property real arcStartDegrees: (resolvedStart + resolvedRotation) * 360 - 90
                readonly property real arcSweepDegrees: Math.max(0, Math.min(359.9, (resolvedEnd - resolvedStart) * 360))
                readonly property real arcEndRadians: (arcStartDegrees + arcSweepDegrees) * Math.PI / 180
                readonly property bool showArrow: !control.refreshing && control.distanceFraction > 0.4
                readonly property real arrowSize: 4 * control.themeGlobalScale
                readonly property real arrowTipX: width / 2 + arcRadius * Math.cos(arcEndRadians)
                readonly property real arrowTipY: height / 2 + arcRadius * Math.sin(arcEndRadians)
                // Arrow arms: local (-s, sign * s) rotated by the end angle around the tip.
                function armX(sign) {
                    return arrowTipX - arrowSize * Math.cos(arcEndRadians) - sign * arrowSize * Math.sin(arcEndRadians)
                }
                function armY(sign) {
                    return arrowTipY - arrowSize * Math.sin(arcEndRadians) + sign * arrowSize * Math.cos(arcEndRadians)
                }

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: indicatorCanvas.arcSweepDegrees > 0 && indicatorCanvas.arcRadius > 0
                                 ? control.themeIndicatorColor : "transparent"
                    strokeWidth: indicatorCanvas.strokeWidth
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: indicatorCanvas.width / 2
                        centerY: indicatorCanvas.height / 2
                        radiusX: indicatorCanvas.arcRadius
                        radiusY: indicatorCanvas.arcRadius
                        startAngle: indicatorCanvas.arcStartDegrees
                        sweepAngle: indicatorCanvas.arcSweepDegrees
                    }
                }

                // Arrowhead while pulling.
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: indicatorCanvas.showArrow ? control.themeIndicatorColor : "transparent"
                    strokeWidth: indicatorCanvas.strokeWidth
                    capStyle: ShapePath.RoundCap
                    startX: indicatorCanvas.armX(-1)
                    startY: indicatorCanvas.armY(-1)
                    PathLine { x: indicatorCanvas.arrowTipX; y: indicatorCanvas.arrowTipY }
                    PathLine { x: indicatorCanvas.armX(1); y: indicatorCanvas.armY(1) }
                }

                // Indeterminate animation
                SequentialAnimation {
                    running: control.animationActive
                    loops: Animation.Infinite

                    ParallelAnimation {
                        NumberAnimation { target: indicatorCanvas; property: "animStartAngle"; from: 0; to: 0.75; duration: control.indeterminateCycleDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
                        NumberAnimation { target: indicatorCanvas; property: "animEndAngle"; from: 0.2; to: 0.95; duration: control.indeterminateCycleDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
                        NumberAnimation { target: indicatorCanvas; property: "animRotationAngle"; from: 0; to: 0.5; duration: control.indeterminateCycleDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingLinear }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: indicatorCanvas; property: "animStartAngle"; from: 0.75; to: 1.5; duration: control.indeterminateCycleDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
                        NumberAnimation { target: indicatorCanvas; property: "animEndAngle"; from: 0.95; to: 1.7; duration: control.indeterminateCycleDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
                        NumberAnimation { target: indicatorCanvas; property: "animRotationAngle"; from: 0.5; to: 1.0; duration: control.indeterminateCycleDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingLinear }
                    }
                    ScriptAction { script: { indicatorCanvas.animStartAngle %= 1.0; indicatorCanvas.animEndAngle %= 1.0; indicatorCanvas.animRotationAngle %= 1.0; } }
                }
            }
        }
    }

    // Scale and opacity transitions
    scale: indicatorVisible ? 1.0 : 0.8
    opacity: indicatorVisible ? 1.0 : 0.0
    Behavior on scale {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: MeoTheme.motionDurationEffectDefault; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
    }
    Behavior on opacity {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: MeoTheme.motionDurationEffectDefault; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
    }
}
