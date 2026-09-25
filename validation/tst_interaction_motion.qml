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
            motion.snapToCurrentState()
        }

        function test_states_use_shared_policy() {
            motion.hovered = true
            motion.snapToCurrentState()
            compare(motion.resolvedScale,
                    MeoTheme.reduceMotion ? 1 : MeoMotion.interactionScale("pixel", true, false, false))
            compare(motion.resolvedOffsetY,
                    MeoTheme.reduceMotion ? 0 : MeoMotion.interactionLift("pixel", true, false, false) * MeoTheme.globalScale)

            motion.hovered = false
            motion.pressed = true
            motion.snapToCurrentState()
            compare(motion.resolvedScale,
                    MeoTheme.reduceMotion ? 1 : MeoMotion.interactionScale("pixel", false, true, false))
        }

        function test_generic_x_offset_is_supported() {
            motion.offsetXTarget = 6
            motion.snapToCurrentState()
            compare(motion.resolvedOffsetX, MeoTheme.reduceMotion ? 0 : 6)
        }
    }
}
