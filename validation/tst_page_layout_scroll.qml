import QtQuick
import QtQuick.Controls
import QtTest
import MeoUI
import "../patterns" as Patterns

Item {
    width: 480
    height: 360

    Patterns.MeoPageLayout {
        id: page
        width: 360
        height: 220

        Item {
            width: page.width
            implicitHeight: 1200
        }
    }

    TestCase {
        name: "MeoPageLayoutScroll"
        when: windowShown

        function test_precisionAndMouseDeltasRespectTheSystemContract() {
            compare(page.wheelDeltaFor(0, 37, 0, 120), 37)
            compare(page.wheelDeltaFor(0, 0, 0, 120),
                    Math.max(1, Application.styleHints.wheelScrollLines) * 20)
            compare(page.wheelDeltaFor(0, 0, 0, -240),
                    -2 * Math.max(1, Application.styleHints.wheelScrollLines) * 20)
        }

        function test_scrollClampsAtBothContentBounds() {
            wait(0)
            verify(page.contentHeight > page.height)
            page.contentY = 120
            compare(page.scrollForWheelDelta(40), 80)
            compare(page.scrollForWheelDelta(1000), 0)

            const maximumContentY = Math.max(0, page.contentHeight - page.height)
            page.contentY = maximumContentY - 10
            compare(page.scrollForWheelDelta(-1000), maximumContentY)
        }
    }
}
