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

        function test_snapPreservesBoundTargetsForLaterRetargets() {
            reveal.active = false
            reveal.snapToActiveState()
            compare(reveal.resolvedScale, reveal.closedScale)

            reveal.active = true
            if (reveal.spatialMotionAllowed)
                tryCompare(reveal, "resolvedScale", reveal.openScale, 1200)
            else
                compare(reveal.resolvedScale, reveal.openScale)
        }

        function test_revealFromClosedSeedsThenRetargets() {
            reveal.active = true
            reveal.revealFromClosed()
            if (reveal.spatialMotionAllowed)
                compare(reveal.resolvedScale, reveal.closedScale)
            tryCompare(reveal, "resolvedScale", reveal.openScale, 1200)
        }

        function test_explicitYOverridesLegacyAlias() {
            reveal.active = false
            reveal.closedOffsetY = 9
            reveal.snapToActiveState()
            compare(reveal.resolvedOffsetY, 9)
            reveal.closedOffsetY = reveal.closedOffset
        }

        function test_disabledSpatialMotionAlwaysResolvesToOpenState() {
            reveal.active = false
            reveal.motionEnabled = false
            reveal.snapToActiveState()
            compare(reveal.spatialMotionAllowed, false)
            compare(reveal.resolvedScale, reveal.openScale)
            compare(reveal.resolvedOffsetX, reveal.openOffsetX)
            compare(reveal.resolvedOffsetY, reveal.openOffsetY)
            reveal.motionEnabled = true
        }

        function test_reducedMotionAlwaysResolvesToOpenState() {
            reveal.active = false
            if (MeoTheme.reduceMotion) {
                reveal.snapToActiveState()
                compare(reveal.spatialMotionAllowed, false)
                compare(reveal.resolvedScale, reveal.openScale)
                compare(reveal.resolvedOffsetX, reveal.openOffsetX)
                compare(reveal.resolvedOffsetY, reveal.openOffsetY)
            }
        }
    }
}
