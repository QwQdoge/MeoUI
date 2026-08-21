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
    property bool snapMode: false
    property bool tickMarksEnabled: discrete
    property bool valueLabelEnabled: true

    // Visual variants
    property bool isThick: false
    property bool wavy: false
    property bool expressive: true
    property string size: expressive ? "m" : "xs" // "xs" | "s" | "m" | "l" | "xl"
    property string trackStyle: expressive && size !== "xs" ? "split" : "standard" // "standard" | "split"
    property string leadingIcon: ""
    property bool leadingIconEnabled: leadingIcon.length > 0
    property color activeTrackColor: trackStyle === "split"
                                     ? (themeIsDarkMode ? themePrimary : themePrimaryContainer)
                                     : themePrimary
    property color inactiveTrackColor: trackStyle === "split"
                                       ? (themeIsDarkMode ? themeSurfaceContainerLow : themeSurfaceContainerHighest)
                                       : Qt.rgba(themeOnSurfaceVariant.r,
                                                 themeOnSurfaceVariant.g,
                                                 themeOnSurfaceVariant.b,
                                                 0.12)
    property color thumbColor: trackStyle === "split" ? activeTrackColor : (size === "xs" ? themePrimary : themeOnPrimary)

    readonly property bool pressed: internalSlider.pressed
    signal moved(real value)

    function normalizedValue(rawValue) {
        var lower = Math.min(from, to)
        var upper = Math.max(from, to)
        var nextValue = Math.max(lower, Math.min(upper, rawValue))

        if ((discrete || snapMode || tickMarksEnabled) && stepSize > 0) {
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

    // Theme fallbacks
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
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined")
                                                   ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined")
                                                      ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerHighest !== "undefined")
                                                          ? MeoTheme.surfaceContainerHighest : "#E6E0E9"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined")
                                             ? MeoTheme.globalScale : 1.0
    readonly property bool reduceMotion: (typeof MeoTheme !== "undefined" && typeof MeoTheme.reduceMotion !== "undefined")
                                         ? MeoTheme.reduceMotion : false
    readonly property int motionStateDuration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationFast !== "undefined")
                                               ? MeoTheme.motionDurationFast : 120
    readonly property int motionTrackDuration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationMedium1 !== "undefined")
                                               ? MeoTheme.motionDurationMedium1 : 250
    readonly property int motionWaveDuration: reduceMotion ? 0 : 720
    readonly property var fontLabelSmall: (typeof MeoTheme !== "undefined" && typeof MeoTheme.labelSmall !== "undefined")
                                           ? MeoTheme.labelSmall : ({ "size": 12, "weight": Font.Medium })

    // Geometry
    readonly property real trackHeight: {
        if (size === "xs") {
            return (typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderTrackHeightXS !== "undefined")
                    ? MeoTheme.sliderTrackHeightXS : 4 * themeGlobalScale
        }
        if (size === "s") {
            return (typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderTrackHeightS !== "undefined")
                    ? MeoTheme.sliderTrackHeightS : 16 * themeGlobalScale
        }
        if (size === "m") {
            return (typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderTrackHeightM !== "undefined")
                    ? MeoTheme.sliderTrackHeightM : 28 * themeGlobalScale
        }
        if (size === "l") {
            return (typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderTrackHeightL !== "undefined")
                    ? MeoTheme.sliderTrackHeightL : 36 * themeGlobalScale
        }
        if (size === "xl") {
            return (typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderTrackHeightXL !== "undefined")
                    ? MeoTheme.sliderTrackHeightXL : 44 * themeGlobalScale
        }
        return 4 * themeGlobalScale
    }

    readonly property real renderedTrackHeight: isThick
                                                ? Math.max(trackHeight, 16 * themeGlobalScale)
                                                : trackHeight
    readonly property real thumbWidth: size === "xs"
                                       ? 20 * themeGlobalScale
                                       : ((typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderThumbWidthExpressive !== "undefined")
                                          ? MeoTheme.sliderThumbWidthExpressive : 4 * themeGlobalScale)
    readonly property real thumbHeight: {
        var tokenHeight = (typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderThumbHeightExpressive !== "undefined")
                ? MeoTheme.sliderThumbHeightExpressive : 44 * themeGlobalScale
        if (size === "xs")
            return 20 * themeGlobalScale
        if (trackStyle === "split")
            return Math.max(tokenHeight, renderedTrackHeight + 8 * themeGlobalScale)
        return tokenHeight
    }
    readonly property real thumbGap: (typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderThumbGapExpressive !== "undefined")
                                     ? MeoTheme.sliderThumbGapExpressive : 6 * themeGlobalScale
    readonly property real trackPositionX: Math.max(0,
                                                    Math.min(internalSlider.availableWidth,
                                                             internalSlider.visualPosition * internalSlider.availableWidth))
    readonly property real handleCenterX: {
        if (!internalSlider)
            return 0
        var travel = Math.max(0, internalSlider.availableWidth - thumbWidth)
        return internalSlider.visualPosition * travel + thumbWidth / 2
    }
    readonly property real activeTrackWidth: trackPositionX
    readonly property real splitActiveWidth: Math.max(0, Math.min(internalSlider.availableWidth, handleCenterX - thumbGap))
    readonly property real splitInactiveX: Math.max(0, Math.min(internalSlider.availableWidth, handleCenterX + thumbGap))
    readonly property bool waveAnimationActive: wavy
                                                && visible
                                                && enabled
                                                && width > 0
                                                && height > 0
                                                && (internalSlider.hovered || internalSlider.pressed || internalSlider.activeFocus)
                                                && !reduceMotion

    implicitWidth: 200 * themeGlobalScale
    implicitHeight: wavy
                    ? 44 * themeGlobalScale
                    : Math.max(thumbHeight + 8 * themeGlobalScale,
                               renderedTrackHeight + 12 * themeGlobalScale,
                               44 * themeGlobalScale)

    opacity: enabled ? 1.0 : 0.38
    Behavior on opacity {
        NumberAnimation { duration: control.motionStateDuration }
    }

    Slider {
        id: internalSlider
        anchors.fill: parent
        from: control.from
        to: control.to
        value: control.value
        stepSize: (control.discrete || control.snapMode || control.tickMarksEnabled) ? control.stepSize : 0.0
        live: true
        enabled: control.enabled

        onMoved: control.setValue(value)

        background: Item {
            id: trackArea
            x: internalSlider.leftPadding
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: internalSlider.availableWidth
            height: control.implicitHeight

            // Standard Material track. Kept for compact sliders and compatibility.
            Rectangle {
                id: standardTrack
                visible: !control.wavy && control.trackStyle !== "split"
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.inactiveTrackColor

                Behavior on height {
                    NumberAnimation { duration: control.motionTrackDuration }
                }
            }

            Rectangle {
                visible: standardTrack.visible
                anchors.verticalCenter: parent.verticalCenter
                width: control.activeTrackWidth
                height: standardTrack.height
                radius: height / 2
                color: control.activeTrackColor

                Behavior on width {
                    enabled: !internalSlider.pressed
                    NumberAnimation {
                        duration: control.motionTrackDuration
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined")
                                            ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                    }
                }
                Behavior on height {
                    NumberAnimation { duration: control.motionTrackDuration }
                }
            }

            // Android 16 / M3 Expressive split pill track.
            // The active and inactive pills stop before the thumb instead of drawing
            // a continuous rail underneath it, which keeps the separator crisp.
            Rectangle {
                id: splitActiveTrack
                visible: !control.wavy && control.trackStyle === "split"
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                width: control.splitActiveWidth
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.activeTrackColor

                Behavior on width {
                    enabled: !internalSlider.pressed
                    NumberAnimation {
                        duration: control.motionTrackDuration
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined")
                                            ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                    }
                }
                Behavior on height {
                    NumberAnimation { duration: control.motionTrackDuration }
                }
            }

            Rectangle {
                visible: splitActiveTrack.visible
                anchors.verticalCenter: parent.verticalCenter
                x: control.splitInactiveX
                width: Math.max(0, parent.width - x)
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.inactiveTrackColor

                Behavior on x {
                    enabled: !internalSlider.pressed
                    NumberAnimation {
                        duration: control.motionTrackDuration
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined")
                                            ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                    }
                }
                Behavior on width {
                    enabled: !internalSlider.pressed
                    NumberAnimation {
                        duration: control.motionTrackDuration
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined")
                                            ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                    }
                }
                Behavior on height {
                    NumberAnimation { duration: control.motionTrackDuration }
                }
            }

            MeoIcon {
                visible: splitActiveTrack.visible
                         && control.leadingIconEnabled
                         && splitActiveTrack.width >= 48 * control.themeGlobalScale
                anchors.left: splitActiveTrack.left
                anchors.leftMargin: 12 * control.themeGlobalScale
                anchors.verticalCenter: splitActiveTrack.verticalCenter
                icon: control.leadingIcon
                size: Math.min(24,
                               Math.max(16,
                                        control.renderedTrackHeight / control.themeGlobalScale - 8))
                color: control.themeIsDarkMode ? control.themeOnPrimary : control.themeOnPrimaryContainer
                opacity: visible ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: control.motionStateDuration }
                }
            }

            // Tick marks remain on the classic track; the split pill intentionally
            // stays visually clean like Android 16 Quick Settings.
            Repeater {
                id: tickRepeater
                model: (!control.wavy
                        && control.trackStyle !== "split"
                        && (control.discrete || control.tickMarksEnabled)
                        && control.stepSize > 0)
                       ? Math.max(0, Math.floor(Math.abs(control.to - control.from) / control.stepSize) + 1)
                       : 0

                delegate: Rectangle {
                    required property int index
                    x: tickRepeater.count > 1
                       ? index * (trackArea.width / (tickRepeater.count - 1)) - width / 2
                       : 0
                    y: (trackArea.height - height) / 2
                    width: (control.size !== "xs" ? 4 : 2) * control.themeGlobalScale
                    height: width
                    radius: width / 2
                    color: control.themeOnSurfaceVariant
                    opacity: 0.38
                }
            }

            Canvas {
                id: wavyCanvas
                visible: control.wavy
                anchors.fill: parent
                property real phase: 0

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var strokeWidth = (control.isThick ? 10 : (control.size === "xs" ? 4 : 8)) * control.themeGlobalScale
                    var mid = height / 2
                    var progressWidth = Math.max(0, Math.min(width, control.trackPositionX))
                    var amp = Math.min(strokeWidth * 0.34, 3.5 * control.themeGlobalScale)
                    var wavelength = 40 * control.themeGlobalScale
                    var sampleStep = Math.max(1, 1.25 * control.themeGlobalScale)

                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.lineWidth = strokeWidth

                    ctx.strokeStyle = control.inactiveTrackColor
                    ctx.beginPath()
                    ctx.moveTo(0, mid)
                    ctx.lineTo(width, mid)
                    ctx.stroke()

                    ctx.strokeStyle = control.themePrimary
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
                    easing.type: Easing.Linear
                }
            }
        }

        handle: Item {
            id: sliderHandle
            x: internalSlider.leftPadding
               + internalSlider.visualPosition * Math.max(0, internalSlider.availableWidth - width)
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: control.thumbWidth
            height: control.thumbHeight

            Rectangle {
                id: thumb
                anchors.centerIn: parent
                width: internalSlider.pressed ? 2 * control.themeGlobalScale : control.thumbWidth
                height: control.trackStyle === "split"
                        ? control.thumbHeight
                        : (control.size === "xs" ? control.thumbWidth : control.thumbHeight)
                radius: width / 2
                color: control.thumbColor
                border.color: control.trackStyle === "split"
                              ? "transparent"
                              : (control.size !== "xs" ? control.themePrimary : "transparent")
                border.width: control.trackStyle === "split"
                              ? 0
                              : (control.size !== "xs" ? 1 * control.themeGlobalScale : 0)

                Behavior on width {
                    NumberAnimation {
                        duration: control.motionStateDuration
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined")
                                            ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
                    }
                }
                Behavior on height {
                    NumberAnimation { duration: control.motionStateDuration }
                }
            }

            Rectangle {
                id: valueLabel
                anchors.bottom: parent.top
                anchors.bottomMargin: 12 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(32 * control.themeGlobalScale,
                                labelText.implicitWidth + 16 * control.themeGlobalScale)
                height: 28 * control.themeGlobalScale
                radius: height / 2
                color: control.themePrimary
                visible: control.valueLabelEnabled && (internalSlider.pressed || internalSlider.hovered)
                scale: visible ? 1.0 : 0.92
                opacity: visible ? 1.0 : 0.0

                Text {
                    id: labelText
                    anchors.centerIn: parent
                    text: control.discrete ? control.value.toFixed(0) : control.value.toFixed(1)
                    color: control.themeOnPrimary
                    font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain)
                                 ? MeoTheme.typefacePlain : "Roboto"
                    font.pixelSize: control.fontLabelSmall.size * control.themeGlobalScale
                    font.weight: control.fontLabelSmall.weight
                }

                Rectangle {
                    anchors.top: parent.bottom
                    anchors.topMargin: -4 * control.themeGlobalScale
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 8 * control.themeGlobalScale
                    height: 8 * control.themeGlobalScale
                    rotation: 45
                    color: control.themePrimary
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: control.motionStateDuration
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined")
                                            ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                    }
                }
                Behavior on opacity {
                    NumberAnimation { duration: control.motionStateDuration }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                radius: width / 2
                z: -1
                color: {
                    if (internalSlider.pressed)
                        return Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12)
                    if (internalSlider.hovered)
                        return Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.08)
                    if (internalSlider.activeFocus)
                        return Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.10)
                    return "transparent"
                }

                Behavior on color {
                    ColorAnimation { duration: control.motionStateDuration }
                }
            }
        }
    }
}
