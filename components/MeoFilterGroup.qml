import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property var model: [] // strings or { label/text, icon, enabled, value }
    property bool multiSelect: false
    property var selectedIndices: []
    property int currentIndex: -1
    property bool allowEmptySelection: true
    property real chipSpacing: 8 * MeoTheme.globalScale
    property string accessibleName: qsTr("Filters")

    signal selected(int index, var data)
    signal selectionChanged(var indices)

    readonly property int itemCount: {
        if (!model)
            return 0
        if (typeof model.count === "number")
            return model.count
        return typeof model.length === "number" ? model.length : 0
    }

    Accessible.role: Accessible.Grouping
    Accessible.name: accessibleName
    Accessible.description: multiSelect
                            ? qsTr("%1 filters selected").arg(normalizedIndices(selectedIndices).length)
                            : currentIndex >= 0 ? qsTr("Selected: %1").arg(labelFor(entryAt(currentIndex)))
                                                : qsTr("No filter selected")

    function entryAt(index) {
        if (!model || index < 0 || index >= itemCount)
            return null
        return typeof model.get === "function" ? model.get(index) : model[index]
    }

    function labelFor(item) {
        return item && typeof item === "object" ? (item.label || item.text || "") : String(item || "")
    }

    function iconFor(item) {
        return item && typeof item === "object" ? (item.icon || "") : ""
    }

    function enabledFor(item) {
        return !item || typeof item !== "object" || item.enabled === undefined ? true : item.enabled
    }

    function isSelected(index) {
        return multiSelect ? selectedIndices.indexOf(index) !== -1 : currentIndex === index
    }

    function normalizedIndices(indices) {
        const result = []
        for (let position = 0; position < indices.length; ++position) {
            const index = Number(indices[position])
            if (index >= 0 && index < itemCount && enabledFor(entryAt(index)) && result.indexOf(index) === -1)
                result.push(index)
        }
        result.sort(function(left, right) { return left - right })
        return result
    }

    function activate(index) {
        if (!enabled || index < 0 || index >= itemCount || !enabledFor(entryAt(index)))
            return false
        if (multiSelect) {
            const next = normalizedIndices(selectedIndices)
            const existing = next.indexOf(index)
            if (existing === -1)
                next.push(index)
            else if (allowEmptySelection || next.length > 1)
                next.splice(existing, 1)
            next.sort(function(left, right) { return left - right })
            selectedIndices = next
            selectionChanged(next)
        } else {
            if (currentIndex === index && allowEmptySelection)
                currentIndex = -1
            else
                currentIndex = index
            selectionChanged(currentIndex < 0 ? [] : [currentIndex])
        }
        selected(index, entryAt(index))
        return true
    }

    implicitWidth: flowLayout.implicitWidth
    implicitHeight: flowLayout.implicitHeight
    padding: 0

    contentItem: Flow {
        id: flowLayout
        width: control.availableWidth
        spacing: control.chipSpacing
        layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        Repeater {
            model: control.model

            delegate: MeoFilterChip {
                id: chip
                required property int index
                required property var modelData
                objectName: "meoFilterGroupChip_" + index
                label: control.labelFor(modelData)
                leadingIcon: control.iconFor(modelData)
                enabled: control.enabled && control.enabledFor(modelData)
                selected: control.isSelected(index)
                onClicked: control.activate(index)
            }
        }
    }
}
