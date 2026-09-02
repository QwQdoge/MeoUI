import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoSuggestionChip { id: suggestionChip; label: "Material" }

    TestCase {
        name: "MeoSuggestionChip"
        when: windowShown

        function test_suggestionDefaultsStayNonClosable() {
            compare(suggestionChip.type, "suggestion")
            verify(!suggestionChip.closable)
            compare(suggestionChip.visualStyle, "outlined")
            compare(suggestionChip.chipHeight, 32 * suggestionChip.themeGlobalScale)
            compare(suggestionChip.leadingIconColor, suggestionChip.themePrimary)
            compare(suggestionChip.Accessible.name, "Material")
        }
    }
}
