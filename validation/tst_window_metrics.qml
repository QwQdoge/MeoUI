import QtQuick
import QtTest
import MeoUI

Item {
    MeoWindowMetrics {
        id: metrics
        availableWidth: 600
        availableHeight: 900
    }

    TestCase {
        name: "MeoWindowMetrics"
        when: windowShown

        function test_materialAdaptiveWidthClasses() {
            metrics.availableWidth = 599
            compare(metrics.widthSizeClass, "compact")
            compare(metrics.navigationMode, "bottomBar")
            metrics.availableWidth = 600
            compare(metrics.widthSizeClass, "medium")
            compare(metrics.navigationMode, "rail")
            metrics.availableWidth = 840
            compare(metrics.widthSizeClass, "expanded")
            compare(metrics.navigationMode, "expandedRail")
            metrics.availableWidth = 1200
            compare(metrics.widthSizeClass, "large")
            compare(metrics.navigationMode, "drawer")
            metrics.availableWidth = 1600
            compare(metrics.widthSizeClass, "extraLarge")
            verify(metrics.supportsTwoPane)
        }

        function test_scaledInputsRemainEffectivePixelBased() {
            metrics.scale = 2
            metrics.availableWidth = 1200
            compare(metrics.widthSizeClass, "medium")
            compare(metrics.effectiveWidth, 600)
            metrics.scale = MeoTheme.globalScale
        }
    }
}
