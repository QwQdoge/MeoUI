import QtQuick
import MeoUI

// Reusable, presentation-agnostic interaction motion for compact controls,
// cards, launchers, toolbar items, and other press/hover surfaces.
//
// The primitive owns no pointer handling and paints nothing. Hosts bind their
// own semantic hovered/pressed/active state and consume scale/offsetY. This
// keeps motion policy in MeoUI while leaving hit targets and visuals with the
// owning control.
QtObject {
    id: control

    property bool enabled: true
    property bool hovered: false
    property bool pressed: false
    property bool active: false

    property string motionProfile: "pixel"
    property string speed: "fast"

    property real restingScale: 1.0
    property real hoverScale: MeoMotion.hoverScale(motionProfile)
    property real pressedScale: MeoMotion.pressScale(motionProfile)
    property real activeScale: 1.0

    property real restingOffsetY: 0
    property real hoverOffsetY: MeoMotion.hoverLift(motionProfile) * MeoTheme.globalScale
    property real pressedOffsetY: 0
    property real activeOffsetY: 0

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

    readonly property real scale: scaleDriver.value
    readonly property real offsetY: offsetDriver.value
    readonly property bool running: scaleDriver.running || offsetDriver.running

    property var scaleDriver: MeoSpringValue {
        value: control.restingScale
        targetValue: control.targetScale
        motionProfile: control.motionProfile
        speed: control.speed
        valueThreshold: 0.0005
        velocityThreshold: 0.005
    }

    property var offsetDriver: MeoSpringValue {
        value: control.restingOffsetY
        targetValue: control.targetOffsetY
        motionProfile: control.motionProfile
        speed: control.speed
        valueThreshold: 0.02 * MeoTheme.globalScale
        velocityThreshold: 0.05
    }

    function snapToRest() {
        scaleDriver.snapTo(restingScale)
        offsetDriver.snapTo(restingOffsetY)
    }
}
