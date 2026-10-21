pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

// Touch-first Quick Settings editor modeled on the Android tile editor.
// It deliberately owns only presentation and edit gestures.  The caller owns
// the model and persists every signal through its real platform authority.
Control {
    id: control

    property var tiles: []
    property var availableTiles: []
    // Android 16's editor lays the active canvas out on four logical units;
    // a normal tile spans two units and a compact tile spans one.
    property int columns: 4
    // Row height of the edit canvas. The host passes the same shell metric the
    // live grid uses, so the editor can never drift away from the panel.
    property real rowHeight: 64 * uiScale
    property int selectedIndex: 0
    property string title: qsTr("Edit tiles")
    property string subtitle: ""
    property string availableTitle: qsTr("Available tiles")
    property bool undoEnabled: true
    property bool editingEnabled: true
    property bool showSelectionFrame: true
    function synchronizeTiles() {
        for (let i = 0; i < tiles.length; ++i) {
            const key = String(tileValue(tiles[i], "id", tileTitle(tiles[i])))
            let found = -1
            for (let j = i; j < stableTiles.count; ++j)
                if (stableTiles.get(j).tileKey === key) { found = j; break }
            if (found < 0) stableTiles.insert(i, {tileKey: key, tileData: tiles[i]})
            else {
                if (found !== i) stableTiles.move(found, i, 1)
                stableTiles.setProperty(i, "tileData", tiles[i])
            }
        }
        while (stableTiles.count > tiles.length) stableTiles.remove(stableTiles.count - 1)
        if (selectedIndex >= tiles.length) selectedIndex = -1
    }
    onTilesChanged: synchronizeTiles()
    Component.onCompleted: synchronizeTiles()
    ListModel { id: stableTiles; dynamicRoles: true }
    readonly property var catalogGroups: {
        const groups = []
        const byCategory = {}
        const added = {}
        for (const tile of tiles) added[String(tileValue(tile, "id", tileTitle(tile)))] = true
        for (const tile of tiles.concat(availableTiles)) {
            const category = String(tileValue(tile, "category", availableTitle))
            if (byCategory[category] === undefined) {
                byCategory[category] = groups.length
                groups.push({ title: category, entries: [] })
            }
            groups[byCategory[category]].entries.push({ tile: tile, alreadyAdded: added[String(tileValue(tile, "id", tileTitle(tile)))] === true })
        }
        return groups
    }
    property color containerColor: MeoTheme.surfaceContainerLow

    signal backRequested()
    signal undoRequested()
    signal tileMoved(int from, int to)
    signal tileResizeRequested(int index, int span)
    signal tileRemoveRequested(int index, var tile)
    signal tileAddRequested(int index, var tile)
    signal tileSelected(int index, var tile)

    // Reorder drag state. The editor owns the hit test so tiles never leave
    // their slot, and the target slot is highlighted while dragging.
    property int draggedTileIndex: -1
    property int dropTileIndex: -1

    readonly property int effectiveColumns: Math.max(4, columns)
    readonly property real uiScale: MeoTheme.globalScale

    function tileValue(tile, key, fallbackValue) {
        if (!tile || tile[key] === undefined || tile[key] === null)
            return fallbackValue
        return tile[key]
    }

    function tileSpan(tile) {
        return Number(tileValue(tile, "span", tileValue(tile, "tileSpan", 2))) === 1 ? 1 : 2
    }

    function tileIcon(tile) {
        return String(tileValue(tile, "iconName", tileValue(tile, "icon", "settings")))
    }

    function tileTitle(tile) {
        return String(tileValue(tile, "title", tileValue(tile, "label", "")))
    }

    function tileSubtitle(tile) {
        return String(tileValue(tile, "supportingText", tileValue(tile, "subtitle", "")))
    }

    function tilePlacement(index) {
        let row = 0
        let column = 0
        for (let i = 0; i < index; ++i) {
            const span = Math.min(effectiveColumns, tileSpan(tiles[i]))
            if (column + span > effectiveColumns) {
                ++row
                column = 0
            }
            column += span
            if (column >= effectiveColumns) {
                ++row
                column = 0
            }
        }

        const currentSpan = Math.min(effectiveColumns, tileSpan(tiles[index]))
        if (column + currentSpan > effectiveColumns) {
            ++row
            column = 0
        }
        return { "row": row, "column": column }
    }

    function tileRowCount() {
        return tiles && tiles.length > 0 ? tilePlacement(tiles.length - 1).row + 1 : 0
    }

    // Hit test for the reorder drag. The pointer arrives in scene coordinates
    // because the panel may still be resolving its own popup transform, so it
    // is mapped into the tile grid before comparing against slot geometry.
    function gridIndexAt(px, py) {
        if (!tiles || tiles.length === 0)
            return -1
        const spacing = MeoTheme.space8
        const cellWidth = tileGrid.cellWidth
        const cellHeight = control.rowHeight
        let nearest = -1
        let nearestDistance = Infinity
        for (let index = 0; index < tiles.length; ++index) {
            const placement = tilePlacement(index)
            const span = Math.min(effectiveColumns, tileSpan(tiles[index]))
            const slotX = placement.column * (cellWidth + spacing)
            const slotY = placement.row * (cellHeight + spacing)
            const slotWidth = span * cellWidth + (span - 1) * spacing
            if (px >= slotX - spacing / 2 && px <= slotX + slotWidth + spacing / 2
                    && py >= slotY - spacing / 2 && py <= slotY + cellHeight + spacing / 2)
                return index
            const centerX = slotX + slotWidth / 2
            const centerY = slotY + cellHeight / 2
            const distance = Math.pow(px - centerX, 2) + Math.pow(py - centerY, 2)
            if (distance < nearestDistance) {
                nearestDistance = distance
                nearest = index
            }
        }
        return nearest
    }

    function beginTileDrag(index) {
        draggedTileIndex = index
        dropTileIndex = index
    }

    function updateTileDrag(sceneX, sceneY) {
        if (draggedTileIndex < 0)
            return
        const local = tileGrid.mapFromItem(null, sceneX, sceneY)
        const target = gridIndexAt(local.x, local.y)
        if (target >= 0)
            dropTileIndex = target
    }

    function finishTileDrag(sceneX, sceneY) {
        if (draggedTileIndex < 0)
            return
        updateTileDrag(sceneX, sceneY)
        const from = draggedTileIndex
        const to = dropTileIndex
        draggedTileIndex = -1
        dropTileIndex = -1
        if (from >= 0 && to >= 0 && from !== to)
            control.tileMoved(from, to)
    }

    implicitWidth: 512 * uiScale
    implicitHeight: editorContent.implicitHeight
    padding: 0
    Accessible.role: Accessible.Pane
    Accessible.name: title

    background: Item {}

    contentItem: ColumnLayout {
        id: editorContent
        spacing: MeoTheme.space24

        RowLayout {
            Layout.fillWidth: true
            spacing: MeoTheme.space16

            MeoIconButton {
                // The SystemUI customizer keeps its navigation affordance in a
                // compact toolbar target. Do not use an expressive XL action
                // here: it steals the title's usable width on a 512dp editor.
                type: "standard"
                size: "s"
                icon.name: "arrow_back"
                Accessible.name: qsTr("Back")
                onClicked: control.backRequested()
            }

            MeoText {
                Layout.fillWidth: true
                text: control.title
                horizontalAlignment: Text.AlignHCenter
                typeRole: "title"
                typeSize: "medium"
                emphasized: true
                color: MeoTheme.contentOnSurface
                elide: Text.ElideRight
            }

            MeoButton {
                // Undo is a secondary editor action, analogous to the reset
                // action exposed by the SystemUI customizer toolbar.
                type: "tonal"
                size: "s"
                icon.name: ""
                objectName: "removeSelectedTile"
                text: qsTr("Remove")
                enabled: control.selectedIndex >= 0
                Accessible.name: qsTr("Remove selected tile")
                onClicked: control.tileRemoveRequested(control.selectedIndex, control.tiles[control.selectedIndex])
            }
        }

        MeoText {
            Layout.fillWidth: true
            visible: control.subtitle !== ""
            text: control.subtitle
            typeRole: "body"
            typeSize: "large"
            emphasized: true
            color: MeoTheme.contentOnSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Rectangle {
            id: selectionFrame
            objectName: "meoQuickSettingsSelectionFrame"
            Layout.fillWidth: true
            implicitHeight: tileGrid.implicitHeight + 2 * MeoTheme.space12
            color: control.containerColor
            radius: MeoTheme.shapeExtraLarge
            border.width: control.showSelectionFrame ? MeoTheme.strokeWidthMedium : 0
            border.color: MeoTheme.primary

            Item {
                id: tileGrid
                objectName: "meoQuickSettingsTileGrid"
                anchors.fill: parent
                anchors.margins: MeoTheme.space12
                readonly property real tileSpacing: MeoTheme.space8
                readonly property real cellWidth: (width - (control.effectiveColumns - 1) * tileSpacing)
                                                  / control.effectiveColumns
                implicitHeight: control.tileRowCount() * control.rowHeight
                                + Math.max(0, control.tileRowCount() - 1) * tileSpacing

                Repeater {
                    model: stableTiles

                    delegate: Item {
                        id: tileSlot
                        required property int index
                        required property var tileData
                        objectName: "meoQuickSettingsTileSlot-" + index
                        readonly property var tile: tileData || ({})
                        readonly property int span: control.tileSpan(tile)
                        readonly property var placement: control.tilePlacement(index)

                        // Keep span placement explicit. Qt's GridLayout
                        // cannot infer a delegate's desired width from its
                        // anchored child, which made equal wide tiles unequal.
                        MeoSpringValue {
                            id: slotX
                            value: 0
                            Component.onCompleted: snapValue(targetValue)
                            targetValue: tileSlot.placement.column * (tileGrid.cellWidth + tileGrid.tileSpacing)
                            speed: "fast"
                        }
                        MeoSpringValue {
                            id: slotY
                            value: 0
                            Component.onCompleted: snapValue(targetValue)
                            targetValue: tileSlot.placement.row * (tileSlot.height + tileGrid.tileSpacing)
                            speed: "fast"
                        }
                        x: slotX.value
                        y: slotY.value
                        width: span * tileGrid.cellWidth + (span - 1) * tileGrid.tileSpacing
                        height: control.rowHeight
                        implicitWidth: (span === 2 ? 196 : 94) * control.uiScale

                        // The reorder target is a hint only: the editor performs
                        // the model move on release, so nothing is dragged into
                        // this slot by Qt's drag-and-drop machinery.
                        Rectangle {
                            objectName: "meoQuickSettingsDropTarget-" + index
                            anchors.fill: parent
                            // Same shape rule as the tile itself, otherwise the
                            // hint outlines a pill with a rounded rectangle.
                            radius: tileSlot.span === 2 ? MeoTheme.shapeLarge
                                                        : MeoTheme.shapeExtraLarge
                            color: "transparent"
                            border.width: MeoTheme.strokeWidthMedium
                            border.color: MeoTheme.primary
                            opacity: 0.85
                            visible: control.editingEnabled
                                     && control.dropTileIndex === tileSlot.index
                                     && control.draggedTileIndex !== tileSlot.index
                        }

                        MeoQuickSettingsTile {
                            anchors.fill: parent
                            title: control.tileTitle(tileSlot.tile)
                            supportingText: control.tileSubtitle(tileSlot.tile)
                            iconName: control.tileIcon(tileSlot.tile)
                            active: control.tileValue(tileSlot.tile, "active", false) === true
                            enabled: control.editingEnabled && control.tileValue(tileSlot.tile, "enabled", true) !== false
                            wide: tileSlot.span === 2
                            visualStyle: "pixel"
                            editMode: true
                            removable: false
                            resizeEnabled: control.tileValue(tileSlot.tile, "resizable", true) !== false
                            editSelectable: true
                            editSelected: control.selectedIndex === tileSlot.index
                            modelIndex: tileSlot.index
                            onEditSelectionRequested: {
                                control.selectedIndex = tileSlot.index
                                control.tileSelected(tileSlot.index, tileSlot.tile)
                            }
                            onResizeRequested: control.tileResizeRequested(tileSlot.index,
                                                                             tileSlot.span === 2 ? 1 : 2)
                            onRemoveRequested: control.tileRemoveRequested(tileSlot.index, tileSlot.tile)
                            onEditDragStarted: control.beginTileDrag(tileSlot.index)
                            onEditDragMoved: function(sceneX, sceneY) { control.updateTileDrag(sceneX, sceneY) }
                            onEditDragFinished: function(sceneX, sceneY) { control.finishTileDrag(sceneX, sceneY) }
                        }
                    }
                }
            }
        }

        Repeater {
            model: control.catalogGroups
            delegate: ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: MeoTheme.space16
                MeoText {
                    Layout.fillWidth: true
                    text: parent.modelData.title
                    color: MeoTheme.contentOnSurface
                    typeRole: "title"; typeSize: "medium"; emphasized: true
                }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    uniformCellWidths: true
                    columnSpacing: MeoTheme.space8
                    rowSpacing: MeoTheme.space16
                    Repeater {
                        model: parent.parent.modelData.entries
                        delegate: Item {
                            id: availableSlot
                            required property var modelData
                            Layout.fillWidth: true
                            implicitWidth: 80 * control.uiScale
                            implicitHeight: 96 * control.uiScale
                            MeoIconButton {
                                id: addButton
                                objectName: "addTile-" + control.tileValue(availableSlot.modelData.tile, "id", "")
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Math.max(40, parent.width - MeoTheme.space8)
                                height: control.rowHeight
                                // A catalog entry is the same square unit as a
                                // compact grid tile instead of a shorter pill.
                                type: "tonal"; size: "m"
                                icon.name: control.tileIcon(availableSlot.modelData.tile)
                                enabled: control.editingEnabled && !availableSlot.modelData.alreadyAdded
                                Accessible.name: qsTr("Add %1").arg(control.tileTitle(availableSlot.modelData.tile))
                                onClicked: control.tileAddRequested(control.tileValue(availableSlot.modelData.tile, "sourceIndex", -1), availableSlot.modelData.tile)
                                MeoIcon {
                                    visible: !availableSlot.modelData.alreadyAdded
                                    // Anchor the badge to the container, not to
                                    // the full-width hit target.
                                    x: (parent.width + addButton.containerWidth - width) / 2
                                       - 4 * control.uiScale
                                    y: (parent.height - addButton.containerHeight) / 2
                                       - 4 * control.uiScale
                                    icon: "add_circle"; size: 20; color: MeoTheme.primary
                                }
                            }
                            MeoText {
                                anchors.top: parent.top
                                anchors.topMargin: control.rowHeight + MeoTheme.space8
                                width: parent.width
                                text: control.tileTitle(availableSlot.modelData.tile)
                                color: MeoTheme.contentOnSurface
                                typeRole: "body"; typeSize: "small"
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                opacity: availableSlot.modelData.alreadyAdded ? MeoTheme.disabledContentOpacity : 1
                            }
                        }
                    }
                }
            }
        }
        MeoButton {
            Layout.alignment: Qt.AlignRight
            visible: control.undoEnabled
            type: "text"; size: "s"
            text: qsTr("Undo tile changes")
            onClicked: control.undoRequested()
        }

    }
}
