import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // Array and QML ListModel inputs are supported. Columns use
    // { label, property|role, width?, sortable?, delegate? }.
    property var columns: []
    property var model: []
    property var rowData: model // Compatibility name retained for callers.
    property bool selectable: false
    property bool showCheckBoxes: selectable
    property bool showDividers: true
    property bool hoverEffect: true
    property string sortProperty: ""
    property bool sortAscending: true
    property var selectedIndices: []
    property bool allSelected: false
    property bool isIndeterminate: false
    property real headerHeight: 56 * MeoTheme.globalScale
    property real rowHeight: 52 * MeoTheme.globalScale
    property real cellPadding: 16 * MeoTheme.globalScale
    property real cornerRadius: 12 * MeoTheme.globalScale

    signal sortRequested(string property, bool ascending)
    signal selectionChanged()
    signal rowActivated(int index, var row)

    readonly property bool isMirrored: control.mirrored
    readonly property int rowCount: {
        if (Array.isArray(control.model))
            return control.model.length
        if (control.model && typeof control.model.count === "number")
            return control.model.count
        return 0
    }
    readonly property real checkboxColumnWidth: 56 * MeoTheme.globalScale
    readonly property real availableColumnWidth: Math.max(0, width - 2 * cellPadding
                                                              - (selectable ? checkboxColumnWidth : 0))

    implicitWidth: 600 * MeoTheme.globalScale
    implicitHeight: 248 * MeoTheme.globalScale
    Accessible.name: qsTr("Data table")

    function rowAt(rowIndex) {
        if (rowIndex < 0 || rowIndex >= rowCount)
            return null
        if (Array.isArray(model))
            return model[rowIndex]
        if (model && typeof model.get === "function")
            return model.get(rowIndex)
        return null
    }

    function rowIsSelected(row) {
        return !!(row && (row.selected || row.isSelected))
    }

    function rowIsEnabled(row) {
        return !row || row.enabled === undefined || !!row.enabled
    }

    function valueFor(row, rolePath) {
        if (!row || !rolePath)
            return ""
        let value = row
        const path = String(rolePath).split(".")
        for (let i = 0; i < path.length; ++i) {
            if (value === null || value === undefined)
                return ""
            value = value[path[i]]
        }
        return value === undefined || value === null ? "" : value
    }

    function columnWidth(column) {
        if (column && typeof column.width === "number" && column.width > 0)
            return column.width * MeoTheme.globalScale
        return columns.length > 0 ? availableColumnWidth / columns.length : availableColumnWidth
    }

    function refreshSelectionState() {
        const indices = []
        let selectableCount = 0
        let selectedSelectableCount = 0
        for (let i = 0; i < rowCount; ++i) {
            const row = rowAt(i)
            if (rowIsSelected(row))
                indices.push(i)
            if (rowIsEnabled(row)) {
                selectableCount += 1
                if (rowIsSelected(row))
                    selectedSelectableCount += 1
            }
        }
        selectedIndices = indices
        allSelected = selectableCount > 0 && selectedSelectableCount === selectableCount
        isIndeterminate = selectedSelectableCount > 0 && selectedSelectableCount < selectableCount
    }

    function setRowSelected(rowIndex, selected) {
        if (rowIndex < 0 || rowIndex >= rowCount)
            return false
        const current = rowAt(rowIndex)
        if (!rowIsEnabled(current))
            return false

        if (Array.isArray(model)) {
            const replacement = []
            for (let i = 0; i < model.length; ++i) {
                const item = model[i]
                if (i !== rowIndex) {
                    replacement.push(item)
                    continue
                }
                const next = {}
                for (const key in item)
                    next[key] = item[key]
                next.selected = selected
                next.isSelected = selected
                replacement.push(next)
            }
            model = replacement
        } else if (model && typeof model.setProperty === "function") {
            model.setProperty(rowIndex, "selected", selected)
            model.setProperty(rowIndex, "isSelected", selected)
        } else {
            return false
        }

        refreshSelectionState()
        selectionChanged()
        return true
    }

    function toggleRow(rowIndex, selected) {
        return setRowSelected(rowIndex, selected)
    }

    function toggleAll(selected) {
        let changed = false
        if (Array.isArray(model)) {
            const replacement = []
            for (let i = 0; i < model.length; ++i) {
                const row = model[i]
                if (!rowIsEnabled(row) || rowIsSelected(row) === selected) {
                    replacement.push(row)
                    continue
                }
                const next = {}
                for (const key in row)
                    next[key] = row[key]
                next.selected = selected
                next.isSelected = selected
                replacement.push(next)
                changed = true
            }
            if (changed)
                model = replacement
        } else if (model && typeof model.setProperty === "function") {
            for (let i = 0; i < rowCount; ++i) {
                const row = rowAt(i)
                if (!rowIsEnabled(row) || rowIsSelected(row) === selected)
                    continue
                model.setProperty(i, "selected", selected)
                model.setProperty(i, "isSelected", selected)
                changed = true
            }
        }
        refreshSelectionState()
        if (changed)
            selectionChanged()
        return changed
    }

    function requestSort(column) {
        if (!column || !column.sortable)
            return false
        const role = column.property || column.role || ""
        if (!role)
            return false
        if (sortProperty === role)
            sortAscending = !sortAscending
        else {
            sortProperty = role
            sortAscending = true
        }
        sortRequested(role, sortAscending)
        return true
    }

    onRowDataChanged: {
        if (model !== rowData)
            model = rowData
    }
    onModelChanged: {
        if (rowData !== model)
            rowData = model
        refreshSelectionState()
    }
    onShowCheckBoxesChanged: {
        if (selectable !== showCheckBoxes)
            selectable = showCheckBoxes
    }
    onSelectableChanged: {
        if (showCheckBoxes !== selectable)
            showCheckBoxes = selectable
    }
    Component.onCompleted: refreshSelectionState()

    background: Rectangle {
        color: MeoTheme.surfaceContainerLowest
        radius: control.cornerRadius
        border.width: Math.max(1, Math.round(MeoTheme.globalScale))
        border.color: MeoTheme.outlineVariant
    }

    contentItem: Column {
        clip: true

        Item {
            id: tableHeader
            width: parent.width
            height: control.headerHeight

            Row {
                anchors.fill: parent
                anchors.leftMargin: control.cellPadding
                anchors.rightMargin: control.cellPadding
                layoutDirection: control.isMirrored ? Qt.RightToLeft : Qt.LeftToRight

                Item {
                    width: control.checkboxColumnWidth
                    height: parent.height
                    visible: control.selectable

                    MeoCheckbox {
                        anchors.centerIn: parent
                        checked: control.allSelected
                        indeterminate: control.isIndeterminate
                        Accessible.name: qsTr("Select all rows")
                        onToggled: function(isChecked) { control.toggleAll(isChecked) }
                    }
                }

                Repeater {
                    model: control.columns

                    delegate: HeaderCell {
                        required property var modelData
                        required property int index
                        width: control.columnWidth(modelData)
                        height: tableHeader.height
                        columnData: modelData
                        columnIndex: index
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: Math.max(1, Math.round(MeoTheme.globalScale))
                color: MeoTheme.outlineVariant
            }
        }

        ListView {
            id: listView
            objectName: "meoDataTableRows"
            width: parent.width
            height: Math.max(0, parent.height - tableHeader.height)
            model: control.model
            clip: true
            focus: true
            keyNavigationEnabled: true
            boundsBehavior: Flickable.StopAtBounds
            highlightFollowsCurrentItem: true

            ScrollBar.vertical: MeoScrollBar {
                policy: listView.contentHeight > listView.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }

            Keys.onSpacePressed: function(event) {
                if (control.selectable && listView.currentIndex >= 0) {
                    const row = control.rowAt(listView.currentIndex)
                    control.toggleRow(listView.currentIndex, !control.rowIsSelected(row))
                    event.accepted = true
                }
            }
            Keys.onReturnPressed: function(event) {
                if (listView.currentIndex >= 0) {
                    control.rowActivated(listView.currentIndex, control.rowAt(listView.currentIndex))
                    event.accepted = true
                }
            }

            delegate: Item {
                id: rowDelegate
                objectName: "meoDataTableRow_" + index
                width: listView.width
                height: control.rowHeight

                readonly property var row: modelData
                readonly property bool selected: control.rowIsSelected(row)
                readonly property bool rowEnabled: control.rowIsEnabled(row)
                readonly property bool focused: listView.activeFocus && listView.currentIndex === index

                opacity: rowEnabled ? 1.0 : MeoTheme.disabledContentOpacity

                Rectangle {
                    anchors.fill: parent
                    color: rowDelegate.selected ? MeoTheme.secondaryContainer : "transparent"

                    MeoStateLayer {
                        anchors.fill: parent
                        radius: 0
                        hovered: control.hoverEffect && rowMouseArea.containsMouse && rowDelegate.rowEnabled
                        pressed: rowMouseArea.pressed && rowDelegate.rowEnabled
                        // Rows use the explicit primary focus outline below;
                        // the generic black focus ring is too heavy for a
                        // dense table and obscures hover versus focus.
                        focused: false
                        focusRingEnabled: false
                        color: rowDelegate.selected ? MeoTheme.contentOnSecondaryContainer
                                                         : MeoTheme.contentOnSurface
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: control.cellPadding
                    anchors.rightMargin: control.cellPadding
                    layoutDirection: control.isMirrored ? Qt.RightToLeft : Qt.LeftToRight

                    Item {
                        width: control.checkboxColumnWidth
                        height: parent.height
                        visible: control.selectable

                        MeoCheckbox {
                            anchors.centerIn: parent
                            checked: rowDelegate.selected
                            enabled: rowDelegate.rowEnabled
                            Accessible.name: qsTr("Select row %1").arg(index + 1)
                        }
                    }

                    Repeater {
                        model: control.columns

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: control.columnWidth(modelData)
                            height: rowDelegate.height

                            Loader {
                                anchors.fill: parent
                                anchors.rightMargin: 8 * MeoTheme.globalScale
                                sourceComponent: modelData.delegate || defaultCell
                                property var rowData: rowDelegate.row
                                property var columnData: modelData
                            }

                            Component {
                                id: defaultCell

                                Text {
                                    anchors.fill: parent
                                    text: control.valueFor(rowData, columnData.property || columnData.role || "")
                                    color: rowDelegate.selected ? MeoTheme.contentOnSecondaryContainer
                                                                       : MeoTheme.contentOnSurfaceVariant
                                    font.family: MeoTheme.typefacePlain
                                    font.pixelSize: MeoTheme.bodyMedium.size * MeoTheme.globalScale
                                    font.weight: MeoTheme.bodyMedium.weight
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: control.isMirrored ? Text.AlignRight : Text.AlignLeft
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: Math.max(1, Math.round(MeoTheme.globalScale))
                    color: MeoTheme.outlineVariant
                    visible: control.showDividers && index < listView.count - 1
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: rowDelegate.focused ? Math.max(1, Math.round(MeoTheme.globalScale)) : 0
                    border.color: MeoTheme.primary
                    visible: rowDelegate.focused
                }

                MouseArea {
                    id: rowMouseArea
                    anchors.fill: parent
                    hoverEnabled: control.hoverEffect
                    enabled: rowDelegate.rowEnabled
                    onClicked: {
                        listView.currentIndex = index
                        listView.forceActiveFocus()
                        if (control.selectable)
                            control.toggleRow(index, !rowDelegate.selected)
                        control.rowActivated(index, rowDelegate.row)
                    }
                }
            }
        }
    }

    component HeaderCell: AbstractButton {
        id: headerCell
        property var columnData: ({})
        property int columnIndex: -1

        enabled: !!columnData.sortable
        activeFocusOnTab: enabled
        Accessible.name: columnData.label || qsTr("Column %1").arg(columnIndex + 1)
        Accessible.description: enabled ? qsTr("Sort column") : ""
        onClicked: control.requestSort(columnData)

        background: Rectangle {
            color: "transparent"
            radius: 20 * MeoTheme.globalScale
            border.width: headerCell.visualFocus ? Math.max(1, Math.round(MeoTheme.globalScale)) : 0
            border.color: MeoTheme.primary

            MeoStateLayer {
                anchors.fill: parent
                radius: parent.radius
                hovered: headerCell.hovered
                pressed: headerCell.pressed
                focused: false
                focusRingEnabled: false
                color: MeoTheme.contentOnSurface
            }
        }

        contentItem: Row {
            spacing: 4 * MeoTheme.globalScale
            layoutDirection: control.isMirrored ? Qt.RightToLeft : Qt.LeftToRight

            Text {
                width: Math.max(0, headerCell.width - (sortIcon.visible ? sortIcon.width + parent.spacing : 0))
                text: headerCell.columnData.label || ""
                color: MeoTheme.contentOnSurface
                font.family: MeoTheme.typefacePlain
                font.pixelSize: MeoTheme.labelLarge.size * MeoTheme.globalScale
                font.weight: MeoTheme.labelLarge.weight
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: control.isMirrored ? Text.AlignRight : Text.AlignLeft
                elide: Text.ElideRight
            }

            MeoIcon {
                id: sortIcon
                visible: !!headerCell.columnData.sortable
                         && control.sortProperty === (headerCell.columnData.property || headerCell.columnData.role)
                icon: control.sortAscending ? "arrow_upward" : "arrow_downward"
                size: 18 * MeoTheme.globalScale
                color: MeoTheme.primary
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
