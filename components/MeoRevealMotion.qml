import QtQuick
import MeoUI

// Reusable interruptible reveal state for transient surfaces and compact
// panes. Hosts own geometry and simply project resolvedScale/resolvedOffset
// onto their transform. This keeps reveal spring policy out of shell widgets.
Item {
    id: control
    visible: false
    width: 0
    height: 0

    property bool active: true
    property string motionProfile: "pixel"
    property string speed: "default"
    property real openScale: 1.0
    property real closedScale: MeoMotion.popupClosedScale(motionProfile)
    property real openOffset: 0
    property real closedOffset: -MeoMotion.popupOffset(motionProfile) * MeoTheme.globalScale

    readonly property real resolvedScale: scaleSpring.value
    readonly property real resolvedOffset: offsetSpring.value
    readonly property bool running: scaleSpring.running || offsetSpring.running

    MeoSpringValue {
        id: scaleSpring
        value: control.active || MeoTheme.reduceMotion ? control.openScale : control.closedScale
        targetValue: control.active || MeoTheme.reduceMotion ? control.openScale : control.closedScale
        motionProfile: control.motionProfile
        speed: control.speed
    }

    MeoSpringValue {
        id: offsetSpring
        value: control.active || MeoTheme.reduceMotion ? control.openOffset : control.closedOffset
        targetValue: control.active || MeoTheme.reduceMotion ? control.openOffset : control.closedOffset
        motionProfile: control.motionProfile
        speed: control.speed
    }

    function snapToActiveState() {
        scaleSpring.snapTo(active || MeoTheme.reduceMotion ? openScale : closedScale)
        offsetSpring.snapTo(active || MeoTheme.reduceMotion ? openOffset : closedOffset)
    }
}
