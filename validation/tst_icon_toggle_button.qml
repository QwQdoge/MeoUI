import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 320
    height: 160

    Components.MeoIconToggleButton {
        id: button
        icon.name: "favorite_border"
        checkedIcon: "favorite"
    }

    TestCase {
        name: "MeoIconToggleButton"
        when: windowShown

        function init() {
            button.enabled = true
            button.checked = false
            button.type = "standard"
            button.size = "s"
            button.shape = "circle"
        }

        function test_toggleTypesKeepPressedGeometryStable() {
            const types = ["standard", "filled", "tonal", "outlined"]
            const background = findChild(button, "meoIconButtonBackground")
            const content = findChild(button, "meoIconButtonContent")
            verify(background !== null)
            verify(content !== null)
            for (let index = 0; index < types.length; ++index) {
                button.type = types[index]
                button.checked = index % 2 === 0
                button.down = true
                compare(background.scale, 1)
                compare(content.scale, 1)
                button.down = false
            }
        }

        function test_disabledToggleKeepsSemanticContrast() {
            button.checked = true
            button.enabled = false
            compare(button.themeOnSurface.a, 1)
            verify(button.implicitWidth > 0)
        }

        function test_checkedVariantUsesThePublicButtonType() {
            const shape = findChild(button, "meoIconButtonShape")
            verify(shape !== null)

            button.checked = true
            button.type = "standard"
            compare(shape.color.a, 0)

            button.type = "filled"
            compare(shape.color, button.themePrimary)

            button.type = "tonal"
            compare(shape.color, button.themeSecondary)

            button.type = "outlined"
            compare(shape.color, button.themeInverseSurface)
        }

        function test_uncheckedFilledUsesSurfaceContainerAndShapeMorphs() {
            const shape = findChild(button, "meoIconButtonShape")
            verify(shape !== null)
            button.type = "filled"
            button.checked = false
            compare(shape.color, button.themeSurfaceContainer)

            button.type = "standard"
            button.shape = "circle"
            button.size = "m"
            compare(shape.radius, button.implicitHeight / 2)
            button.checked = true
            tryCompare(shape, "radius", 16 * button.themeGlobalScale, 500)
            button.down = true
            tryCompare(shape, "radius", 12 * button.themeGlobalScale, 500)
            button.down = false
        }

        function test_checkedIconAndAccessibilityDelegateToIconButton() {
            button.checked = true
            compare(button.Accessible.role, Accessible.CheckBox)
            compare(button.Accessible.checked, true)
            compare(button.selectedIcon, button.checkedIcon)
            compare(button.implicitWidth, 48 * button.themeGlobalScale)
        }
    }
}
