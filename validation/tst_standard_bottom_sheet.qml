import QtQuick
import QtTest
import MeoUI

Item {
    id: root
    width: 480
    height: 640

    MeoStandardBottomSheet {
        id: sheet
        width: parent.width
        height: parent.height
        content: Component { Item { implicitHeight: 80 } }
    }

    TestCase {
        name: "MeoStandardBottomSheet"
        when: windowShown

        function test_defaultPeekHeightUsesMaterialBottomSheetDefault() {
            compare(sheet.peekHeight, 56 * MeoTheme.globalScale)
            compare(sheet.implicitHeight, sheet.peekHeight)
        }

        function test_openStateUsesCallerControlledExpandedHeight() {
            sheet.expandedHeight = 312 * MeoTheme.globalScale
            sheet.isOpen = true
            compare(sheet.implicitHeight, sheet.expandedHeight)
            sheet.isOpen = false
        }

        function test_expandedSurfaceDoesNotOverflowItsHost() {
            sheet.expandedHeight = root.height + 120 * MeoTheme.globalScale
            compare(sheet.resolvedExpandedHeight, root.height)
            sheet.isOpen = true
            compare(sheet.implicitHeight, root.height)
            sheet.isOpen = false
        }
    }
}
