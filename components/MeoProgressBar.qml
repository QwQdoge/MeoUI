import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // Progress model
    property real value: 0.0 // 0.0 ~ 1.0
    property bool indeterminate: false
    property string type: "linear" // "linear" | "circular"
    property bool wavy: false
    property bool isThick: false
    property bool vibrant: false
    property bool showTrack: true

    // Linear presentation. Thick indicators opt into the Android 16-style
    // split pill by default, while thin indicators stay backwards compatible.
    property string linearStyle: isThick ? "pill" : "standard" // "standard" | "pill"
    property string leadingIcon: ""
    property bool leadingIconEnabled: leadingIcon.length > 0

    property color activeColor: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined")
                                ? MeoTheme.primary : "#6750A4"
    property color trackColor: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerHighest !== "undefined")
                               ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    property color pillActiveColor: vibrant ? activeColor : (themeIsDarkMode ? themePrimary : themePrimaryContainer)
    property color pillTrackColor: themeIsDarkMode ? themeSurfaceContainerLow : themeSurfaceContainerHighest
    property color pillMarkerColor: pillActiveColor

    readonly property bool themeIsDarkMode: (typeof MeoTheme !== "undefined" && typeof MeoTheme.isDarkMode !== "undefined")
                                            ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined")
                                          ? MeoTheme.primary : "#6750A4"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primaryContainer !== "undefined")
                                                   ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnPrimary !== "undefined")
                                            ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnPrimaryContainer !== "undefined")
                                                     ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined")
                                                      ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerHighest !== "undefined")
                                                          ? MeoTheme.surfaceContainerHighest : "#E6E0E9"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined")
                                             ? MeoTheme.globalScale : 1.0
    readonly property real themeMotionScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionScale !== "undefined")
                                             ? MeoTheme.motionScale : 1.0
    readonly property bool reduceMotion: (typeof MeoTheme !== "undefined" && typeof MeoTheme.reduceMotion !== "undefined")
                                         ? MeoTheme.reduceMotion : false
    readonly property int motionDuration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationEffectDefault !== "undefined")
                                          ? MeoTheme.motionDurationEffectDefault : 150
    readonly property var motionEasing: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined")
                                        ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]

    readonly property real clampedValue: Math.max(0, Math.min(1, value))
    readonly property real linearWavelength: 40 * themeGlobalScale
    readonly property real linearAmplitude: reduceMotion ? 0 : 3 * themeGlobalScale
    readonly property real circularWavelengthTarget: 15 * themeGlobalScale
    readonly property real circularAmplitude: reduceMotion ? 0 : 2 * themeGlobalScale
    readonly property real strokeThickness: 4 * themeGlobalScale

    readonly property real pillHeight: (isThick ? 28 : 24) * themeGlobalScale
    readonly property real pillGap: 6 * themeGlobalScale
    readonly property real pillMarkerWidth: 4 * themeGlobalScale
    readonly property real pillMarkerHeight: pillHeight + 8 * themeGlobalScale

    implicitWidth: type === "linear"
                   ? 240 * themeGlobalScale
                   : (wavy ? 48 * themeGlobalScale : 40 * themeGlobalScale)
    implicitHeight: type === "linear"
                    ? (wavy
                       ? 10 * themeGlobalScale
                       : (linearStyle === "pill"
                          ? pillMarkerHeight
                          : (isThick ? 8 : 4) * themeGlobalScale))
                    : (wavy ? 48 * themeGlobalScale : 40 * themeGlobalScale)

    // One wavelength per second. Reduced motion freezes the waveform without
    // changing geometry.
    property real wavePhase: 0.0
    NumberAnimation on wavePhase {
        running: control.wavy && control.visible && !control.reduceMotion
        loops: Animation.Infinite
        from: 0.0
        to: 1.0
        duration: Math.max(1, Math.round(1000 * control.themeMotionScale))
    }

    Canvas {
        id: wavyCanvas
        anchors.fill: parent
        visible: control.wavy

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var w = width
            var h = height
            if (w <= 0 || h <= 0)
                return

            var stroke = control.strokeThickness
            var phase = control.wavePhase

            if (control.type === "linear") {
                var centerY = h / 2
                var linearAmp = control.linearAmplitude
                var wl = control.linearWavelength

                if (control.showTrack) {
                    ctx.strokeStyle = control.trackColor
                    ctx.lineWidth = stroke
                    ctx.lineCap = "round"
                    ctx.beginPath()
                    ctx.moveTo(0, centerY)
                    ctx.lineTo(w, centerY)
                    ctx.stroke()
                }

                var activeW = w * (control.indeterminate ? 0.6 : control.clampedValue)
                if (activeW > 0) {
                    ctx.strokeStyle = control.activeColor
                    ctx.lineWidth = stroke
                    ctx.lineCap = "round"
                    ctx.beginPath()

                    for (var x = 0; x <= activeW; x += 2) {
                        var y = centerY + linearAmp * Math.sin(2 * Math.PI * (x / wl - phase))
                        if (x === 0)
                            ctx.moveTo(x, y)
                        else
                            ctx.lineTo(x, y)
                    }
                    ctx.stroke()

                    ctx.fillStyle = control.activeColor
                    ctx.beginPath()
                    ctx.arc(activeW, centerY, stroke / 2, 0, 2 * Math.PI)
                    ctx.fill()
                }
            } else {
                var circularAmp = control.circularAmplitude
                var radius = (Math.min(w, h) - stroke - circularAmp * 2) / 2
                var cx = w / 2
                var cy = h / 2
                var circumference = 2 * Math.PI * radius
                var waveCount = Math.max(3, Math.round(circumference / control.circularWavelengthTarget))

                if (control.showTrack) {
                    ctx.strokeStyle = control.trackColor
                    ctx.lineWidth = stroke
                    ctx.beginPath()
                    ctx.arc(cx, cy, radius, 0, 2 * Math.PI)
                    ctx.stroke()
                }

                var activeAngle = 2 * Math.PI * (control.indeterminate ? 0.75 : control.clampedValue)
                if (activeAngle > 0) {
                    ctx.strokeStyle = control.activeColor
                    ctx.lineWidth = stroke
                    ctx.lineCap = "round"
                    ctx.beginPath()

                    var step = Math.PI / 60
                    for (var angle = -Math.PI / 2;
                         angle <= -Math.PI / 2 + activeAngle;
                         angle += step) {
                        var currentRadius = radius
                                + circularAmp * Math.sin(waveCount * angle - 2 * Math.PI * phase)
                        var px = cx + currentRadius * Math.cos(angle)
                        var py = cy + currentRadius * Math.sin(angle)

                        if (angle === -Math.PI / 2)
                            ctx.moveTo(px, py)
                        else
                            ctx.lineTo(px, py)
                    }
                    ctx.stroke()
                }
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // Keep Canvas-based variants in sync with dynamic theme changes.
    onWavePhaseChanged: if (wavy) wavyCanvas.requestPaint()
    onValueChanged: {
        if (wavy)
            wavyCanvas.requestPaint()
        circularCanvas.requestPaint()
    }
    onActiveColorChanged: {
        if (wavy)
            wavyCanvas.requestPaint()
        circularCanvas.requestPaint()
    }
    onTrackColorChanged: {
        if (wavy)
            wavyCanvas.requestPaint()
        circularCanvas.requestPaint()
    }
    onShowTrackChanged: {
        if (wavy)
            wavyCanvas.requestPaint()
        circularCanvas.requestPaint()
    }
    onIsThickChanged: circularCanvas.requestPaint()
    onTypeChanged: {
        if (wavy)
            wavyCanvas.requestPaint()
        circularCanvas.requestPaint()
    }

    // Standard thin linear progress.
    Rectangle {
        id: standardLinear
        visible: control.type === "linear"
                 && !control.wavy
                 && control.linearStyle !== "pill"
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: control.isThick ? 8 * control.themeGlobalScale : 4 * control.themeGlobalScale
        color: control.showTrack ? control.trackColor : "transparent"
        radius: height / 2
        clip: true

        Rectangle {
            visible: !control.indeterminate
            height: parent.height
            x: 0
            width: parent.width * control.clampedValue
            radius: height / 2
            color: control.activeColor

            Behavior on width {
                enabled: !control.indeterminate
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: control.motionEasing
                }
            }
        }

        Repeater {
            model: 2

            delegate: Rectangle {
                required property int index
                visible: control.indeterminate
                height: parent.height
                radius: height / 2
                color: control.activeColor
                x: -width
                width: parent.width * (index === 0 ? 0.4 : 0.25)

                SequentialAnimation on x {
                    running: control.indeterminate
                             && control.type === "linear"
                             && !control.wavy
                             && control.linearStyle !== "pill"
                             && control.visible
                    loops: Animation.Infinite
                    PauseAnimation { duration: index === 0 ? 0 : 500 }
                    NumberAnimation {
                        from: -width
                        to: parent ? parent.width : 240
                        duration: Math.max(1, Math.round(1200 * control.themeMotionScale))
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined")
                                            ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]
                    }
                }
            }
        }
    }

    // Android 16-style split pill determinate progress.
    Item {
        id: pillLinear
        visible: control.type === "linear"
                 && !control.wavy
                 && control.linearStyle === "pill"
                 && !control.indeterminate
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: control.pillMarkerHeight

        readonly property real progressX: width * control.clampedValue
        readonly property real activeWidth: control.clampedValue >= 0.999
                                            ? width
                                            : Math.max(0, progressX - control.pillGap)
        readonly property real inactiveX: control.clampedValue <= 0.001
                                          ? 0
                                          : Math.min(width, progressX + control.pillGap)

        Rectangle {
            id: pillActiveTrack
            visible: control.clampedValue > 0
            anchors.verticalCenter: parent.verticalCenter
            x: 0
            width: pillLinear.activeWidth
            height: control.pillHeight
            radius: height / 2
            color: control.pillActiveColor

            Behavior on width {
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: control.motionEasing
                }
            }
        }

        Rectangle {
            visible: control.showTrack && control.clampedValue < 1
            anchors.verticalCenter: parent.verticalCenter
            x: pillLinear.inactiveX
            width: Math.max(0, parent.width - x)
            height: control.pillHeight
            radius: height / 2
            color: control.pillTrackColor

            Behavior on x {
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: control.motionEasing
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: control.motionEasing
                }
            }
        }

        MeoIcon {
            visible: pillActiveTrack.visible
                     && control.leadingIconEnabled
                     && pillActiveTrack.width >= 48 * control.themeGlobalScale
            anchors.left: pillActiveTrack.left
            anchors.leftMargin: 12 * control.themeGlobalScale
            anchors.verticalCenter: pillActiveTrack.verticalCenter
            icon: control.leadingIcon
            size: Math.min(24,
                           Math.max(16,
                                    control.pillHeight / control.themeGlobalScale - 8))
            color: control.themeIsDarkMode ? control.themeOnPrimary : control.themeOnPrimaryContainer
        }

        Rectangle {
            visible: control.clampedValue > 0.001 && control.clampedValue < 0.999
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0,
                        Math.min(parent.width - width,
                                 pillLinear.progressX - width / 2))
            width: control.pillMarkerWidth
            height: control.pillMarkerHeight
            radius: width / 2
            color: control.pillMarkerColor

            Behavior on x {
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: control.motionEasing
                }
            }
        }
    }

    // Indeterminate pill keeps the same large rounded surface while moving two
    // independent segments through it.
    Rectangle {
        visible: control.type === "linear"
                 && !control.wavy
                 && control.linearStyle === "pill"
                 && control.indeterminate
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: control.pillHeight
        radius: height / 2
        color: control.showTrack ? control.pillTrackColor : "transparent"
        clip: true

        Repeater {
            model: 2

            delegate: Rectangle {
                required property int index
                height: parent.height
                radius: height / 2
                color: control.pillActiveColor
                x: -width
                width: parent.width * (index === 0 ? 0.34 : 0.20)

                SequentialAnimation on x {
                    running: control.indeterminate
                             && control.type === "linear"
                             && !control.wavy
                             && control.linearStyle === "pill"
                             && control.visible
                    loops: Animation.Infinite
                    PauseAnimation { duration: index === 0 ? 0 : 420 }
                    NumberAnimation {
                        from: -width
                        to: parent ? parent.width : 240
                        duration: Math.max(1, Math.round(1100 * control.themeMotionScale))
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined")
                                            ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]
                    }
                }
            }
        }
    }

    // Circular progress.
    Item {
        id: classicCircular
        visible: control.type === "circular" && !control.wavy
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width

        RotationAnimation on rotation {
            running: control.indeterminate
                     && control.type === "circular"
                     && !control.wavy
                     && control.visible
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: Math.max(1, Math.round(1568 * control.themeMotionScale))
        }

        Canvas {
            id: circularCanvas
            anchors.fill: parent
            visible: parent.visible

            property real determinateValue: control.clampedValue
            property real indeterminateArcStart: -90
            property real indeterminateArcLength: 10

            onDeterminateValueChanged: requestPaint()
            onIndeterminateArcStartChanged: requestPaint()
            onIndeterminateArcLengthChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            SequentialAnimation {
                running: control.indeterminate
                         && control.type === "circular"
                         && !control.wavy
                         && control.visible
                loops: Animation.Infinite

                ParallelAnimation {
                    NumberAnimation {
                        target: circularCanvas
                        property: "indeterminateArcLength"
                        from: 10
                        to: 270
                        duration: Math.max(1, Math.round(1333 * control.themeMotionScale))
                        easing.bezierCurve: control.motionEasing
                    }
                    NumberAnimation {
                        target: circularCanvas
                        property: "indeterminateArcStart"
                        from: -90
                        to: 45
                        duration: Math.max(1, Math.round(1333 * control.themeMotionScale))
                        easing.bezierCurve: control.motionEasing
                    }
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: circularCanvas
                        property: "indeterminateArcLength"
                        from: 270
                        to: 10
                        duration: Math.max(1, Math.round(1333 * control.themeMotionScale))
                        easing.bezierCurve: control.motionEasing
                    }
                    NumberAnimation {
                        target: circularCanvas
                        property: "indeterminateArcStart"
                        from: 45
                        to: 270
                        duration: Math.max(1, Math.round(1333 * control.themeMotionScale))
                        easing.bezierCurve: control.motionEasing
                    }
                }

                ScriptAction {
                    script: circularCanvas.indeterminateArcStart = -90
                }
            }

            Behavior on determinateValue {
                enabled: !control.indeterminate
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: control.motionEasing
                }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var stroke = (control.isThick ? 8 : 4) * control.themeGlobalScale
                var radius = (Math.min(width, height) - stroke) / 2
                var cx = width / 2
                var cy = height / 2

                if (control.showTrack) {
                    ctx.strokeStyle = control.trackColor
                    ctx.lineWidth = stroke
                    ctx.beginPath()
                    ctx.arc(cx, cy, radius, 0, 2 * Math.PI)
                    ctx.stroke()
                }

                ctx.strokeStyle = control.activeColor
                ctx.lineWidth = stroke
                ctx.lineCap = "round"
                ctx.beginPath()

                if (control.indeterminate) {
                    var startRad = indeterminateArcStart * Math.PI / 180
                    var endRad = (indeterminateArcStart + indeterminateArcLength) * Math.PI / 180
                    ctx.arc(cx, cy, radius, startRad, endRad)
                    ctx.stroke()
                } else if (determinateValue > 0) {
                    var detStartRad = -Math.PI / 2
                    var detEndRad = detStartRad + determinateValue * 2 * Math.PI
                    ctx.arc(cx, cy, radius, detStartRad, detEndRad)
                    ctx.stroke()
                }
            }
        }
    }
}
