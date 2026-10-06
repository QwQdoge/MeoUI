import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    width: 720
    height: 640

    property var arrayModel: [
        { "id": "inbox", "label": "Inbox", "icon": "inbox", "badgeText": "24" },
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
            rail.resizeInstantly = true
            rail.currentIndex = 0
            rail.currentId = "inbox"
            wait(0)
        }

        function test_staysCompactIconRail() {
            compare(Math.round(rail.width), Math.round(96 * rail.themeGlobalScale))
            verify(rail.visible)
        }

        function test_selectionAndStableIdStaySynchronized() {
            rail.currentIndex = 1
            compare(rail.currentId, "favorites")
            rail.currentId = "trash"
            compare(rail.currentIndex, 2)
        }

        function test_disabledDestinationRejectsActivation() {
            const locked = rail.destinationAt(3)
            verify(locked !== null)
            verify(!rail.destinationEnabled(locked))
            rail.activateDestination(3, locked)
            compare(rail.currentIndex, 0)
            compare(rail.currentId, "inbox")
        }

        function test_listModelIsSupported() {
            rail.model = listModel
            compare(rail.destinationCount, 2)
            compare(rail.destinationAt(1).label, "List archive")
        }
    }
}
