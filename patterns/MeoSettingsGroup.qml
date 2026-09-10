import QtQuick
import MeoUI

// Semantic Settings adapter over MeoSegmentedList. The base pattern owns the
// connected container, member gaps, dividers, positions, and selection. This
// type only maps Settings row roles and forwards their actions.
MeoSegmentedList {
    id: control

    property color selectedContainerColor: MeoTheme.secondaryContainer
    property real radius: MeoTheme.connectedGroupOuterRadius
    property Component rowDelegate: settingsRowDelegate

    signal rowActivated(int index, var row)
    signal rowToggled(int index, bool checked, var row)
    signal rowActionTriggered(int index, var row)
    signal rowSliderMoved(int index, real value, var row)
    signal rowOptionSelected(int index, int optionIndex, var option, var row)
    signal rowDropdownSelected(int index, int optionIndex, string value, var row)

    containerRadius: radius
    titleColor: MeoTheme.primary
    loaderObjectNamePrefix: "meoSettingsGroupLoader_"
    delegate: rowDelegate

    Component {
        id: settingsRowDelegate

        MeoSettingsRow {
            id: row
            property var modelData: null
            property int index: -1
            readonly property var item: modelData || ({})

            objectName: item.objectName || item.id || ""
            title: item.title || item.label || ""
            subtitle: item.subtitle || item.supportingText || ""
            leadingIcon: item.leadingIcon || item.icon || ""
            leadingTone: item.tone || item.leadingTone || "primary"
            leadingStyle: item.leadingStyle || "plain"
            trailingKind: item.trailingKind || item.kind || "navigation"
            trailingText: {
                if (item.trailingText !== undefined && item.trailingText !== null)
                    return String(item.trailingText)
                if (!row.isSlider && !row.isProgress
                        && item.value !== undefined && item.value !== null)
                    return String(item.value)
                if (item.status !== undefined && item.status !== null)
                    return String(item.status)
                return ""
            }
            badgeText: item.badgeText || ""
            badgeColor: item.badgeColor || MeoTheme.error
            statusTone: item.statusTone || "neutral"
            actionText: item.actionText || ""
            actionType: item.actionType || "text"
            statusShowsChevron: item.statusShowsChevron === true
            checked: item.checked === true
            indeterminate: item.indeterminate === true
            valueText: item.valueText !== undefined
                       ? String(item.valueText)
                       : (row.isValue && item.value !== undefined ? String(item.value) : "")
            from: row.isSlider && item.from !== undefined ? Number(item.from) : 0
            to: row.isSlider && item.to !== undefined ? Number(item.to) : 100
            value: row.isSlider && item.value !== undefined ? Number(item.value) : 0
            stepSize: row.isSlider && item.stepSize !== undefined ? Number(item.stepSize) : 1
            discrete: item.discrete === true
            snapMode: item.snapMode === true
            tickMarksEnabled: item.tickMarksEnabled === undefined ? row.discrete : item.tickMarksEnabled
            sliderValueLabelEnabled: item.sliderValueLabelEnabled === true
            sliderIsThick: item.sliderIsThick === true
            sliderWavy: item.sliderWavy === true
            sliderExpressive: item.sliderExpressive === undefined ? true : item.sliderExpressive
            sliderTrackStyle: item.sliderTrackStyle || (sliderExpressive ? "split" : "standard")
            sliderSize: item.sliderSize || "s"
            valueSuffix: item.valueSuffix || ""
            showValueLabel: item.showValueLabel === undefined ? true : item.showValueLabel
            options: item.options || []
            model: item.model || []
            choiceModel: item.choiceModel || []
            dropdownModel: item.dropdownModel || []
            segmentedModel: item.segmentedModel || []
            currentIndex: item.currentIndex === undefined ? -1 : item.currentIndex
            multiSelect: item.multiSelect === true
            selectedIndices: item.selectedIndices || []
            dropdownLabel: item.dropdownLabel || ""
            dropdownType: item.dropdownType || "outlined"
            segmentedSize: item.segmentedSize || "s"
            progress: row.isProgress && item.progress !== undefined ? Number(item.progress) : 0
            progressIndeterminate: item.progressIndeterminate === true
            progressIsThick: item.progressIsThick === true
            progressWavy: item.progressWavy === true
            progressVibrant: item.progressVibrant === true
            progressShowTrack: item.progressShowTrack === undefined ? true : item.progressShowTrack
            progressText: item.progressText || ""
            showProgressLabel: item.showProgressLabel === undefined ? true : item.showProgressLabel
            enabled: control.enabledFor(item)
            selectionColor: control.selectedContainerColor
            interactive: item.interactive === undefined
                         ? trailingKind !== "status" && trailingKind !== "none"
                         : item.interactive

            onActivated: {
                if (typeof item.action === "function")
                    item.action()
                control.rowActivated(index, item)
            }
            onToggled: (checkedValue) => {
                if (typeof item.onToggled === "function")
                    item.onToggled(checkedValue)
                control.rowToggled(index, checkedValue, item)
            }
            onActionTriggered: {
                if (typeof item.action === "function")
                    item.action()
                control.rowActionTriggered(index, item)
            }
            onSliderMoved: (nextValue) => {
                if (typeof item.onSliderMoved === "function")
                    item.onSliderMoved(nextValue)
                control.rowSliderMoved(index, nextValue, item)
            }
            onOptionSelected: (optionIndex, option) => {
                if (typeof item.onOptionSelected === "function")
                    item.onOptionSelected(optionIndex, option)
                control.rowOptionSelected(index, optionIndex, option, item)
            }
            onDropdownSelected: (optionIndex, optionValue) => {
                if (typeof item.onDropdownSelected === "function")
                    item.onDropdownSelected(optionIndex, optionValue)
                control.rowDropdownSelected(index, optionIndex, optionValue, item)
            }
        }
    }
}
