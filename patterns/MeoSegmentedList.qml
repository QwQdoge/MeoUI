import QtQuick
import QtQuick.Controls
import QtQuick.Window
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

    // Large Settings models used to instantiate every MeoSettingsRow at once.
    // That is cheap for ordinary 4-10 row groups but can freeze the UI for
    // seconds when an application/package list contains hundreds or thousands
    // of entries. Keep the small-list contract unchanged and virtualize only
    // genuinely large models.
    property int virtualizationThreshold: 24
    property real preloadMargin: 900 * MeoTheme.globalScale
    property real unloadMargin: 1800 * MeoTheme.globalScale
    property real estimatedItemHeight: 76 * MeoTheme.globalScale
    property bool virtualizationEnabled: model && model.length > virtualizationThreshold
    property int viewportEpoch: 0

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

    function itemAt(index) {
        // Preserve the long-standing public contract: callers receive the
        // delegate Loader and can inspect `.item`, focus it, or query its
        // accessibility state. Virtualization changes Loader activity, not the
        // shape of the API.
        return itemRepeater.itemAt(index)
    }

    width: parent ? parent.width : 420 * MeoTheme.globalScale
    spacing: 8 * MeoTheme.globalScale

    // One inexpensive heartbeat per large group is enough to observe scene
    // movement caused by an ancestor Flickable. mapToItem() itself is not a
    // QML binding dependency, so without this epoch a far-away Loader would not
    // necessarily notice that scrolling brought it near the viewport.
    Timer {
        interval: 120
        repeat: true
        running: control.visible && control.virtualizationEnabled
        onTriggered: control.viewportEpoch += 1
    }

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
                id: itemRepeater
                model: control.model

                delegate: Loader {
                    id: itemLoader
                    required property int index
                    required property var modelData
                    property real cachedHeight: control.estimatedItemHeight
                    property bool wasLoaded: false
                    property bool nearViewport: true

                    objectName: control.loaderObjectNamePrefix + index
                    width: itemsColumn.width
                    height: item ? Math.max(item.implicitHeight, 1) : Math.max(cachedHeight, 1)
                    asynchronous: control.virtualizationEnabled
                    active: !control.virtualizationEnabled || nearViewport
                    sourceComponent: control.delegate || defaultItemComponent

                    function updateViewportState() {
                        // Read the epoch explicitly so this function is invoked
                        // when an ancestor Flickable scrolls even though the
                        // delegate's local y does not change.
                        const epoch = control.viewportEpoch
                        if (!control.virtualizationEnabled) {
                            nearViewport = true
                            return
                        }

                        const windowObject = itemLoader.Window.window
                        if (!windowObject || !windowObject.visible) {
                            // During tests/offscreen construction retain the
                            // historic eager behavior so contracts stay stable.
                            nearViewport = true
                            return
                        }

                        const scenePoint = itemLoader.mapToItem(null, 0, 0)
                        const top = scenePoint.y
                        const bottom = top + Math.max(itemLoader.height, control.estimatedItemHeight)
                        const margin = itemLoader.wasLoaded ? control.unloadMargin : control.preloadMargin
                        nearViewport = bottom >= -margin && top <= windowObject.height + margin
                    }

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

                    Component.onCompleted: updateViewportState()
                    onLoaded: {
                        applyListContract()
                        wasLoaded = true
                        if (item && item.implicitHeight > 0)
                            cachedHeight = item.implicitHeight
                    }
                    onWidthChanged: applyListContract()
                    onModelDataChanged: applyListContract()

                    Connections {
                        target: control
                        function onViewportEpochChanged() {
                            itemLoader.updateViewportState()
                        }
                    }

                    Connections {
                        target: itemLoader.item
                        ignoreUnknownSignals: true
                        function onClicked() {
                            control.activate(itemLoader.index)
                        }
                        function onImplicitHeightChanged() {
                            if (itemLoader.item && itemLoader.item.implicitHeight > 0)
                                itemLoader.cachedHeight = itemLoader.item.implicitHeight
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
            isSegmented: control.isSegmented
            headline: control.labelFor(modelData)
            supportingText: control.supportingFor(modelData)
            leadingIcon: control.iconFor(modelData)
            interactive: enabled
        }
    }
}
