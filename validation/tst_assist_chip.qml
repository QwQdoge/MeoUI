import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoAssistChip {
        id: assistChip
        label: "Directions"
        icon: "directions"
    }

    TestCase {
        name: "MeoAssistChip"
        when: windowShown

        function test_assistDefaultsStayNonClosable() {
            compare(assistChip.type, "assist")
            verify(!assistChip.closable)
            compare(assistChip.visualStyle, "outlined")
            compare(assistChip.chipHeight, 32 * assistChip.themeGlobalScale)
            compare(assistChip.chipRadius, 8 * assistChip.themeGlobalScale)
            compare(assistChip.Accessible.name, "Directions")
        }

        function test_expressivePropsRemainAvailable() {
            assistChip.elevated = true
            assistChip.shape = "rounded"
            assistChip.visualStyle = "outlined"
            verify(assistChip.elevated)
            verify(!assistChip.usesOutlinedContainer)
            compare(assistChip.shape, "rounded")
            compare(assistChip.visualStyle, "outlined")
        }
    }
}
