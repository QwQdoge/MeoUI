import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 520
    height: 180

    Components.MeoSplitButton {
        id: split
        text: "Create"
        icon: "add"
        menuModel: [{ "label": "All", "icon": "apps" }]
    }

    TestCase {
        name: "MeoSplitButton"
        when: windowShown

        function init() {
            split.enabled = true
            split.type = "filled"
            split.size = "s"
            split.LayoutMirroring.enabled = false
            split.LayoutMirroring.childrenInherit = true
        }

        function test_variantsUseSeparatedActionSurfaces() {
            const primaryBackground = findChild(split, "meoSplitButtonPrimaryBackground")
            const menuBackground = findChild(split, "meoSplitButtonMenuBackground")
            const primary = findChild(split, "meoSplitButtonPrimaryAction")
            const menu = findChild(split, "meoSplitButtonMenuAction")
            const content = findChild(split, "meoSplitButtonContent")
            verify(primaryBackground !== null)
            verify(menuBackground !== null)
            verify(primary !== null)
            verify(menu !== null)
            verify(content !== null)

            const types = ["filled", "tonal", "outlined", "elevated"]
            for (let index = 0; index < types.length; ++index) {
                split.type = types[index]
                compare(primaryBackground.color, split.containerColor)
                compare(menuBackground.color, split.containerColor)
                compare(menu.x - (primary.x + primary.width), 2 * split.themeGlobalScale)
                compare(primary.implicitHeight, split.containerHeight)
            }
        }

        function test_disabledAndRtlUseSemanticAndLogicalContracts() {
            const primaryBackground = findChild(split, "meoSplitButtonPrimaryBackground")
            const content = findChild(split, "meoSplitButtonContent")
            split.enabled = false
            tryVerify(function() { return Math.abs(primaryBackground.color.a - MeoTheme.disabledContainerOpacity) < 0.001 }, 500)

            split.enabled = true
            split.LayoutMirroring.enabled = true
            compare(content.layoutDirection, Qt.RightToLeft)
        }

        function test_sizeTokensAndMenuSelectionShape() {
            const menu = findChild(split, "meoSplitButtonMenuAction")
            const menuBackground = findChild(split, "meoSplitButtonMenuBackground")
            const sizes = ["xs", "s", "m", "l", "xl"]
            const heights = [32, 40, 56, 96, 136]
            for (let index = 0; index < sizes.length; ++index) {
                split.size = sizes[index]
                compare(split.implicitHeight, heights[index] * split.themeGlobalScale)
            }

            menu.click()
            tryVerify(function() { return menuBackground.topLeftRadius === split.outerCorner }, 500)
            menu.click()
        }
    }
}
