import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 480
    height: 140

    MeoSwipeToDismiss {
        id: swipe
        width: 420
        content: Component { Rectangle { implicitWidth: 420; implicitHeight: 72 } }
        leftAction: Component { Item {} }
    }

    TestCase {
        name: "MeoSwipeToDismiss"
        when: windowShown

        function test_directionAvailabilityAndRestore() {
            verify(swipe.canSwipeRight)
            verify(!swipe.canSwipeLeft)
            compare(swipe.positionalThreshold, 56 * MeoTheme.globalScale)
            compare(swipe.thresholdDistance, swipe.positionalThreshold)
            verify(swipe.canSwipeStartToEnd)
            verify(!swipe.canSwipeEndToStart)
            swipe.dismissed = true
            swipe.restore()
            compare(swipe.dismissed, false)
        }

        function test_disabledStateIsExposed() {
            swipe.enabled = false
            compare(swipe.enabled, false)
            swipe.gesturesEnabled = false
            compare(swipe.gesturesEnabled, false)
        }
    }
}
