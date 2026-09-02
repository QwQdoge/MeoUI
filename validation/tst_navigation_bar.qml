import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    width: 560
    height: 160

    Widgets.MeoNavigationBar {
        id: navigationBar
        width: parent.width
        model: [
            { "id": "home", "label": "Home", "icon": "home" },
            { "id": "updates", "label": "Updates", "icon": "notifications", "badgeText": "24" },
            { "id": "locked", "label": "Locked", "icon": "lock", "badgeDot": true, "enabled": false },
            { "id": "profile", "label": "Profile", "icon": "person" }
        ]
        currentId: "updates"
    }

    TestCase {
        name: "MeoNavigationBar"
        when: windowShown

        function init() {
            navigationBar.compact = false
            navigationBar.labelType = "always"
            navigationBar.currentId = "updates"
            wait(0)
        }

        function test_m3HeightAndPillGeometry() {
            compare(Math.round(navigationBar.height), Math.round(80 * navigationBar.themeGlobalScale))
            const indicator = findChild(navigationBar, "meoNavigationBarIndicator_1")
            verify(indicator !== null)
            compare(Math.round(indicator.width), Math.round(56 * navigationBar.themeGlobalScale))
            compare(Math.round(indicator.height), Math.round(32 * navigationBar.themeGlobalScale))
            compare(Math.round(indicator.radius), Math.round(16 * navigationBar.themeGlobalScale))

            navigationBar.currentIndex = 0
            const unselectedIndicator = findChild(navigationBar, "meoNavigationBarIndicator_1")
            verify(unselectedIndicator !== null)
            compare(Math.round(unselectedIndicator.width), 0)

            navigationBar.compact = true
            compare(Math.round(navigationBar.height), Math.round(64 * navigationBar.themeGlobalScale))
        }

        function test_selectionAndCurrentIdStaySynchronized() {
            navigationBar.currentIndex = 3
            compare(navigationBar.currentId, "profile")

            navigationBar.currentId = "home"
            compare(navigationBar.currentIndex, 0)
        }

        function test_androidxColorTokenMappings() {
            compare(navigationBar.color, MeoTheme.surfaceContainer)
            compare(navigationBar.themeSecondaryContainer, MeoTheme.secondaryContainer)
            compare(navigationBar.themeOnSecondaryContainer, MeoTheme.contentOnSecondaryContainer)
            compare(navigationBar.themeSecondary, MeoTheme.secondary)
        }

        function test_wholeDestinationActivatesButDisabledDestinationDoesNot() {
            const home = findChild(navigationBar, "meoNavigationBarDestination_0")
            const locked = findChild(navigationBar, "meoNavigationBarDestination_2")
            verify(home !== null)
            verify(locked !== null)

            mouseClick(home, home.width / 2, home.height / 2)
            compare(navigationBar.currentId, "home")

            mouseClick(locked, locked.width / 2, locked.height / 2)
            compare(navigationBar.currentId, "home")
        }

        function test_labelAndBadgeConfigurationsRemainAvailable() {
            navigationBar.labelType = "selected"
            compare(navigationBar.labelType, "selected")
            navigationBar.labelType = "none"
            compare(navigationBar.labelType, "none")
            verify(findChild(navigationBar, "meoNavigationBarIndicator_1") !== null)
        }
    }
}
