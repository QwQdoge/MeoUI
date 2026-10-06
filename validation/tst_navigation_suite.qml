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
            suite.searchText = ""
            suite.searchResults = null
            suite.availableWidth = 1200
            suite.currentIndex = 0
            suite.currentId = "home"
        }

        function test_sidebarAndStableSelectionContract() {
            verify(suite.usesExpandedSidebar)
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

        function test_routeSurvivesReordering() {
            const original = suite.model
            suite.currentId = "browse"
            suite.model = [original[2], original[0], original[1], original[3]]
            compare(suite.currentId, "browse")
            compare(suite.currentIndex, 0)
            suite.model = original
        }

        function test_explicitEmptyResultsRemainEmpty() {
            suite.searchText = "browse"
            suite.searchResults = []
            compare(suite.effectiveSearchResults.length, 0)
        }

        function test_searchFindsDestinationsByLabel() {
            suite.searchText = "browse"
            compare(suite.effectiveSearchResults.length, 1)
            compare(suite.effectiveSearchResults[0].route, "browse")
        }
    }
}
