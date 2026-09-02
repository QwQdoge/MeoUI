import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    width: 720
    height: 640

    property var arrayModel: [
        { "id": "inbox", "label": "Inbox", "icon": "inbox", "badgeText": "24" },
        { "type": "header", "label": "Labels" },
        { "id": "favorites", "label": "Favorites", "icon": "favorite", "badgeDot": true },
        { "id": "trash", "label": "Trash", "icon": "delete" },
        { "id": "locked", "label": "Locked", "icon": "lock", "enabled": false }
    ]

    ListModel {
        id: listModel
        ListElement { label: "List inbox"; icon: "inbox" }
        ListElement { label: "List archive"; icon: "archive" }
    }

    Widgets.MeoNavigationRail {
        id: rail
        height: parent.height
        model: arrayModel
        currentIndex: 0
    }

    TestCase {
        name: "MeoNavigationRail"
        when: windowShown

        function init() {
            rail.model = arrayModel
            rail.isExpanded = false
            // Width intentionally animates during normal interaction. Make
            // geometry assertions deterministic without weakening runtime
            // motion coverage elsewhere.
            rail.resizeInstantly = true
            rail.expandedWidth = 280 * rail.themeGlobalScale
            rail.hideWhenCollapsed = false
            rail.currentIndex = 0
            rail.currentId = "inbox"
            wait(0)
        }

        function test_expressiveWidthsAreBounded() {
            compare(Math.round(rail.width), Math.round(96 * rail.themeGlobalScale))

            rail.isExpanded = true
            compare(Math.round(rail.width), Math.round(280 * rail.themeGlobalScale))

            rail.expandedWidth = 100 * rail.themeGlobalScale
            compare(Math.round(rail.width), Math.round(220 * rail.themeGlobalScale))

            rail.expandedWidth = 420 * rail.themeGlobalScale
            compare(Math.round(rail.width), Math.round(360 * rail.themeGlobalScale))
        }

        function test_expandedRailCanHideWhenCollapsed() {
            rail.hideWhenCollapsed = true
            compare(Math.round(rail.width), 0)
            verify(!rail.visible)

            rail.isExpanded = true
            compare(Math.round(rail.width), Math.round(280 * rail.themeGlobalScale))
            verify(rail.visible)
        }

        function test_selectionAndCurrentIdStaySynchronized() {
            rail.currentIndex = 2
            compare(rail.currentId, "favorites")

            rail.currentId = "trash"
            compare(rail.currentIndex, 3)
        }

        function test_fullWidthDestinationActivatesAndUsesPill() {
            rail.isExpanded = true
            const destination = findChild(rail, "meoNavigationRailDestination_2")
            const indicator = findChild(rail, "meoNavigationRailExpandedIndicator_2")
            verify(destination !== null)
            verify(indicator !== null)
            compare(Math.round(destination.width), Math.round(rail.width))
            compare(Math.round(indicator.height), Math.round(56 * rail.themeGlobalScale))
            verify(indicator.width < destination.width)
            compare(Math.round(indicator.x), Math.round(36 * rail.themeGlobalScale))

            mouseClick(destination, destination.width / 2, destination.height / 2)
            compare(rail.currentIndex, 2)
            verify(rail.currentId === "favorites")
        }

        function test_badgeAndGroupAreRepresented() {
            rail.isExpanded = false
            const collapsedIndicator = findChild(rail, "meoNavigationRailCollapsedIndicator_0")
            const collapsedLabel = findChild(rail, "meoNavigationRailCollapsedLabel_0")
            const groupedDestination = findChild(rail, "meoNavigationRailDestination_2")
            verify(collapsedIndicator !== null)
            verify(collapsedLabel !== null)
            verify(groupedDestination !== null)
            compare(Math.round(collapsedIndicator.width), Math.round(56 * rail.themeGlobalScale))
            compare(collapsedLabel.color, rail.themeSecondary)
        }

        function test_expandedActiveLabelUsesSecondaryRole() {
            rail.isExpanded = true
            const label = findChild(rail, "meoNavigationRailExpandedLabel_0")
            verify(label !== null)
            verify(rail.themeSecondary !== rail.themeOnSecondaryContainer)
            compare(label.color, rail.themeSecondary)
        }

        function test_disabledDestinationRejectsProgrammaticActivation() {
            const locked = rail.destinationAt(4)
            verify(locked !== null)
            verify(!rail.destinationEnabled(locked))

            rail.activateDestination(4, locked)
            compare(rail.currentIndex, 0)
            compare(rail.currentId, "inbox")
        }

        function test_listModelCountAndAccessAreSupported() {
            rail.model = listModel
            compare(rail.destinationCount, 2)
            compare(rail.destinationAt(1).label, "List archive")
        }
    }
}
