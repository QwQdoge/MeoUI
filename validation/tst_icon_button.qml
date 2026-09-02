import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 320
    height: 160

    Components.MeoIconButton {
        id: button
        icon.name: "favorite"
    }

    TestCase {
        name: "MeoIconButton"
        when: windowShown

        function init() {
            button.enabled = true
            button.toggle = false
            button.selected = false
            button.checkable = false
            button.checked = false
            button.type = "filled"
            button.size = "s"
            button.shape = "circle"
        }

        function test_materialTypesPreservePressedBounds() {
            const types = ["standard", "filled", "tonal", "outlined"]
            const background = findChild(button, "meoIconButtonBackground")
            const content = findChild(button, "meoIconButtonContent")
            verify(background !== null)
            verify(content !== null)
            for (let index = 0; index < types.length; ++index) {
                button.type = types[index]
                button.down = true
                compare(background.scale, 1)
                compare(content.scale, 1)
                button.down = false
                compare(button.implicitWidth, button.implicitHeight)
            }
        }

        function test_selectedAndDisabledColorsUseSemanticRoles() {
            const shape = findChild(button, "meoIconButtonShape")
            verify(shape !== null)

            button.type = "filled"
            button.selected = true
            compare(shape.color, button.themePrimary)

            button.type = "tonal"
            button.selected = true
            compare(shape.color, button.themeSecondary)

            button.type = "outlined"
            button.selected = true
            compare(shape.color, button.themeInverseSurface)

            button.type = "standard"
            button.selected = true
            compare(shape.color.a, 0)

            button.enabled = false
            compare(button.themeOnSurface.a, 1)
        }

        function test_unselectedFilledToggleUsesSurfaceContainer() {
            const shape = findChild(button, "meoIconButtonShape")
            verify(shape !== null)
            button.type = "filled"
            button.toggle = true
            button.selected = false
            compare(shape.color, button.themeSurfaceContainer)
        }

        function test_defaultAndOutlinedUseSourceRoles() {
            const shape = findChild(button, "meoIconButtonShape")
            verify(shape !== null)

            button.type = "filled"
            compare(shape.color, button.themePrimary)

            button.type = "outlined"
            compare(shape.strokeColor, MeoTheme.outlineVariant)
        }

        function test_semanticsAndTouchTargetFollowSourceContract() {
            button.size = "xs"
            compare(button.implicitWidth, 48 * button.themeGlobalScale)
            compare(button.iconSize, 20)
            compare(button.Accessible.role, Accessible.Button)

            button.toggle = true
            button.selected = true
            compare(button.Accessible.role, Accessible.CheckBox)
            compare(button.Accessible.checked, true)
        }

        function test_toggleSelectionAndPressedShapeUseM3Corners() {
            const shape = findChild(button, "meoIconButtonShape")
            verify(shape !== null)

            button.size = "m"
            button.shape = "circle"
            button.selected = false
            compare(shape.radius, button.implicitHeight / 2)

            button.selected = true
            tryCompare(shape, "radius", 16 * button.themeGlobalScale, 500)

            button.down = true
            tryCompare(shape, "radius", 12 * button.themeGlobalScale, 500)
            button.down = false
        }
    }
}
