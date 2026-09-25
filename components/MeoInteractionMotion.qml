import QtQuick
import MeoUI

// Platform-neutral interaction motion for compact clickable surfaces.
//
// Hosts own pointer/focus semantics and feed hovered/pressed/active state into
// this object. The motion stays reusable across bars, cards, toolbars,
// navigation items and popup triggers instead of embedding product-specific
// animation in each consumer.
QtObject {
    id: control

    property bool hovered: false
    property bool pressed: false
    property bool active: false
    property bool enabled: true
    property string motionProfile: "pixel"

    property real restingScale: 1.0
    property real hoverScale: 1.012
    property real activeScale: 1.022
    property real pressedScale: 0.965

    property real restingOffsetY: 0
    property real hoverOffsetY: -1.0 * MeoTheme.globalScale
    property real activeOffsetY: -1.0 * MeoTheme.globalScale
    property real pressedOffsetY: 0.5 * MeoTheme.globalScale

    readonly property real targetScale: !enabled ? restingScale
                                               : pressed ? pressedScale
                                               : active ? activeScale
                                               : hovered ? hoverScale
                                               : restingScale
    readonly property real targetOffsetY: !enabled ? restingOffsetY
                                                 : pressed ? pressedOffsetY
                                                 : active ? activeOffsetY
                                                 : hovered ? hoverOffsetY
                                                 : restingOffsetY

    readonly property real scale: scaleSpring.value
    readonly property real offsetY: offsetSpring.value
    readonly property bool running: scaleSpring.running || offsetSpring.running

    function snapToState() {
        scaleSpring.snapTo(targetScale)
        offsetSpring.snapTo(targetOffsetY)
    }

    MeoSpringValue {
        id: scaleSpring
        value: control.restingScale
        targetValue: control.targetScale
        motionProfile: control.motionProfile
        speed: control.pressed ? "fast" : "default"
        enabled: control.enabled
        valueThreshold: 0.0008
        velocityThreshold: 0.008
    }

    MeoSpringValue {
        id: offsetSpring
        value: control.restingOffsetY
        targetValue: control.targetOffsetY
        motionProfile: control.motionProfile
        speed: control.pressed ? "fast" : "default"
        enabled: control.enabled
        valueThreshold: 0.02
        velocityThreshold: 0.08
    }

    Component.onCompleted: snapToState()
}
