import QtQuick
import QtQuick.Controls
import QtQuick.Effects
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
    background: Rectangle {
        radius: width / 2
        color: control.themeSurfaceContainerHigh

        // Elevation Shadow (Standard MD3 Level 2 for pull-to-refresh)
        layer.enabled: control.indicatorVisible && control.opacity > 0
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: 2 * control.themeGlobalScale
            shadowColor: Qt.rgba(0,0,0,0.2)
        }

        // Indeterminate Progress (using the logic from MeoProgressBar circular type)
        Canvas {
            id: indicatorCanvas
            anchors.fill: parent
            anchors.margins: 8 * control.themeGlobalScale

            property real startAngle: 0
            property real endAngle: control.refreshing ? 0.2 : (control.pullDistance * 0.8)
            property real rotationAngle: 0

            // Internal state to avoid binding destruction
            property real animStartAngle: 0
            property real animEndAngle: 0
            property real animRotationAngle: 0

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var centerX = width / 2;
                var centerY = height / 2;
                var strokeWidth = 2.5 * control.themeGlobalScale;
                var radius = (width - strokeWidth) / 2;

                ctx.beginPath();
                ctx.strokeStyle = control.themeIndicatorColor;
                ctx.lineWidth = strokeWidth;
                ctx.lineCap = "round";
                ctx.globalAlpha = control.refreshing ? 1 : Math.max(0.3, control.visibleFraction);

                var sA, eA, rA;
                if (control.refreshing) {
                    sA = animStartAngle;
                    eA = animEndAngle;
                    rA = animRotationAngle;
                } else {
                    sA = startAngle;
                    eA = endAngle;
                    rA = rotationAngle;
                }

                // Draw arc based on pull progress or rotation
                var start = (sA + rA) * 2 * Math.PI - 0.5 * Math.PI;
                var end = (eA + rA) * 2 * Math.PI - 0.5 * Math.PI;

                ctx.arc(centerX, centerY, radius, start, end);
                ctx.stroke();

                // Draw arrowhead when pulling
                if (!control.refreshing && control.distanceFraction > 0.4) {
                    var arrowAngle = end;
                    var arrowSize = 4 * control.themeGlobalScale;
                    ctx.save();
                    ctx.translate(centerX + radius * Math.cos(arrowAngle), centerY + radius * Math.sin(arrowAngle));
                    ctx.rotate(arrowAngle);
                    ctx.beginPath();
                    ctx.moveTo(-arrowSize, -arrowSize);
                    ctx.lineTo(0, 0);
                    ctx.lineTo(-arrowSize, arrowSize);
                    ctx.stroke();
                    ctx.restore();
                }
            }

            onStartAngleChanged: requestPaint()
            onEndAngleChanged: requestPaint()
            onRotationAngleChanged: requestPaint()
            onAnimStartAngleChanged: requestPaint()
            onAnimEndAngleChanged: requestPaint()
            onAnimRotationAngleChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            // Indeterminate animation
            SequentialAnimation {
                running: control.animationActive
                loops: Animation.Infinite

                ParallelAnimation {
                    NumberAnimation { target: indicatorCanvas; property: "animStartAngle"; from: 0; to: 0.75; duration: 666; easing.type: Easing.InOutSine }
                    NumberAnimation { target: indicatorCanvas; property: "animEndAngle"; from: 0.2; to: 0.95; duration: 666; easing.type: Easing.InOutSine }
                    NumberAnimation { target: indicatorCanvas; property: "animRotationAngle"; from: 0; to: 0.5; duration: 666; easing.type: Easing.Linear }
                }
                ParallelAnimation {
                    NumberAnimation { target: indicatorCanvas; property: "animStartAngle"; from: 0.75; to: 1.5; duration: 666; easing.type: Easing.InOutSine }
                    NumberAnimation { target: indicatorCanvas; property: "animEndAngle"; from: 0.95; to: 1.7; duration: 666; easing.type: Easing.InOutSine }
                    NumberAnimation { target: indicatorCanvas; property: "animRotationAngle"; from: 0.5; to: 1.0; duration: 666; easing.type: Easing.Linear }
                }
                ScriptAction { script: { indicatorCanvas.animStartAngle %= 1.0; indicatorCanvas.animEndAngle %= 1.0; indicatorCanvas.animRotationAngle %= 1.0; } }
            }
        }
    }

    // Scale and opacity transitions
    scale: indicatorVisible ? 1.0 : 0.8
    opacity: indicatorVisible ? 1.0 : 0.0
    Behavior on scale {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: MeoTheme.motionDurationEffectDefault; easing.bezierCurve: MeoTheme.motionEasingStandard }
    }
    Behavior on opacity {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: MeoTheme.motionDurationEffectDefault; easing.bezierCurve: MeoTheme.motionEasingStandard }
    }
}
