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
            tryVerify(function() { return shape.color.a < 0.001 }, 500)

            button.type = "filled"
            tryCompare(shape, "color", button.themePrimary, 500)

            button.type = "tonal"
            tryCompare(shape, "color", button.themeSecondary, 500)

            button.type = "outlined"
            tryCompare(shape, "color", button.themeInverseSurface, 500)
        }

        function test_uncheckedFilledUsesSurfaceContainerAndShapeMorphs() {
            const shape = findChild(button, "meoIconButtonShape")
            verify(shape !== null)
            button.type = "filled"
            button.checked = false
            tryCompare(shape, "color", button.themeSurfaceContainer, 500)

            button.type = "standard"
            button.shape = "circle"
            button.size = "m"
            tryCompare(shape, "radius", button.containerHeight / 2, 500)
            button.checked = true
            tryCompare(shape, "radius", 16 * button.themeGlobalScale, 500)
            mousePress(button, button.width / 2, button.height / 2, Qt.LeftButton)
            tryCompare(shape, "radius", 12 * button.themeGlobalScale, 500)
            mouseRelease(button, button.width / 2, button.height / 2, Qt.LeftButton)
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
