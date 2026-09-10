import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 480
    height: 260

    Components.MeoExposedDropdown {
        id: dropdown
        width: 280
        label: "Environment"
        model: ["Development", "Staging", "Production"]
    }

    TestCase {
        name: "MeoExposedDropdown"
        when: windowShown

        function init() {
            if (dropdown.opened)
                dropdown.toggleMenu()
            wait(MeoTheme.motionDurationPopupEffectsExit + 50)
            dropdown.enabled = true
            dropdown.model = ["Development", "Staging", "Production"]
            dropdown.textRole = ""
            dropdown.valueRole = ""
            dropdown.currentValue = undefined
            dropdown.text = ""
            dropdown.currentIndex = -1
            dropdown.type = "filled"
            dropdown.isError = false
            dropdown.LayoutMirroring.enabled = false
            dropdown.LayoutMirroring.childrenInherit = true
        }

        function test_selectionSynchronizesTextAndBounds() {
            dropdown.selectIndex(1)
            compare(dropdown.currentIndex, 1)
            compare(dropdown.text, "Staging")

            dropdown.moveSelection(1)
            compare(dropdown.currentIndex, 2)
            dropdown.moveSelection(1)
            compare(dropdown.currentIndex, 2)
            dropdown.moveSelection(-5)
            compare(dropdown.currentIndex, 0)
        }

        function test_objectRolesSynchronizeValueTextAndIndex() {
            dropdown.textRole = "label"
            dropdown.valueRole = "id"
            dropdown.model = [
                { "id": "dev", "label": "Development" },
                { "id": "prod", "label": "Production" }
            ]

            dropdown.currentValue = "prod"
            compare(dropdown.currentIndex, 1)
            compare(dropdown.text, "Production")

            dropdown.selectIndex(0)
            compare(dropdown.currentValue, "dev")
            compare(dropdown.text, "Development")
        }

        function test_menuStateAndDisabledContract() {
            const field = findChild(dropdown, "exposedDropdownField")
            const focusRing = findChild(dropdown, "exposedDropdownFocusRing")
            verify(field !== null)
            verify(focusRing !== null)

            dropdown.openMenu()
            tryCompare(dropdown, "opened", true, 500)
            dropdown.activateHighlighted()
            tryCompare(dropdown, "opened", false, 500)

            dropdown.enabled = false
            dropdown.openMenu()
            compare(dropdown.opened, false)
        }

        function test_errorAndRtlPropagateWithoutGeometryMutation() {
            const field = findChild(dropdown, "exposedDropdownField")
            const width = dropdown.width
            dropdown.type = "outlined"
            dropdown.isError = true
            compare(dropdown.width, width)
            compare(field.type, "outlined")
            compare(field.isError, true)

            dropdown.LayoutMirroring.enabled = true
            compare(field.LayoutMirroring.enabled, true)
        }

        function test_pointerFeedbackUsesSharedClickOrigin() {
            const stateLayer = findChild(dropdown, "exposedDropdownStateLayer")
            verify(stateLayer !== null)
            const x = 36
            const y = Math.min(24, dropdown.height / 2)
            const expected = stateLayer.mapFromItem(dropdown, x, y)
            verify(stateLayer.visible)
            verify(stateLayer.enabled)
            verify(!stateLayer.theme.reduceMotion)
            mouseMove(dropdown, x, y)
            mousePress(dropdown, x, y, Qt.LeftButton)
            wait(0)
            verify(stateLayer.rippleActive)
            compare(Math.round(stateLayer.rippleOriginX), Math.round(expected.x))
            compare(Math.round(stateLayer.rippleOriginY), Math.round(expected.y))
            mouseRelease(dropdown, x, y, Qt.LeftButton)
            if (dropdown.opened)
                dropdown.toggleMenu()
        }
    }
}
