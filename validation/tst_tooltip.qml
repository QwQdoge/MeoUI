import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    id: root
    width: 360
    height: 180

    Components.MeoTooltip {
        id: tooltip
        parent: root
        text: "Copy link"
    }

    TestCase {
        name: "MeoTooltip"
        when: windowShown

        function test_plainTooltipTokens() {
            compare(tooltip.themeInverseSurface, MeoTheme.inverseSurface)
            compare(tooltip.themeInverseOnSurface, MeoTheme.contentOnInverseSurface)
            compare(tooltip.leftPadding, 8 * MeoTheme.globalScale)
            compare(tooltip.topPadding, 4 * MeoTheme.globalScale)
            verify(tooltip.implicitWidth >= 40 * MeoTheme.globalScale)
            verify(tooltip.implicitHeight >= 24 * MeoTheme.globalScale)
            verify(findChild(tooltip, "meoTooltipText") !== null)
            verify(findChild(tooltip, "meoTooltipBackground") !== null)
        }

        function test_textIsConstrainedToMaterialMaximumWidth() {
            tooltip.text = "A deliberately long tooltip sentence that should wrap within the Material plain tooltip maximum width rather than running off the screen."
            verify(tooltip.implicitWidth <= 200 * MeoTheme.globalScale)
        }
    }
}
