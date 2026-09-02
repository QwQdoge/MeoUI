import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 360
    height: 120

    Components.MeoButton {
        id: button
        text: "Save"
        icon.name: "save"
    }

    TestCase {
        name: "MeoButton"
        when: windowShown

        function init() {
            button.enabled = true
            button.loading = false
            button.selected = false
            button.toggle = false
            button.checkable = false
            button.selectedIcon = ""
            button.LayoutMirroring.enabled = false
        }

        function test_materialTypesUseSemanticColorsAndPressedShape() {
            const types = ["filled", "tonal", "outlined", "elevated", "text"]
            for (let index = 0; index < types.length; ++index) {
                button.type = types[index]
                verify(button.implicitHeight > 0)
                verify(button.textColor.a > 0)
                compare(button.stateColor.a, 1)
            }

            button.type = "filled"
            mousePress(button, button.width / 2, button.height / 2, Qt.LeftButton)
            compare(button.activeRadius, MeoTheme.shapeSmall)
            mouseRelease(button, button.width / 2, button.height / 2, Qt.LeftButton)
            compare(button.restingRadius, button.buttonHeight / 2)
        }

        function test_materialPaddingIsSymmetric() {
            compare(button.leftPadding, button.horizontalPad)
            compare(button.rightPadding, button.horizontalPad)

            button.LayoutMirroring.enabled = true
            wait(0)
            compare(button.leftPadding, button.horizontalPad)
            compare(button.rightPadding, button.horizontalPad)
        }

        function test_toggleUsesMaterialColorAndShapeRoles() {
            button.type = "filled"
            button.toggle = true
            compare(button.baseContainerColor, MeoTheme.surfaceContainer)
            compare(button.textColor, MeoTheme.contentOnSurfaceVariant)

            button.type = "outlined"
            button.toggle = false
            compare(button.textColor, MeoTheme.contentOnSurfaceVariant)

            button.type = "filled"
            button.toggle = true
            button.selected = true
            compare(button.baseContainerColor, MeoTheme.primary)
            compare(button.textColor, MeoTheme.contentOnPrimary)
            compare(button.restingRadius, MeoTheme.shapeMedium)

            button.type = "outlined"
            compare(button.baseContainerColor, MeoTheme.inverseSurface)
            compare(button.textColor, MeoTheme.contentOnInverseSurface)
        }

        function test_disabledAndLoadingRemainExplicitStates() {
            button.type = "filled"
            button.enabled = false
            compare(button.textColor.a, 0.38)
            compare(button.stateColor.a, 1)

            button.enabled = true
            button.loading = true
            verify(button.loading)
            verify(button.activeRadius > 0)
        }
    }
}
