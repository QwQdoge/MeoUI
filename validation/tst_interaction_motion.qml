import QtQuick
import QtTest
import MeoUI 1.0

Item {
    MeoInteractionMotion {
        id: motion
        hoverScale: 1.02
        pressedScale: 0.93
        activeScale: 1.01
        hoverOffsetY: -2
        pressedOffsetY: 1
        activeOffsetY: -1
    }

    TestCase {
        name: "MeoInteractionMotion"

        function cleanup() {
            motion.enabled = true
            motion.hovered = false
            motion.pressed = false
            motion.active = false
            motion.snapToRest()
        }

        function test_statePriorityIsPressedThenActiveThenHover() {
            compare(motion.targetScale, 1.0)
            compare(motion.targetOffsetY, 0)

            motion.hovered = true
            compare(motion.targetScale, 1.02)
            compare(motion.targetOffsetY, -2)

            motion.active = true
            compare(motion.targetScale, 1.01)
            compare(motion.targetOffsetY, -1)

            motion.pressed = true
            compare(motion.targetScale, 0.93)
            compare(motion.targetOffsetY, 1)

            motion.enabled = false
            compare(motion.targetScale, 1.0)
            compare(motion.targetOffsetY, 0)
        }

        function test_snapToRestIsDeterministic() {
            motion.scaleDriver.snapTo(0.8)
            motion.offsetDriver.snapTo(7)
            compare(motion.scale, 0.8)
            compare(motion.offsetY, 7)
            motion.snapToRest()
            compare(motion.scale, 1.0)
            compare(motion.offsetY, 0)
        }
    }
}
