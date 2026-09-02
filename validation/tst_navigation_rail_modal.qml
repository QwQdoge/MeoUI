import QtQuick
import QtTest
import MeoUI
import "../widgets" as Widgets

Item {
    id: root
    width: 720
    height: 640

    Widgets.MeoNavigationRailModal {
        id: modalRail
        parent: root
        model: [
            { "id": "inbox", "label": "Inbox", "icon": "inbox" },
            { "id": "outbox", "label": "Outbox", "icon": "send" }
        ]
        expandedWidth: 280 * MeoTheme.globalScale
    }

    TestCase {
        name: "MeoNavigationRailModal"
        when: windowShown

        function init() {
            modalRail.close()
            modalRail.expandedWidth = 280 * MeoTheme.globalScale
            modalRail.currentIndex = 0
            modalRail.currentId = "inbox"
        }

        function test_m3ModalWidthIsBounded() {
            compare(modalRail.minimumWidth, 220 * MeoTheme.globalScale)
            compare(modalRail.maximumWidth, 360 * MeoTheme.globalScale)
            compare(modalRail.resolvedWidth, 280 * MeoTheme.globalScale)
            // AndroidX NavigationRailExpandedTokens uses CornerLarge for the
            // modal expanded rail.  The docked expanded rail is deliberately
            // square, so this assertion protects the modal-only distinction.
            compare(modalRail.surfaceRadius, MeoTheme.shapeLarge)

            modalRail.expandedWidth = 100 * MeoTheme.globalScale
            compare(modalRail.resolvedWidth, 220 * MeoTheme.globalScale)
            modalRail.expandedWidth = 420 * MeoTheme.globalScale
            compare(modalRail.resolvedWidth, 360 * MeoTheme.globalScale)
        }

        function test_modalSurfaceOpens() {
            const surface = findChild(modalRail, "meoNavigationRailModalSurface")
            verify(surface !== null)
            compare(surface.Accessible.role, Accessible.Dialog)
            modalRail.open()
            wait(0)
            verify(modalRail.visible)
            modalRail.close()
        }

        function test_programmaticSelectionKeepsStableIdSynchronized() {
            modalRail.currentIndex = 1
            compare(modalRail.currentId, "outbox")

            modalRail.currentId = "inbox"
            compare(modalRail.currentIndex, 0)
        }
    }
}
