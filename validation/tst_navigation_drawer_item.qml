import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 400
    height: 320

    Components.MeoNavigationDrawerItem {
        id: item
        width: 336 * MeoTheme.globalScale
        label: "Inbox"
        icon: "inbox"
        badgeText: "8"
    }

    TestCase {
        name: "MeoNavigationDrawerItem"
        when: windowShown

        function init() {
            item.mode = "drawer"
            item.visualStyle = "standard"
            item.selected = false
            item.supportingText = ""
        }

        function test_dynamicThemeAndSelectionRoles() {
            compare(item.themeGlobalScale, MeoTheme.globalScale)
            compare(item.themeSecondaryContainer, MeoTheme.secondaryContainer)
            compare(item.themeOnSecondaryContainer, MeoTheme.contentOnSecondaryContainer)
            compare(item.animationDuration, MeoTheme.motionDurationSelection)
            compare(item.implicitHeight, MeoTheme.settingsSidebarItemHeight)
            compare(item.Accessible.role, Accessible.PageTab)

            item.selected = true
            compare(item.selectedContainerColor, MeoTheme.secondaryContainer)
            compare(item.selectedContentColor, MeoTheme.contentOnSecondaryContainer)
        }

        function test_groupAndSettingsCompatibilityGeometry() {
            item.mode = "group"
            item.supportingText = "Grouped row"
            compare(item.implicitHeight, MeoTheme.settingsRowHeight)

            item.visualStyle = "settings"
            item.selected = true
            compare(item.selectedContainerColor, MeoTheme.primaryContainer)
            compare(item.selectedContentColor, MeoTheme.contentOnPrimaryContainer)
        }
    }
}
