import QtQuick
import QtTest
import MeoUI

Item {
    width: 480
    height: 160

    MeoBottomAppBar {
        id: bar
        width: parent.width
        navigationIcons: ["search", "more_vert"]
    }

    TestCase {
        name: "MeoBottomAppBar"
        when: windowShown

        function test_baselineMaterialContainerTokens() {
            compare(bar.height, 80 * MeoTheme.globalScale)
            compare(bar.radius, MeoTheme.shapeNone)
            compare(bar.color, MeoTheme.surfaceContainer)
        }

        function test_actionModelRemainsAvailableWithoutFab() {
            compare(bar.navigationIcons.length, 2)
            verify(!bar.fab)
        }
    }
}
