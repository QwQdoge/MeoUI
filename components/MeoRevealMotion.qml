import QtQuick
import MeoUI

// Generic state-driven reveal motion for transient surfaces.
//
// Consumers keep ownership of geometry and visuals. This object only exposes
// spring-sampled opacity/scale/translation values so popup contents, cards,
// sheets, launch surfaces, and other transient UI can share one interruption-
// safe entrance/exit model.
Item {
    id: control

    width: 0
    height: 0
    visible: false

    property bool revealed: false
    property bool motionEnabled: true
    property string motionProfile: "pixel"
    property string speed: "default"

    property real shownScale: 1.0
    property real hiddenScale: motionProfile === "calm" ? 0.985 : 0.965
    property real shownOpacity: 1.0
    property real hiddenOpacity: 0.0
    property real shownOffsetX: 0
    property real shownOffsetY: 0
    property real hiddenOffsetX: 0
    property real hiddenOffsetY: -MeoMotion.popupOffset(motionProfile) * MeoTheme.globalScale

    readonly property real targetScale: revealed ? shownScale : hiddenScale
    readonly property real targetOpacity: revealed ? shownOpacity : hiddenOpacity
    readonly property real targetOffsetX: revealed ? shownOffsetX : hiddenOffsetX
    readonly property real targetOffsetY: revealed ? shownOffsetY : hiddenOffsetY

    readonly property real scaleValue: scaleSpring.value
    readonly property real opacityValue: opacitySpring.value
    readonly property real offsetX: xSpring.value
    readonly property real offsetY: ySpring.value
    readonly property bool running: scaleSpring.running || opacitySpring.running
                                    || xSpring.running || ySpring.running

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
        id: opacitySpring
        motionProfile: control.motionProfile
        speed: control.speed
        spring: MeoMotion.effectsSpec(control.speed)
        targetValue: control.targetOpacity
        enabled: control._ready && control.motionEnabled && !MeoTheme.reduceMotion
        valueThreshold: 0.002
        velocityThreshold: 0.01
        Component.onCompleted: value = control.targetOpacity
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
        scaleSpring.snapTo(targetScale)
        opacitySpring.snapTo(targetOpacity)
        xSpring.snapTo(targetOffsetX)
        ySpring.snapTo(targetOffsetY)
        _ready = true
    }
}
