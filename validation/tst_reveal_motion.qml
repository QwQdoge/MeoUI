import QtQuick
import QtTest
import MeoUI 1.0

Item {
    MeoRevealMotion {
        id: reveal
        hiddenScale: 0.9
        hiddenOpacity: 0
        hiddenOffsetX: 4
        hiddenOffsetY: -8
    }

    TestCase {
        name: "MeoRevealMotion"

        function cleanup() {
            reveal.enabled = true
            reveal.shown = false
            reveal.snapHidden()
        }

        function test_targetsFollowShownState() {
            compare(reveal.targetScale, 0.9)
            compare(reveal.targetOpacity, 0)
            compare(reveal.targetOffsetX, 4)
            compare(reveal.targetOffsetY, -8)

            reveal.shown = true
            compare(reveal.targetScale, 1)
            compare(reveal.targetOpacity, 1)
            compare(reveal.targetOffsetX, 0)
            compare(reveal.targetOffsetY, 0)

            reveal.enabled = false
            compare(reveal.targetScale, 1)
            compare(reveal.targetOpacity, 1)
            compare(reveal.targetOffsetX, 0)
            compare(reveal.targetOffsetY, 0)
        }

        function test_snapHelpers() {
            reveal.snapShown()
            compare(reveal.scale, 1)
            compare(reveal.opacity, 1)
            compare(reveal.offsetX, 0)
            compare(reveal.offsetY, 0)
            reveal.snapHidden()
            compare(reveal.scale, 0.9)
            compare(reveal.opacity, 0)
            compare(reveal.offsetX, 4)
            compare(reveal.offsetY, -8)
        }
    }
}
