import QtQuick
import QtTest
import MeoUI
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
            tryCompare(shape, "color", button.themePrimary, 500)

            button.type = "tonal"
            button.selected = true
            tryCompare(shape, "color", button.themeSecondary, 500)

            button.type = "outlined"
            button.selected = true
            tryCompare(shape, "color", button.themeInverseSurface, 500)

            button.type = "standard"
            button.selected = true
            tryVerify(function() { return shape.color.a < 0.001 }, 500)

            button.enabled = false
            compare(button.themeOnSurface.a, 1)
        }

        function test_unselectedFilledToggleUsesSurfaceContainer() {
            const shape = findChild(button, "meoIconButtonShape")
            verify(shape !== null)
            button.type = "filled"
            button.toggle = true
            button.selected = false
            tryCompare(shape, "color", button.themeSurfaceContainer, 500)
        }

        function test_defaultAndOutlinedUseSourceRoles() {
            const shape = findChild(button, "meoIconButtonShape")
            verify(shape !== null)

            button.type = "filled"
            tryCompare(shape, "color", button.themePrimary, 500)

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
            tryCompare(shape, "radius", button.containerHeight / 2, 500)

            button.selected = true
            tryCompare(shape, "radius", 16 * button.themeGlobalScale, 500)

            mousePress(button, button.width / 2, button.height / 2, Qt.LeftButton)
            tryCompare(shape, "radius", 12 * button.themeGlobalScale, 500)
            mouseRelease(button, button.width / 2, button.height / 2, Qt.LeftButton)
        }
    }
}
