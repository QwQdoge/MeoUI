import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 320
    height: 240

    MeoInteractionMotion {
        id: motion
        hoverScale: 1.02
        activeScale: 1.03
        pressedScale: 0.97
        hoverOffsetY: -2
        activeOffsetY: -1
        pressedOffsetY: 1
    }

    TestCase {
        name: "MeoInteractionMotion"
        when: windowShown

        function cleanup() {
            motion.hovered = false
            motion.pressed = false
            motion.active = false
            motion.enabled = true
            motion.snapToState()
        }

        function test_statePriority() {
            compare(motion.targetScale, 1.0)
            compare(motion.targetOffsetY, 0)

            motion.hovered = true
            compare(motion.targetScale, 1.02)
            compare(motion.targetOffsetY, -2)

            motion.active = true
            compare(motion.targetScale, 1.03)
            compare(motion.targetOffsetY, -1)

            motion.pressed = true
            compare(motion.targetScale, 0.97)
            compare(motion.targetOffsetY, 1)
        }

        function test_disabledReturnsToRest() {
            motion.hovered = true
            motion.active = true
            motion.enabled = false
            compare(motion.targetScale, motion.restingScale)
            compare(motion.targetOffsetY, motion.restingOffsetY)
        }

        function test_snapUsesCurrentState() {
            motion.hovered = true
            motion.snapToState()
            compare(motion.scale, motion.hoverScale)
            compare(motion.offsetY, motion.hoverOffsetY)
        }
    }
}
