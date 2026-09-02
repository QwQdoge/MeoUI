import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    id: root
    width: 800
    height: 160

    Component {
        id: action
        Rectangle {
            width: 40
            height: 40
            color: "transparent"
        }
    }

    Widgets.MeoSearchAppBar {
        id: appBar
        width: root.width
        height: 64
        placeholder: "Search library"
        actions: [action]
    }

    TestCase {
        name: "MeoSearchAppBar"
        when: windowShown

        function test_usesStableAppBarGeometry() {
            compare(appBar.implicitHeight, 64)
            verify(appBar.width > 0)
            verify(appBar.actionReservation > 0)
        }

        function test_activeStateKeepsCompactSearchAffordance() {
            appBar.active = true
            wait(0)
            compare(appBar.active, true)
            compare(appBar.actionReservation, 0)
            appBar.active = false
        }
    }
}
