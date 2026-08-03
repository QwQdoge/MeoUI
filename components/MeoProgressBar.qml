import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 M3 Expressive Progress & Wavy Indicator Suite
    property real value: 0.0 // 0.0 ~ 1.0
    property bool indeterminate: false
    property string type: "linear" // "linear" | "circular"
    property bool wavy: false // 🌟 MD3 Expressive: Wavy waveform indicator
    property bool isThick: false
    property bool vibrant: false
    property bool showTrack: true
    property color activeColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    property color trackColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property real themeMotionScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionScale !== 'undefined') ? MeoTheme.motionScale : 1.0
    readonly property bool reduceMotion: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.reduceMotion !== 'undefined') ? MeoTheme.reduceMotion : false

    // Official Wavy Parameters
    readonly property real linearWavelength: 40 * themeGlobalScale
    readonly property real linearAmplitude: reduceMotion ? 0 : 3 * themeGlobalScale
    readonly property real circularWavelengthTarget: 15 * themeGlobalScale
    readonly property real circularAmplitude: reduceMotion ? 0 : 2 * themeGlobalScale
    readonly property real strokeThickness: 4 * themeGlobalScale

    implicitWidth: type === "linear" ? 240 * themeGlobalScale : (wavy ? 48 * themeGlobalScale : 40 * themeGlobalScale)
    implicitHeight: type === "linear" ? (wavy ? 10 * themeGlobalScale : (isThick ? 8 : 4) * themeGlobalScale) : (wavy ? 48 * themeGlobalScale : 40 * themeGlobalScale)

    // Phase Timer for continuous Wave Motion (1 wavelength per second = 40dp/s)
    property real wavePhase: 0.0
    NumberAnimation on wavePhase {
        running: control.wavy && control.visible && !control.reduceMotion
        loops: Animation.Infinite
        from: 0.0
        to: 1.0
        duration: Math.round(1000 * control.themeMotionScale)
    }

    // Canvas for Linear / Circular Wavy Progress
    Canvas {
        id: wavyCanvas
        anchors.fill: parent
        visible: control.wavy
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var w = width;
            var h = height;
            var stroke = control.strokeThickness;
            var phase = control.wavePhase;

            if (control.type === "linear") {
                var centerY = h / 2;
                var amp = control.linearAmplitude;
                var wl = control.linearWavelength;

                // Track Line
                if (control.showTrack) {
                    ctx.strokeStyle = control.trackColor;
                    ctx.lineWidth = stroke;
                    ctx.lineCap = "round";
                    ctx.beginPath();
                    ctx.moveTo(0, centerY);
                    ctx.lineTo(w, centerY);
                    ctx.stroke();
                }

                // Active Wavy Line: y(x,t) = centerY + A * sin(2pi * (x/wavelength - phase))
                var activeW = w * Math.max(0.0, Math.min(1.0, control.indeterminate ? 0.6 : control.value));
                if (activeW > 0) {
                    ctx.strokeStyle = control.activeColor;
                    ctx.lineWidth = stroke;
                    ctx.lineCap = "round";
                    ctx.beginPath();

                    for (var x = 0; x <= activeW; x += 2) {
                        var y = centerY + amp * Math.sin(2 * Math.PI * (x / wl - phase));
                        if (x === 0) ctx.moveTo(x, y);
                        else ctx.lineTo(x, y);
                    }
                    ctx.stroke();

                    // Stop indicator dot (4dp)
                    ctx.fillStyle = control.activeColor;
                    ctx.beginPath();
                    ctx.arc(activeW, centerY, stroke / 2, 0, 2 * Math.PI);
                    ctx.fill();
                }
            } else {
                // Circular Wavy: r(theta, t) = R + A * sin(n * theta - 2pi * phase)
                var R = (Math.min(w, h) - stroke - amp * 2) / 2;
                var cx = w / 2;
                var cy = h / 2;

                // Seamless Closed Loop integer wave count n
                var circumference = 2 * Math.PI * R;
                var n = Math.max(3, Math.round(circumference / control.circularWavelengthTarget));

                // Track Circle
                if (control.showTrack) {
                    ctx.strokeStyle = control.trackColor;
                    ctx.lineWidth = stroke;
                    ctx.beginPath();
                    ctx.arc(cx, cy, R, 0, 2 * Math.PI);
                    ctx.stroke();
                }

                // Active Wavy Circle
                var activeAngle = 2 * Math.PI * Math.max(0.0, Math.min(1.0, control.indeterminate ? 0.75 : control.value));
                if (activeAngle > 0) {
                    ctx.strokeStyle = control.activeColor;
                    ctx.lineWidth = stroke;
                    ctx.lineCap = "round";
                    ctx.beginPath();

                    var step = Math.PI / 60;
                    for (var angle = -Math.PI / 2; angle <= -Math.PI / 2 + activeAngle; angle += step) {
                        var currR = R + amp * Math.sin(n * angle - 2 * Math.PI * phase);
                        var px = cx + currR * Math.cos(angle);
                        var py = cy + currR * Math.sin(angle);

                        if (angle === -Math.PI / 2) ctx.moveTo(px, py);
                        else ctx.lineTo(px, py);
                    }
                    ctx.stroke();
                }
            }
        }
    }

    onWavePhaseChanged: if (wavy) wavyCanvas.requestPaint()
    onValueChanged: if (wavy) wavyCanvas.requestPaint()

    // Classic Standard Linear Progress (Non-wavy)
    Rectangle {
        visible: control.type === "linear" && !control.wavy
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: control.isThick ? 8 * control.themeGlobalScale : 4 * control.themeGlobalScale
        color: control.showTrack ? control.trackColor : "transparent"
        radius: height / 2
        clip: true

        Rectangle {
            id: indicator
            visible: !control.indeterminate
            height: parent.height
            x: 0
            width: parent.width * Math.max(0, Math.min(1, control.value))
            radius: height / 2
            color: control.activeColor

            Behavior on width {
                enabled: !control.indeterminate
                NumberAnimation {
                    duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationEffectDefault !== 'undefined') ? MeoTheme.motionDurationEffectDefault : 150
                    easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
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
                    running: control.indeterminate && control.type === "linear" && !control.wavy && control.visible
                    loops: Animation.Infinite
                    PauseAnimation { duration: index === 0 ? 0 : 500 }
                    NumberAnimation {
                        from: -width
                        to: parent ? parent.width : 240
                        duration: Math.round(1200 * control.themeMotionScale)
                        easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingEmphasized !== 'undefined') ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]
                    }
                }
            }
        }
    }
}
