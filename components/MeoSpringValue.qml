import QtQuick
import MeoUI

// Interruptible scalar spring for interaction-owned position, scale, and
// bounds. Retargeting preserves the current velocity, so a second gesture
// changes course immediately instead of waiting for an earlier animation.
QtObject {
    id: control

    property real value: 0
    property real targetValue: 0
    property real velocity: 0
    property string motionProfile: "pixel"
    property string speed: "default"
    property var spring: MeoMotion.spatialSpec(motionProfile, speed)
    property int maximumRunDuration: MeoMotion.maximumDuration(motionProfile, speed)
    property bool enabled: !MeoTheme.reduceMotion
    property real valueThreshold: 0.001
    property real velocityThreshold: 0.01
    readonly property bool running: driver.running

    property real _startValue: 0
    property real _startVelocity: 0
    property double _startedAt: 0
    property bool _snapping: false

    signal settled(real value)

    function snapTo(nextValue) {
        _snapping = true
        driver.stop()
        targetValue = nextValue
        value = nextValue
        velocity = 0
        _snapping = false
        settled(value)
    }

    function retarget() {
        if (!enabled || MeoTheme.reduceMotion || MeoTheme.effectiveMotionScale <= 0) {
            driver.stop()
            value = targetValue
            velocity = 0
            settled(value)
            return
        }
        _startValue = value
        _startVelocity = velocity
        _startedAt = Date.now()
        driver.restart()
    }

    onTargetValueChanged: {
        if (!_snapping)
            retarget()
    }
    onSpringChanged: {
        if (driver.running)
            retarget()
    }
    onEnabledChanged: {
        if (!enabled)
            snapTo(targetValue)
    }

    property Timer driver: Timer {
        interval: 16
        repeat: true
        onTriggered: {
            const elapsed = Date.now() - control._startedAt
            if (elapsed >= control.maximumRunDuration) {
                stop()
                control.value = control.targetValue
                control.velocity = 0
                control.settled(control.value)
                return
            }
            const state = MeoMotion.stateAt(control.spring,
                                            control._startValue,
                                            control._startVelocity,
                                            control.targetValue,
                                            MeoMotion.scaledElapsed(elapsed, MeoTheme.effectiveMotionScale))
            control.value = state.value
            control.velocity = state.velocity
            if (MeoMotion.isAtRest(state, control.targetValue,
                                   control.valueThreshold,
                                   control.velocityThreshold)) {
                stop()
                control.value = control.targetValue
                control.velocity = 0
                control.settled(control.value)
            }
        }
    }
}
