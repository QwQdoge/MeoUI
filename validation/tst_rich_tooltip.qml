import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    id: root
    width: 480
    height: 320

    Components.MeoRichTooltip {
        id: tooltip
        parent: root
        title: "Rich tooltip"
        text: "Useful supporting detail."
        actions: [{ "text": "Learn more" }]
    }

    TestCase {
        name: "MeoRichTooltip"
        when: windowShown

        function init() {
            tooltip.actions = [{ "text": "Learn more" }]
        }

        function test_richTooltipTokensAndAction() {
            compare(tooltip.themeSurfaceContainer, MeoTheme.surfaceContainer)
            compare(tooltip.themeOnSurfaceVariant, MeoTheme.contentOnSurfaceVariant)
            compare(tooltip.background.radius, MeoTheme.shapeMedium)
            compare(tooltip.focus, true)
            compare(tooltip.maximumWidth, 320 * MeoTheme.globalScale)
            compare(tooltip.width, tooltip.maximumWidth)
            tooltip.open()
            tryVerify(function() { return tooltip.visible }, 500)
            verify(findChild(tooltip, "meoRichTooltipTitle") !== null)
            verify(findChild(tooltip, "meoRichTooltipText") !== null)
            const actionsRepeater = findChild(tooltip, "meoRichTooltipActions")
            verify(actionsRepeater !== null)
            tryCompare(actionsRepeater, "count", 1, 500)
            tooltip.close()
        }

        function test_nonInteractiveTooltipDoesNotTakeFocus() {
            tooltip.actions = []
            compare(tooltip.focus, false)
        }
    }
}
