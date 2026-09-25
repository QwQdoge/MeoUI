import QtQuick
import MeoUI

// Reusable interruptible hover/press/active motion for controls and surfaces.
// Hosts keep ownership of pointer, focus, visuals, and geometry; this object
// only resolves shared MeoUI motion policy into spring-sampled transform values.
Item {
    id: control
    visible: false
    width: 0
    height: 0

    property bool hovered: false
    property bool pressed: false
    property bool active: false
    property bool motionEnabled: true
    property string motionProfile: "pixel"
    property string speed: "fast"
    property real offsetXTarget: 0
    property real liftMultiplier: 1.0

    readonly property bool spatialMotionAllowed: motionEnabled
                                                  && !MeoTheme.reduceMotion
                                                  && MeoTheme.effectiveMotionScale > 0
    readonly property real targetScale: spatialMotionAllowed
                                        ? MeoMotion.interactionScale(
                                              motionProfile,
                                              hovered,
                                              pressed,
                                              active)
                                        : 1
    readonly property real targetOffsetY: spatialMotionAllowed
                                          ? MeoMotion.interactionLift(
                                                motionProfile,
                                                hovered,
                                                pressed,
                                                active)
                                            * MeoTheme.globalScale
                                            * liftMultiplier
                                          : 0
    readonly property real targetOffsetX: spatialMotionAllowed ? offsetXTarget : 0
    readonly property real resolvedScale: scaleSpring.value
    readonly property real resolvedOffsetX: xSpring.value
    readonly property real resolvedOffsetY: ySpring.value
    readonly property bool running: scaleSpring.running
                                    || xSpring.running
                                    || ySpring.running

    MeoSpringValue {
        id: scaleSpring
        value: 1
        targetValue: control.targetScale
        enabled: control.spatialMotionAllowed
        motionProfile: control.motionProfile
        speed: control.speed
    }

    MeoSpringValue {
        id: xSpring
        value: 0
        targetValue: control.targetOffsetX
        enabled: control.spatialMotionAllowed
        motionProfile: control.motionProfile
        speed: control.speed
    }

    MeoSpringValue {
        id: ySpring
        value: 0
        targetValue: control.targetOffsetY
        enabled: control.spatialMotionAllowed
        motionProfile: control.motionProfile
        speed: control.speed
    }

    function snapToCurrentState() {
        scaleSpring.snapTo(targetScale)
        xSpring.snapTo(targetOffsetX)
        ySpring.snapTo(targetOffsetY)
    }
}
