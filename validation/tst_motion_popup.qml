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
            popup.presentation = MeoMotionPopup.Dialog
            popup.motionProfile = "pixel"
            popup.placement = "auto"
        }

        function test_expressiveMenuUsesReusableSpatialPolicy() {
            popup.presentation = MeoMotionPopup.Menu
            popup.motionProfile = "pixel"
            popup.placement = "below"

            if (!MeoTheme.reduceMotion)
                verify(popup.expressiveSpatialEntrance)
            compare(popup.entranceScale, MeoMotion.popupClosedScale("pixel"))
            compare(popup.spatialRevealScale, popup.scale)
            compare(popup.transformOrigin, Item.TopLeft)

            popup.placement = "above"
            compare(popup.transformOrigin, Item.BottomLeft)
            popup.placement = "left"
            compare(popup.transformOrigin, Item.Right)
            popup.placement = "right"
            compare(popup.transformOrigin, Item.Left)
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