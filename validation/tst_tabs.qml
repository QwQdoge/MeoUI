import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    id: root
    width: 640
    height: 280

    Components.MeoTabs {
        id: tabs
        width: 420
        model: [
            { "label": "Overview", "icon": "dashboard" },
            { "label": "Files", "enabled": false },
            { "label": "Activity", "badgeDot": true }
        ]
    }

    SignalSpy {
        id: clickedSpy
        target: tabs
        signalName: "clicked"
    }

    TestCase {
        name: "MeoTabs"
        when: windowShown

        function init() {
            tabs.style = "standard"
            tabs.type = "primary"
            tabs.currentIndex = 0
            tabs.isScrollable = false
            tabs.LayoutMirroring.enabled = false
            clickedSpy.clear()
        }

        function test_standardIsTheDefaultMaterialTreatment() {
            compare(tabs.style, "standard")
            verify(!tabs.expressive)
            compare(tabs.implicitHeight, 72 * MeoTheme.globalScale)
            verify(tabs.activate(2))
            compare(tabs.currentIndex, 2)
            compare(clickedSpy.count, 1)
        }

        function test_disabledTabsCannotActivate() {
            verify(!tabs.tabEnabled(tabs.model[1]))
            verify(!tabs.activate(1))
            compare(tabs.currentIndex, 0)
            compare(clickedSpy.count, 0)
        }

        function test_focusTraversalSkipsDisabledItems() {
            verify(tabs.focusTab(0, 1))
            compare(tabs.currentIndex, 2)
            verify(tabs.focusTab(2, 1))
            compare(tabs.currentIndex, 0)
            verify(tabs.focusTab(0, -1))
            compare(tabs.currentIndex, 2)
        }

        function test_secondaryAndExpressiveGeometryAreExplicit() {
            tabs.type = "secondary"
            compare(tabs.implicitHeight, 48 * MeoTheme.globalScale)
            compare(tabs.edgeInset, 0)
            var firstTab = findChild(tabs, "meoTab_0")
            verify(firstTab !== null)
            compare(firstTab.selectedContentColor, MeoTheme.contentOnSurface)
            tabs.isScrollable = true
            compare(tabs.edgeInset, 52 * MeoTheme.globalScale)
            tabs.type = "primary"
            tabs.style = "expressive"
            verify(tabs.expressive)
            compare(tabs.implicitHeight, 72 * MeoTheme.globalScale)
            compare(tabs.edgeInset, 4 * MeoTheme.globalScale)
        }

        function test_rtlDoesNotChangeSelectionSemantics() {
            tabs.LayoutMirroring.enabled = true
            verify(tabs.mirrored)
            verify(tabs.activate(2))
            compare(tabs.currentIndex, 2)
        }
    }
}
