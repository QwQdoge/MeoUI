import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // Public progress model. Values outside the range remain accepted at the
    // API boundary but are clamped by the visual contract.
    property real value: 0.0
    property bool indeterminate: false
    property string type: "linear" // "linear" | "circular"
    property bool showTrack: true
    property bool isThick: false

    // Expressive variants are opt-in. isThick changes stroke thickness only;
    // it must not silently turn a normal progress bar into a different shape.
    property string linearStyle: "standard" // "standard" | "pill"
    property string leadingIcon: ""
    readonly property bool leadingIconEnabled: leadingIcon.length > 0
    property bool wavy: false

    // Kept so existing callers keep loading. M3 progress uses the same token
    // set regardless of this historical flag, so it intentionally has no
    // separate palette effect.
    property bool vibrant: false

    property color activeColor: MeoTheme.primary
    // ProgressIndicatorTokens.TrackColor is SecondaryContainer.
    property color trackColor: MeoTheme.secondaryContainer
    property color pillActiveColor: activeColor
    property color pillTrackColor: trackColor
    property color pillMarkerColor: activeColor

    readonly property real clampedValue: Math.max(0, Math.min(1, value))
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool reduceMotion: MeoTheme.reduceMotion
    readonly property int motionDuration: MeoTheme.motionDurationEffectDefault
    readonly property var motionEasing: MeoTheme.motionEasingStandard
    // M3 keeps inactive tracks at 4dp while the active indicator may expand
    // to 8dp for the thick configurations.
    readonly property real trackThickness: 4 * themeGlobalScale
    readonly property real strokeThickness: (isThick ? 8 : 4) * themeGlobalScale
    readonly property real pillHeight: (isThick ? 28 : 24) * themeGlobalScale
    readonly property real pillGap: 6 * themeGlobalScale
    readonly property real pillMarkerWidth: 4 * themeGlobalScale
    readonly property real pillMarkerHeight: pillHeight + 8 * themeGlobalScale
    readonly property real linearWavelength: 40 * themeGlobalScale
    readonly property real indeterminateLinearWavelength: 20 * themeGlobalScale
    // M3 Expressive keeps the wavy silhouette when motion is reduced; only
    // phase movement stops. 4/8dp tracks with a 3dp amplitude produce the
    // specified 10/14dp bounds and 40dp wavelength.
    readonly property real linearAmplitude: 3 * themeGlobalScale
    readonly property real circularWavelengthTarget: 15 * themeGlobalScale
    // CircularProgressIndicatorTokens.ActiveWaveAmplitude = 1.6dp. The
    // waveform is a visual configuration, so reduced motion freezes phase
    // rather than changing the selected configuration's geometry.
    readonly property real circularAmplitude: 1.6 * themeGlobalScale
    readonly property bool isPill: type === "linear" && linearStyle === "pill" && !wavy
    readonly property string accessibleProgress: Math.round(clampedValue * 100) + "%"
    readonly property real wavyReferenceWidth: width > 0 ? width : implicitWidth
    readonly property real wavyActiveWidth: type === "linear"
                                           ? wavyReferenceWidth * (indeterminate ? 0.42 : clampedValue)
                                           : 0
    // The quiet track begins after the same 4dp active/track gap as the
    // standard M3 linear indicator. Keeping this observable makes the
    // renderer's geometry independently testable.
    readonly property real wavyTrackStart: Math.min(wavyReferenceWidth,
                                                    wavyActiveWidth + Math.min(wavyActiveWidth,
                                                                               4 * themeGlobalScale))

    // AndroidX uses a 1750ms two-line indeterminate cycle. A linear clock is
    // deliberately separated from the segment easing so each of the four
    // head/tail positions can follow the source delays and durations.
    property real indeterminateLinearPhase: 0.0
    readonly property real effectiveIndeterminateLinearPhase: reduceMotion ? 0.75 : indeterminateLinearPhase
    readonly property real indeterminateLinearElapsed: effectiveIndeterminateLinearPhase * 1750

    function cubicBezierCoordinate(t, first, second) {
        const inverse = 1 - t
        return 3 * inverse * inverse * t * first
               + 3 * inverse * t * t * second
               + t * t * t
    }

    function emphasizedAccelerateFraction(fraction) {
        const target = Math.max(0, Math.min(1, fraction))
        const curve = MeoTheme.motionEasingEmphasizedAccelerate
        let low = 0
        let high = 1
        for (let iteration = 0; iteration < 16; ++iteration) {
            const candidate = (low + high) / 2
            if (cubicBezierCoordinate(candidate, curve[0], curve[2]) < target)
                low = candidate
            else
                high = candidate
        }
        return cubicBezierCoordinate((low + high) / 2, curve[1], curve[3])
    }

    function indeterminateLinePosition(delay, duration) {
        const elapsed = indeterminateLinearElapsed
        if (elapsed <= delay)
            return 0
        if (elapsed >= delay + duration)
            return 1
        return emphasizedAccelerateFraction((elapsed - delay) / duration)
    }

    readonly property real firstLineHead: indeterminateLinePosition(0, 1000)
    readonly property real firstLineTail: indeterminateLinePosition(250, 1000)
    readonly property real secondLineHead: indeterminateLinePosition(650, 850)
    readonly property real secondLineTail: indeterminateLinePosition(900, 850)

    // AndroidX CircularProgressIndicator compensates the supplied 4dp gap
    // for round stroke caps, then reserves that space on both sides of the
    // determinate active arc. The helper keeps the source formula in one
    // place for Canvas rendering and focused geometry checks.
    function circularTrackGapSweepDegrees(diameter, stroke) {
        if (diameter <= 0)
            return 0
        return ((4 * themeGlobalScale + stroke) / (Math.PI * diameter)) * 360
    }

    function circularDeterminateTrackSweepDegrees(diameter, stroke) {
        const activeSweep = clampedValue * 360
        const gapSweep = circularTrackGapSweepDegrees(diameter, stroke)
        return Math.max(0, 360 - activeSweep - 2 * Math.min(activeSweep, gapSweep))
    }

    implicitWidth: type === "linear"
                   ? 240 * themeGlobalScale
                   : (wavy ? (isThick ? 52 : 48) * themeGlobalScale
                           : (isThick ? 44 : 40) * themeGlobalScale)
    implicitHeight: type === "linear"
                    ? (wavy ? strokeThickness + 2 * linearAmplitude
                            : (isPill ? pillMarkerHeight : strokeThickness))
                    : (wavy ? (isThick ? 52 : 48) * themeGlobalScale
                            : (isThick ? 44 : 40) * themeGlobalScale)

    opacity: enabled ? 1 : MeoTheme.disabledContentOpacity
    Accessible.role: Accessible.ProgressBar
    Accessible.name: indeterminate
                     ? qsTr("Loading progress")
                     : qsTr("Progress %1").arg(accessibleProgress)

    // A contained waveform is an M3 Expressive treatment. It is not used for
    // the default indicator and reduced motion deliberately freezes its pose.
    property real wavePhase: 0.0
    NumberAnimation on wavePhase {
        running: control.wavy && control.visible && !control.reduceMotion
        loops: Animation.Infinite
        from: 0.0
        to: 1.0
        duration: Math.max(1, Math.round(1000 * MeoTheme.effectiveMotionScale))
    }

    NumberAnimation on indeterminateLinearPhase {
        running: control.indeterminate && control.visible && !control.reduceMotion
                 && control.type === "linear" && !control.wavy && !control.isPill
        loops: Animation.Infinite
        from: 0.0
        to: 1.0
        duration: Math.max(1, Math.round(1750 * MeoTheme.effectiveMotionScale))
        easing.type: Easing.Linear
    }

    Canvas {
        id: wavyCanvas
        objectName: "meoProgressWavyCanvas"
        anchors.fill: parent
        visible: control.wavy

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const w = width
            const h = height
            if (w <= 0 || h <= 0)
                return

            const stroke = control.strokeThickness
            const phase = control.wavePhase

            if (control.type === "linear") {
                const centerY = h / 2
                const activeW = w * (control.indeterminate ? 0.42 : control.clampedValue)
                const trackStart = Math.min(w, activeW + Math.min(activeW, 4 * control.themeGlobalScale))
                const wavelength = control.indeterminate
                                 ? control.indeterminateLinearWavelength
                                 : control.linearWavelength

                // The source implementation draws from inline start. Mirror
                // the whole geometry once for RTL so active segment, gap,
                // track, and stop all remain internally consistent.
                ctx.save()
                if (control.mirrored) {
                    ctx.translate(w, 0)
                    ctx.scale(-1, 1)
                }

                if (control.showTrack && trackStart < w) {
                    ctx.strokeStyle = control.trackColor
                    ctx.lineWidth = control.trackThickness
                    ctx.lineCap = "round"
                    ctx.beginPath()
                    ctx.moveTo(trackStart, centerY)
                    ctx.lineTo(w, centerY)
                    ctx.stroke()

                    ctx.fillStyle = control.activeColor
                    ctx.beginPath()
                    ctx.arc(w - 2 * control.themeGlobalScale,
                            centerY, 2 * control.themeGlobalScale, 0, 2 * Math.PI)
                    ctx.fill()
                }

                if (activeW <= 0) {
                    ctx.restore()
                    return
                }

                ctx.strokeStyle = control.activeColor
                ctx.lineWidth = stroke
                ctx.lineCap = "round"
                ctx.beginPath()
                for (let x = 0; x <= activeW; x += 2) {
                    const y = centerY + control.linearAmplitude
                            * Math.sin(2 * Math.PI * (x / wavelength - phase))
                    if (x === 0)
                        ctx.moveTo(x, y)
                    else
                        ctx.lineTo(x, y)
                }
                ctx.stroke()
                ctx.restore()
                return
            }

            const radius = (Math.min(w, h) - stroke - control.circularAmplitude * 2) / 2
            const cx = w / 2
            const cy = h / 2
            const circumference = 2 * Math.PI * radius
            const waveCount = Math.max(3, Math.round(circumference / control.circularWavelengthTarget))

            if (control.showTrack) {
                ctx.strokeStyle = control.trackColor
                ctx.lineWidth = control.trackThickness
                ctx.beginPath()
                ctx.arc(cx, cy, radius, 0, 2 * Math.PI)
                ctx.stroke()
            }

            const activeAngle = 2 * Math.PI * (control.indeterminate ? 0.30 : control.clampedValue)
            if (activeAngle <= 0)
                return

            ctx.strokeStyle = control.activeColor
            ctx.lineWidth = stroke
            ctx.lineCap = "round"
            ctx.beginPath()
            for (let angle = -Math.PI / 2;
                 angle <= -Math.PI / 2 + activeAngle;
                 angle += Math.PI / 60) {
                const currentRadius = radius + control.circularAmplitude
                        * Math.sin(waveCount * angle - 2 * Math.PI * phase)
                const px = cx + currentRadius * Math.cos(angle)
                const py = cy + currentRadius * Math.sin(angle)
                if (angle === -Math.PI / 2)
                    ctx.moveTo(px, py)
                else
                    ctx.lineTo(px, py)
            }
            ctx.stroke()
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

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
    onIndeterminateChanged: {
        if (wavy)
            wavyCanvas.requestPaint()
        circularCanvas.requestPaint()
    }
    onShowTrackChanged: {
        if (wavy)
            wavyCanvas.requestPaint()
        circularCanvas.requestPaint()
    }

    // Default M3 progress: one continuous active segment over a quiet track.
    Rectangle {
        id: standardLinear
        objectName: "meoProgressStandardLinear"
        visible: control.type === "linear" && !control.wavy && !control.isPill
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Math.max(control.strokeThickness, control.trackThickness)
        radius: height / 2
        color: "transparent"
        clip: true

        Rectangle {
            id: standardTrack
            objectName: "meoProgressStandardTrack"
            visible: control.showTrack && !control.indeterminate
            anchors.verticalCenter: parent.verticalCenter
            // ProgressIndicatorDefaults keeps a 4dp TrackActiveSpace after a
            // determinate active segment. At zero progress the gap collapses
            // with the active segment, matching the AndroidX draw contract.
            readonly property real activeGap: !control.indeterminate
                                              ? Math.min(parent.width * control.clampedValue,
                                                         4 * control.themeGlobalScale)
                                              : 0
            width: Math.max(0, parent.width
                                  - parent.width * control.clampedValue
                                  - activeGap)
            x: control.mirrored ? 0 : parent.width - width
            height: control.trackThickness
            radius: height / 2
            color: control.trackColor
        }

        Rectangle {
            id: determinateSegment
            objectName: "meoProgressDeterminateSegment"
            visible: !control.indeterminate && control.clampedValue > 0
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * control.clampedValue
            height: parent.height
            x: control.mirrored ? parent.width - width : 0
            radius: height / 2
            color: control.activeColor

            // AndroidX progress indicators apply the supplied determinate
            // value directly. Hosts that need interpolation should animate
            // their own value with ProgressAnimationSpec-equivalent motion.
        }

        Rectangle {
            id: indeterminateSegment
            objectName: "meoProgressIndeterminateSegment"
            visible: control.indeterminate
            anchors.verticalCenter: parent.verticalCenter
            readonly property real startFraction: control.firstLineTail
            readonly property real endFraction: control.firstLineHead
            width: Math.max(0, (endFraction - startFraction) * parent.width)
            height: parent.height
            x: control.mirrored ? parent.width - endFraction * parent.width
                                : startFraction * parent.width
            radius: height / 2
            color: control.activeColor
        }

        Rectangle {
            id: indeterminateSegment2
            objectName: "meoProgressIndeterminateSegment2"
            visible: control.indeterminate
            anchors.verticalCenter: parent.verticalCenter
            readonly property real startFraction: control.secondLineTail
            readonly property real endFraction: control.secondLineHead
            width: Math.max(0, (endFraction - startFraction) * parent.width)
            height: parent.height
            x: control.mirrored ? parent.width - endFraction * parent.width
                                : startFraction * parent.width
            radius: height / 2
            color: control.activeColor
        }

        // The indeterminate source implementation draws separated track
        // sections around two moving active segments. These three pieces keep
        // the 4dp active/track gap visible instead of painting a track below
        // either segment.
        Rectangle {
            id: indeterminateTrackAfterFirst
            objectName: "meoProgressIndeterminateTrackAfterFirst"
            visible: control.showTrack && control.indeterminate
            anchors.verticalCenter: parent.verticalCenter
            readonly property real startFraction: control.firstLineHead > 0
                                                  ? Math.min(1, control.firstLineHead + 4 * control.themeGlobalScale / parent.width)
                                                  : 0
            width: Math.max(0, parent.width * (1 - startFraction))
            height: control.trackThickness
            x: control.mirrored ? 0 : startFraction * parent.width
            radius: height / 2
            color: control.trackColor
        }

        Rectangle {
            id: indeterminateTrackBetween
            objectName: "meoProgressIndeterminateTrackBetween"
            visible: control.showTrack && control.indeterminate
                     && control.firstLineTail > 4 * control.themeGlobalScale / parent.width
            anchors.verticalCenter: parent.verticalCenter
            readonly property real startFraction: control.secondLineHead > 0
                                                  ? Math.min(1, control.secondLineHead + 4 * control.themeGlobalScale / parent.width)
                                                  : 0
            readonly property real endFraction: control.firstLineTail < 1
                                                ? Math.max(0, control.firstLineTail - 4 * control.themeGlobalScale / parent.width)
                                                : 1
            width: Math.max(0, parent.width * (endFraction - startFraction))
            x: control.mirrored ? parent.width - endFraction * parent.width
                                : startFraction * parent.width
            height: control.trackThickness
            radius: height / 2
            color: control.trackColor
        }

        Rectangle {
            id: indeterminateTrackBeforeSecond
            objectName: "meoProgressIndeterminateTrackBeforeSecond"
            visible: control.showTrack && control.indeterminate
                     && control.secondLineTail > 4 * control.themeGlobalScale / parent.width
            anchors.verticalCenter: parent.verticalCenter
            readonly property real endFraction: control.secondLineTail < 1
                                                ? Math.max(0, control.secondLineTail - 4 * control.themeGlobalScale / parent.width)
                                                : 1
            width: Math.max(0, endFraction * parent.width)
            x: control.mirrored ? parent.width - width : 0
            height: control.trackThickness
            radius: height / 2
            color: control.trackColor
        }

        // A fixed 4dp end stop preserves contrast at the far end of the
        // quiet track, matching the M3 progress indicator specification.
        Rectangle {
            id: linearEndStop
            objectName: "meoProgressLinearEndStop"
            visible: control.showTrack && !control.indeterminate
            width: 4 * control.themeGlobalScale
            height: width
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            x: control.mirrored ? 0 : parent.width - width
            color: control.activeColor
        }
    }

    // Expressive split pill. Its gap and marker describe the current position
    // but the external bounds never pulse or change with pointer state.
    Item {
        id: pillLinear
        objectName: "meoProgressPill"
        visible: control.isPill && !control.indeterminate
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: control.pillMarkerHeight

        readonly property real progressX: width * control.clampedValue
        readonly property real activeWidth: control.clampedValue >= 0.999
                                            ? width
                                            : Math.max(0, progressX - control.pillGap)
        readonly property real inactiveWidth: control.clampedValue <= 0.001
                                              ? width
                                              : Math.max(0, width - progressX - control.pillGap)

        Rectangle {
            id: pillActiveTrack
            objectName: "meoProgressPillActive"
            visible: control.clampedValue > 0
            anchors.verticalCenter: parent.verticalCenter
            width: pillLinear.activeWidth
            height: control.pillHeight
            x: control.mirrored ? parent.width - width : 0
            radius: height / 2
            color: control.pillActiveColor

            Behavior on width {
                enabled: !control.reduceMotion
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: control.motionEasing
                }
            }
        }

        Rectangle {
            id: pillInactiveTrack
            objectName: "meoProgressPillTrack"
            visible: control.showTrack && control.clampedValue < 1
            anchors.verticalCenter: parent.verticalCenter
            width: pillLinear.inactiveWidth
            height: control.pillHeight
            x: control.mirrored ? 0 : parent.width - width
            radius: height / 2
            color: control.pillTrackColor

            Behavior on width {
                enabled: !control.reduceMotion
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: control.motionEasing
                }
            }
        }

        MeoIcon {
            visible: pillActiveTrack.visible && control.leadingIconEnabled
                     && pillActiveTrack.width >= 48 * control.themeGlobalScale
            anchors.left: control.mirrored ? undefined : pillActiveTrack.left
            anchors.right: control.mirrored ? pillActiveTrack.right : undefined
            anchors.leftMargin: control.mirrored ? 0 : 12 * control.themeGlobalScale
            anchors.rightMargin: control.mirrored ? 12 * control.themeGlobalScale : 0
            anchors.verticalCenter: pillActiveTrack.verticalCenter
            icon: control.leadingIcon
            size: Math.min(MeoTheme.iconSizeM,
                           Math.max(MeoTheme.iconSizeS,
                                    control.pillHeight / control.themeGlobalScale - 8))
            color: MeoTheme.contentOnPrimary
        }

        Rectangle {
            id: pillMarker
            objectName: "meoProgressPillMarker"
            visible: control.clampedValue > 0.001 && control.clampedValue < 0.999
            anchors.verticalCenter: parent.verticalCenter
            width: control.pillMarkerWidth
            height: control.pillMarkerHeight
            x: Math.max(0, Math.min(parent.width - width,
                                    (control.mirrored ? parent.width - pillLinear.progressX
                                                      : pillLinear.progressX) - width / 2))
            radius: width / 2
            color: control.pillMarkerColor

            Behavior on x {
                enabled: !control.reduceMotion
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: control.motionEasing
                }
            }
        }

    }

    Rectangle {
        id: indeterminatePill
        objectName: "meoProgressIndeterminatePill"
        visible: control.isPill && control.indeterminate
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: control.pillHeight
        radius: height / 2
        color: control.showTrack ? control.pillTrackColor : "transparent"
        clip: true

        Rectangle {
            objectName: "meoProgressIndeterminatePillSegment"
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.34
            height: parent.height
            x: control.reduceMotion ? (parent.width - width) / 2
                                    : (control.mirrored ? parent.width : -width)
            radius: height / 2
            color: control.pillActiveColor

            NumberAnimation on x {
                running: control.indeterminate && !control.reduceMotion
                         && control.isPill && control.visible
                loops: Animation.Infinite
                from: control.mirrored ? (parent ? parent.width : 240) : -width
                to: control.mirrored ? -width : (parent ? parent.width : 240)
                duration: Math.max(1, Math.round(1100 * MeoTheme.effectiveMotionScale))
                easing.bezierCurve: MeoTheme.motionEasingEmphasized
            }
        }
    }

    Item {
        id: classicCircular
        objectName: "meoProgressCircular"
        visible: control.type === "circular" && !control.wavy
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        readonly property bool sourceDrawsTrack: control.showTrack && !control.indeterminate

        Canvas {
            id: circularCanvas
            objectName: "meoProgressCircularCanvas"
            anchors.fill: parent
            visible: parent.visible
            property real determinateValue: control.clampedValue
            property real indeterminateArcStart: -90
            property real indeterminateArcLength: 90

            onDeterminateValueChanged: requestPaint()
            onIndeterminateArcStartChanged: requestPaint()
            onIndeterminateArcLengthChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            SequentialAnimation {
                running: control.indeterminate && !control.reduceMotion
                         && control.type === "circular" && !control.wavy
                         && control.visible
                loops: Animation.Infinite

                ParallelAnimation {
                    NumberAnimation {
                        target: circularCanvas
                        property: "indeterminateArcLength"
                        from: 30
                        to: 270
                        duration: Math.max(1, Math.round(1333 * MeoTheme.effectiveMotionScale))
                        easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                    NumberAnimation {
                        target: circularCanvas
                        property: "indeterminateArcStart"
                        from: -90
                        to: 45
                        duration: Math.max(1, Math.round(1333 * MeoTheme.effectiveMotionScale))
                        easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: circularCanvas
                        property: "indeterminateArcLength"
                        from: 270
                        to: 30
                        duration: Math.max(1, Math.round(1333 * MeoTheme.effectiveMotionScale))
                        easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                    NumberAnimation {
                        target: circularCanvas
                        property: "indeterminateArcStart"
                        from: 45
                        to: 270
                        duration: Math.max(1, Math.round(1333 * MeoTheme.effectiveMotionScale))
                        easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
                ScriptAction { script: circularCanvas.indeterminateArcStart = -90 }
            }

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const stroke = control.strokeThickness
                const radius = (Math.min(width, height) - stroke) / 2
                const cx = width / 2
                const cy = height / 2

                // The default circular indeterminate source token is
                // transparent. Determinate circular progress instead keeps a
                // SecondaryContainer track, separated from both active arc
                // ends by the source's cap-compensated 4dp gap.
                if (classicCircular.sourceDrawsTrack) {
                    const diameter = Math.min(width, height)
                    const activeSweep = control.clampedValue * 360
                    const gapSweep = control.circularTrackGapSweepDegrees(diameter, stroke)
                    const adjustedGapSweep = Math.min(activeSweep, gapSweep)
                    const trackSweep = control.circularDeterminateTrackSweepDegrees(diameter, stroke)
                    ctx.strokeStyle = control.trackColor
                    ctx.lineWidth = control.trackThickness
                    ctx.lineCap = "round"
                    ctx.beginPath()
                    if (trackSweep > 0)
                        ctx.arc(cx, cy, radius,
                                -Math.PI / 2 + (activeSweep + adjustedGapSweep) * Math.PI / 180,
                                -Math.PI / 2 + (activeSweep + adjustedGapSweep + trackSweep) * Math.PI / 180)
                    ctx.stroke()
                }

                ctx.strokeStyle = control.activeColor
                ctx.lineWidth = stroke
                ctx.lineCap = "round"
                ctx.beginPath()
                if (control.indeterminate) {
                    const start = indeterminateArcStart * Math.PI / 180
                    const end = (indeterminateArcStart + indeterminateArcLength) * Math.PI / 180
                    ctx.arc(cx, cy, radius, start, end)
                } else if (determinateValue > 0) {
                    ctx.arc(cx, cy, radius, -Math.PI / 2,
                            -Math.PI / 2 + determinateValue * 2 * Math.PI)
                }
                ctx.stroke()
            }
        }
    }
}
