import QtQuick
import QtTest
import MeoUI 1.0

Item {
    MeoInteractionMotion {
        id: motion
        motionProfile: "pixel"
    }

    TestCase {
        name: "MeoInteractionMotion"
        when: windowShown

        function cleanup() {
            motion.hovered = false
            motion.pressed = false
            motion.active = false
            motion.offsetXTarget = 0
            motion.motionEnabled = true
            motion.snapToCurrentState()
        }

        function test_states_use_shared_policy() {
            motion.hovered = true
            motion.snapToCurrentState()
            compare(motion.resolvedScale,
                    motion.spatialMotionAllowed
                    ? MeoMotion.interactionScale("pixel", true, false, false) : 1)
            compare(motion.resolvedOffsetY,
                    motion.spatialMotionAllowed
                    ? MeoMotion.interactionLift("pixel", true, false, false) * MeoTheme.globalScale
                    : 0)

            motion.hovered = false
            motion.pressed = true
            motion.snapToCurrentState()
            compare(motion.resolvedScale,
                    motion.spatialMotionAllowed
                    ? MeoMotion.interactionScale("pixel", false, true, false) : 1)
        }

        function test_generic_x_offset_is_supported() {
            motion.offsetXTarget = 6
            motion.snapToCurrentState()
            compare(motion.resolvedOffsetX,
                    motion.spatialMotionAllowed ? 6 : 0)
        }

        function test_motion_disabled_is_spatially_neutral() {
            motion.hovered = true
            motion.pressed = true
            motion.active = true
            motion.offsetXTarget = 12
            motion.motionEnabled = false
            motion.snapToCurrentState()

            compare(motion.targetScale, 1)
            compare(motion.targetOffsetX, 0)
            compare(motion.targetOffsetY, 0)
            compare(motion.resolvedScale, 1)
            compare(motion.resolvedOffsetX, 0)
            compare(motion.resolvedOffsetY, 0)
        }
    }
}
