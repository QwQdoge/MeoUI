import QtQuick
import QtTest
import MeoUI
import "../patterns" as Patterns

Item {
    width: 1200
    height: 720

    Patterns.MeoNavigationSuite {
        id: suite
        height: parent.height
        availableWidth: 1024
        model: [
            { "id": "home", "label": "Home", "icon": "home" },
            { "type": "header", "label": "Library" },
            { "id": "browse", "label": "Browse", "icon": "explore" },
            { "id": "disabled", "label": "Disabled", "icon": "block", "enabled": false }
        ]
        currentIndex: 0
    }

    TestCase {
        name: "MeoNavigationSuite"
        when: windowShown

        function init() {
            suite.availableWidth = 1024
            suite.currentIndex = 0
            suite.currentId = "home"
        }

        function test_expandedRailAndStableSelectionContract() {
            verify(suite.usesExpandedRail)
            compare(suite.themeGlobalScale, MeoTheme.globalScale)
            compare(suite.currentId, "home")
            suite.select(2)
            compare(suite.currentIndex, 2)
            compare(suite.currentId, "browse")
            suite.currentId = "home"
            compare(suite.currentIndex, 0)
        }

        function test_headersAndDisabledDestinationsDoNotSelect() {
            suite.select(1)
            compare(suite.currentIndex, 0)
            suite.select(3)
            compare(suite.currentIndex, 0)
        }

        function test_optInCompatibilityDrawerRemainsScoped() {
            suite.preferPersistentDrawer = true
            verify(suite.usesPersistentDrawer)
            verify(!suite.usesExpandedRail)
            suite.preferPersistentDrawer = false
        }
    }
}
