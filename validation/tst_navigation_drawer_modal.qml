import QtQuick
import QtTest
import MeoUI
import "../widgets" as Widgets

Item {
    id: root
    width: 720
    height: 640

    Widgets.MeoNavigationDrawerModal {
        id: drawer
        parent: root
        model: [
            { "id": "inbox", "label": "Inbox", "icon": "inbox" },
            { "id": "outbox", "label": "Outbox", "icon": "send" }
        ]
    }

    TestCase {
        name: "MeoNavigationDrawerModal"
        when: windowShown

        function init() {
            drawer.close()
            drawer.currentIndex = 0
            drawer.currentId = "inbox"
        }

        function test_compatibilitySurfaceUsesExpandedRailContract() {
            compare(drawer.expandedWidth, 360 * MeoTheme.globalScale)
            compare(drawer.resolvedWidth, 360 * MeoTheme.globalScale)
            compare(drawer.minimumWidth, 220 * MeoTheme.globalScale)
            compare(drawer.maximumWidth, 360 * MeoTheme.globalScale)
            compare(drawer.closeOnDestination, false)
            const surface = findChild(drawer, "meoNavigationRailModalSurface")
            verify(surface !== null)
            compare(surface.Accessible.role, Accessible.Dialog)
        }

        function test_compatibilitySelectionKeepsStableId() {
            drawer.currentIndex = 1
            compare(drawer.currentId, "outbox")
            drawer.currentId = "inbox"
            compare(drawer.currentIndex, 0)
        }
    }
}
