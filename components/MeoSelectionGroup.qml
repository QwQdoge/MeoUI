import QtQuick
import QtQuick.Controls
import MeoUI

// A grouped list for checkbox or radio selection. Model entries are copied on
// every user change, so consuming applications can treat the input array as
// immutable and update their own state from changed().
Control {
    id: control

    property var model: [] // [{ label: "Design", checked: false, enabled: true }, ...]
    property string type: "checkbox" // "checkbox" | "radio"
    property bool showSelectAll: false
    property string selectAllLabel: qsTr("Select all")
    signal changed(var model)
    signal selectionChanged(int index, bool checked)

    readonly property int optionCount: {
        if (!model)
            return 0
        if (typeof model.count === "number")
            return model.count
        return typeof model.length === "number" ? model.length : 0
    }
    readonly property int selectedIndex: {
        for (let index = 0; index < optionCount; ++index) {
            if (isSelected(index))
                return index
        }
        return -1
    }

    // A radio group is one Tab stop. Once focused, its option rows manage
    // Arrow navigation and selection as required by M3 radio accessibility.
    activeFocusOnTab: enabled && type === "radio"
    implicitWidth: 320 * MeoTheme.globalScale
    implicitHeight: groupColumn.implicitHeight
    Accessible.role: type === "radio" ? Accessible.Grouping : Accessible.List
    Accessible.name: type === "radio" ? qsTr("Single-choice options") : qsTr("Multiple-choice options")
    Accessible.description: type === "radio"
                            ? qsTr("%1 selected").arg(selectedIndex >= 0 ? entryLabel(selectedIndex) : qsTr("None"))
                            : qsTr("%1 of %2 selected").arg(selectedCount()).arg(optionCount)
    Accessible.focusable: enabled && type === "radio"

    function entryAt(index) {
        if (index < 0 || index >= optionCount)
            return null
        if (model && typeof model.get === "function")
            return model.get(index)
        return model[index]
    }

    function entryLabel(index) {
        const entry = entryAt(index)
        if (entry === null || typeof entry === "undefined")
            return ""
        if (typeof entry === "string" || typeof entry === "number")
            return String(entry)
        return entry.label || entry.title || ""
    }

    function entrySupportingText(index) {
        const entry = entryAt(index)
        return entry && typeof entry === "object" ? (entry.supportingText || entry.subtitle || "") : ""
    }

    function entryEnabled(index) {
        const entry = entryAt(index)
        return !entry || typeof entry !== "object" || entry.enabled !== false
    }

    function isSelected(index) {
        const entry = entryAt(index)
        return !!(entry && typeof entry === "object" && entry.checked)
    }

    function selectedCount() {
        let count = 0
        for (let index = 0; index < optionCount; ++index) {
            if (isSelected(index))
                count += 1
        }
        return count
    }

    function isAllSelected() {
        let selectableCount = 0
        for (let index = 0; index < optionCount; ++index) {
            if (!entryEnabled(index))
                continue
            selectableCount += 1
            if (!isSelected(index))
                return false
        }
        return selectableCount > 0
    }

    function isAnySelected() {
        return selectedCount() > 0
    }

    function copiedModel() {
        const next = []
        for (let index = 0; index < optionCount; ++index) {
            const entry = entryAt(index)
            if (entry && typeof entry === "object")
                next.push(Object.assign({}, entry))
            else
                next.push({ "label": entry === null || typeof entry === "undefined" ? "" : String(entry), "checked": false })
        }
        return next
    }

    function publish(nextModel, changedIndex) {
        model = nextModel
        changed(model)
        if (changedIndex >= 0 && changedIndex < nextModel.length)
            selectionChanged(changedIndex, !!nextModel[changedIndex].checked)
    }

    function activateIndex(index) {
        if (!enabled || index < 0 || index >= optionCount || !entryEnabled(index))
            return false

        const next = copiedModel()
        if (type === "radio") {
            for (let candidate = 0; candidate < next.length; ++candidate)
                next[candidate].checked = candidate === index
        } else {
            next[index].checked = !next[index].checked
        }
        publish(next, index)
        return true
    }

    function firstEnabledIndex(direction) {
        const start = direction < 0 ? optionCount - 1 : 0
        const end = direction < 0 ? -1 : optionCount
        for (let index = start; index !== end; index += direction) {
            if (entryEnabled(index))
                return index
        }
        return -1
    }

    function focusRadioIndex(index) {
        for (let childIndex = 0; childIndex < groupColumn.children.length; ++childIndex) {
            const candidate = groupColumn.children[childIndex]
            if (candidate && candidate.objectName === "meoSelectionGroupRow_" + index) {
                candidate.forceActiveFocus(Qt.TabFocusReason)
                return true
            }
        }
        return false
    }

    function moveRadioSelection(currentIndex, direction) {
        if (type !== "radio" || optionCount === 0)
            return

        const step = direction < 0 ? -1 : 1
        let nextIndex = currentIndex
        for (let attempts = 0; attempts < optionCount; ++attempts) {
            nextIndex = (nextIndex + step + optionCount) % optionCount
            if (entryEnabled(nextIndex)) {
                activateIndex(nextIndex)
                focusRadioIndex(nextIndex)
                return
            }
        }
    }

    function setAllSelected(selected) {
        if (!enabled || type !== "checkbox")
            return false

        const next = copiedModel()
        for (let index = 0; index < next.length; ++index) {
            if (entryEnabled(index))
                next[index].checked = selected
        }
        model = next
        changed(model)
        selectionChanged(-1, selected)
        return true
    }

    onActiveFocusChanged: {
        if (!activeFocus || type !== "radio")
            return
        const focusIndex = selectedIndex >= 0 ? selectedIndex : firstEnabledIndex(1)
        if (focusIndex >= 0)
            focusRadioIndex(focusIndex)
    }

    contentItem: Column {
        id: groupColumn
        width: control.availableWidth
        spacing: 4 * MeoTheme.globalScale

        MeoListItem {
            id: selectAllRow
            visible: control.showSelectAll && control.type === "checkbox" && control.optionCount > 0
            width: parent.width
            headline: control.selectAllLabel
            interactive: control.enabled
            enabled: control.enabled
            selected: control.isAllSelected()
            isSegmented: true
            roundingStrategy: "all"
            trailingComponent: Component {
                MeoCheckbox {
                    checked: control.isAllSelected()
                    indeterminate: !control.isAllSelected() && control.isAnySelected()
                    enabled: control.enabled
                    Accessible.name: control.selectAllLabel
                    onToggled: control.setAllSelected(!control.isAllSelected())
                }
            }
            onClicked: control.setAllSelected(!control.isAllSelected())
        }

        MeoDivider {
            width: parent.width
            visible: selectAllRow.visible
        }

        Repeater {
            model: control.optionCount

            delegate: MeoListItem {
                id: optionRow
                required property int index
                objectName: "meoSelectionGroupRow_" + index
                width: parent.width
                headline: control.entryLabel(index)
                supportingText: control.entrySupportingText(index)
                interactive: control.enabled && control.entryEnabled(index)
                enabled: control.enabled && control.entryEnabled(index)
                activeFocusOnTab: control.type !== "radio" && interactive && enabled
                selected: control.isSelected(index)
                isSegmented: true
                roundingStrategy: "all"
                trailingComponent: control.type === "radio" ? radioControl : checkboxControl
                Accessible.description: control.type === "radio"
                                        ? (selected ? qsTr("Selected") : qsTr("Not selected"))
                                        : (selected ? qsTr("Checked") : qsTr("Not checked"))

                Component {
                    id: checkboxControl
                    MeoCheckbox {
                        checked: control.isSelected(index)
                        enabled: optionRow.enabled
                        Accessible.name: control.entryLabel(index)
                        onToggled: control.activateIndex(index)
                    }
                }

                Component {
                    id: radioControl
                    MeoRadioButton {
                        checked: control.isSelected(index)
                        enabled: optionRow.enabled
                        Accessible.name: control.entryLabel(index)
                        onToggled: control.activateIndex(index)
                    }
                }

                onClicked: control.activateIndex(index)
                Keys.onPressed: function(event) {
                    if (control.type !== "radio")
                        return
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                        control.moveRadioSelection(index, -1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                        control.moveRadioSelection(index, 1)
                        event.accepted = true
                    }
                }
            }
        }
    }

    opacity: enabled ? 1.0 : MeoTheme.disabledContentOpacity
    Behavior on opacity {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: MeoTheme.motionDurationState }
    }
}
