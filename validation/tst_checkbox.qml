import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 400
    height: 180

    Components.MeoCheckbox {
        id: checkbox
        label: "Receive updates"
    }

    TestCase {
        name: "MeoCheckbox"
        when: windowShown

        function init() {
            checkbox.enabled = true
            checkbox.checked = false
            checkbox.indeterminate = false
            checkbox.isError = false
            checkbox.size = "m"
            checkbox.LayoutMirroring.enabled = false
            checkbox.LayoutMirroring.childrenInherit = true
        }

        function test_checkedAndIndeterminateTransitionsAreSemantic() {
            const indicator = findChild(checkbox, "meoCheckboxIndicator")
            verify(indicator !== null)
            checkbox.indeterminate = true
            compare(checkbox.Accessible.checkStateMixed, true)
            checkbox.toggleSelection()
            compare(checkbox.indeterminate, false)
            compare(checkbox.checked, true)
            compare(checkbox.Accessible.checkStateMixed, false)
            tryCompare(indicator, "color", checkbox.themePrimary, 500)

            checkbox.toggleSelection()
            compare(checkbox.checked, false)
        }

        function test_sizesAndPressKeepIndicatorGeometryStable() {
            const indicator = findChild(checkbox, "meoCheckboxIndicator")
            compare(checkbox.minimumTargetSize, 48 * checkbox.themeGlobalScale)
            compare(checkbox.stateLayerSize, 40 * checkbox.themeGlobalScale)
            compare(checkbox.implicitHeight, checkbox.minimumTargetSize)
            const sizes = ["xs", "s", "m", "l", "xl"]
            for (let index = 0; index < sizes.length; ++index) {
                checkbox.size = sizes[index]
                const width = indicator.width
                const radius = indicator.radius
                compare(indicator.scale, 1)
                compare(indicator.width, width)
                compare(indicator.radius, radius)
            }
        }

        function test_unselectedOutlineUsesStateRoles() {
            const indicator = findChild(checkbox, "meoCheckboxIndicator")
            verify(indicator !== null)
            // The resting role is OnSurfaceVariant, rather than the generic
            // Outline role. AndroidX maps hover/focus/press to OnSurface.
            tryVerify(function() { return indicator.border.color === checkbox.themeOnSurfaceVariant }, 500)
            mousePress(checkbox, indicator.x + indicator.width / 2,
                       indicator.y + indicator.height / 2)
            tryVerify(function() { return indicator.border.color === checkbox.themeOnSurface }, 500)
            mouseRelease(checkbox, indicator.x + indicator.width / 2,
                         indicator.y + indicator.height / 2)
        }

        function test_disabledKeyboardAndRtlContracts() {
            const indicator = findChild(checkbox, "meoCheckboxIndicator")
            const row = findChild(checkbox, "meoCheckboxRow")
            checkbox.enabled = false
            checkbox.toggleSelection()
            compare(checkbox.checked, false)
            tryVerify(function() { return Math.abs(indicator.border.color.a - 0.38) < 0.001 }, 500)

            checkbox.checked = true
            tryVerify(function() { return Math.abs(indicator.color.a - 0.38) < 0.001 }, 500)
            compare(checkbox.checkmarkColor, checkbox.themeSurface)

            checkbox.enabled = true
            checkbox.isError = true
            compare(checkbox.checkmarkColor, checkbox.themeOnError)
            compare(indicator.border.width, 0)
            checkbox.LayoutMirroring.enabled = true
            compare(row.layoutDirection, Qt.RightToLeft)
        }
    }
}
