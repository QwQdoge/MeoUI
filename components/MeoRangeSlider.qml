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
    property bool expressive: false
    property string size: expressive ? "m" : "xs" // "xs" | "s" | "m" | "l" | "xl"
    property bool wavy: false
    property bool valueLabelEnabled: false
    property string trackStyle: expressive && size !== "xs" ? "split" : "standard" // "standard" | "split"

    // Expressive range selection follows the same primary/neutral pair as the
    // standard slider. The prior primary-container treatment lost contrast in
    // light schemes and did not match the shared slider contract.
    property color activeTrackColor: themePrimary
    property color inactiveTrackColor: themeSecondaryContainer
    property color thumbColor: themePrimary

    signal moved()

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
    readonly property int motionWaveDuration: reduceMotion ? 0 : 720

    function compositeColor(foreground, opacity, background) {
        return Qt.rgba(foreground.r * opacity + background.r * (1 - opacity),
                       foreground.g * opacity + background.g * (1 - opacity),
                       foreground.b * opacity + background.b * (1 - opacity),
                       1)
    }
    readonly property color resolvedActiveTrackColor: enabled ? activeTrackColor
                                                       : compositeColor(themeOnSurface, MeoTheme.disabledContentOpacity, themeSurface)
    readonly property color resolvedInactiveTrackColor: enabled ? inactiveTrackColor
                                                         : compositeColor(themeOnSurface, MeoTheme.disabledContainerOpacity, themeSurface)
    readonly property color resolvedThumbColor: enabled ? thumbColor
                                                  : compositeColor(themeOnSurface, MeoTheme.disabledContentOpacity, themeSurface)

    readonly property real trackHeight: {
        if (size === "xs") return MeoTheme.sliderTrackHeightXS
        if (size === "s") return MeoTheme.sliderTrackHeightS
        if (size === "m") return MeoTheme.sliderTrackHeightM
        if (size === "l") return MeoTheme.sliderTrackHeightL
        if (size === "xl") return MeoTheme.sliderTrackHeightXL
        return MeoTheme.sliderTrackHeightXS
    }
    readonly property real renderedTrackHeight: isThick ? Math.max(trackHeight, 16 * themeGlobalScale) : trackHeight
    readonly property real expressiveThumbHeight: {
        if (size === "s") return MeoTheme.sliderThumbHeightS
        if (size === "m") return MeoTheme.sliderThumbHeightM
        if (size === "l") return MeoTheme.sliderThumbHeightL
        if (size === "xl") return MeoTheme.sliderThumbHeightXL
        return MeoTheme.sliderThumbHeightXS
    }
    readonly property real thumbWidth: MeoTheme.sliderThumbWidthExpressive
    readonly property real thumbHeight: expressiveThumbHeight
    readonly property real thumbGap: MeoTheme.sliderThumbGapExpressive
    readonly property real firstTrackX: internalSlider.first.visualPosition * internalSlider.availableWidth
    readonly property real secondTrackX: internalSlider.second.visualPosition * internalSlider.availableWidth
    readonly property real lowerTrackX: Math.min(firstTrackX, secondTrackX)
    readonly property real upperTrackX: Math.max(firstTrackX, secondTrackX)
    readonly property bool waveAnimationActive: wavy && visible && enabled && !reduceMotion
                                                && (internalSlider.first.hovered || internalSlider.first.pressed
                                                    || internalSlider.second.hovered || internalSlider.second.pressed
                                                    || internalSlider.activeFocus)

    implicitWidth: 220 * themeGlobalScale
    implicitHeight: Math.max(thumbHeight, 48 * themeGlobalScale)
    Accessible.ignored: true

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
        Accessible.name: qsTr("Range from %1 to %2").arg(Math.round(control.firstValue)).arg(Math.round(control.secondValue))

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
                objectName: "meoRangeSliderStandardTrack"
                visible: !control.wavy && control.trackStyle !== "split"
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.resolvedInactiveTrackColor
            }

            Rectangle {
                id: activeRangeTrack
                objectName: "meoRangeSliderActiveTrack"
                visible: standardTrack.visible
                anchors.verticalCenter: parent.verticalCenter
                x: control.lowerTrackX
                width: Math.max(0, control.upperTrackX - control.lowerTrackX)
                height: standardTrack.height
                radius: height / 2
                color: control.resolvedActiveTrackColor
                Behavior on x { NumberAnimation { duration: control.motionTrackDuration } }
                Behavior on width { NumberAnimation { duration: control.motionTrackDuration } }
            }

            // Android 16 / Pixel expressive range track: three independent pills.
            Rectangle {
                id: splitRangeLeadingTrack
                objectName: "meoRangeSliderSplitLeadingTrack"
                visible: !control.wavy && control.trackStyle === "split"
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                width: Math.max(0, control.lowerTrackX - control.thumbGap)
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.resolvedInactiveTrackColor
                Behavior on width { NumberAnimation { duration: control.motionTrackDuration } }
            }

            Rectangle {
                id: splitRangeActiveTrack
                objectName: "meoRangeSliderSplitActiveTrack"
                visible: !control.wavy && control.trackStyle === "split"
                anchors.verticalCenter: parent.verticalCenter
                x: Math.min(parent.width, control.lowerTrackX + control.thumbGap)
                width: Math.max(0, control.upperTrackX - control.lowerTrackX - control.thumbGap * 2)
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.resolvedActiveTrackColor
                Behavior on x { NumberAnimation { duration: control.motionTrackDuration } }
                Behavior on width { NumberAnimation { duration: control.motionTrackDuration } }
            }

            Rectangle {
                id: splitRangeTrailingTrack
                objectName: "meoRangeSliderSplitTrailingTrack"
                visible: !control.wavy && control.trackStyle === "split"
                anchors.verticalCenter: parent.verticalCenter
                x: Math.min(parent.width, control.upperTrackX + control.thumbGap)
                width: Math.max(0, parent.width - x)
                height: control.renderedTrackHeight
                radius: height / 2
                color: control.resolvedInactiveTrackColor
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
                    readonly property real tickValue: control.from + index * control.stepSize
                    color: tickValue >= control.firstValue
                           && tickValue <= control.secondValue
                           ? control.themeSecondaryContainer : control.themePrimary
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

                    ctx.strokeStyle = control.resolvedInactiveTrackColor
                    ctx.beginPath()
                    ctx.moveTo(0, mid)
                    ctx.lineTo(width, mid)
                    ctx.stroke()

                    if (endX > startX) {
                        ctx.strokeStyle = control.resolvedActiveTrackColor
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
            objectName: "meoRangeSliderThumb"
            anchors.centerIn: parent
            width: control.thumbWidth
            height: control.thumbHeight
            radius: width / 2
            color: control.resolvedThumbColor
            border.width: 0
        }

        Rectangle {
            visible: control.valueLabelEnabled && rangeThumb.sliderHandle.pressed
            anchors.bottom: parent.top
            anchors.bottomMargin: 10 * control.themeGlobalScale
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(36 * control.themeGlobalScale, valueText.implicitWidth + 18 * control.themeGlobalScale)
            height: 32 * control.themeGlobalScale
            radius: height / 2
            color: control.themeInverseSurface

            Text {
                id: valueText
                anchors.centerIn: parent
                text: control.discrete ? Math.round(rangeThumb.displayValue).toString() : rangeThumb.displayValue.toFixed(1)
                color: control.themeOnInverseSurface
                font.pixelSize: 12 * control.themeGlobalScale
                font.weight: Font.Medium
            }
        }

        Rectangle {
            objectName: "meoRangeSliderStateLayer"
            anchors.centerIn: parent
            width: 40 * control.themeGlobalScale
            height: width
            radius: width / 2
            z: -1
            color: rangeThumb.sliderHandle.pressed
                   ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b,
                             MeoTheme.stateOpacityPressed)
                   : rangeThumb.sliderHandle.hovered
                     ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b,
                               MeoTheme.stateOpacityHover)
                     : "transparent"
            Behavior on color {
                enabled: !control.reduceMotion
                ColorAnimation { duration: control.motionStateDuration }
            }
        }
    }
}
