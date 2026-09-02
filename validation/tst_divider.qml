import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 240
    height: 160

    Components.MeoDivider {
        id: horizontalDivider
        width: 200
        leftInset: 20
        rightInset: 12
        thickness: 2
    }

    Components.MeoDivider {
        id: verticalDivider
        x: 216
        orientation: "vertical"
        height: 120
        topInset: 8
        bottomInset: 16
        thickness: 3
    }

    TestCase {
        name: "MeoDivider"
        when: windowShown

        function test_horizontalLineAppliesInsetsAndThickness() {
            const line = findChild(horizontalDivider, "meoDividerLine")
            verify(line !== null)
            compare(Math.round(line.width), 168)
            compare(Math.round(line.height), 2)
            compare(horizontalDivider.Accessible.name, "Divider")
        }

        function test_verticalLineAppliesInsetsAndThickness() {
            const line = findChild(verticalDivider, "meoDividerLine")
            verify(line !== null)
            compare(Math.round(line.width), 3)
            compare(Math.round(line.height), 96)
        }
    }
}
