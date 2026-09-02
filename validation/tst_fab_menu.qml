import QtQuick
import QtTest
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

        function test_triggerTransitionsToTheM3CloseAffordance() {
            const trigger = findChild(menu, "meoFabMenuTrigger")
            verify(trigger !== null)
            const background = findChild(trigger, "meoFabBackground")
            verify(background !== null)
            const closedRadius = background.radius
            const closedColor = background.color

            trigger.click()
            compare(menu.opened, true)
            tryCompare(background, "radius", menu.finalTriggerSize / 2, 500)
            compare(trigger.implicitWidth, menu.finalTriggerSize)
            compare(background.color, menu.blendedColor(menu.color, menu.styleFinalColor, 1))
            verify(background.radius > closedRadius)
            verify(background.color !== closedColor)

            trigger.click()
            compare(menu.opened, false)
        }

        function test_actionSurfaceIsTokenDrivenAndRtlAware() {
            menu.opened = true
            tryVerify(function() {
                return findChild(menu.Window.window.contentItem, "meoFabMenuAction0") !== null
            }, 500)
            const firstAction = findChild(menu.Window.window.contentItem, "meoFabMenuAction0")
            verify(firstAction !== null)
            const firstBackground = findChild(menu.Window.window.contentItem, "meoFabMenuActionBackground_0")
            verify(firstBackground !== null)
            compare(firstAction.implicitHeight, 56 * menu.themeGlobalScale)
            compare(firstBackground.color, menu.itemColor)

            const secondAction = findChild(menu.Window.window.contentItem, "meoFabMenuAction1")
            verify(secondAction !== null)
            compare(secondAction.y - firstAction.y,
                    firstAction.implicitHeight + 4 * menu.themeGlobalScale)

            menu.LayoutMirroring.enabled = true
            compare(menu.mirrored, true)
        }

        function test_colorStylesUseMatchingContainerAndClosePairs() {
            menu.colorStyle = "secondary"
            compare(menu.color, MeoTheme.secondaryContainer)
            compare(menu.itemColor, MeoTheme.secondaryContainer)
            compare(menu.styleFinalColor, MeoTheme.secondary)

            menu.colorStyle = "tertiary"
            compare(menu.color, MeoTheme.tertiaryContainer)
            compare(menu.itemOnColor, MeoTheme.contentOnTertiaryContainer)
            compare(menu.styleFinalOnColor, MeoTheme.contentOnTertiary)
        }
    }
}
