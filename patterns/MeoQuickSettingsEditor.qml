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
    property int selectedIndex: -1
    property string title: qsTr("Edit tiles")
    property string subtitle: qsTr("Select tiles to rearrange and resize")
    property string availableTitle: qsTr("Available tiles")
    property bool undoEnabled: true
    property bool editingEnabled: true
    property bool showSelectionFrame: true
    property color containerColor: MeoTheme.surfaceContainerLow

    signal backRequested()
    signal undoRequested()
    signal tileMoved(int from, int to)
    signal tileResizeRequested(int index, int span)
    signal tileRemoveRequested(int index, var tile)
    signal tileAddRequested(int index, var tile)
    signal tileSelected(int index, var tile)

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
                typeRole: "title"
                typeSize: "medium"
                emphasized: true
                color: MeoTheme.contentOnSurface
                elide: Text.ElideRight
            }

            MeoButton {
                // Undo is a secondary editor action, analogous to the reset
                // action exposed by the SystemUI customizer toolbar.
                type: "text"
                size: "s"
                icon.name: "undo"
                text: qsTr("Undo")
                enabled: control.undoEnabled
                Accessible.name: qsTr("Undo tile changes")
                onClicked: control.undoRequested()
            }
        }

        MeoText {
            Layout.fillWidth: true
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
                implicitHeight: control.tileRowCount() * 80 * control.uiScale
                                + Math.max(0, control.tileRowCount() - 1) * tileSpacing

                Repeater {
                    model: control.tiles

                    delegate: Item {
                        id: tileSlot
                        required property int index
                        required property var modelData
                        objectName: "meoQuickSettingsTileSlot-" + index
                        readonly property var tile: modelData || ({})
                        readonly property int span: control.tileSpan(tile)
                        readonly property var placement: control.tilePlacement(index)

                        // Keep span placement explicit. Qt's GridLayout
                        // cannot infer a delegate's desired width from its
                        // anchored child, which made equal wide tiles unequal.
                        x: placement.column * (tileGrid.cellWidth + tileGrid.tileSpacing)
                        y: placement.row * (height + tileGrid.tileSpacing)
                        width: span * tileGrid.cellWidth + (span - 1) * tileGrid.tileSpacing
                        height: 80 * control.uiScale
                        implicitWidth: (span === 2 ? 224 : 108) * control.uiScale

                        DropArea {
                            anchors.fill: parent
                            enabled: control.editingEnabled
                            onEntered: function(drag) {
                                const from = drag.source ? drag.source.modelIndex : -1
                                if (from >= 0 && from !== tileSlot.index)
                                    control.tileMoved(from, tileSlot.index)
                            }
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
                            removable: control.tileValue(tileSlot.tile, "removable", true) !== false
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
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: control.availableTiles && control.availableTiles.length > 0
            spacing: MeoTheme.space12

            MeoText {
                Layout.fillWidth: true
                text: control.availableTitle
                typeRole: "title"
                typeSize: "small"
                emphasized: true
                color: MeoTheme.contentOnSurface
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space8

                Repeater {
                    model: control.availableTiles

                    delegate: MeoButton {
                        required property int index
                        required property var modelData
                        readonly property var tile: modelData || ({})

                        type: "tonal"
                        size: "s"
                        icon.name: "add"
                        text: control.tileTitle(tile)
                        enabled: control.editingEnabled
                                 && control.tileValue(tile, "enabled", true) !== false
                        Accessible.name: qsTr("Add %1").arg(control.tileTitle(tile))
                        onClicked: control.tileAddRequested(index, tile)
                    }
                }
            }
        }
    }
}
