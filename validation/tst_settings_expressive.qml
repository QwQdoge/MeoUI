import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 1024
    height: 900

    MeoSearchBar {
        id: search
        width: 760
        trailingIcon: ""
        visualStyle: "settings"
    }

    MeoSettingsAccountCard {
        id: account
        y: 80
        width: 760
        title: "Shekong"
        subtitle: "Local session"
        initials: "SH"
    }

    MeoSettingsRow {
        id: row
        y: 188
        width: 760
        title: "Display & touch"
        subtitle: "Dark theme, font size, touch"
        leadingIcon: "monitor"
        leadingTone: "tertiary"
        trailingKind: "navigation"
    }

    MeoSettingsGroup {
        id: group
        y: 276
        width: 760
        model: [
            { "id": "network", "title": "Network", "icon": "wifi", "tone": "primary" },
            { "id": "apps", "title": "Apps", "icon": "apps", "tone": "secondary" }
        ]
    }

    MeoNavigationSuite {
        id: navigation
        visible: false
        availableWidth: 1024
        height: 700
        preferPersistentDrawer: true
        navigationVisualStyle: "settings"
        model: [{ "label": "Home", "icon": "home" }]
    }

    TestCase {
        name: "MeoSettingsExpressive"
        when: windowShown

        property var savedScheme: ({})
        property bool savedDynamic: false
        property bool savedDark: false
        property string savedSource: ""

        function initTestCase() {
            savedScheme = JSON.parse(JSON.stringify(MeoTheme.dynamicColorScheme || ({})))
            savedDynamic = MeoTheme.dynamicColorsAvailable
            savedDark = MeoTheme.isDarkMode
            savedSource = MeoTheme.dynamicColorSourceId
        }

        function cleanupTestCase() {
            MeoTheme.isDarkMode = savedDark
            if (savedDynamic)
                MeoTheme.applyDynamicColorScheme(savedScheme, savedSource)
            else
                MeoTheme.clearDynamicColorScheme()
        }

        function test_geometryContract() {
            compare(search.implicitHeight, 64 * MeoTheme.globalScale)
            compare(search.radius, 32 * MeoTheme.globalScale * MeoTheme.cornerScale)
            compare(account.implicitHeight, 92 * MeoTheme.globalScale)
            compare(row.implicitHeight, 72 * MeoTheme.globalScale)
            compare(row.dividerInset, 0)
            compare(group.radius, MeoTheme.shapeExtraLarge)
            compare(navigation.implicitWidth, 288 * MeoTheme.globalScale)
        }

        function test_semanticDynamicColorRole() {
            const scheme = JSON.parse(JSON.stringify(MeoTheme.fallbackLightColorScheme))
            scheme.tertiaryContainer = "#F1D7FF"
            scheme.onTertiaryContainer = "#4D1763"
            verify(MeoTheme.applyDynamicColorScheme(scheme, "settings-test"))
            wait(0)
            compare(String(row.iconContainerColor).toLowerCase(), "#f1d7ff")
            compare(String(row.iconColor).toLowerCase(), "#4d1763")
        }

        function test_pointerAndKeyboardStates() {
            mouseMove(row, 20, 20)
            tryCompare(row, "hovered", true)
            mousePress(row, 20, 20, Qt.LeftButton)
            tryCompare(row, "pressed", true)
            mouseRelease(row, 20, 20, Qt.LeftButton)

            row.forceActiveFocus(Qt.TabFocusReason)
            tryCompare(row, "focusVisible", true)

            search.forceSearchFocus()
            tryCompare(search, "focusVisible", true)

            account.forceActiveFocus(Qt.TabFocusReason)
            tryCompare(account, "focusVisible", true)
        }
    }
}
