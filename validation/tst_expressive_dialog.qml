import QtQuick
import QtTest
import "../patterns" as Patterns

Item {
    id: root
    width: 720
    height: 640

    Patterns.MeoExpressiveDialog {
        id: dialog
        parent: root
        title: "Confirm change"
        message: "The focused dialog contract is shared with MeoDialog."
        icon: "auto_awesome"
        content: Component { Text { text: "Extra detail" } }
    }

    TestCase {
        name: "MeoExpressiveDialog"
        when: windowShown

        function test_wrapperRetainsContentSlotAndDialogContract() {
            compare(dialog.preferredDialogWidth, 400 * MeoTheme.globalScale)
            compare(dialog.supportingContent, dialog.content)
            compare(dialog.minimumDialogWidth, 280 * MeoTheme.globalScale)
            compare(dialog.maximumDialogWidth, 560 * MeoTheme.globalScale)
            compare(dialog.initialFocusItem.objectName, "meoDialogRejectButton")
        }
    }
}
