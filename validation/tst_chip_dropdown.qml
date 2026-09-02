import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoChipDropdown {
        id: dropdown
        model: ["A", "B", "C"]
        selectedIndices: [0]
    }

    TestCase {
        name: "MeoChipDropdown"
        when: windowShown

        function test_selectionCanBeChangedWithoutDuplicateManualEmission() {
            let signalCount = 0
            const handler = function() { signalCount++ }
            dropdown.selectedIndicesChanged.connect(handler)
            dropdown.selectedIndices = [0, 2]
            compare(signalCount, 1)
            dropdown.selectedIndicesChanged.disconnect(handler)
            compare(dropdown.selectedIndices.length, 2)
        }

        function test_errorAndCounterContractsRemainAvailable() {
            dropdown.showCounter = true
            dropdown.isError = true
            dropdown.errorText = "Select a tag"
            compare(dropdown.error, true)
            compare(dropdown.selectedIndices.length, 2)
        }
    }
}
