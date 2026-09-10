import QtQuick
import QtTest
import MeoUI 1.0
import "../components" as Components

Item {
    width: 520
    height: 360

    Components.MeoFABMenu {
        id: menu
        enableScrim: false
        model: [
            { "label": "Create", "icon": "add" },
            { "label": "Note", "icon": "note_add" }
        ]
    }

    TestCase {
        name: "MeoFABMenu"
        when: windowShown

        function init() {
            menu.opened = false
            menu.fabType = "regular"
            menu.colorStyle = "primary"
            menu.LayoutMirroring.enabled = false
            menu.LayoutMirroring.childrenInherit = true
        }

        function test_triggerOpensTheSharedMenuSurface() {
            const trigger = findChild(menu, "meoFabMenuTrigger")
            verify(trigger !== null)
            const background = findChild(trigger, "meoFabBackground")
            verify(background !== null)
            const closedColor = background.color

            trigger.click()
            compare(menu.opened, true)
            const popup = findChild(menu, "meoFabMenuPopup")
            verify(popup !== null)
            tryCompare(popup, "opened", true, 500)
            tryCompare(background, "color", menu.styleFinalColor, 500)

            trigger.click()
            tryCompare(menu, "opened", false, 500)
        }

        function test_actionMenuIsCappedAndRtlAware() {
            menu.opened = true
            const popup = findChild(menu, "meoFabMenuPopup")
            tryCompare(popup, "opened", true, 500)
            compare(popup.preferredMenuWidth, 224 * menu.themeGlobalScale)
            compare(popup.model.length, 2)

            menu.LayoutMirroring.enabled = true
            compare(menu.mirrored, true)
        }

        function test_colorStylesUseMatchingContainerAndClosePairs() {
            menu.colorStyle = "secondary"
            compare(menu.color, MeoTheme.secondaryContainer)
            compare(menu.itemColor, MeoTheme.surfaceContainer)
            compare(menu.styleFinalColor, MeoTheme.secondary)

            menu.colorStyle = "tertiary"
            compare(menu.color, MeoTheme.tertiaryContainer)
            compare(menu.itemOnColor, MeoTheme.contentOnSurface)
            compare(menu.styleFinalOnColor, MeoTheme.contentOnTertiary)
        }
    }
}
