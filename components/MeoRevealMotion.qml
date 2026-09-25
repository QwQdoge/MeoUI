import QtQuick
import MeoUI

// Reusable reveal/hide motion for surfaces whose lifecycle is owned by a host
// (for example a shell, StackView, or window manager) rather than by
// MeoMotionPopup itself. It paints nothing and does not own visibility.
QtObject {
    id: control

    property bool shown: false
    property bool enabled: true
    property string motionProfile: "pixel"
    property string speed: "default"

    property real hiddenScale: MeoMotion.popupEntranceScale(motionProfile)
    property real shownScale: 1.0
    property real hiddenOpacity: 0.0
    property real shownOpacity: 1.0

    // Offsets are real scene units. A top-anchored surface normally uses a
    // negative hiddenOffsetY; a side surface can use hiddenOffsetX instead.
    property real hiddenOffsetX: 0
    property real hiddenOffsetY: -MeoMotion.popupOffset(motionProfile) * MeoTheme.globalScale
    property real shownOffsetX: 0
    property real shownOffsetY: 0

    readonly property real targetScale: !enabled ? shownScale : (shown ? shownScale : hiddenScale)
    readonly property real targetOpacity: !enabled ? shownOpacity : (shown ? shownOpacity : hiddenOpacity)
    readonly property real targetOffsetX: !enabled ? shownOffsetX : (shown ? shownOffsetX : hiddenOffsetX)
    readonly property real targetOffsetY: !enabled ? shownOffsetY : (shown ? shownOffsetY : hiddenOffsetY)

    readonly property real scale: scaleDriver.value
    readonly property real opacity: opacityDriver.value
    readonly property real offsetX: offsetXDriver.value
    readonly property real offsetY: offsetYDriver.value
    readonly property bool running: scaleDriver.running || opacityDriver.running
                                    || offsetXDriver.running || offsetYDriver.running

    property var scaleDriver: MeoSpringValue {
        value: control.hiddenScale
        targetValue: control.targetScale
        motionProfile: control.motionProfile
        speed: control.speed
        valueThreshold: 0.001
        velocityThreshold: 0.01
    }

    property var opacityDriver: MeoSpringValue {
        value: control.hiddenOpacity
        targetValue: control.targetOpacity
        spring: MeoMotion.effectsSpec(control.speed)
        maximumRunDuration: MeoMotion.scaledMaximumDuration(
                                MeoMotion.maximumDuration("calm", control.speed),
                                MeoTheme.effectiveMotionScale)
        valueThreshold: 0.005
        velocityThreshold: 0.01
    }

    property var offsetXDriver: MeoSpringValue {
        value: control.hiddenOffsetX
        targetValue: control.targetOffsetX
        motionProfile: control.motionProfile
        speed: control.speed
        valueThreshold: 0.02 * MeoTheme.globalScale
        velocityThreshold: 0.05
    }

    property var offsetYDriver: MeoSpringValue {
        value: control.hiddenOffsetY
        targetValue: control.targetOffsetY
        motionProfile: control.motionProfile
        speed: control.speed
        valueThreshold: 0.02 * MeoTheme.globalScale
        velocityThreshold: 0.05
    }

    function snapHidden() {
        scaleDriver.snapTo(hiddenScale)
        opacityDriver.snapTo(hiddenOpacity)
        offsetXDriver.snapTo(hiddenOffsetX)
        offsetYDriver.snapTo(hiddenOffsetY)
    }

    function snapShown() {
        scaleDriver.snapTo(shownScale)
        opacityDriver.snapTo(shownOpacity)
        offsetXDriver.snapTo(shownOffsetX)
        offsetYDriver.snapTo(shownOffsetY)
    }
}
