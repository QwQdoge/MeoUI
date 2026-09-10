import QtQuick
import QtQuick.Controls
import QtTest
import MeoUI 1.0

Item {
    id: root
    width: 640
    height: 480

    Item {
        id: anchor
        x: 40
        y: 40
        width: 40
        height: 40
    }

    MeoMotionPopup {
        id: popup
        parent: root
        width: 180
        height: 120
        placement: "auto"

        contentItem: Item {
            implicitWidth: 180
            implicitHeight: 120
        }
    }

    MeoMotionPopup {
        id: childPopup
        parent: root
        width: 100
        height: 80
    }

    TestCase {
        name: "MeoMotionPopup"
        when: windowShown

        function cleanup() {
            if (childPopup.opened)
                childPopup.close()
            if (popup.opened)
                popup.close()
            tryCompare(childPopup, "opened", false)
            tryCompare(popup, "opened", false)
            tryCompare(popup, "contentActive", false)
            popup.unregisterTransientSurface(null)
        }

        function test_openFromPrewarmsAndPlacesBeforeOpening() {
            compare(popup.contentActive, false)
            popup.openFrom(anchor)
            tryCompare(popup, "opened", true)
            compare(popup.contentActive, true)
            verify(popup.y >= anchor.y + anchor.height)
            verify(popup.x >= popup.viewportMargin)
            popup.close()
            tryCompare(popup, "opened", false)
            tryCompare(popup, "contentActive", false)
        }

        function test_childTransientSuppressesParentOutsideDismissal() {
            popup.openFrom(anchor)
            tryCompare(popup, "opened", true)
            childPopup.open()
            tryCompare(childPopup, "opened", true)
            popup.registerTransientSurface(childPopup)
            verify(popup.hasOpenTransientSurface)
            compare(popup.closePolicy, Popup.CloseOnEscape)

            childPopup.close()
            tryCompare(childPopup, "opened", false)
            tryCompare(popup, "hasOpenTransientSurface", false)
            compare(popup.closePolicy, popup.defaultClosePolicy)
        }
    }
}
