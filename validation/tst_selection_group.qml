import QtQuick
import QtTest
import "../" as Source
import "../components" as Components

Item {
    width: 760
    height: 360

    property var sourceCheckboxModel: [
        { "label": "Design", "checked": true },
        { "label": "Code", "checked": false },
        { "label": "Unavailable", "checked": false, "enabled": false }
    ]

    Components.MeoSelectionGroup {
        id: checkboxGroup
        width: 360
        showSelectAll: true
        model: sourceCheckboxModel
    }

    Components.MeoSelectionGroup {
        id: radioGroup
        x: 390
        width: 360
        type: "radio"
        model: [
            { "label": "Light", "checked": false },
            { "label": "System", "checked": true },
            { "label": "Dark", "checked": false }
        ]
    }

    ListModel {
        id: listModelChoices
        ListElement { label: "One"; checked: false }
        ListElement { label: "Two"; checked: true }
        ListElement { label: "Unavailable"; checked: false; enabled: false }
    }

    SignalSpy {
        id: changedSpy
        target: checkboxGroup
        signalName: "changed"
    }

    TestCase {
        name: "MeoSelectionGroup"
        when: windowShown

        function init() {
            checkboxGroup.enabled = true
            checkboxGroup.type = "checkbox"
            checkboxGroup.model = sourceCheckboxModel
            radioGroup.enabled = true
            radioGroup.model = [
                { "label": "Light", "checked": false },
                { "label": "System", "checked": true },
                { "label": "Dark", "checked": false }
            ]
            changedSpy.clear()
        }

        function test_checkboxChangesCopyTheModel() {
            const initial = checkboxGroup.model
            checkboxGroup.activateIndex(1)
            verify(checkboxGroup.model !== initial)
            verify(checkboxGroup.isSelected(0))
            verify(checkboxGroup.isSelected(1))
            verify(sourceCheckboxModel[1].checked === false)
            compare(changedSpy.count, 1)
        }

        function test_selectAllLeavesDisabledEntriesUntouched() {
            checkboxGroup.setAllSelected(true)
            verify(checkboxGroup.isSelected(0))
            verify(checkboxGroup.isSelected(1))
            verify(!checkboxGroup.isSelected(2))
            verify(checkboxGroup.isAllSelected())
        }

        function test_radioMaintainsSingleSelection() {
            compare(radioGroup.selectedIndex, 1)
            radioGroup.activateIndex(2)
            compare(radioGroup.selectedIndex, 2)
            verify(!radioGroup.isSelected(1))
            verify(radioGroup.isSelected(2))
        }

        function test_radioGroupProvidesAGroupContractAndWrapsSelection() {
            compare(radioGroup.Accessible.role, Accessible.Grouping)
            compare(radioGroup.activeFocusOnTab, true)
            radioGroup.moveRadioSelection(2, 1)
            compare(radioGroup.selectedIndex, 0)
            radioGroup.moveRadioSelection(0, -1)
            compare(radioGroup.selectedIndex, 2)
        }

        function test_rowsAndDisabledState() {
            verify(findChild(checkboxGroup, "meoSelectionGroupRow_0") !== null)
            checkboxGroup.enabled = false
            wait(Source.MeoTheme.motionDurationState + 20)
            compare(checkboxGroup.opacity, Source.MeoTheme.disabledContentOpacity)
        }

        function test_listModelAndInvalidActivationAreSafe() {
            checkboxGroup.model = listModelChoices
            wait(0)
            compare(checkboxGroup.optionCount, 3)
            compare(checkboxGroup.entryLabel(1), "Two")
            verify(!checkboxGroup.activateIndex(-1))
            verify(!checkboxGroup.activateIndex(2))
            verify(checkboxGroup.activateIndex(0))
            verify(checkboxGroup.isSelected(0))
            verify(checkboxGroup.setAllSelected(false))
            verify(!checkboxGroup.isSelected(0))
        }
    }
}
