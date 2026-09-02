import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 400
    height: 180

    Components.MeoRadioButton {
        id: radio
        label: "Option A"
    }

    TestCase {
        name: "MeoRadioButton"
        when: windowShown

        function init() {
            radio.enabled = true
            radio.checked = false
            radio.isError = false
            radio.size = "m"
            radio.LayoutMirroring.enabled = false
            radio.LayoutMirroring.childrenInherit = true
        }

        function test_selectIsOneWayAndUsesSemanticDot() {
            const dot = findChild(radio, "meoRadioButtonDot")
            verify(dot !== null)
            radio.select()
            compare(radio.checked, true)
            tryCompare(dot, "color", radio.themePrimary, 500)
            radio.select()
            compare(radio.checked, true)
        }

        function test_sizesKeepOuterGeometryStable() {
            const outer = findChild(radio, "meoRadioButtonOuter")
            compare(radio.minimumTargetSize, 48 * radio.themeGlobalScale)
            compare(radio.stateLayerSize, 40 * radio.themeGlobalScale)
            compare(radio.implicitHeight, radio.minimumTargetSize)
            const sizes = ["xs", "s", "m", "l", "xl"]
            for (let index = 0; index < sizes.length; ++index) {
                radio.size = sizes[index]
                const width = outer.width
                const radius = outer.radius
                compare(outer.scale, 1)
                compare(outer.width, width)
                compare(outer.radius, radius)
            }

            radio.checked = false
            tryCompare(outer.border, "color", radio.themeOnSurfaceVariant, 500)
            compare(outer.border.width, 2 * radio.themeGlobalScale)
        }

        function test_unselectedRingUsesM3StateRoles() {
            const outer = findChild(radio, "meoRadioButtonOuter")
            verify(outer !== null)

            radio.checked = false
            radio.forceActiveFocus()
            tryVerify(function() {
                return outer.border.color === radio.themeOnSurface
            }, 500)

            radio.focus = false
            tryVerify(function() {
                return outer.border.color === radio.themeOnSurfaceVariant
            }, 500)
        }

        function test_disabledErrorAndRtlContracts() {
            const dot = findChild(radio, "meoRadioButtonDot")
            const row = findChild(radio, "meoRadioButtonRow")
            radio.checked = true
            radio.enabled = false
            tryVerify(function() { return Math.abs(dot.color.a - 0.38) < 0.001 }, 500)

            radio.enabled = true
            radio.isError = true
            tryCompare(dot, "color", radio.themeError, 500)
            radio.LayoutMirroring.enabled = true
            compare(row.layoutDirection, Qt.RightToLeft)
        }
    }
}
