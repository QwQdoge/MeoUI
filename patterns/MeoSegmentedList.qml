import QtQuick
import QtQuick.Controls
import MeoUI

Column {
    id: control

    property string title: ""
    property string subtitle: ""
    property var model: []
    // Custom delegates may declare optional `modelData` and `index` properties;
    // they are assigned after creation alongside the rounding contract.
    property Component delegate: null
    property bool isSegmented: true
    property real itemSpacing: 0
    property int selectedIndex: -1
    property color containerColor: MeoTheme.surfaceContainerLowest
    readonly property bool isMirrored: LayoutMirroring.enabled

    signal clicked(int index)

    function labelFor(item) {
        return item && typeof item === "object" ? (item.label || item.title || "") : String(item || "")
    }

    function supportingFor(item) {
        return item && typeof item === "object" ? (item.supportingText || item.subtitle || "") : ""
    }

    function iconFor(item) {
        return item && typeof item === "object" ? (item.icon || "") : ""
    }

    function enabledFor(item) {
        return !item || typeof item !== "object" || item.enabled === undefined ? true : item.enabled
    }

    function roundingFor(index) {
        if (model.length === 1)
            return "all"
        if (index === 0)
            return "top"
        if (index === model.length - 1)
            return "bottom"
        return "middle"
    }

    function activate(index) {
        if (index < 0 || index >= model.length || !enabledFor(model[index]))
            return false
        selectedIndex = index
        clicked(index)
        return true
    }

    width: parent ? parent.width : 420 * MeoTheme.globalScale
    spacing: 8 * MeoTheme.globalScale

    Column {
        width: parent.width
        visible: control.title !== "" || control.subtitle !== ""
        spacing: 2 * MeoTheme.globalScale

        MeoText {
            width: parent.width
            text: control.title
            visible: text !== ""
            typeRole: "title"
            typeSize: "small"
            emphasized: true
            color: MeoTheme.contentOnSurface
        }
        MeoText {
            width: parent.width
            text: control.subtitle
            visible: text !== ""
            typeRole: "body"
            typeSize: "medium"
            color: MeoTheme.contentOnSurfaceVariant
            wrapMode: Text.WordWrap
        }
    }

    Item {
        width: parent.width
        implicitHeight: itemsColumn.implicitHeight
        visible: control.model.length > 0

        Rectangle {
            anchors.fill: parent
            radius: MeoTheme.shapeLarge
            color: control.containerColor
        }

        Column {
            id: itemsColumn
            width: parent.width
            spacing: control.itemSpacing

            Repeater {
                model: control.model

                delegate: Loader {
                    id: itemLoader
                    required property int index
                    required property var modelData
                    objectName: "meoSegmentedListItem_" + index
                    width: itemsColumn.width
                    sourceComponent: control.delegate || defaultItemComponent

                    function applyListContract() {
                        if (!item)
                            return
                        item.width = itemLoader.width
                        if (item.hasOwnProperty("modelData"))
                            item.modelData = itemLoader.modelData
                        if (item.hasOwnProperty("index"))
                            item.index = itemLoader.index
                        if (item.hasOwnProperty("roundingStrategy"))
                            item.roundingStrategy = control.roundingFor(itemLoader.index)
                        if (item.hasOwnProperty("isSegmented"))
                            item.isSegmented = control.isSegmented
                        if (item.hasOwnProperty("selected"))
                            item.selected = control.selectedIndex === itemLoader.index
                        if (item.hasOwnProperty("enabled"))
                            item.enabled = control.enabledFor(itemLoader.modelData)
                    }

                    onLoaded: applyListContract()
                    onWidthChanged: applyListContract()
                    onModelDataChanged: applyListContract()

                    Connections {
                        target: itemLoader.item
                        function onClicked() {
                            control.activate(itemLoader.index)
                        }
                    }

                    Connections {
                        target: control

                        function onSelectedIndexChanged() {
                            itemLoader.applyListContract()
                        }

                        function onIsSegmentedChanged() {
                            itemLoader.applyListContract()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: defaultItemComponent
        MeoListItem {
            property var modelData: null
            property int index: -1
            headline: control.labelFor(modelData)
            supportingText: control.supportingFor(modelData)
            leadingIcon: control.iconFor(modelData)
            interactive: enabled
        }
    }
}
