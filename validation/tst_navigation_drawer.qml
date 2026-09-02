import QtQuick
import QtTest
import MeoUI
import "../widgets" as Widgets

Item {
    width: 400
    height: 520

    Widgets.MeoNavigationDrawer {
        id: drawer
        height: parent.height
        title: "Mail"
        model: [
            { "type": "header", "label": "Mail" },
            { "id": "inbox", "label": "Inbox", "icon": "inbox" },
            { "id": "outbox", "label": "Outbox", "icon": "send" }
        ]
        currentIndex: 1
    }

    TestCase {
        name: "MeoNavigationDrawer"
        when: windowShown

        function init() {
            drawer.currentIndex = 1
            drawer.currentId = "inbox"
            drawer.isModal = false
            drawer.visualStyle = "standard"
        }

        function test_themeAndPermanentDrawerGeometry() {
            compare(drawer.themeSurface, MeoTheme.surface)
            compare(drawer.themeSurfaceContainerLow, MeoTheme.surfaceContainerLow)
            compare(drawer.themeGlobalScale, MeoTheme.globalScale)
            compare(drawer.implicitWidth, 360 * MeoTheme.globalScale)
            compare(drawer.width, 360 * MeoTheme.globalScale)
            compare(drawer.color, MeoTheme.surface)

            drawer.isModal = true
            compare(drawer.color, MeoTheme.surfaceContainerLow)
        }

        function test_stableDestinationIdentitySkipsHeaders() {
            compare(drawer.currentId, "inbox")
            drawer.currentIndex = 2
            compare(drawer.currentId, "outbox")
            drawer.currentId = "inbox"
            compare(drawer.currentIndex, 1)
            drawer.currentIndex = 0
            compare(drawer.currentId, "inbox")
        }
    }
}
