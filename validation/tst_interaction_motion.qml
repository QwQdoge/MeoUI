import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 320
    height: 200

    MeoInteractionMotion {
        id: motion
        motionEnabled: false
    }

    TestCase {
        name: "MeoInteractionMotion"
        when: windowShown

        function test_stateTargetsRemainBoundAfterInitialization() {
            compare(motion.scaleValue, 1.0)
            compare(motion.offsetY, 0)

            motion.hovered = true
            compare(motion.scaleValue, motion.hoverScale)
            compare(motion.offsetY, motion.hoverOffsetY)

            motion.pressed = true
            compare(motion.scaleValue, motion.pressedScale)
            compare(motion.offsetY, motion.pressedOffsetY)

            motion.pressed = false
            motion.hovered = false
            motion.active = true
            compare(motion.scaleValue, motion.activeScale)
            compare(motion.offsetY, motion.activeOffsetY)
        }
    }
}
