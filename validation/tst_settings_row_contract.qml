import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 720
    height: 1500

    Column {
        id: rows
        width: 640
        spacing: 8

        MeoSettingsRow {
            id: navigationRow
            width: parent.width
            title: "Wi-Fi"
            trailingKind: "navigation"
            trailingText: "Connected"
        }

        MeoSettingsRow {
            id: switchRow
            width: parent.width
            title: "Bluetooth"
            trailingKind: "switch"
            checked: true
        }

        MeoSettingsRow {
            id: valueRow
            width: parent.width
            title: "Resolution"
            trailingKind: "value"
            valueText: "2560×1600"
        }

        MeoSettingsRow {
            id: sliderRow
            width: parent.width
            title: "Brightness"
            trailingKind: "slider"
            value: 72
            valueSuffix: "%"
        }

        MeoSettingsRow {
            id: segmentedRow
            width: parent.width
            title: "Theme"
            trailingKind: "segmented"
            options: ["Light", "Dark", "Auto"]
            currentIndex: 2
        }

        MeoSettingsRow {
            id: dropdownRow
            width: parent.width
            title: "Refresh rate"
            trailingKind: "dropdown"
            options: ["60 Hz", "120 Hz", "165 Hz"]
            currentIndex: 2
        }

        MeoSettingsRow {
            id: radioRow
            width: parent.width
            title: "Default output"
            trailingKind: "radio"
        }

        MeoSettingsRow {
            id: checkboxRow
            width: parent.width
            title: "Show battery percentage"
            trailingKind: "checkbox"
            checked: true
        }

        MeoSettingsRow {
            id: actionRow
            width: parent.width
            title: "Reset settings"
            trailingKind: "button"
            actionText: "Reset"
        }

        MeoSettingsRow {
            id: statusRow
            width: parent.width
            title: "System update"
            trailingKind: "status"
            trailingText: "Up to date"
            statusTone: "primary"
        }

        MeoSettingsRow {
            id: progressRow
            width: parent.width
            title: "Downloading update"
            trailingKind: "progress"
            progress: 0.42
        }

        // Existing compact choice behavior remains available without options.
        MeoSettingsRow {
            id: compactChoiceRow
            width: parent.width
            title: "Power profile"
            trailingKind: "choice"
            trailingText: "Balanced"
        }
    }

    SignalSpy { id: toggledSpy; target: checkboxRow; signalName: "toggled" }
    SignalSpy { id: sliderSpy; target: sliderRow; signalName: "sliderMoved" }
    SignalSpy { id: segmentSpy; target: segmentedRow; signalName: "optionSelected" }
    SignalSpy { id: dropdownSpy; target: dropdownRow; signalName: "optionSelected" }
    SignalSpy { id: actionSpy; target: actionRow; signalName: "actionTriggered" }

    // The group model must forward the extended row contract too, otherwise
    // every page would need its own settings-control wrapper.
    MeoSettingsGroup {
        id: modelGroup
        visible: false
        width: 640
        model: [
            {
                "id": "group-slider",
                "title": "Group brightness",
                "trailingKind": "slider",
                "value": 31,
                "valueSuffix": "%"
            },
            {
                "id": "group-dropdown",
                "title": "Group refresh rate",
                "trailingKind": "dropdown",
                "options": ["60 Hz", "165 Hz"],
                "currentIndex": 1
            },
            {
                "id": "group-progress",
                "title": "Group download",
                "trailingKind": "progress",
                "progress": 0.5
            }
        ]
    }

    TestCase {
        name: "MeoSettingsRowContract"
        when: windowShown

        function init() {
            switchRow.checked = true
            sliderRow.value = 72
            segmentedRow.currentIndex = 2
            dropdownRow.currentIndex = 2
            radioRow.checked = false
            checkboxRow.checked = true
            toggledSpy.clear()
            sliderSpy.clear()
            segmentSpy.clear()
            dropdownSpy.clear()
            actionSpy.clear()
            wait(0)
        }

        function test_allKindsInstantiateWithExpectedSemantics() {
            verify(navigationRow.isNavigation)
            verify(switchRow.isToggle)
            verify(valueRow.isValue)
            verify(sliderRow.isSlider)
            verify(segmentedRow.isSegmented)
            verify(dropdownRow.isDropdown)
            verify(radioRow.isRadio)
            verify(checkboxRow.isCheckbox)
            verify(actionRow.isAction)
            verify(statusRow.isStatus)
            verify(progressRow.isProgress)

            verify(sliderRow.implicitHeight > 72 * MeoTheme.globalScale)
            verify(segmentedRow.implicitHeight > 72 * MeoTheme.globalScale)
            verify(dropdownRow.implicitHeight > 72 * MeoTheme.globalScale)
            verify(progressRow.implicitHeight > 72 * MeoTheme.globalScale)
            compare(valueRow.effectiveValueText, "2560×1600")
            compare(sliderRow.effectiveSliderText, "72%")
            compare(dropdownRow.selectedOptionText, "165 Hz")
            compare(progressRow.effectiveProgressText, "42%")

            verify(compactChoiceRow.isLegacyChoice)
            verify(compactChoiceRow.hasChevron)
            verify(compactChoiceRow.isInteractive)
        }

        function test_controlsUpdateTheSharedRowState() {
            sliderRow.setSliderValue(76)
            compare(sliderRow.value, 76)
            compare(sliderSpy.count, 1)

            segmentedRow.selectOption(1, "Dark")
            compare(segmentedRow.currentIndex, 1)
            compare(segmentSpy.count, 1)

            dropdownRow.selectOption(0, "60 Hz")
            compare(dropdownRow.currentIndex, 0)
            compare(dropdownSpy.count, 1)

            checkboxRow.activate()
            compare(checkboxRow.checked, false)
            compare(toggledSpy.count, 1)

            radioRow.activate()
            verify(radioRow.checked)

            actionRow.activate()
            compare(actionSpy.count, 1)
        }

        function test_disabledInteractiveRowIsNotAccessibilityFocusable() {
            navigationRow.enabled = false
            verify(!navigationRow.isInteractive)
            verify(!navigationRow.Accessible.focusable)
            navigationRow.enabled = true
            verify(navigationRow.isInteractive)
        }

        function test_groupForwardsExtendedModelData() {
            const groupSlider = findChild(modelGroup, "group-slider")
            const groupDropdown = findChild(modelGroup, "group-dropdown")
            const groupProgress = findChild(modelGroup, "group-progress")
            verify(groupSlider !== null)
            verify(groupDropdown !== null)
            verify(groupProgress !== null)
            compare(groupSlider.value, 31)
            compare(groupSlider.effectiveSliderText, "31%")
            compare(groupDropdown.selectedOptionText, "165 Hz")
            compare(groupProgress.progress, 0.5)
            compare(groupProgress.effectiveProgressText, "50%")
        }
    }
}
