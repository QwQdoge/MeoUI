import QtQuick
import QtTest
import MeoUI 1.0

Item {
    MeoRevealMotion {
        id: reveal
        active: false
        motionProfile: "pixel"
        closedScale: 0.97
        closedOffset: -12
    }

    TestCase {
        name: "MeoRevealMotion"
        when: windowShown

        function test_defaultClosedScaleUsesSharedPopupPolicy() {
            const original = reveal.closedScale
            reveal.closedScale = MeoMotion.popupClosedScale("pixel")
            compare(reveal.closedScale, MeoMotion.popupClosedScale("pixel"))
            reveal.closedScale = original
        }

        function test_closedAndOpenTargetsAreReusable() {
            reveal.active = false
            reveal.snapToActiveState()
            compare(reveal.resolvedScale, 0.97)
            compare(reveal.resolvedOffset, -12)

            reveal.active = true
            reveal.snapToActiveState()
            compare(reveal.resolvedScale, 1.0)
            compare(reveal.resolvedOffset, 0)
        }

        function test_reducedMotionAlwaysResolvesToOpenState() {
            reveal.active = false
            if (MeoTheme.reduceMotion) {
                reveal.snapToActiveState()
                compare(reveal.resolvedScale, 1.0)
                compare(reveal.resolvedOffset, 0)
            }
        }
    }
}
