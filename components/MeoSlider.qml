import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // Value model
    property real from: 0.0
    property real to: 100.0
    property real value: 0.0
    property bool discrete: false
    property real stepSize: 1.0
    // M3 Expressive configurations. `discrete` remains the compatible name;
    // `stops` is the current Material name for the same snapping behavior.
    property bool stops: false
    property bool snapMode: false
    property bool tickMarksEnabled: discrete || stops
    property bool valueLabelEnabled: false
    property int orientation: Qt.Horizontal
    property string variant: "standard" // "standard" | "centered"
    property real centerValue: {
        const lower = Math.min(from, to)
        const upper = Math.max(from, to)
        return lower <= 0 && upper >= 0 ? 0 : (from + to) / 2
    }

    // Visual variants
    property bool isThick: false
    property bool wavy: false
    property bool expressive: false
    // Expressive motion and split geometry must not silently make the control
    // forty dp thick.  XS is the Android/Pixel default; callers opt into the
    // larger expressive sizes explicitly.
    property string size: "xs" // "xs" | "s" | "m" | "l" | "xl"
    property string trackStyle: expressive ? "split" : "standard" // "standard" | "split"
    property bool endStopEnabled: expressive || effectiveTrackStyle === "split"
    property bool animateExternalChanges: true
    property string insetIcon: ""
    property string leadingIcon: ""
    readonly property string effectiveInsetIcon: insetIcon !== "" ? insetIcon : leadingIcon
    readonly property bool insetIconSupported: size === "m" || size === "l" || size === "xl"
    property bool leadingIconEnabled: effectiveInsetIcon.length > 0 && insetIconSupported
    // The concrete Qt Slider below owns the platform slider semantic.  These
    // inputs let composites provide a task-specific name without adding a
    // second accessibility node around the same adjustable value.
    property string accessibleName: qsTr("Slider %1").arg(Math.round(normalizedValue(value)))
    property string accessibleDescription: ""
    property color activeTrackColor: themePrimary
    property color inactiveTrackColor: themeSecondaryContainer
    property color thumbColor: themePrimary

    readonly property bool pressed: internalSlider.pressed
    readonly property bool horizontal: orientation !== Qt.Vertical
    readonly property bool centered: variant === "centered"
    readonly property string effectiveTrackStyle: centered ? "standard" : trackStyle
    signal moved(real value)

    function normalizedValue(rawValue) {
        var lower = Math.min(from, to)
        var upper = Math.max(from, to)
        var nextValue = Math.max(lower, Math.min(upper, rawValue))

        if ((discrete || stops || snapMode || tickMarksEnabled) && stepSize > 0) {
            var steps = Math.round((nextValue - from) / stepSize)
            nextValue = from + steps * stepSize
        }

        return Math.max(lower, Math.min(upper, nextValue))
    }

    function setValue(rawValue) {
        var nextValue = normalizedValue(rawValue)
        if (value !== nextValue) {
            value = nextValue
            moved(value)
        }
    }

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeSurfaceContainerHighest: MeoTheme.surfaceContainerHighest
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeInverseSurface: MeoTheme.inverseSurface
    readonly property color themeOnInverseSurface: MeoTheme.contentOnInverseSurface
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool reduceMotion: MeoTheme.reduceMotion
    readonly property int motionStateDuration: MeoTheme.motionDurationState
    readonly property int motionTrackDuration: MeoTheme.motionDurationSelection
    readonly property int motionWaveDuration: MeoTheme.motionDurationWaveCycle
    readonly property var fontLabelSmall: MeoTheme.labelSmall

    function compositeColor(foreground, opacity, background) {
        return Qt.rgba(foreground.r * opacity + background.r * (1 - opacity),
                       foreground.g * opacity + background.g * (1 - opacity),
                       foreground.b * opacity + background.b * (1 - opacity),
                       1)
    }

    // Current AndroidX SliderTokens use distinct disabled roles for the thumb,
    // active rail, inactive rail, and stops. Resolve them locally instead of
    // dimming the complete control, which would make both rail segments 38%.
    readonly property color resolvedActiveTrackColor: enabled
                                                    ? activeTrackColor
                                                    : compositeColor(themeOnSurface,
                                                                     MeoTheme.disabledContentOpacity,
                                                                     themeSurface)
    readonly property color resolvedInactiveTrackColor: enabled
                                                      ? inactiveTrackColor
                                                      : compositeColor(themeOnSurface,
                                                                       MeoTheme.disabledContainerOpacity,
                                                                       themeSurface)
    readonly property color resolvedThumbColor: enabled
                                               ? thumbColor
                                               : compositeColor(themeOnSurface,
                                                                MeoTheme.disabledContentOpacity,
                                                                themeSurface)
    readonly property color resolvedActiveTickColor: enabled
                                                    ? themeSecondaryContainer
                                                    : compositeColor(themeOnSurface,
                                                                     MeoTheme.disabledContainerOpacity,
                                                                     themeSurface)
    readonly property color resolvedInactiveTickColor: enabled
                                                      ? themePrimary
                                                      : compositeColor(themeOnSurface,
                                                                       MeoTheme.disabledContentOpacity,
                                                                       themeSurface)

    // Geometry
    readonly property real trackHeight: {
        if (size === "xs") {
            return MeoTheme.sliderTrackHeightXS
        }
        if (size === "s") {
            return MeoTheme.sliderTrackHeightS
        }
        if (size === "m") {
            return MeoTheme.sliderTrackHeightM
        }
        if (size === "l") {
            return MeoTheme.sliderTrackHeightL
        }
        if (size === "xl") {
            return MeoTheme.sliderTrackHeightXL
        }
        return 4 * themeGlobalScale
    }

    readonly property real renderedTrackHeight: isThick
                                                ? Math.max(trackHeight, 16 * themeGlobalScale)
                                                : trackHeight
    readonly property real expressiveThumbHeight: {
        if (size === "s") return MeoTheme.sliderThumbHeightS
        if (size === "m") return MeoTheme.sliderThumbHeightM
        if (size === "l") return MeoTheme.sliderThumbHeightL
        if (size === "xl") return MeoTheme.sliderThumbHeightXL
        return MeoTheme.sliderThumbHeightXS
    }
    readonly property real thumbWidth: MeoTheme.sliderThumbWidthExpressive
    readonly property real pressedThumbWidth: MeoTheme.sliderThumbPressedWidthExpressive
    readonly property real thumbHeight: expressiveThumbHeight
    readonly property real thumbGap: MeoTheme.sliderThumbGapExpressive
    readonly property real trackCornerRadius: MeoTheme.sliderTrackCornerRadiusForSize(size)
    readonly property real trackInsideCornerRadius: MeoTheme.sliderTrackInsideCornerRadius
    readonly property real insetIconSize: MeoTheme.sliderInsetIconSizeForSize(size)
    readonly property real trackLength: horizontal ? internalSlider.availableWidth : internalSlider.availableHeight
    // Vertical sliders grow from the bottom edge, matching Android's control.
    readonly property real visualProgress: horizontal ? internalSlider.visualPosition : 1 - internalSlider.visualPosition
    readonly property real trackPosition: Math.max(0, Math.min(trackLength, visualProgress * trackLength))
    readonly property real centerProgress: {
        const span = to - from
        if (span === 0)
            return 0.5
        return Math.max(0, Math.min(1, (centerValue - from) / span))
    }
    readonly property real centerPosition: centerProgress * trackLength
    readonly property real activeTrackStart: centered ? Math.min(trackPosition, centerPosition) : 0
    readonly property real activeTrackEnd: centered ? Math.max(trackPosition, centerPosition) : trackPosition
    readonly property real handleCenterPosition: {
        if (!internalSlider)
            return 0
        var travel = Math.max(0, trackLength - thumbWidth)
        return visualProgress * travel + thumbWidth / 2
    }
    readonly property real splitActiveLength: Math.max(0, Math.min(trackLength, handleCenterPosition - thumbGap))
    readonly property real splitInactiveStart: Math.max(0, Math.min(trackLength, handleCenterPosition + thumbGap))
    readonly property real dragThreshold: trackLength > 0
                                                ? Math.min(1, 4 * themeGlobalScale / trackLength)
                                                : 1
    property real _pressVisualPosition: 0
    property bool _dragged: false
    readonly property bool wavyEnabled: wavy && horizontal
    readonly property bool waveAnimationActive: wavyEnabled
                                                && visible
                                                && enabled
                                                && width > 0
                                                && height > 0
                                                && (internalSlider.hovered || internalSlider.pressed || internalSlider.activeFocus)
                                                && !reduceMotion

    implicitWidth: 200 * themeGlobalScale
    implicitHeight: wavy
                    ? 48 * themeGlobalScale
                    : Math.max(thumbHeight,
                               renderedTrackHeight,
                               48 * themeGlobalScale)
    // Do not expose both this visual wrapper and the interactive Qt Slider as
    // sliders.  The latter receives native value/range actions and is the
    // single accessibility focus target.
    Accessible.ignored: true

    Slider {
        id: internalSlider
        objectName: "meoSliderNative"
        anchors.fill: parent
        from: control.from
        to: control.to
        value: control.value
        stepSize: (control.discrete || control.stops || control.snapMode || control.tickMarksEnabled) ? control.stepSize : 0.0
        orientation: control.orientation
        live: true
        enabled: control.enabled
        activeFocusOnTab: true
        Accessible.name: control.accessibleName
        Accessible.description: control.accessibleDescription

        onMoved: control.setValue(value)
        onPressedChanged: {
            if (pressed) {
                control._pressVisualPosition = visualPosition
                control._dragged = false
            } else {
                control._dragged = false
            }
        }
        onVisualPositionChanged: {
            if (pressed && Math.abs(visualPosition - control._pressVisualPosition) >= control.dragThreshold)
                control._dragged = true
        }

        background: Item {
            id: trackArea
            x: internalSlider.leftPadding
            y: internalSlider.topPadding
            width: internalSlider.availableWidth
            height: internalSlider.availableHeight

            // Standard Material track. Kept for compact sliders and compatibility.
            Rectangle {
                id: standardTrack
                objectName: "meoSliderStandardTrack"
                visible: !control.wavyEnabled && control.effectiveTrackStyle !== "split"
                x: control.horizontal ? 0 : (parent.width - width) / 2
                y: control.horizontal ? (parent.height - height) / 2 : 0
                width: control.horizontal ? parent.width : control.renderedTrackHeight
                height: control.horizontal ? control.renderedTrackHeight : parent.height
                radius: Math.min(control.trackCornerRadius, width / 2, height / 2)
                color: control.resolvedInactiveTrackColor

                Behavior on height {
                    NumberAnimation { duration: control.motionTrackDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
                }
            }

            Rectangle {
                id: standardActiveTrack
                objectName: "meoSliderActiveTrack"
                visible: standardTrack.visible
                x: control.horizontal ? control.activeTrackStart : (parent.width - width) / 2
                y: control.horizontal ? (parent.height - height) / 2 : parent.height - control.activeTrackEnd
                width: control.horizontal ? Math.max(0, control.activeTrackEnd - control.activeTrackStart) : standardTrack.width
                height: control.horizontal ? standardTrack.height : Math.max(0, control.activeTrackEnd - control.activeTrackStart)
                radius: Math.min(control.trackCornerRadius, width / 2, height / 2)
                color: control.resolvedActiveTrackColor

                Behavior on width {
                    enabled: control.animateExternalChanges && !internalSlider.pressed
                    NumberAnimation {
                        duration: control.motionTrackDuration
                        easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
                Behavior on height {
                    NumberAnimation { duration: control.motionTrackDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
                }
            }

            // Android 16 / M3 Expressive split pill track.
            // The active and inactive pills stop before the thumb instead of drawing
            // a continuous rail underneath it, which keeps the separator crisp.
            Rectangle {
                id: splitActiveTrack
                objectName: "meoSliderSplitActiveTrack"
                visible: !control.wavyEnabled && control.effectiveTrackStyle === "split"
                x: control.horizontal ? 0 : (parent.width - width) / 2
                y: control.horizontal ? (parent.height - height) / 2 : parent.height - control.splitActiveLength
                width: control.horizontal ? control.splitActiveLength : control.renderedTrackHeight
                height: control.horizontal ? control.renderedTrackHeight : control.splitActiveLength
                radius: 0
                topLeftRadius: control.horizontal ? Math.min(control.trackCornerRadius, width / 2, height / 2)
                                                  : Math.min(control.trackInsideCornerRadius, width / 2, height / 2)
                bottomLeftRadius: control.horizontal ? Math.min(control.trackCornerRadius, width / 2, height / 2)
                                                     : Math.min(control.trackCornerRadius, width / 2, height / 2)
                topRightRadius: control.horizontal ? Math.min(control.trackInsideCornerRadius, width / 2, height / 2)
                                                   : Math.min(control.trackInsideCornerRadius, width / 2, height / 2)
                bottomRightRadius: control.horizontal ? Math.min(control.trackInsideCornerRadius, width / 2, height / 2)
                                                      : Math.min(control.trackCornerRadius, width / 2, height / 2)
                color: control.resolvedActiveTrackColor

                Behavior on width {
                    enabled: control.animateExternalChanges && !internalSlider.pressed
                    NumberAnimation {
                        duration: control.motionTrackDuration
                        easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
                Behavior on height {
                    NumberAnimation { duration: control.motionTrackDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
                }
            }

            Rectangle {
                id: splitInactiveTrack
                objectName: "meoSliderSplitInactiveTrack"
                visible: splitActiveTrack.visible
                anchors.verticalCenter: parent.verticalCenter
                x: control.horizontal ? control.splitInactiveStart : (parent.width - width) / 2
                y: control.horizontal ? (parent.height - height) / 2 : 0
                width: control.horizontal ? Math.max(0, parent.width - x) : control.renderedTrackHeight
                height: control.horizontal ? control.renderedTrackHeight : Math.max(0, parent.height - control.splitInactiveStart)
                radius: 0
                topLeftRadius: control.horizontal ? Math.min(control.trackInsideCornerRadius, width / 2, height / 2)
                                                  : Math.min(control.trackCornerRadius, width / 2, height / 2)
                bottomLeftRadius: control.horizontal ? Math.min(control.trackInsideCornerRadius, width / 2, height / 2)
                                                     : Math.min(control.trackInsideCornerRadius, width / 2, height / 2)
                topRightRadius: control.horizontal ? Math.min(control.trackCornerRadius, width / 2, height / 2)
                                                   : Math.min(control.trackCornerRadius, width / 2, height / 2)
                bottomRightRadius: control.horizontal ? Math.min(control.trackCornerRadius, width / 2, height / 2)
                                                      : Math.min(control.trackInsideCornerRadius, width / 2, height / 2)
                color: control.resolvedInactiveTrackColor

                Behavior on x {
                    enabled: control.animateExternalChanges && !internalSlider.pressed
                    NumberAnimation {
                        duration: control.motionTrackDuration
                        easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
                Behavior on width {
                    enabled: control.animateExternalChanges && !internalSlider.pressed
                    NumberAnimation {
                        duration: control.motionTrackDuration
                        easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
                Behavior on height {
                    NumberAnimation { duration: control.motionTrackDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
                }
            }

            MeoIcon {
                objectName: "meoSliderInsetIcon"
                visible: control.horizontal && splitActiveTrack.visible
                         && control.leadingIconEnabled
                anchors.left: splitActiveTrack.left
                anchors.leftMargin: control.trackCornerRadius
                anchors.verticalCenter: splitActiveTrack.verticalCenter
                icon: control.effectiveInsetIcon
                size: control.insetIconSize / control.themeGlobalScale
                color: splitActiveTrack.width >= anchors.leftMargin + width
                       ? MeoTheme.contentOnPrimary
                       : MeoTheme.primary
                opacity: visible ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: control.motionStateDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
                }
            }

            // Tick marks remain on the classic track; the split pill intentionally
            // stays visually clean like Android 16 Quick Settings.
            Repeater {
                id: tickRepeater
                model: (!control.wavy
                        && (control.discrete || control.stops || control.tickMarksEnabled)
                        && control.stepSize > 0)
                       ? Math.max(0, Math.floor(Math.abs(control.to - control.from) / control.stepSize) + 1)
                       : 0

                delegate: Rectangle {
                    required property int index
                    objectName: "meoSliderTick_" + index
                    x: control.horizontal
                       ? (tickRepeater.count > 1 ? index * (trackArea.width / (tickRepeater.count - 1)) - width / 2 : 0)
                       : (trackArea.width - width) / 2
                    y: control.horizontal
                       ? (trackArea.height - height) / 2
                       : (tickRepeater.count > 1 ? trackArea.height - index * (trackArea.height / (tickRepeater.count - 1)) - height / 2 : 0)
                    width: MeoTheme.sliderStopSizeExpressive
                    height: width
                    radius: width / 2
                    readonly property real progress: tickRepeater.count > 1
                                                    ? index / (tickRepeater.count - 1) : 0
                    color: progress <= control.visualProgress
                           ? control.resolvedActiveTickColor
                           : control.resolvedInactiveTickColor
                }
            }

            // M3 Expressive retains contrasting outer stops. The leading stop
            // yields to an inset icon because both must never occupy the same
            // start slot; the trailing stop remains visible.
            Rectangle {
                id: leadingEndStop
                objectName: "meoSliderLeadingEndStop"
                visible: control.endStopEnabled && !control.wavyEnabled && control.horizontal
                         && !control.leadingIconEnabled
                width: MeoTheme.sliderStopSizeExpressive
                height: width
                radius: width / 2
                x: Math.max(0, control.trackCornerRadius - width / 2)
                anchors.verticalCenter: parent.verticalCenter
                color: control.visualProgress > 0
                       ? control.resolvedInactiveTrackColor
                       : control.resolvedActiveTrackColor
            }

            Rectangle {
                id: trailingEndStop
                objectName: "meoSliderTrailingEndStop"
                visible: control.endStopEnabled && !control.wavyEnabled && control.horizontal
                width: MeoTheme.sliderStopSizeExpressive
                height: width
                radius: width / 2
                x: Math.max(0, parent.width - control.trackCornerRadius - width / 2)
                anchors.verticalCenter: parent.verticalCenter
                color: control.visualProgress >= 1
                       ? control.resolvedInactiveTrackColor
                       : control.resolvedActiveTrackColor
            }

            Canvas {
                id: wavyCanvas
                visible: control.wavyEnabled
                anchors.fill: parent
                property real phase: 0

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var strokeWidth = (control.isThick ? 10 : (control.size === "xs" ? 4 : 8)) * control.themeGlobalScale
                    var mid = height / 2
                    var progressWidth = Math.max(0, Math.min(width, control.trackPosition))
                    var amp = Math.min(strokeWidth * 0.34, 3.5 * control.themeGlobalScale)
                    var wavelength = 40 * control.themeGlobalScale
                    var sampleStep = Math.max(1, 1.25 * control.themeGlobalScale)

                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.lineWidth = strokeWidth

                    ctx.strokeStyle = control.resolvedInactiveTrackColor
                    ctx.beginPath()
                    ctx.moveTo(0, mid)
                    ctx.lineTo(width, mid)
                    ctx.stroke()

                    ctx.strokeStyle = control.resolvedActiveTrackColor
                    ctx.beginPath()
                    for (var x = 0; x < progressWidth; x += sampleStep) {
                        var y = mid + Math.sin((x + phase) / wavelength * Math.PI * 2) * amp
                        if (x === 0)
                            ctx.moveTo(x, y)
                        else
                            ctx.lineTo(x, y)
                    }

                    if (progressWidth > 0) {
                        var endY = mid + Math.sin((progressWidth + phase) / wavelength * Math.PI * 2) * amp
                        if (progressWidth < sampleStep)
                            ctx.moveTo(0, mid)
                        ctx.lineTo(progressWidth, endY)
                    }
                    ctx.stroke()
                }

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPhaseChanged: requestPaint()

                Connections {
                    target: internalSlider
                    function onVisualPositionChanged() {
                        wavyCanvas.requestPaint()
                    }
                }

                NumberAnimation on phase {
                    running: control.waveAnimationActive
                    from: 0
                    to: 40 * control.themeGlobalScale
                    duration: control.motionWaveDuration
                    loops: Animation.Infinite
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingLinear
                }
            }
        }

        handle: Item {
            id: sliderHandle
            objectName: "meoSliderHandle"
            x: control.horizontal
               ? internalSlider.leftPadding + internalSlider.visualPosition * Math.max(0, internalSlider.availableWidth - width)
               : internalSlider.leftPadding + (internalSlider.availableWidth - width) / 2
            y: control.horizontal
               ? internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
               : internalSlider.topPadding + (1 - internalSlider.visualPosition) * Math.max(0, internalSlider.availableHeight - height)
            width: control.horizontal ? control.thumbWidth : control.thumbHeight
            height: control.horizontal ? control.thumbHeight : control.thumbWidth

            Rectangle {
                id: thumb
                objectName: "meoSliderThumb"
                z: 1
                anchors.centerIn: parent
                width: control.horizontal
                       ? (internalSlider.pressed ? control.pressedThumbWidth : control.thumbWidth)
                       : (control.effectiveTrackStyle === "split" ? control.thumbHeight : control.thumbWidth)
                height: control.horizontal
                        ? (control.effectiveTrackStyle === "split" ? control.thumbHeight : control.thumbWidth)
                        : control.thumbWidth
                radius: width / 2
                color: control.resolvedThumbColor
                border.width: 0

                Behavior on width {
                    enabled: !control.reduceMotion
                    NumberAnimation {
                        duration: internalSlider.pressed
                                  ? MeoTheme.motionDurationPress
                                  : MeoTheme.motionDurationSelection
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: internalSlider.pressed ? MeoTheme.motionEasingStandardDecelerate : MeoTheme.motionEasingEmphasizedDecelerate
                    }
                }
            }

            Rectangle {
                id: valueLabel
                objectName: "meoSliderValueIndicator"
                z: 2
                x: control.horizontal ? (parent.width - width) / 2 : parent.width + 12 * control.themeGlobalScale
                y: control.horizontal ? -height - MeoTheme.sliderValueIndicatorGap : (parent.height - height) / 2
                width: Math.max(MeoTheme.sliderValueIndicatorSize,
                                labelText.implicitWidth + 20 * control.themeGlobalScale)
                height: MeoTheme.sliderValueIndicatorSize
                radius: height / 2
                color: control.themeInverseSurface
                visible: control.valueLabelEnabled && (internalSlider.pressed || internalSlider.hovered)
                opacity: visible ? 1.0 : 0.0

                Text {
                    id: labelText
                    anchors.centerIn: parent
                    text: control.discrete ? control.value.toFixed(0) : control.value.toFixed(1)
                    color: control.themeOnInverseSurface
                    font.family: MeoTheme.typefacePlain
                    font.pixelSize: MeoTheme.labelLarge.size * control.themeGlobalScale
                    font.weight: MeoTheme.labelLarge.weight
                }

                Rectangle {
                    visible: control.horizontal
                    anchors.top: parent.bottom
                    anchors.topMargin: -4 * control.themeGlobalScale
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 8 * control.themeGlobalScale
                    height: 8 * control.themeGlobalScale
                    rotation: 45
                    color: control.themeInverseSurface
                }

                Behavior on opacity {
                    enabled: !control.reduceMotion
                    NumberAnimation { duration: control.motionStateDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
                }
            }

            Item {
                objectName: "meoSliderStateLayer"
                anchors.centerIn: parent
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                z: 0

                MeoStateLayer {
                    objectName: "meoSliderThumbStateLayer"
                    anchors.fill: parent
                    shape: "circle"
                    hovered: internalSlider.hovered
                    pressed: internalSlider.pressed
                    dragged: control._dragged
                    focused: internalSlider.activeFocus
                    rippleEnabled: true
                    color: control.themePrimary
                }
            }
        }
    }
}
