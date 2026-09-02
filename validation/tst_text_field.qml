import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 560
    height: 160

    Components.MeoTextField {
        id: field
        width: 360
        label: "Search"
        placeholder: "Search components"
        leadingIcon: "search"
        suffixText: ".qml"
        showClearButton: true
    }

    TestCase {
        name: "MeoTextField"
        when: windowShown

        function init() {
            field.enabled = true
            field.type = "filled"
            field.text = ""
            field.isError = false
            field.LayoutMirroring.enabled = false
        }

        function test_floatingLabelOnlyRaisesForFocusOrContent() {
            verify(!field.labelRaised)
            compare(field.placeholderText, field.label)

            field.text = "MeoTheme"
            verify(field.labelRaised)
            compare(field.placeholderText, field.placeholder)
        }

        function test_realFieldStatesKeepContainerGeometry() {
            const types = ["filled", "outlined"]
            const initialWidth = field.implicitWidth
            const initialHeight = field.implicitHeight
            for (let index = 0; index < types.length; ++index) {
                field.type = types[index]
                field.isError = false
                field.enabled = true
                compare(field.implicitWidth, initialWidth)
                compare(field.implicitHeight, initialHeight)
            }

            field.isError = true
            compare(field.color, field.themeOnSurface)
            field.enabled = false
            compare(field.color.a, 0.38)
        }

        function test_logicalLeadingAndTrailingPaddingMirrors() {
            field.text = "Meo"
            verify(field.leadingContentWidth > 0)
            verify(field.trailingContentWidth > 0)
            compare(field.leftPadding, field.sidePadding + field.leadingContentWidth)
            compare(field.rightPadding, field.sidePadding + field.trailingContentWidth)

            field.LayoutMirroring.enabled = true
            wait(0)
            verify(field.mirrored)
            compare(field.leftPadding, field.sidePadding + field.trailingContentWidth)
            compare(field.rightPadding, field.sidePadding + field.leadingContentWidth)
        }

        function test_m3IconPaddingAndFilledIndicatorAreExposed() {
            const indicator = findChild(field, "meoTextFieldActiveIndicator")
            verify(indicator !== null)
            field.type = "filled"
            field.leadingIcon = "search"
            field.trailingIcon = ""
            field.text = ""
            compare(field.sidePadding, 12 * field.themeGlobalScale)
            compare(field.leadingContentWidth, field.iconSizePx + 16 * field.themeGlobalScale)
            compare(indicator.height, 1 * field.themeGlobalScale)
            field.isError = true
            compare(indicator.color, field.themeError)
            field.leadingIcon = ""
            field.isError = false
            compare(field.sidePadding, 16 * field.themeGlobalScale)
        }
    }
}
