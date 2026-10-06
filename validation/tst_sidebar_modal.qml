import QtQuick
import QtTest
import MeoUI

Item {
    id: root
    width: 720
    height: 640

    MeoSidebarModal {
        id: sidebarModal
        parent: root
        groups: [{ "title": "General", "rows": [
            { "title": "Home", "route": "home", "leadingIcon": "home" },
            { "title": "Explore", "route": "explore", "leadingIcon": "explore" }
        ] }]
        selectedRoute: "home"
    }

    SignalSpy { id: routeSpy; target: sidebarModal; signalName: "routeActivated" }

    TestCase {
        name: "MeoSidebarModal"
        when: windowShown

        function init() {
            sidebarModal.close()
            routeSpy.clear()
        }

        function test_openHasAccessibleDialogSurface() {
            sidebarModal.openForNavigation()
            wait(0)
            compare(sidebarModal.visible, true)
            compare(sidebarModal.contentItem.Accessible.role, Accessible.Dialog)
            sidebarModal.close()
        }

        function test_escapeDismissesWhileSearchHasFocus() {
            sidebarModal.openForNavigation()
            wait(100)
            keyClick(Qt.Key_Escape)
            tryCompare(sidebarModal, "visible", false)
        }

        function test_destinationActivationForwardsRouteAndCloses() {
            sidebarModal.open()
            const sidebar = findChild(sidebarModal, "meoSidebar")
            verify(sidebar !== null)
            sidebar.activateRow(sidebar.groups[0].rows[1])
            compare(routeSpy.count, 1)
            compare(routeSpy.signalArguments[0][0], "explore")
            wait(400)
            compare(sidebarModal.visible, false)
        }
    }
}
