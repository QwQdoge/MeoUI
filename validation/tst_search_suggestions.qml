import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    width: 480
    height: 240

    Widgets.MeoSearchSuggestions {
        id: suggestions
        width: 400
        model: [
            { "label": "MeoTheme <primary>", "isHistory": true },
            { "label": "MeoSearchView", "icon": "search" }
        ]
    }

    TestCase {
        name: "MeoSearchSuggestions"
        when: windowShown

        function test_escapesLabelsBeforeStyledTextRendering() {
            suggestions.highlightText = "primary"
            verify(suggestions.highlightedLabel("<primary>").indexOf("&lt;") >= 0)
            verify(suggestions.highlightedLabel("<primary>").indexOf("<b>primary</b>") >= 0)
        }

        function test_literalQueriesDoNotBecomeRegularExpressions() {
            suggestions.highlightText = "["
            verify(suggestions.highlightedLabel("Use [ bracket").indexOf("<b>[</b>") >= 0)
        }
    }
}
