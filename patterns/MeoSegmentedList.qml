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
    property bool showDividers: true
    property string separatorStyle: "gap" // gap | line | none
    property real memberGap: MeoTheme.connectedGroupGap
    property real itemSpacing: showDividers && separatorStyle === "gap" ? memberGap : 0
    property real dividerInset: 0
    property color dividerColor: separatorColor
    property real dividerOpacity: 0.28
    property int selectedIndex: -1
    property color containerColor: MeoTheme.surfaceContainerLowest
    property color separatorColor: MeoTheme.surface
    property real containerRadius: MeoTheme.connectedGroupOuterRadius
    property real innerCornerRadius: MeoTheme.connectedGroupInnerRadius
    property real horizontalInset: 0
    property color titleColor: MeoTheme.contentOnSurface
    property color subtitleColor: MeoTheme.contentOnSurfaceVariant
    property string loaderObjectNamePrefix: "meoSegmentedListItem_"
    property string itemObjectNamePrefix: ""
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

    function selectedFor(item, index) {
        return selectedIndex === index
               || (!!item && typeof item === "object" && item.selected === true)
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

    function positionFor(index) {
        const rounding = roundingFor(index)
        if (rounding === "all")
            return "only"
        if (rounding === "top")
            return "first"
        if (rounding === "bottom")
            return "last"
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
        leftPadding: control.horizontalInset
        rightPadding: control.horizontalInset
        visible: control.title !== "" || control.subtitle !== ""
        spacing: 2 * MeoTheme.globalScale

        MeoText {
            width: parent.width
            text: control.title
            visible: text !== ""
            typeRole: "title"
            typeSize: "small"
            emphasized: true
            color: control.titleColor
        }
        MeoText {
            width: parent.width
            text: control.subtitle
            visible: text !== ""
            typeRole: "body"
            typeSize: "medium"
            color: control.subtitleColor
            wrapMode: Text.WordWrap
        }
    }

    Item {
        width: parent.width
        implicitHeight: itemsColumn.implicitHeight
        visible: control.model.length > 0

        Rectangle {
            objectName: "meoSegmentedListSurface"
            anchors.fill: parent
            radius: control.containerRadius
            color: control.separatorColor
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
                    objectName: control.loaderObjectNamePrefix + index
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
                        if (item.hasOwnProperty("positionInGroup"))
                            item.positionInGroup = control.positionFor(itemLoader.index)
                        if (item.hasOwnProperty("isSegmented"))
                            item.isSegmented = control.isSegmented
                        if (item.hasOwnProperty("surfaceColor"))
                            item.surfaceColor = control.containerColor
                        if (item.hasOwnProperty("outerCornerRadius"))
                            item.outerCornerRadius = control.containerRadius
                        if (item.hasOwnProperty("innerCornerRadius"))
                            item.innerCornerRadius = control.innerCornerRadius
                        if (item.hasOwnProperty("showDivider"))
                            item.showDivider = control.showDividers
                                               && control.separatorStyle === "line"
                                               && itemLoader.index < control.model.length - 1
                        if (item.hasOwnProperty("dividerInset"))
                            item.dividerInset = control.dividerInset
                        if (item.hasOwnProperty("dividerColor"))
                            item.dividerColor = control.dividerColor
                        if (item.hasOwnProperty("dividerOpacity"))
                            item.dividerOpacity = control.dividerOpacity
                        if (item.hasOwnProperty("selected"))
                            item.selected = control.selectedFor(itemLoader.modelData, itemLoader.index)
                        if (item.hasOwnProperty("enabled"))
                            item.enabled = control.enabledFor(itemLoader.modelData)
                        if (control.itemObjectNamePrefix !== "")
                            item.objectName = control.itemObjectNamePrefix + itemLoader.index
                    }

                    onLoaded: applyListContract()
                    onWidthChanged: applyListContract()
                    onModelDataChanged: applyListContract()

                    Connections {
                        target: itemLoader.item
                        ignoreUnknownSignals: true
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

                        function onShowDividersChanged() {
                            itemLoader.applyListContract()
                        }

                        function onSeparatorStyleChanged() {
                            itemLoader.applyListContract()
                        }

                        function onDividerInsetChanged() {
                            itemLoader.applyListContract()
                        }

                        function onDividerColorChanged() {
                            itemLoader.applyListContract()
                        }

                        function onDividerOpacityChanged() {
                            itemLoader.applyListContract()
                        }

                        function onContainerColorChanged() {
                            itemLoader.applyListContract()
                        }

                        function onContainerRadiusChanged() {
                            itemLoader.applyListContract()
                        }

                        function onInnerCornerRadiusChanged() {
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
