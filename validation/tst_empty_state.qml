import QtQuick
import QtTest
import "../patterns" as Patterns

Item {
    width: 480
    height: 320

    Patterns.MeoEmptyState {
        id: emptyState
        anchors.fill: parent
        icon: "inbox"
        title: "No messages"
        description: "Empty states explain what happened."
        actionText: "Refresh"
    }

    SignalSpy {
        id: actionSpy
        target: emptyState
        signalName: "actionClicked"
    }

    TestCase {
        name: "MeoEmptyState"
        when: windowShown

        function test_contentThemeAndActionContract() {
            compare(emptyState.themeOnSurface, MeoTheme.contentOnSurface)
            compare(emptyState.themeOnSurfaceVariant, MeoTheme.contentOnSurfaceVariant)
            verify(findChild(emptyState, "meoEmptyStateAction") !== null)
            emptyState.actionClicked()
            compare(actionSpy.count, 1)
        }
    }
}
