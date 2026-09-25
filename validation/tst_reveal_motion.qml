import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 320
    height: 200

    MeoRevealMotion {
        id: reveal
        motionEnabled: false
        hiddenScale: 0.9
        hiddenOffsetX: 4
        hiddenOffsetY: -12
    }

    TestCase {
        name: "MeoRevealMotion"
        when: windowShown

        function test_hiddenAndShownTargetsRemainLive() {
            compare(reveal.opacityValue, reveal.hiddenOpacity)
            compare(reveal.scaleValue, 0.9)
            compare(reveal.offsetX, 4)
            compare(reveal.offsetY, -12)

            reveal.revealed = true
            compare(reveal.opacityValue, reveal.shownOpacity)
            compare(reveal.scaleValue, reveal.shownScale)
            compare(reveal.offsetX, reveal.shownOffsetX)
            compare(reveal.offsetY, reveal.shownOffsetY)

            reveal.revealed = false
            compare(reveal.opacityValue, reveal.hiddenOpacity)
            compare(reveal.scaleValue, 0.9)
            compare(reveal.offsetY, -12)
        }
    }
}
