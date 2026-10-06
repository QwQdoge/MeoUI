import QtQuick
import QtTest
import MeoUI
import "../patterns" as Patterns

Item {
    width: 720
    height: 720

    Patterns.MeoSidebar {
        id: sidebar
        height: 320
        selectedRoute: "category:devices"
        groups: [
            {
                "title": "Connections",
                "rows": [
                    { "title": "Network", "route": "category:network", "leadingIcon": "wifi" },
                    { "title": "Devices", "route": "category:devices", "leadingIcon": "devices" }
                ]
            }
        ]
        searchResults: [
            { "title": "Wi-Fi", "route": "wifi", "leadingIcon": "wifi" }
        ]
    }

    SignalSpy {
        id: activationSpy
        target: sidebar
        signalName: "routeActivated"
    }

    TestCase {
        name: "MeoSidebar"
        when: windowShown

        function init() {
            sidebar.groups = [{
                "title": "Connections",
                "rows": [
                    { "title": "Network", "route": "category:network", "leadingIcon": "wifi" },
                    { "title": "Devices", "route": "category:devices", "leadingIcon": "devices" }
                ]
            }]
            sidebar.searchResults = [{ "title": "Wi-Fi", "route": "wifi", "leadingIcon": "wifi" }]
            sidebar.searchText = ""
            sidebar.selectedRoute = "category:devices"
            activationSpy.clear()
        }

        function test_usesSharedSettingsGeometry() {
            compare(sidebar.implicitWidth, MeoTheme.settingsSidebarWidth)
            compare(sidebar.color, MeoTheme.surfaceContainerLow)
            compare(sidebar.selectedIndexFor(sidebar.groups[0].rows), 1)
        }

        function test_selectedRouteIsRevealedInAClippedIndex() {
            sidebar.groups = [{
                "title": "System",
                "rows": [
                    { "title": "One", "route": "one" },
                    { "title": "Two", "route": "two" },
                    { "title": "Three", "route": "three" },
                    { "title": "Four", "route": "four" },
                    { "title": "Five", "route": "five" }
                ]
            }]
            sidebar.selectedRoute = "five"
            wait(0)
            const scroll = findChild(sidebar, "meoSidebarScroll")
            verify(scroll.contentItem.contentY > 0)
        }

        function test_localSearchFiltersRealRoutes() {
            sidebar.searchResults = null
            sidebar.searchText = "devices"
            compare(sidebar.effectiveSearchResults.length, 1)
            compare(sidebar.effectiveSearchResults[0].route, "category:devices")
            sidebar.searchText = "missing destination"
            compare(sidebar.effectiveSearchResults.length, 0)
        }

        function test_searchSwitchesTheVisibleIndex() {
            verify(!sidebar.searching)
            sidebar.searchText = "wifi"
            verify(sidebar.searching)
            compare(sidebar.searchResults.length, 1)
        }

        function test_searchHasAccessibleNameAndKeyboardFocusEntry() {
            compare(sidebar.Accessible.name, sidebar.title)
            sidebar.focusSearch()
            wait(0)
            const search = findChild(sidebar, "meoSidebarSearch")
            verify(search !== null)
            verify(search.focusVisible)
        }

        function test_keyboardActivatesFocusedDestination() {
            const group = findChild(sidebar, "meoSidebarGroup_0")
            verify(group !== null)
            const row = group.itemAt(0).item
            row.forceActiveFocus(Qt.TabFocusReason)
            keyClick(Qt.Key_Return)
            compare(activationSpy.count, 1)
            compare(activationSpy.signalArguments[0][0], "category:network")
        }

        function test_activationForwardsOnlyUsableRoutes() {
            sidebar.activateRow(sidebar.groups[0].rows[0])
            compare(activationSpy.count, 1)
            compare(activationSpy.signalArguments[0][0], "category:network")

            sidebar.activateRow({ "title": "Disabled", "route": "blocked", "enabled": false })
            sidebar.activateRow({ "title": "No route" })
            compare(activationSpy.count, 1)
        }
    }
}
