import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoColorField { id: colorField; color: "#6750A4" }

    TestCase {
        name: "MeoColorField"
        when: windowShown

        function test_textAliasCanBePrefilledAndCommitted() {
            compare(colorField.text, "#6750a4")
            colorField.text = "#FF8800"
            compare(colorField.normalizedText, "#ff8800")
            verify(colorField.commit())
            compare(colorField.color.toString(), "#ff8800")
        }

        function test_invalidTextRemainsActionable() {
            colorField.text = "#12AB"
            compare(colorField.valid, false)
            compare(colorField.commit(), false)
            compare(colorField.text, "#12AB")
        }
    }
}
