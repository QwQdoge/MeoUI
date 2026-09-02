import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 460
    height: 200

    Components.MeoListItem {
        id: standardRow
        width: 420
        headline: "Inbox"
        supportingText: "Three unread messages"
        leadingIcon: "inbox"
    }

    Components.MeoListItem {
        id: selectedRow
        y: 88
        width: 420
        headline: "Selected"
        supportingText: "Tonal selection"
        selected: true
        isSegmented: true
    }

    Components.MeoListItem {
        id: overlineRow
        y: 176
        width: 420
        headline: "Draft"
        overline: "Recent"
    }

    SignalSpy {
        id: clickSpy
        target: standardRow
        signalName: "clicked"
    }

    TestCase {
        name: "MeoListItem"
        when: windowShown

        function init() {
            standardRow.enabled = true
            standardRow.LayoutMirroring.enabled = false
            MeoTheme.isExpressive = false
            selectedRow.vibrant = false
            selectedRow.LayoutMirroring.enabled = false
            clickSpy.clear()
        }

        function test_tonalSelectionUsesSemanticContainer() {
            compare(selectedRow.selectedContainerColor, MeoTheme.secondaryContainer)
            compare(selectedRow.selectedContentColor, MeoTheme.contentOnSecondaryContainer)
            verify(findChild(selectedRow, "meoListItemSurface") !== null)
        }

        function test_overlineOnlyUsesTwoLineHeight() {
            compare(Math.round(overlineRow.implicitHeight),
                    Math.round(72 * MeoTheme.globalScale))
        }

        function test_vibrantContentMatchesItsContainer() {
            MeoTheme.isExpressive = true
            selectedRow.vibrant = true
            compare(selectedRow.selectedContainerColor, MeoTheme.primary)
            compare(selectedRow.selectedContentColor, MeoTheme.contentOnPrimary)
            MeoTheme.isExpressive = false
        }

        function test_pointerKeyboardAndRtlContracts() {
            mouseClick(standardRow, 24, 24, Qt.LeftButton)
            compare(clickSpy.count, 1)
            standardRow.forceActiveFocus(Qt.TabFocusReason)
            keyClick(Qt.Key_Space)
            compare(clickSpy.count, 2)

            standardRow.LayoutMirroring.enabled = true
            wait(0)
            verify(standardRow.mirrored)
        }

        function test_disabledDoesNotActivate() {
            standardRow.enabled = false
            mouseClick(standardRow, 24, 24, Qt.LeftButton)
            compare(clickSpy.count, 0)
            verify(!standardRow.activeFocusOnTab)
            verify(!standardRow.Accessible.focusable)

            selectedRow.enabled = false
            compare(selectedRow.resolvedSelectedContainerColor, MeoTheme.contentOnSurface)
            compare(selectedRow.resolvedSelectedContainerOpacity, MeoTheme.disabledContentOpacity)
        }
    }
}
