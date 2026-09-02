import QtQuick
import QtTest
import "../components" as Components

Item {
    id: root
    width: 520
    height: 320

    Component {
        id: panelContent
        Item {
            implicitHeight: 48
            implicitWidth: 300
        }
    }

    Components.MeoExpansionPanel {
        id: panel
        width: 420
        title: "More options"
        subtitle: "Additional controls"
        icon: "tune"
        contentItem: panelContent
    }

    SignalSpy {
        id: toggledSpy
        target: panel
        signalName: "toggled"
    }

    TestCase {
        name: "MeoExpansionPanel"
        when: windowShown

        function init() {
            panel.enabled = true
            panel.interactive = true
            panel.expanded = false
            panel.LayoutMirroring.enabled = false
            toggledSpy.clear()
        }

        function test_toggleChangesContentHeightWithoutTransformingTheHeader() {
            const collapsedHeight = panel.implicitHeight
            verify(panel.toggle())
            compare(panel.expanded, true)
            tryVerify(function() { return panel.implicitHeight > collapsedHeight }, 500)
            compare(toggledSpy.count, 1)
            verify(panel.toggle())
            compare(panel.expanded, false)
            compare(toggledSpy.count, 2)
        }

        function test_disabledOrNonInteractivePanelsDoNotToggle() {
            panel.enabled = false
            verify(!panel.toggle())
            verify(!panel.expanded)
            panel.enabled = true
            panel.interactive = false
            verify(!panel.toggle())
            verify(!panel.expanded)
        }

        function test_rtlAndAccessibilityStateRemainSemantic() {
            panel.LayoutMirroring.enabled = true
            verify(panel.isMirrored)
            verify(panel.Accessible.focusable)
            verify(panel.toggle())
            verify(panel.expanded)
        }

        function test_disabledPanelIsNotAccessibilityFocusable() {
            panel.enabled = false
            verify(!panel.Accessible.focusable)
            panel.enabled = true
            panel.interactive = false
            verify(!panel.Accessible.focusable)
        }
    }
}
