import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoFilterChip { id: filterChip; label: "Design" }

    TestCase {
        name: "MeoFilterChip"
        when: windowShown

        function test_filterSelectionToggles() {
            compare(filterChip.type, "filter")
            verify(!filterChip.closable)
            compare(filterChip.visualStyle, "outlined")
            compare(filterChip.chipHeight, 32 * filterChip.themeGlobalScale)
            filterChip.activate()
            verify(filterChip.selected)
            filterChip.activate()
            verify(!filterChip.selected)
        }
    }
}
