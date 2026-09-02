import QtQuick
import QtTest
import MeoUI

Item {
    id: root
    width: 800
    height: 640

    MeoActionSheet {
        id: sheet
        parent: root
        title: "Share"
        model: [
            { "label": "Messages", "icon": "chat" },
            { "label": "Email", "icon": "mail" }
        ]
    }

    TestCase {
        name: "MeoActionSheet"
        when: windowShown

        function test_usesSharedModalSheetSizingContract() {
            compare(sheet.maximumWidth, 640 * MeoTheme.globalScale)
            compare(sheet.width, sheet.maximumWidth)
            compare(sheet.model.length, 2)
        }

        function test_actionSheetOpensAndClosesThroughSharedPopupLifecycle() {
            sheet.open()
            tryCompare(sheet, "opened", true, 1000)
            sheet.close()
            tryCompare(sheet, "opened", false, 1000)
        }
    }
}
