import QtQuick
import QtTest
import MeoUI

Item {
    width: 1200
    height: 720
    MeoAppLayout {
        id: layout
        navigationModel: [{ "id": "home", "label": "Home", "icon": "home" },
                          { "id": "privacy", "label": "Privacy", "icon": "security" }]
    }
    TestCase {
        name: "MeoAppLayout"
        when: windowShown
        function test_routeSurvivesReordering() {
            const original = layout.navigationModel
            layout.currentIndex = 1
            compare(layout.currentRoute, "privacy")
            layout.navigationModel = [original[1], original[0]]
            compare(layout.currentRoute, "privacy")
            compare(layout.currentIndex, 0)
            layout.navigationModel = original
        }
        function test_emptyApplicationSearchIsAuthoritative() {
            layout.searchText = "home"
            layout.searchResults = []
            compare(layout.effectiveSearchResults.length, 0)
            layout.searchResults = null
            compare(layout.effectiveSearchResults[0].route, "home")
        }
    }
}
