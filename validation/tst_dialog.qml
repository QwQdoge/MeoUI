import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    id: root
    width: 720
    height: 640

    Components.MeoDialog {
        id: basic
        parent: root
        title: "Reset settings?"
        message: "This restores preferences to their defaults."
        confirmText: "Accept"
        cancelText: "Cancel"
        icon: "restart_alt"
        showDivider: true
        supportingContent: Component {
            Text {
                text: "Example account row"
                color: MeoTheme.contentOnSurface
            }
        }
    }

    Components.MeoFullScreenDialog {
        id: full
        parent: root
        title: "Edit item"
        showDivider: true
        actions: [{ "text": "Save" }]
        bottomActions: [{ "text": "Cancel" }, { "text": "Apply" }]
        content: Component {
            Text {
                text: "Dialog content"
                color: MeoTheme.contentOnSurface
            }
        }
    }

    SignalSpy {
        id: confirmedSpy
        target: basic
        signalName: "confirmed"
    }

    SignalSpy {
        id: cancelledSpy
        target: basic
        signalName: "cancelled"
    }

    SignalSpy {
        id: dismissedSpy
        target: basic
        signalName: "dismissed"
    }

    TestCase {
        name: "MeoDialog"
        when: windowShown

        function init() {
            basic.close()
            full.close()
            confirmedSpy.clear()
            cancelledSpy.clear()
            dismissedSpy.clear()
        }

        function test_basicM3MeasurementsAndActions() {
            const basicSurface = findChild(basic, "meoDialogSurface")
            verify(basicSurface !== null)
            compare(basicSurface.Accessible.role, Accessible.Dialog)
            compare(basicSurface.Accessible.name, "Reset settings?")
            compare(basicSurface.Accessible.description,
                    "This restores preferences to their defaults.")
            compare(basic.minimumDialogWidth, 280 * MeoTheme.globalScale)
            compare(basic.maximumDialogWidth, 560 * MeoTheme.globalScale)
            compare(basic.contentPadding, 24 * MeoTheme.globalScale)
            compare(basic.contentGap, 16 * MeoTheme.globalScale)
            compare(basic.actionsGap, 24 * MeoTheme.globalScale)
            compare(basic.actionSpacing, 8 * MeoTheme.globalScale)
            compare(basic.width, 400 * MeoTheme.globalScale)
            const reject = findChild(basic, "meoDialogRejectButton")
            verify(reject !== null)
            compare(basic.initialFocusItem, reject)

            basic.open()
            wait(0)
            verify(basic.visible)
            const accept = findChild(basic, "meoDialogAcceptButton")
            verify(accept !== null)
            accept.click()
            compare(confirmedSpy.count, 1)

            basic.open()
            wait(0)
            const reject = findChild(basic, "meoDialogRejectButton")
            verify(reject !== null)
            reject.click()
            compare(cancelledSpy.count, 1)
            compare(dismissedSpy.count, 0)

            basic.open()
            wait(0)
            basic.close()
            compare(dismissedSpy.count, 1)
        }

        function test_fullScreenM3LayoutContract() {
            const fullSurface = findChild(full, "meoFullScreenDialogSurface")
            verify(fullSurface !== null)
            compare(fullSurface.Accessible.role, Accessible.Dialog)
            compare(fullSurface.Accessible.name, "Edit item")
            compare(full.maximumDialogWidth, 560 * MeoTheme.globalScale)
            compare(full.headerHeight, 56 * MeoTheme.globalScale)
            compare(full.bottomActionHeight, 56 * MeoTheme.globalScale)
            compare(full.inlinePadding, 24 * MeoTheme.globalScale)
            compare(full.width, 560 * MeoTheme.globalScale)
            verify(full.hasBottomActions)
            const closeButton = findChild(full, "meoFullScreenDialogCloseButton")
            verify(closeButton !== null)
            compare(full.initialFocusItem, closeButton)
            compare(closeButton.x, 12 * MeoTheme.globalScale)
            compare(closeButton.iconSize, 24)
            compare(closeButton.implicitWidth, 48 * MeoTheme.globalScale)
            compare(closeButton.containerHeight, 40 * MeoTheme.globalScale)

            full.open()
            wait(0)
            verify(full.visible)
            closeButton.click()
            tryVerify(function() { return !full.visible }, 500)
        }
    }
}
