import QtQuick
import MeoUI

// Generic spring-driven feedback for clickable surfaces.
//
// This primitive owns no visuals and no pointer handlers. Hosts bind their
// existing pressed/hovered/active state and consume scaleValue/offset values.
// Keeping gesture ownership outside means buttons, menu-bar items, cards,
// launchers, and shell controls can share the same motion without duplicating
// pointer semantics or stealing events.
Item {
    id: control

    width: 0
    height: 0
    visible: false

    property bool pressed: false
    property bool hovered: false
    property bool active: false
    property bool motionEnabled: true
    property string motionProfile: "pixel"
    property string speed: "fast"

    property real restScale: 1.0
    property real hoverScale: motionProfile === "calm" ? 1.0 : 1.01
    property real pressedScale: MeoMotion.pressScale(motionProfile)
    property real activeScale: 1.0

    property real restOffsetX: 0
    property real restOffsetY: 0
    property real hoverOffsetX: 0
    property real hoverOffsetY: motionProfile === "calm" ? 0 : -0.5 * MeoTheme.globalScale
    property real pressedOffsetX: 0
    property real pressedOffsetY: motionProfile === "calm" ? 0 : 0.75 * MeoTheme.globalScale
    property real activeOffsetX: 0
    property real activeOffsetY: 0

    readonly property real targetScale: pressed ? pressedScale
                                              : hovered ? hoverScale
                                              : active ? activeScale
                                                       : restScale
    readonly property real targetOffsetX: pressed ? pressedOffsetX
                                                : hovered ? hoverOffsetX
                                                : active ? activeOffsetX
                                                         : restOffsetX
    readonly property real targetOffsetY: pressed ? pressedOffsetY
                                                : hovered ? hoverOffsetY
                                                : active ? activeOffsetY
                                                         : restOffsetY

    readonly property real scaleValue: scaleSpring.value
    readonly property real offsetX: xSpring.value
    readonly property real offsetY: ySpring.value
    readonly property bool running: scaleSpring.running || xSpring.running || ySpring.running

    property bool _ready: false

    MeoSpringValue {
        id: scaleSpring
        motionProfile: control.motionProfile
        speed: control.speed
        targetValue: control.targetScale
        enabled: control._ready && control.motionEnabled && !MeoTheme.reduceMotion
        valueThreshold: 0.0005
        velocityThreshold: 0.005
        Component.onCompleted: value = control.targetScale
    }

    MeoSpringValue {
        id: xSpring
        motionProfile: control.motionProfile
        speed: control.speed
        targetValue: control.targetOffsetX
        enabled: control._ready && control.motionEnabled && !MeoTheme.reduceMotion
        valueThreshold: 0.02 * MeoTheme.globalScale
        velocityThreshold: 0.02
        Component.onCompleted: value = control.targetOffsetX
    }

    MeoSpringValue {
        id: ySpring
        motionProfile: control.motionProfile
        speed: control.speed
        targetValue: control.targetOffsetY
        enabled: control._ready && control.motionEnabled && !MeoTheme.reduceMotion
        valueThreshold: 0.02 * MeoTheme.globalScale
        velocityThreshold: 0.02
        Component.onCompleted: value = control.targetOffsetY
    }

    Component.onCompleted: {
        scaleSpring.value = targetScale
        scaleSpring.velocity = 0
        xSpring.value = targetOffsetX
        xSpring.velocity = 0
        ySpring.value = targetOffsetY
        ySpring.velocity = 0
        _ready = true
    }
}
