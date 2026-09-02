import QtQuick
import QtQuick.Effects

Item {
    id: control

    // 🌟 核心属性
    property bool pressed: false
    property bool hovered: false
    property bool focused: false
    property bool dragged: false
    property bool focusRingEnabled: true
    property bool rippleEnabled: true
    property color color: "#000000" // 默认覆盖颜色（通常为 On-Surface 或 Primary）
    property real radius: 0
    // Connected groups need one continuous outer silhouette: only the first
    // and last item inherit the container corners.  Keep this in the shared
    // state-layer primitive so button groups, lists, and semantic adapters do
    // not each invent a different mask.
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius
    // Keep the state layer clipped to the same silhouette as its owner.  The
    // primitive handles rectangular, pill, and square-circle masks; a host
    // using an arbitrary MeoShape keeps responsibility for its own clip.
    property string shape: "rect"
    property real pressX: pointerTracker.containsMouse ? pointerTracker.mouseX : width / 2
    property real pressY: pointerTracker.containsMouse ? pointerTracker.mouseY : height / 2
    readonly property bool usesFullRoundMask: shape === "circle" || shape === "pill"
    readonly property real maskRadius: usesFullRoundMask ? Math.min(width, height) / 2 : radius
    readonly property real maskTopLeftRadius: usesFullRoundMask ? maskRadius : topLeftRadius
    readonly property real maskTopRightRadius: usesFullRoundMask ? maskRadius : topRightRadius
    readonly property real maskBottomLeftRadius: usesFullRoundMask ? maskRadius : bottomLeftRadius
    readonly property real maskBottomRightRadius: usesFullRoundMask ? maskRadius : bottomRightRadius

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // 🌟 状态层透明度定义 (MD3 规范)
    readonly property real hoverOpacity: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.stateOpacityHover !== 'undefined') ? MeoTheme.stateOpacityHover : 0.08
    readonly property real focusOpacity: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.stateOpacityFocus !== 'undefined') ? MeoTheme.stateOpacityFocus : 0.10
    readonly property real pressedOpacity: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.stateOpacityPressed !== 'undefined') ? MeoTheme.stateOpacityPressed : 0.10
    readonly property real draggedOpacity: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.stateOpacityDragged !== 'undefined') ? MeoTheme.stateOpacityDragged : 0.16
    readonly property int hoverDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationFast !== 'undefined') ? MeoTheme.motionDurationFast : 120
    readonly property int rippleExpandDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationRippleExpand !== 'undefined') ? MeoTheme.motionDurationRippleExpand : 280
    readonly property int rippleFadeDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationRippleFade !== 'undefined') ? MeoTheme.motionDurationRippleFade : 160

    anchors.fill: parent
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    clip: true

    MouseArea {
        id: pointerTracker
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    function trigger(x, y) {
        if (!control.enabled || !control.rippleEnabled || (typeof MeoTheme !== "undefined" && MeoTheme.reduceMotion))
            return
        rippleExpand.stop()
        rippleFade.stop()
        rippleFadeIn.stop()
        rippleLayer.originX = Math.max(0, Math.min(control.width, x))
        rippleLayer.originY = Math.max(0, Math.min(control.height, y))
        rippleLayer.radiusValue = 0
        rippleLayer.opacity = 0
        rippleFadeIn.start()
        rippleExpand.start()
    }

    onPressedChanged: {
        if (pressed && !dragged)
            trigger(pressX, pressY)
        else
            rippleFade.restart()
    }

    // A drag is a continuous state, not another click.  Stop the expanding
    // ripple immediately so sliders and draggable list items cannot leave a
    // delayed press flash behind after the pointer crosses the drag threshold.
    onDraggedChanged: {
        if (dragged) {
            rippleExpand.stop()
            rippleFadeIn.stop()
            rippleFade.restart()
        }
    }

    Item {
        id: maskedLayer
        anchors.fill: parent
        visible: baseLayer.opacity > 0 || rippleLayer.opacity > 0
        layer.enabled: visible && control.maskRadius > 0
        layer.effect: MultiEffect {
            maskEnabled: true
            maskThresholdMin: 0.5
            // Rectangle + radius is intentionally self-contained here.  The
            // state layer is used by every primitive, so importing the module
            // it belongs to would create a runtime self-import cycle.
            maskSource: Rectangle {
                width: control.width
                height: control.height
                radius: control.maskRadius
                topLeftRadius: control.maskTopLeftRadius
                topRightRadius: control.maskTopRightRadius
                bottomLeftRadius: control.maskBottomLeftRadius
                bottomRightRadius: control.maskBottomRightRadius
            }
        }

        Rectangle {
            id: baseLayer
            anchors.fill: parent
            color: control.color
            opacity: {
                if (!control.enabled) return 0
                if (control.dragged) return control.draggedOpacity
                if (control.pressed) return control.pressedOpacity
                if (control.hovered) return control.hoverOpacity
                if (control.focused) return control.focusOpacity
                return 0
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: control.hoverDuration
                    easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                }
            }
        }

        Rectangle {
            id: rippleLayer
            property real originX: control.width / 2
            property real originY: control.height / 2
            property real radiusValue: 0
            readonly property real targetRadius: Math.sqrt(Math.pow(Math.max(originX, control.width - originX), 2)
                                                        + Math.pow(Math.max(originY, control.height - originY), 2))
            x: originX - radiusValue
            y: originY - radiusValue
            width: radiusValue * 2
            height: radiusValue * 2
            radius: radiusValue
            color: control.color
            opacity: 0
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: control.maskRadius
            topLeftRadius: control.maskTopLeftRadius
            topRightRadius: control.maskTopRightRadius
            bottomLeftRadius: control.maskBottomLeftRadius
            bottomRightRadius: control.maskBottomRightRadius
            border.width: control.focused && control.focusRingEnabled ? Math.max(2, 2 * control.themeGlobalScale) : 0
            border.color: control.color
            opacity: control.enabled && control.focused && control.focusRingEnabled ? 0.78 : 0

            Behavior on opacity {
                NumberAnimation { duration: control.hoverDuration }
            }
        }
    }

    NumberAnimation {
        id: rippleExpand
        target: rippleLayer
        property: "radiusValue"
        from: 0
        to: rippleLayer.targetRadius
        duration: control.rippleExpandDuration
        easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingEmphasizedDecelerate !== 'undefined') ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
    }

    NumberAnimation {
        id: rippleFadeIn
        target: rippleLayer
        property: "opacity"
        to: control.pressedOpacity
        duration: control.hoverDuration
        easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
    }

    NumberAnimation {
        id: rippleFade
        target: rippleLayer
        property: "opacity"
        to: 0
        duration: control.hoverDuration
        easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
    }

    readonly property real stateOpacity: {
        if (!control.enabled) return 0
        if (dragged) return draggedOpacity
        if (pressed) return pressedOpacity
        if (hovered) return hoverOpacity
        if (focused) return focusOpacity
        return 0
    }
}
