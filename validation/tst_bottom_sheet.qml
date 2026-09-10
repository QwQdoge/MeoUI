import QtQuick
import QtTest
import MeoUI

Item {
    id: root
    width: 800
    height: 640

    MeoBottomSheet {
        id: sheet
        parent: root
        content: Component { Item { implicitHeight: 120 } }
    }

    TestCase {
        name: "MeoBottomSheet"
        when: windowShown

        function test_modalSheetUsesTheMaterialMaximumWidth() {
            compare(sheet.maximumWidth, 640 * MeoTheme.globalScale)
            compare(sheet.width, sheet.maximumWidth)
            sheet.open()
            tryVerify(function() { return sheet.visible }, 500)
            compare(sheet.x, (root.width - sheet.width) / 2)
            sheet.close()
        }

        function test_sheetHeightIsBoundedByTheVisibleHost() {
            sheet.open()
            tryVerify(function() { return sheet.visible }, 500)
            sheet.preferredHeight = root.height * 2
            compare(sheet.height, root.height * sheet.maximumHeightRatio)
            sheet.preferredHeight = 0
            sheet.close()
        }
    }
}
