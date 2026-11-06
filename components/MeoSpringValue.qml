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
    property int maximumRunDuration: MeoMotion.scaledMaximumDuration(
                                         MeoMotion.maximumDuration(motionProfile, speed),
                                         MeoTheme.effectiveMotionScale)
    property bool enabled: !MeoTheme.reduceMotion
    property real valueThreshold: 0.001
    property real velocityThreshold: 0.01
    readonly property bool running: driver.running

    property real _startValue: 0
    property real _startVelocity: 0
    property double _startedAt: 0
    property double _lastTickAt: 0
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

    // Jump only the sampled value while preserving any declarative binding on
    // targetValue. Higher-level motion primitives use this when they need to
    // seed an entrance state before the bound target changes on the next turn.
    function snapValue(nextValue) {
        driver.stop()
        value = nextValue
        velocity = 0
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
        // The timeline starts on the first rendered frame (see driver), not
        // here: a retarget is often followed by window creation, a model
        // refresh or a shader compile, and that stall must not consume the
        // opening of the motion.
        _startedAt = 0
        driver.stop()
        driver.start()
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
        // Disabling motion is a sampled-value policy change, not an
        // imperative retarget. Preserve declarative targetValue bindings so
        // the same spring can resume reacting when motion is enabled again.
        if (!enabled)
            snapValue(targetValue)
    }

    // FrameAnimation ticks once per rendered frame, in step with the scene
    // graph's vsync-driven animation clock. A 16 ms Timer drifts against the
    // display (dropped/doubled frames at 60 Hz) and caps 90/120/144 Hz panels
    // at ~60 updates per second.
    property FrameAnimation driver: FrameAnimation {
        onTriggered: {
            const now = Date.now()
            if (control._startedAt <= 0) {
                control._startedAt = now - 16
                control._lastTickAt = now - 16
            }
            // Pause the timeline over main-thread stalls longer than ~4
            // frames, so motion continues from where it was instead of
            // jumping ahead (a jump reads as a snap or as linear travel).
            const gap = now - control._lastTickAt
            if (gap > 64)
                control._startedAt += gap - 16
            control._lastTickAt = now
            const elapsed = now - control._startedAt
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
