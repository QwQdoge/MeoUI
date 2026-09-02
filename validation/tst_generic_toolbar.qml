import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoToolbar { id: toolbar; title: "Tools" }

    TestCase {
        name: "MeoToolbar"
        when: windowShown

        function test_intrinsicHeightTracksCompactMode() {
            toolbar.isCompact = false
            compare(toolbar.implicitHeight, 56 * MeoTheme.globalScale)
            toolbar.isCompact = true
            compare(toolbar.implicitHeight, 48 * MeoTheme.globalScale)
            toolbar.isCompact = false
        }

        function test_intrinsicWidthIncludesMinimumTarget() {
            toolbar.title = ""
            verify(toolbar.implicitWidth >= 160 * MeoTheme.globalScale)
        }
    }
}
