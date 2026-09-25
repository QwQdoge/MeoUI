import QtQuick
import MeoUI

// Reusable interruptible reveal state for transient surfaces and compact
// panes. Hosts own geometry and project resolvedScale/resolvedOffsetX/Y onto
// their transform. The legacy scalar openOffset/closedOffset/resolvedOffset
// remain vertical aliases so existing consumers keep working.
Item {
    id: control
    visible: false
    width: 0
    height: 0

    property bool active: true
    property bool motionEnabled: true
    property string motionProfile: "pixel"
    property string speed: "default"
    property real openScale: 1.0
    property real closedScale: MeoMotion.popupClosedScale(motionProfile)

    // Backwards-compatible vertical offset API.
    property real openOffset: 0
    property real closedOffset: -MeoMotion.popupOffset(motionProfile) * MeoTheme.globalScale

    // Generic 2D reveal API. By default Y follows the legacy scalar contract.
    property real openOffsetX: 0
    property real closedOffsetX: 0
    property real openOffsetY: openOffset
    property real closedOffsetY: closedOffset

    readonly property bool spatialMotionAllowed: motionEnabled
                                                  && !MeoTheme.reduceMotion
                                                  && MeoTheme.effectiveMotionScale > 0
    readonly property bool resolvedOpenState: active || !spatialMotionAllowed
    readonly property real resolvedScale: scaleSpring.value
    readonly property real resolvedOffsetX: xSpring.value
    readonly property real resolvedOffsetY: ySpring.value
    readonly property real resolvedOffset: resolvedOffsetY
    readonly property bool running: scaleSpring.running || xSpring.running || ySpring.running

    MeoSpringValue {
        id: scaleSpring
        value: control.resolvedOpenState ? control.openScale : control.closedScale
        targetValue: control.resolvedOpenState ? control.openScale : control.closedScale
        enabled: control.spatialMotionAllowed
        motionProfile: control.motionProfile
        speed: control.speed
    }

    MeoSpringValue {
        id: xSpring
        value: control.resolvedOpenState ? control.openOffsetX : control.closedOffsetX
        targetValue: control.resolvedOpenState ? control.openOffsetX : control.closedOffsetX
        enabled: control.spatialMotionAllowed
        motionProfile: control.motionProfile
        speed: control.speed
    }

    MeoSpringValue {
        id: ySpring
        value: control.resolvedOpenState ? control.openOffsetY : control.closedOffsetY
        targetValue: control.resolvedOpenState ? control.openOffsetY : control.closedOffsetY
        enabled: control.spatialMotionAllowed
        motionProfile: control.motionProfile
        speed: control.speed
    }

    function snapToActiveState() {
        const isOpen = resolvedOpenState
        scaleSpring.snapTo(isOpen ? openScale : closedScale)
        xSpring.snapTo(isOpen ? openOffsetX : closedOffsetX)
        ySpring.snapTo(isOpen ? openOffsetY : closedOffsetY)
    }
}
