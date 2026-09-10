import QtQuick
import QtQuick.Effects
import ".." as Meo

Item {
    id: control

    // 🌟 核心属性
    property bool pressed: false
    property bool hovered: false
    property bool focused: false
    property bool dragged: false
    property bool focusRingEnabled: true
    property bool rippleEnabled: true
    property bool _keyboardRipplePending: false
    // `color` remains the semantic foreground/focus color for compatibility.
    // Pointer feedback itself uses the theme scrim so every filled, tonal, and
    // neutral surface becomes perceptibly darker instead of changing hue.
    property color color: theme.contentOnSurface
    property color overlayColor: theme.scrim
    property color focusColor: theme.primary
    property real rippleFeather: 2 * themeGlobalScale
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

    // MeoTheme is the only source for state and motion tokens.  Do not keep
    // a second set of fallback curves in this primitive: consumers must get a
    // complete theme or fail visibly during development.
    readonly property var theme: Meo.MeoTheme
    readonly property real themeGlobalScale: theme.globalScale

    // 🌟 状态层透明度定义 (MD3 规范)
    readonly property real hoverOpacity: theme.stateOpacityHover
    readonly property real focusOpacity: theme.stateOpacityFocus
    readonly property real pressedOpacity: theme.stateOpacityPressed
    readonly property real draggedOpacity: theme.stateOpacityDragged
    readonly property int hoverDuration: theme.motionDurationFast
    readonly property int pressDuration: theme.motionDurationPress
    readonly property int rippleExpandDuration: theme.motionDurationRippleExpand
    readonly property int rippleFadeDuration: theme.motionDurationRippleFade
    // This exposes the lifetime boundary for hosts and tests.  The ripple
    // surface is not painted between interactions, so it cannot become a
    // permanent GPU workload on a dense list.
    readonly property bool rippleActive: rippleLayer.opacity > 0
    readonly property real rippleOriginX: rippleLayer.originX
    readonly property real rippleOriginY: rippleLayer.originY

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
        if (!control.enabled || !control.rippleEnabled || theme.reduceMotion)
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

    // Hosts handling a keyboard activation call this rather than reusing the
    // last pointer location; Material keyboard feedback originates centrally.
    function triggerFromKeyboard() {
        _keyboardRipplePending = true
        trigger(control.width / 2, control.height / 2)
    }

    onPressedChanged: {
        if (pressed && !dragged) {
            if (_keyboardRipplePending)
                _keyboardRipplePending = false
            else
                trigger(pressX, pressY)
        }
        else if (rippleActive)
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
        visible: baseLayer.opacity > 0 || control.rippleActive
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
            color: control.overlayColor
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
                    duration: control.pressed ? control.pressDuration : control.hoverDuration
                    easing.type: Easing.BezierSpline; easing.bezierCurve: Meo.MeoTheme.motionEasingStandard
                }
            }
        }

        Item {
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
            opacity: 0
            visible: opacity > 0

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: control.overlayColor
                layer.enabled: rippleLayer.visible && control.rippleFeather > 0
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.28
                    blurMax: Math.max(4, Math.ceil(control.rippleFeather * 4))
                    autoPaddingEnabled: true
                }
            }
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
            border.color: control.focusColor
            opacity: control.enabled && control.focused && control.focusRingEnabled ? 0.78 : 0

            Behavior on opacity {
                NumberAnimation { duration: control.hoverDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Meo.MeoTheme.motionEasingStandard }
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
        easing.type: Easing.BezierSpline; easing.bezierCurve: Meo.MeoTheme.motionEasingEmphasizedDecelerate
    }

    NumberAnimation {
        id: rippleFadeIn
        target: rippleLayer
        property: "opacity"
        to: control.pressedOpacity
        duration: control.hoverDuration
        easing.type: Easing.BezierSpline; easing.bezierCurve: Meo.MeoTheme.motionEasingStandard
    }

    NumberAnimation {
        id: rippleFade
        target: rippleLayer
        property: "opacity"
        to: 0
        duration: control.rippleFadeDuration
        easing.type: Easing.BezierSpline; easing.bezierCurve: Meo.MeoTheme.motionEasingStandard
    }

    Connections {
        target: control.theme
        function onReduceMotionChanged() {
            if (!control.theme.reduceMotion)
                return
            rippleExpand.stop()
            rippleFadeIn.stop()
            rippleFade.stop()
            rippleLayer.opacity = 0
            rippleLayer.radiusValue = 0
        }
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
