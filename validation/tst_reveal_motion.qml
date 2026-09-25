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
        closedOffsetX: 6
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

        function test_closedAndOpenTargetsAreReusableInTwoDimensions() {
            reveal.active = false
            reveal.snapToActiveState()
            compare(reveal.resolvedScale, 0.97)
            compare(reveal.resolvedOffsetX, 6)
            compare(reveal.resolvedOffsetY, -12)
            compare(reveal.resolvedOffset, reveal.resolvedOffsetY)

            reveal.active = true
            reveal.snapToActiveState()
            compare(reveal.resolvedScale, 1.0)
            compare(reveal.resolvedOffsetX, 0)
            compare(reveal.resolvedOffsetY, 0)
        }

        function test_explicitYOverridesLegacyAlias() {
            reveal.active = false
            reveal.closedOffsetY = 9
            reveal.snapToActiveState()
            compare(reveal.resolvedOffsetY, 9)
            reveal.closedOffsetY = Qt.binding(function() { return reveal.closedOffset })
        }

        function test_reducedMotionAlwaysResolvesToOpenState() {
            reveal.active = false
            if (MeoTheme.reduceMotion) {
                reveal.snapToActiveState()
                compare(reveal.resolvedScale, 1.0)
                compare(reveal.resolvedOffsetX, 0)
                compare(reveal.resolvedOffsetY, 0)
            }
        }
    }
}
