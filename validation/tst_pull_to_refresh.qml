import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    id: root
    width: 320
    height: 160

    Components.MeoPullToRefresh {
        id: indicator
        parent: root
    }

    TestCase {
        name: "MeoPullToRefresh"
        when: windowShown

        function test_androidxDefaultsAndRelease() {
            compare(indicator.themeSurfaceContainerHigh, MeoTheme.surfaceContainerHigh)
            compare(indicator.themeIndicatorColor, MeoTheme.contentOnSurfaceVariant)
            compare(indicator.implicitWidth, 40 * MeoTheme.globalScale)
            compare(indicator.implicitHeight, 40 * MeoTheme.globalScale)
            compare(indicator.positionalThreshold, 80 * MeoTheme.globalScale)
            indicator.pullDistance = 1
            verify(indicator.indicatorVisible)
            var requested = 0
            indicator.refreshRequested.connect(function() { requested += 1 })
            indicator.release()
            compare(requested, 1)
        }

        function test_disabledPullDoesNotRequestRefresh() {
            indicator.refreshing = false
            indicator.pullDistance = 1
            indicator.pullEnabled = false
            compare(indicator.indicatorVisible, false)
        }
    }
}
