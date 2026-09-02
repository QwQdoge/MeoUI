import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoSpinBox { id: spin; from: 0; to: 10; value: 4; stepSize: 2 }

    TestCase {
        name: "MeoSpinBox"
        when: windowShown

        function test_rangeAndStepContract() {
            spin.increase()
            compare(spin.value, 6)
            spin.decrease()
            compare(spin.value, 4)
            spin.value = spin.to
            verify(findChild(spin, "meoSpinBoxIncrement") !== null)
            verify(findChild(spin, "meoSpinBoxDecrement") !== null)
            compare(spin.value, 10)
        }

        function test_editableModeCanBeDisabled() {
            spin.editable = false
            compare(spin.contentItem.readOnly, true)
        }

        function test_accessibleNamesDescribeTheNativeSpinBoxAndActions() {
            spin.accessibleName = "Columns"
            compare(spin.Accessible.name, "Columns")
            verify(spin.Accessible.description.indexOf("Range 0 to 10") !== -1)
            compare(findChild(spin, "meoSpinBoxIncrement").Accessible.name,
                    "Increase Columns")
            compare(findChild(spin, "meoSpinBoxDecrement").Accessible.name,
                    "Decrease Columns")
        }
    }
}
