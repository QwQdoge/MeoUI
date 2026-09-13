import QtQuick
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
    property bool internalPointerTrackingEnabled: true
    property string rippleOriginMode: "pointer" // pointer | center
    property bool _keyboardRipplePending: false
    property bool _pointerPressActive: false
    // `color` remains the semantic foreground/focus color for compatibility.
    // Activation feedback itself uses the theme scrim so every filled, tonal, and
    // neutral surface becomes perceptibly darker instead of changing hue.
    property color color: theme.contentOnSurface
    property color overlayColor: theme.scrim
    property color focusColor: theme.primary
    property real rippleFeather: theme.rippleEdgeFeather
    property real rippleStartRadius: Math.max(width, height) * theme.rippleStartRadiusFactor
    property real rippleBoundedExtraRadius: theme.rippleBoundedExtraRadius
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
    readonly property int hoverDuration: theme.motionDurationStateHoverEnter
    readonly property int focusDuration: theme.motionDurationStateFocusEnter
    readonly property int dragEnterDuration: theme.motionDurationStateDragEnter
    readonly property int stateExitDuration: theme.motionDurationStateExit
    readonly property int dragExitDuration: theme.motionDurationStateDragExit
    readonly property int pressDuration: theme.motionDurationPress
    readonly property int rippleFadeInDuration: theme.motionDurationRippleFadeIn
    readonly property int rippleExpandDuration: theme.motionDurationRippleExpand
    readonly property int rippleFadeDuration: theme.motionDurationRippleFade
    // This exposes the lifetime boundary for hosts and tests.  The ripple
    // surface is not painted between interactions, so it cannot become a
    // permanent GPU workload on a dense list.
    property bool _rippleInProgress: false
    property int _stateTransitionDuration: hoverDuration
    readonly property bool rippleActive: _rippleInProgress
    readonly property real rippleOriginX: rippleLayer.originX
    readonly property real rippleOriginY: rippleLayer.originY
    readonly property real rippleCenterX: rippleLayer.centerX
    readonly property real rippleCenterY: rippleLayer.centerY
    readonly property real rippleOpacity: rippleLayer.opacity
    readonly property real rippleRadius: rippleLayer.radiusValue
    readonly property real rippleTargetRadius: rippleLayer.targetRadius
    readonly property real baseStateTargetOpacity: {
        if (!enabled) return 0
        if (dragged) return draggedOpacity
        // Pointer presses are painted by the circular ripple itself. Avoid
        // stacking a second full-surface pressed tint beneath it.
        if (rippleActive && rippleEnabled) return 0
        if (pressed) return theme.stateOpacityPressed
        if (hovered) return theme.stateOpacityHover
        if (focused) return theme.stateOpacityFocus
        return 0
    }
    readonly property real focusRingTargetOpacity: enabled && focused
                                                   && focusRingEnabled ? 0.78 : 0
    readonly property real _renderedBaseOpacity: stateLayerShader.baseOpacity
    readonly property real _renderedFocusOpacity: stateLayerShader.focusOpacity
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    readonly property string renderBackend: softwareRendering
                                                ? "software-fallback"
                                                : "single-pass-shader"

    function animateBaseState() {
        baseOpacityAnimation.stop()
        baseOpacityAnimation.from = stateLayerShader.baseOpacity
        baseOpacityAnimation.to = baseStateTargetOpacity
        baseOpacityAnimation.start()
    }

    function animateFocusRing() {
        focusOpacityAnimation.stop()
        focusOpacityAnimation.from = stateLayerShader.focusOpacity
        focusOpacityAnimation.to = focusRingTargetOpacity
        focusOpacityAnimation.start()
    }

    onBaseStateTargetOpacityChanged: animateBaseState()
    onFocusRingTargetOpacityChanged: animateFocusRing()
    Component.onCompleted: {
        stateLayerShader.baseOpacity = baseStateTargetOpacity
        stateLayerShader.focusOpacity = focusRingTargetOpacity
    }

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

    // Observe the real press point without owning the button action. This is
    // intentionally passive so parent Buttons, MouseAreas, Tabs, and navigation
    // delegates keep their existing click/drag semantics.
    PointHandler {
        id: ripplePointerTracker
        enabled: control.internalPointerTrackingEnabled && control.enabled
                 && control.rippleEnabled && !control.theme.reduceMotion
        acceptedButtons: Qt.LeftButton
        onActiveChanged: {
            control._pointerPressActive = active
            if (active) {
                control.trigger(point.position.x, point.position.y)
            } else {
                control.releaseRipple()
            }
        }
    }

    function trigger(x, y) {
        if (!control.enabled || !control.rippleEnabled || theme.reduceMotion)
            return
        rippleExpand.stop()
        rippleCenterXAnimation.stop()
        rippleCenterYAnimation.stop()
        rippleFadeIn.stop()
        rippleFade.stop()
        rippleMinimumLifetime.stop()
        _releasePending = false
        const requestedX = control.rippleOriginMode === "pointer" ? x : control.width / 2
        const requestedY = control.rippleOriginMode === "pointer" ? y : control.height / 2
        rippleLayer.originX = Math.max(0, Math.min(control.width, requestedX))
        rippleLayer.originY = Math.max(0, Math.min(control.height, requestedY))
        rippleLayer.centerX = rippleLayer.originX
        rippleLayer.centerY = rippleLayer.originY
        rippleLayer.radiusValue = control.rippleStartRadius
        rippleLayer.opacity = 0
        _rippleInProgress = true
        rippleMinimumLifetime.restart()
        rippleFadeIn.start()
        rippleExpand.start()
        rippleCenterXAnimation.start()
        rippleCenterYAnimation.start()
    }

    property bool _releasePending: false

    function releaseRipple() {
        if (!rippleActive)
            return
        _releasePending = true
        // AndroidX immediately draws the ripple at final press alpha when a
        // quick release arrives before fade-in completes, but still lets the
        // radius and center finish their 225ms reveal before fading out.
        if (rippleFadeIn.running) {
            rippleFadeIn.stop()
            rippleLayer.opacity = control.pressedOpacity
        }
        if (!rippleMinimumLifetime.running) {
            _releasePending = false
            rippleFade.restart()
        }
    }

    // Hosts handling a keyboard activation call this rather than reusing the
    // last pointer location; Material keyboard feedback originates centrally.
    function triggerFromKeyboard() {
        _keyboardRipplePending = true
        trigger(control.width / 2, control.height / 2)
        keyboardPendingReset.restart()
    }

    Timer {
        id: keyboardPendingReset
        interval: 0
        repeat: false
        onTriggered: control._keyboardRipplePending = false
    }

    onPressedChanged: {
        if (_pointerPressActive)
            return
        if (pressed && !dragged) {
            if (_keyboardRipplePending)
                _keyboardRipplePending = false
            else
                trigger(pressX, pressY)
        }
        else
            releaseRipple()
    }

    onHoveredChanged: {
        if (!dragged && !pressed)
            _stateTransitionDuration = hovered ? hoverDuration : stateExitDuration
    }
    onFocusedChanged: {
        if (!dragged && !pressed && !hovered)
            _stateTransitionDuration = focused ? focusDuration : stateExitDuration
    }

    // A drag is a continuous state, not another click.  Stop the expanding
    // ripple immediately so sliders and draggable list items cannot leave a
    // delayed press flash behind after the pointer crosses the drag threshold.
    onDraggedChanged: {
        _stateTransitionDuration = dragged ? dragEnterDuration : dragExitDuration
        if (dragged) {
            rippleExpand.stop()
            rippleCenterXAnimation.stop()
            rippleCenterYAnimation.stop()
            rippleFadeIn.stop()
            rippleMinimumLifetime.stop()
            _releasePending = false
            rippleFade.restart()
        }
    }

    Timer {
        id: rippleMinimumLifetime
        interval: control.rippleExpandDuration
        repeat: false
        onTriggered: {
            if (control._releasePending && !control.pressed) {
                control._releasePending = false
                rippleFade.restart()
            }
        }
    }

    ShaderEffect {
        id: stateLayerShader
        anchors.fill: parent
        visible: !control.softwareRendering
                 && control.enabled
                 && (control.hovered || control.focused || control.pressed
                     || control.dragged || control.rippleActive)
        blending: true
        fragmentShader: "qrc:/qt/qml/MeoUI/shaders/state_layer.frag.qsb"

        property color overlayColor: control.overlayColor
        property color focusColor: control.focusColor
        property vector4d dimensions: Qt.vector4d(control.width, control.height,
                                                   control.theme.stateMaskEdgeFeather, 0)
        property vector4d cornerRadii: Qt.vector4d(control.maskTopLeftRadius,
                                                   control.maskTopRightRadius,
                                                   control.maskBottomRightRadius,
                                                   control.maskBottomLeftRadius)
        property vector4d rippleData: Qt.vector4d(rippleLayer.centerX,
                                                  rippleLayer.centerY,
                                                  rippleLayer.radiusValue,
                                                  control.rippleFeather)
        property vector4d opacityData: Qt.vector4d(baseOpacity, rippleOpacity,
                                                   focusOpacity, focusWidth)

        property real baseOpacity: 0
        property real rippleOpacity: control.rippleActive ? rippleLayer.opacity : 0
        property real focusOpacity: 0
        property real focusWidth: focusOpacity > 0
                                  ? Math.max(2, 2 * control.themeGlobalScale) : 0
    }

    NumberAnimation {
        id: baseOpacityAnimation
        target: stateLayerShader
        property: "baseOpacity"
        duration: control._stateTransitionDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Meo.MeoTheme.motionEasingLinear
    }

    NumberAnimation {
        id: focusOpacityAnimation
        target: stateLayerShader
        property: "focusOpacity"
        duration: control.focused ? control.focusDuration : control.stateExitDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Meo.MeoTheme.motionEasingLinear
    }

    // Qt's software scenegraph does not execute ShaderEffect. Keep this
    // compatibility path strictly behind the renderer check so offscreen
    // tests and emergency software sessions retain feedback, while normal
    // Wayland/OpenGL/Vulkan rendering pays only for the single shader pass.
    // Deliberately use basic scenegraph geometry here: stacking MultiEffect
    // masks and blur passes is precisely the frame-time spike this component
    // is intended to remove.
    Item {
        id: softwareFallback
        anchors.fill: parent
        visible: control.softwareRendering && control.enabled
                 && (control.hovered || control.focused || control.pressed
                     || control.dragged || control.rippleActive)

        Rectangle {
            id: fallbackBase
            anchors.fill: parent
            color: control.overlayColor
            opacity: stateLayerShader.baseOpacity
            radius: control.maskRadius
            topLeftRadius: control.maskTopLeftRadius
            topRightRadius: control.maskTopRightRadius
            bottomLeftRadius: control.maskBottomLeftRadius
            bottomRightRadius: control.maskBottomRightRadius
        }

        Rectangle {
            x: rippleLayer.centerX - rippleLayer.radiusValue
            y: rippleLayer.centerY - rippleLayer.radiusValue
            width: rippleLayer.radiusValue * 2
            height: width
            radius: width / 2
            visible: control.rippleActive
            opacity: rippleLayer.opacity
            color: control.overlayColor
        }

        Rectangle {
            id: fallbackFocus
            anchors.fill: parent
            color: "transparent"
            radius: control.maskRadius
            topLeftRadius: control.maskTopLeftRadius
            topRightRadius: control.maskTopRightRadius
            bottomLeftRadius: control.maskBottomLeftRadius
            bottomRightRadius: control.maskBottomRightRadius
            border.width: stateLayerShader.focusWidth
            border.color: control.focusColor
            opacity: stateLayerShader.focusOpacity
        }
    }

    QtObject {
        id: rippleLayer
        property real originX: control.width / 2
        property real originY: control.height / 2
        property real centerX: originX
        property real centerY: originY
        property real radiusValue: 0
        property real opacity: 0
        readonly property real targetRadius: Math.sqrt(control.width * control.width
                                                       + control.height * control.height) / 2
                                             + control.rippleBoundedExtraRadius
    }

    NumberAnimation {
        id: rippleFadeIn
        target: rippleLayer
        property: "opacity"
        from: 0
        to: control.pressedOpacity
        duration: control.rippleFadeInDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Meo.MeoTheme.motionEasingLinear
    }

    NumberAnimation {
        id: rippleExpand
        target: rippleLayer
        property: "radiusValue"
        from: control.rippleStartRadius
        to: rippleLayer.targetRadius
        duration: control.rippleExpandDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Meo.MeoTheme.motionEasingRippleRadius
    }

    NumberAnimation {
        id: rippleCenterXAnimation
        target: rippleLayer
        property: "centerX"
        from: rippleLayer.originX
        to: control.width / 2
        duration: control.rippleExpandDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Meo.MeoTheme.motionEasingLinear
    }

    NumberAnimation {
        id: rippleCenterYAnimation
        target: rippleLayer
        property: "centerY"
        from: rippleLayer.originY
        to: control.height / 2
        duration: control.rippleExpandDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Meo.MeoTheme.motionEasingLinear
    }

    NumberAnimation {
        id: rippleFade
        target: rippleLayer
        property: "opacity"
        to: 0
        duration: control.rippleFadeDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Meo.MeoTheme.motionEasingLinear
        onFinished: {
            control._rippleInProgress = false
            rippleLayer.opacity = 0
            rippleLayer.radiusValue = 0
        }
    }

    Connections {
        target: control.theme
        function onReduceMotionChanged() {
            if (!control.theme.reduceMotion)
                return
            rippleExpand.stop()
            rippleCenterXAnimation.stop()
            rippleCenterYAnimation.stop()
            rippleFadeIn.stop()
            rippleMinimumLifetime.stop()
            keyboardPendingReset.stop()
            rippleFade.stop()
            control._keyboardRipplePending = false
            control._pointerPressActive = false
            control._releasePending = false
            control._rippleInProgress = false
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
