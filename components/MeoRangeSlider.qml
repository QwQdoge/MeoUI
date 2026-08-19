import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property real from: 0.0
    property real to: 100.0
    property real firstValue: 20.0
    property real secondValue: 80.0
    property bool discrete: false
    property real stepSize: 1.0
    property bool isThick: false // 🌟 MD3 Expressive: Thicker track variant
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property bool wavy: false // 🌟 MD3 Expressive: Wavy track variant
    property bool valueLabelEnabled: true

    signal moved()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // 📐 尺寸映射 (MD3 Expressive Slider)
    readonly property real trackHeight: {
        if (isThick) return 16 * themeGlobalScale;
        if (size === "s") return (MeoTheme.sliderTrackHeightS || 16 * themeGlobalScale)
        if (size === "m") return (MeoTheme.sliderTrackHeightM || 28 * themeGlobalScale)
        if (size === "l") return (MeoTheme.sliderTrackHeightL || 36 * themeGlobalScale)
        if (size === "xl") return (MeoTheme.sliderTrackHeightXL || 44 * themeGlobalScale)
        return (MeoTheme.sliderTrackHeightXS || 4 * themeGlobalScale) // default "xs"
    }

    readonly property real motionTrackDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationSelection !== 'undefined') ? MeoTheme.motionDurationSelection : 200
    readonly property real motionStateDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationState !== 'undefined') ? MeoTheme.motionDurationState : 150
    readonly property real motionWaveDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationWave !== 'undefined') ? MeoTheme.motionDurationWave : 1500


    readonly property real thumbWidth: {
        if (size === "xs") return 20 * themeGlobalScale
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderThumbWidthExpressive !== 'undefined') ? MeoTheme.sliderThumbWidthExpressive : 4 * themeGlobalScale
    }

    readonly property real thumbHeight: {
        if (size === "xs") return 20 * themeGlobalScale
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderThumbHeightExpressive !== 'undefined') ? MeoTheme.sliderThumbHeightExpressive : 44 * themeGlobalScale
    }

    readonly property real thumbGap: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderThumbGapExpressive !== 'undefined') ? MeoTheme.sliderThumbGapExpressive : 6 * themeGlobalScale

    readonly property bool waveAnimationActive: wavy && visible && enabled && width > 0 && height > 0 && (internalSlider.first.hovered || internalSlider.first.pressed || internalSlider.second.hovered || internalSlider.second.pressed || internalSlider.activeFocus)

    implicitWidth: 200 * themeGlobalScale
    implicitHeight: wavy ? 44 * themeGlobalScale : Math.max(thumbHeight + 8 * themeGlobalScale, 44 * themeGlobalScale)

    RangeSlider {
        id: internalSlider
        anchors.fill: parent
        from: control.from
        to: control.to
        first.value: control.firstValue
        second.value: control.secondValue
        stepSize: control.discrete ? control.stepSize : 0.0
        live: true

        first.onMoved: {
            control.firstValue = first.value
            control.moved()
        }
        second.onMoved: {
            control.secondValue = second.value
            control.moved()
        }

        background: Item {
            x: internalSlider.leftPadding
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: internalSlider.availableWidth
            height: Math.max(control.implicitHeight, trackRect.height + 8 * control.themeGlobalScale)

            // 轨道背景
            Rectangle {
                id: trackRect
                visible: !control.wavy
                anchors.centerIn: parent
                width: parent.width
                height: control.trackHeight
                radius: height / 2
                color: Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.12)

                Behavior on height { NumberAnimation { duration: 200 } }

                // Tick marks for discrete slider
                Repeater {
                    model: control.discrete ? Math.floor((control.to - control.from) / control.stepSize) + 1 : 0
                    delegate: Rectangle {
                        x: index * (parent.width / (model - 1)) - width / 2
                        y: (parent.height - height) / 2
                        width: (control.size !== "xs" ? 4 : 2) * control.themeGlobalScale
                        height: (control.size !== "xs" ? 4 : 2) * control.themeGlobalScale
                        radius: width / 2
                        color: control.themeOnSurfaceVariant
                        opacity: 0.38
                    }
                }
            }

            // 已填充部分 (Active Range)
            Rectangle {
                visible: !control.wavy
                y: (parent.height - height) / 2
                x: internalSlider.first.visualPosition * parent.width
                width: (internalSlider.second.visualPosition - internalSlider.first.visualPosition) * parent.width
                height: trackRect.height
                radius: height / 2
                color: control.themePrimary

                Behavior on height { NumberAnimation { duration: 200 } }
            }

            Canvas {
                id: wavyCanvas
                visible: control.wavy
                anchors.fill: parent
                property real phase: 0

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    var strokeWidth = (control.isThick ? 10 : (control.size === "xs" ? 4 : 8)) * control.themeGlobalScale;
                    var mid = height / 2;
                    var startWidth = width * internalSlider.first.visualPosition;
                    var endWidth = width * internalSlider.second.visualPosition;
                    var amp = Math.min(strokeWidth * 0.34, 3.5 * control.themeGlobalScale);
                    var wavelength = 40 * control.themeGlobalScale;
                    var sampleStep = Math.max(1, 1.25 * control.themeGlobalScale);

                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";
                    ctx.lineWidth = strokeWidth;

                    // Inactive wavy track
                    ctx.strokeStyle = Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.12);
                    ctx.beginPath();
                    ctx.moveTo(0, mid);
                    ctx.lineTo(width, mid);
                    ctx.stroke();

                    // Active wavy track
                    ctx.strokeStyle = control.themePrimary;
                    ctx.beginPath();
                    for (var x = startWidth; x <= endWidth; x += sampleStep) {
                        var y = mid + Math.sin((x + phase) / wavelength * Math.PI * 2) * amp;
                        if (x === startWidth) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                    }
                    if (endWidth > startWidth) {
                        var endY = mid + Math.sin((endWidth + phase) / wavelength * Math.PI * 2) * amp;
                        ctx.lineTo(endWidth, endY);
                    }
                    ctx.stroke();
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
                    duration: control.motionWaveDuration
                    loops: Animation.Infinite
                    easing.type: Easing.Linear
                }
            }

        }

        first.handle: Item {
            x: internalSlider.leftPadding + internalSlider.first.visualPosition * (internalSlider.availableWidth - width)
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: control.thumbWidth
            height: control.thumbHeight

            Rectangle {
                anchors.centerIn: parent
                width: internalSlider.first.pressed ? 2 * control.themeGlobalScale : control.thumbWidth
                height: parent.height
                radius: width / 2
                color: control.size !== "xs" ? control.themeOnPrimary : control.themePrimary
                border.color: control.size !== "xs" ? control.themePrimary : "transparent"
                border.width: control.size !== "xs" ? 1 * control.themeGlobalScale : 0
                Behavior on width { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) } }
            }

            // 🌟 Value Label (MD3 Tooltip style)
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 12 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(32 * control.themeGlobalScale, firstLabelText.implicitWidth + 16 * control.themeGlobalScale)
                height: 28 * control.themeGlobalScale
                radius: height / 2
                color: control.themePrimary
                visible: internalSlider.first.pressed

                Text {
                    id: firstLabelText
                    anchors.centerIn: parent
                    text: control.discrete ? control.firstValue.toFixed(0) : control.firstValue.toFixed(1)
                    color: control.themeOnPrimary
                    font.pixelSize: 12 * control.themeGlobalScale
                    font.weight: Font.Medium
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

                scale: internalSlider.first.pressed ? 1.0 : 0.0
                opacity: internalSlider.first.pressed ? 1.0 : 0.0
                Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // State layer
            Rectangle {
                anchors.centerIn: parent
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                radius: 20 * control.themeGlobalScale
                z: -1
                color: internalSlider.first.pressed ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12) :
                       (internalSlider.first.hovered ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.08) : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        second.handle: Item {
            x: internalSlider.leftPadding + internalSlider.second.visualPosition * (internalSlider.availableWidth - width)
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: control.thumbWidth
            height: control.thumbHeight

            Rectangle {
                anchors.centerIn: parent
                width: internalSlider.second.pressed ? 2 * control.themeGlobalScale : control.thumbWidth
                height: parent.height
                radius: width / 2
                color: control.size !== "xs" ? control.themeOnPrimary : control.themePrimary
                border.color: control.size !== "xs" ? control.themePrimary : "transparent"
                border.width: control.size !== "xs" ? 1 * control.themeGlobalScale : 0
                Behavior on width { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) } }
            }

            // 🌟 Value Label (MD3 Tooltip style)
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 12 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(32 * control.themeGlobalScale, secondLabelText.implicitWidth + 16 * control.themeGlobalScale)
                height: 28 * control.themeGlobalScale
                radius: height / 2
                color: control.themePrimary
                visible: internalSlider.second.pressed

                Text {
                    id: secondLabelText
                    anchors.centerIn: parent
                    text: control.discrete ? control.secondValue.toFixed(0) : control.secondValue.toFixed(1)
                    color: control.themeOnPrimary
                    font.pixelSize: 12 * control.themeGlobalScale
                    font.weight: Font.Medium
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

                scale: internalSlider.second.pressed ? 1.0 : 0.0
                opacity: internalSlider.second.pressed ? 1.0 : 0.0
                Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // State layer
            Rectangle {
                anchors.centerIn: parent
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                radius: 20 * control.themeGlobalScale
                z: -1
                color: internalSlider.second.pressed ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12) :
                       (internalSlider.second.hovered ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.08) : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
