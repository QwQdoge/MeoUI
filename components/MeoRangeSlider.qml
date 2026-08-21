import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property real from: 0.0
    property real to: 100.0
    property real firstValue: 20.0
    property real secondValue: 80.0
    property bool discrete: false
    property real stepSize: 1.0
    property bool isThick: false
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property bool wavy: false
    property bool valueLabelEnabled: true
    property string trackStyle: size === "xs" ? "standard" : "split" // "standard" | "split"

    property color activeTrackColor: trackStyle === "split"
                                     ? (isDarkMode ? themePrimary : themePrimaryContainer)
                                     : themePrimary
    property color inactiveTrackColor: trackStyle === "split"
                                       ? (isDarkMode ? themeSurfaceContainerLow : themeSurfaceContainerHighest)
                                       : Qt.rgba(themeOnSurfaceVariant.r, themeOnSurfaceVariant.g, themeOnSurfaceVariant.b, 0.12)
    property color thumbColor: trackStyle === "split" ? activeTrackColor : (size === "xs" ? themePrimary : themeOnPrimary)

    signal moved()

    readonly property bool isDarkMode: (typeof MeoTheme !== "undefined" && typeof MeoTheme.isDarkMode !== "undefined") ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primaryContainer !== "undefined") ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnPrimary !== "undefined") ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined") ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerHighest !== "undefined") ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property bool reduceMotion: (typeof MeoTheme !== "undefined" && typeof MeoTheme.reduceMotion !== "undefined") ? MeoTheme.reduceMotion : false
    readonly property int motionStateDuration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 100
    readonly property int motionTrackDuration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSelection !== "undefined") ? MeoTheme.motionDurationSelection : 220
    readonly property int motionWaveDuration: reduceMotion ? 0 : 720

    readonly property real trackHeight: {
        if (size === "xs") return 4 * themeGlobalScale
        if (size === "s") return 16 * themeGlobalScale
        if (size === "m") return 28 * themeGlobalScale
        if (size === "l") return 36 * themeGlobalScale
        if (size === "xl") return 44 * themeGlobalScale
        return 28 * themeGlobalScale
    }
    readonly property real renderedTrackHeight: isThick ? Math.max(trackHeight, 16 * themeGlobalScale) : trackHeight
    readonly property real thumbWidth: size === "xs" ? 20 * themeGlobalScale
                                                      : ((typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderThumbWidthExpressive !== "undefined") ? MeoTheme.sliderThumbWidthExpressive : 4 * themeGlobalScale)
    readonly property real thumbHeight: size === "xs" ? 20 * themeGlobalScale
                                                       : Math.max((typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderThumbHeightExpressive !== "undefined") ? MeoTheme.sliderThumbHeightExpressive : 44 * themeGlobalScale,
                                                                  renderedTrackHeight + 8 * themeGlobalScale)
    readonly property real thumbGap: (typeof MeoTheme !== "undefined" && typeof MeoTheme.sliderThumbGapExpressive !== "undefined") ? MeoTheme.sliderThumbGapExpressive : 6 * themeGlobalScale
    readonly property real firstTrackX: internalSlider.first.visualPosition * internalSlider.availableWidth
    readonly property real secondTrackX: internalSlider.second.visualPosition * internalSlider.availableWidth
    readonly property real lowerTrackX: Math.min(firstTrackX, secondTrackX)
    readonly property real upperTrackX: Math.max(firstTrackX, secondTrackX)
    readonly property bool waveAnimationActive: wavy && visible && enabled && !reduceMotion
                                                && (internalSlider.first.hovered || internalSlider.first.pressed
                                                    || internalSlider.second.hovered || internalSlider.second.pressed
                                                    || internalSlider.activeFocus)

    implicitWidth: 220 * themeGlobalScale
    implicitHeight: Math.max(thumbHeight + 8 * themeGlobalScale, 52 * themeGlobalScale)
    opacity: enabled ? 1.0 : 0.38
    Behavior on opacity { NumberAnimation { duration: control.motionStateDuration } }

    RangeSlider {
        id: internalSlider
        anchors.fill: parent
        from: control.from
        to: control.to
        first.value: control.firstValue
        second.value: control.secondValue
        stepSize: control.discrete ? control.stepSize : 0.0
        live: true
        enabled: control.enabled

        first.onMoved: {
            control.firstValue = first.value
            control.moved()
        }
        second.onMoved: {
            control.secondValue = second.value
            control.moved()
        }

        background: Item {
            id: trackArea
            x: internalSlider.leftPadding
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: internalSlider.availableWidth
            height: control.implicitHeight

            // Classic range track retained for compact/legacy use.
            Rectangle {
                id: standardTrack
                visible: !control.wavy && control.trackStyle !== "split"
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.inactiveTrackColor
            }

            Rectangle {
                visible: standardTrack.visible
                anchors.verticalCenter: parent.verticalCenter
                x: control.lowerTrackX
                width: Math.max(0, control.upperTrackX - control.lowerTrackX)
                height: standardTrack.height
                radius: height / 2
                color: control.activeTrackColor
                Behavior on x { NumberAnimation { duration: control.motionTrackDuration } }
                Behavior on width { NumberAnimation { duration: control.motionTrackDuration } }
            }

            // Android 16 / Pixel expressive range track: three independent pills.
            Rectangle {
                visible: !control.wavy && control.trackStyle === "split"
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                width: Math.max(0, control.lowerTrackX - control.thumbGap)
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.inactiveTrackColor
                Behavior on width { NumberAnimation { duration: control.motionTrackDuration } }
            }

            Rectangle {
                visible: !control.wavy && control.trackStyle === "split"
                anchors.verticalCenter: parent.verticalCenter
                x: Math.min(parent.width, control.lowerTrackX + control.thumbGap)
                width: Math.max(0, control.upperTrackX - control.lowerTrackX - control.thumbGap * 2)
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.activeTrackColor
                Behavior on x { NumberAnimation { duration: control.motionTrackDuration } }
                Behavior on width { NumberAnimation { duration: control.motionTrackDuration } }
            }

            Rectangle {
                visible: !control.wavy && control.trackStyle === "split"
                anchors.verticalCenter: parent.verticalCenter
                x: Math.min(parent.width, control.upperTrackX + control.thumbGap)
                width: Math.max(0, parent.width - x)
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.inactiveTrackColor
                Behavior on x { NumberAnimation { duration: control.motionTrackDuration } }
                Behavior on width { NumberAnimation { duration: control.motionTrackDuration } }
            }

            // Tick marks intentionally stay on the classic compact track.
            Repeater {
                id: tickRepeater
                model: (!control.wavy && control.trackStyle !== "split" && control.discrete && control.stepSize > 0)
                       ? Math.max(0, Math.floor(Math.abs(control.to - control.from) / control.stepSize) + 1)
                       : 0
                delegate: Rectangle {
                    required property int index
                    x: tickRepeater.count > 1 ? index * (trackArea.width / (tickRepeater.count - 1)) - width / 2 : 0
                    y: (trackArea.height - height) / 2
                    width: 2 * control.themeGlobalScale
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
                    if (width <= 0 || height <= 0)
                        return

                    var strokeWidth = (control.isThick ? 10 : (control.size === "xs" ? 4 : 8)) * control.themeGlobalScale
                    var mid = height / 2
                    var startX = control.lowerTrackX
                    var endX = control.upperTrackX
                    var amp = control.reduceMotion ? 0 : Math.min(strokeWidth * 0.34, 3.5 * control.themeGlobalScale)
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

                    if (endX > startX) {
                        ctx.strokeStyle = control.activeTrackColor
                        ctx.beginPath()
                        for (var x = startX; x < endX; x += sampleStep) {
                            var y = mid + Math.sin((x + phase) / wavelength * Math.PI * 2) * amp
                            if (x === startX) ctx.moveTo(x, y)
                            else ctx.lineTo(x, y)
                        }
                        var endY = mid + Math.sin((endX + phase) / wavelength * Math.PI * 2) * amp
                        ctx.lineTo(endX, endY)
                        ctx.stroke()
                    }
                }

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPhaseChanged: requestPaint()

                Connections {
                    target: internalSlider.first
                    function onVisualPositionChanged() { wavyCanvas.requestPaint() }
                }
                Connections {
                    target: internalSlider.second
                    function onVisualPositionChanged() { wavyCanvas.requestPaint() }
                }

                NumberAnimation on phase {
                    running: control.waveAnimationActive
                    from: 0
                    to: 40 * control.themeGlobalScale
                    duration: Math.max(1, control.motionWaveDuration)
                    loops: Animation.Infinite
                    easing.type: Easing.Linear
                }
            }
        }

        first.handle: RangeThumb {
            sliderHandle: internalSlider.first
            displayValue: control.firstValue
        }
        second.handle: RangeThumb {
            sliderHandle: internalSlider.second
            displayValue: control.secondValue
        }
    }

    component RangeThumb: Item {
        id: rangeThumb
        required property var sliderHandle
        required property real displayValue

        x: internalSlider.leftPadding + sliderHandle.visualPosition * Math.max(0, internalSlider.availableWidth - width)
        y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
        width: control.thumbWidth
        height: control.thumbHeight

        Rectangle {
            id: thumb
            anchors.centerIn: parent
            width: rangeThumb.sliderHandle.pressed ? 2 * control.themeGlobalScale : control.thumbWidth
            height: control.trackStyle === "split" ? control.thumbHeight : (control.size === "xs" ? control.thumbWidth : control.thumbHeight)
            radius: width / 2
            color: control.thumbColor
            border.color: control.trackStyle === "split" ? "transparent" : (control.size !== "xs" ? control.themePrimary : "transparent")
            border.width: control.trackStyle === "split" ? 0 : (control.size !== "xs" ? 1 * control.themeGlobalScale : 0)

            Behavior on width {
                NumberAnimation {
                    duration: control.motionStateDuration
                    easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                }
            }
        }

        Rectangle {
            visible: control.valueLabelEnabled && rangeThumb.sliderHandle.pressed
            anchors.bottom: parent.top
            anchors.bottomMargin: 10 * control.themeGlobalScale
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(36 * control.themeGlobalScale, valueText.implicitWidth + 18 * control.themeGlobalScale)
            height: 32 * control.themeGlobalScale
            radius: height / 2
            color: control.themePrimary

            Text {
                id: valueText
                anchors.centerIn: parent
                text: control.discrete ? Math.round(rangeThumb.displayValue).toString() : rangeThumb.displayValue.toFixed(1)
                color: control.themeOnPrimary
                font.pixelSize: 12 * control.themeGlobalScale
                font.weight: Font.Medium
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 40 * control.themeGlobalScale
            height: width
            radius: width / 2
            z: -1
            color: rangeThumb.sliderHandle.pressed
                   ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12)
                   : rangeThumb.sliderHandle.hovered
                     ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.08)
                     : "transparent"
            Behavior on color { ColorAnimation { duration: control.motionStateDuration } }
        }
    }
}
