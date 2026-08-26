import QtQuick
import QtQuick.Controls
import MeoUI

// A high-density, rounded group for settings indexes and category pages.
// The model deliberately maps semantic row roles rather than exposing a
// generic "trailing component", which keeps navigation, mutable controls,
// and status-only facts distinguishable to both users and assistive tools.
Column {
    id: control

    property string title: ""
    property string subtitle: ""
    property var model: []
    property bool showDividers: true
    property color containerColor: MeoTheme.surfaceContainerLowest
    property color selectedContainerColor: MeoTheme.secondaryContainer
    property real radius: MeoTheme.shapeExtraLarge
    property real horizontalInset: 0
    property Component delegate: defaultDelegate

    signal rowActivated(int index, var row)
    signal rowToggled(int index, bool checked, var row)
    signal rowActionTriggered(int index, var row)
    signal rowSliderMoved(int index, real value, var row)
    signal rowOptionSelected(int index, int optionIndex, var option, var row)
    signal rowDropdownSelected(int index, int optionIndex, string value, var row)

    readonly property real scale: MeoTheme.globalScale
    readonly property var titleFont: MeoTheme.titleSmall
    readonly property var subtitleFont: MeoTheme.bodyMedium

    width: parent ? parent.width : 560 * scale
    spacing: 8 * scale

    Column {
        width: parent.width
        leftPadding: control.horizontalInset
        rightPadding: control.horizontalInset
        spacing: 2 * control.scale
        visible: control.title !== "" || control.subtitle !== ""

        Text {
            width: parent.width
            text: control.title
            visible: text !== ""
            font.family: MeoTheme.typefacePlain
            font.pixelSize: control.titleFont.size * control.scale
            font.weight: control.titleFont.weight
            color: MeoTheme.contentOnSurface
            elide: Text.ElideRight
            textFormat: Text.PlainText
        }

        Text {
            width: parent.width
            text: control.subtitle
            visible: text !== ""
            font.family: MeoTheme.typefacePlain
            font.pixelSize: control.subtitleFont.size * control.scale
            font.weight: control.subtitleFont.weight
            color: MeoTheme.contentOnSurfaceVariant
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            textFormat: Text.PlainText
        }
    }

    Item {
        width: parent.width
        implicitHeight: rows.implicitHeight

        Rectangle {
            anchors.fill: parent
            radius: control.radius
            color: control.containerColor
        }

        Column {
            id: rows
            width: parent.width
            spacing: 0

            Repeater {
                id: rowRepeater
                model: control.model
                delegate: control.delegate
            }
        }
    }

    Component {
        id: defaultDelegate

        MeoSettingsRow {
            id: row
            readonly property var item: modelData || ({})

            objectName: item.objectName || item.id || ""
            width: rows.width
            title: item.title || item.label || ""
            subtitle: item.subtitle || item.supportingText || ""
            leadingIcon: item.icon || ""
            leadingTone: item.tone || item.leadingTone || "primary"
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
            enabled: item.enabled === undefined ? true : item.enabled
            selected: item.selected === true
            interactive: item.interactive === undefined
                         ? trailingKind !== "status" && trailingKind !== "none"
                         : item.interactive
            surfaceColor: "transparent"
            selectionColor: control.selectedContainerColor
            positionInGroup: rowRepeater.count <= 1 ? "only"
                             : index === 0 ? "first"
                             : index === rowRepeater.count - 1 ? "last"
                             : "middle"
            showDivider: control.showDividers && index < rowRepeater.count - 1

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
            onSliderMoved: (value) => {
                if (typeof item.onSliderMoved === "function")
                    item.onSliderMoved(value)
                control.rowSliderMoved(index, value, item)
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
