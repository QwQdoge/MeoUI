import QtQuick
import MeoUI

// Platform-neutral interaction motion controller.
//
// Hosts keep ownership of hit testing and visuals, while this controller owns
// the reusable spatial response for hover, press, and active/open states.
// It intentionally exposes values rather than drawing a menu/button so the
// same spring can drive toolbar items, cards, navigation rows, popout anchors,
// and shell surfaces.
QtObject {
    id: control

    property bool hovered: false
    property bool pressed: false
    property bool active: false
    property bool enabled: true

    property string motionProfile: "pixel"
    property string speed: "fast"

    property real restingScale: 1.0
    property real hoverScale: MeoMotion.hoverScale(motionProfile)
    property real activeScale: MeoMotion.activeScale(motionProfile)
    property real pressedScale: MeoMotion.pressScale(motionProfile)

    property real restingOffsetX: 0
    property real restingOffsetY: 0
    property real hoverOffsetX: 0
    property real hoverOffsetY: -MeoMotion.hoverLift(motionProfile) * MeoTheme.globalScale
    property real activeOffsetX: 0
    property real activeOffsetY: -MeoMotion.activeLift(motionProfile) * MeoTheme.globalScale
    property real pressedOffsetX: 0
    property real pressedOffsetY: 0

    readonly property real targetScale: !enabled ? restingScale
                                              : pressed ? pressedScale
                                              : active ? activeScale
                                              : hovered ? hoverScale
                                                        : restingScale
    readonly property real targetOffsetX: !enabled ? restingOffsetX
                                                : pressed ? pressedOffsetX
                                                : active ? activeOffsetX
                                                : hovered ? hoverOffsetX
                                                          : restingOffsetX
    readonly property real targetOffsetY: !enabled ? restingOffsetY
                                                : pressed ? pressedOffsetY
                                                : active ? activeOffsetY
                                                : hovered ? hoverOffsetY
                                                          : restingOffsetY

    readonly property real scale: scaleSpring.value
    readonly property real offsetX: xSpring.value
    readonly property real offsetY: ySpring.value
    readonly property bool running: scaleSpring.running || xSpring.running || ySpring.running

    function snapToCurrentState() {
        scaleSpring.snapTo(targetScale)
        xSpring.snapTo(targetOffsetX)
        ySpring.snapTo(targetOffsetY)
    }

    property MeoSpringValue scaleSpring: MeoSpringValue {
        value: control.restingScale
        targetValue: control.targetScale
        motionProfile: control.motionProfile
        speed: control.speed
        enabled: control.enabled
        valueThreshold: 0.0005
        velocityThreshold: 0.005
    }

    property MeoSpringValue xSpring: MeoSpringValue {
        value: control.restingOffsetX
        targetValue: control.targetOffsetX
        motionProfile: control.motionProfile
        speed: control.speed
        enabled: control.enabled
        valueThreshold: 0.05
        velocityThreshold: 0.05
    }

    property MeoSpringValue ySpring: MeoSpringValue {
        value: control.restingOffsetY
        targetValue: control.targetOffsetY
        motionProfile: control.motionProfile
        speed: control.speed
        enabled: control.enabled
        valueThreshold: 0.05
        velocityThreshold: 0.05
    }

    Component.onCompleted: snapToCurrentState()
}
