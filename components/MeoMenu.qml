import QtQuick
import QtQuick.Controls
import MeoUI

MeoMotionPopup {
    id: control
    presentation: MeoMotionPopup.Menu

    // Entries support: label/text, icon, supportingText, shortcut/trailingText,
    // trailingIcon, checked, selected, enabled, action, subItems, vibrant,
    // and type (item, label, separator).
    property var model: []
    property bool vibrant: false
    property real itemSpacing: 0
    property real menuPadding: 8 * themeGlobalScale
    property real menuHorizontalInset: 4 * themeGlobalScale
    property real itemHeight: 48 * themeGlobalScale
    property real supportingItemHeight: 64 * themeGlobalScale
    property real minimumMenuWidth: 112 * themeGlobalScale
    property real maximumMenuWidth: 320 * themeGlobalScale
    property real preferredMenuWidth: 240 * themeGlobalScale
    property int currentIndex: -1
    property int submenuDelay: MeoTheme.reduceMotion ? 0 : 120
    property var parentMenu: null
    signal submenuRequested(int index, var item, Item anchor)

    // Standard and vibrant vertical-menu color roles follow AndroidX Compose
    // Material3 StandardMenuTokens and VibrantMenuTokens (Apache-2.0, commit
    // 9df4d001962d58aabca222967b8ceb1789acb960).
    // This is a token mapping; no upstream implementation code is copied.
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeTertiaryContainer: MeoTheme.tertiaryContainer
    readonly property color themeOnTertiaryContainer: MeoTheme.contentOnTertiaryContainer
    readonly property color themeTertiary: MeoTheme.tertiary
    readonly property color themeOnTertiary: MeoTheme.contentOnTertiary
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeSecondary: MeoTheme.secondary
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real menuWidth: Math.max(minimumMenuWidth,
                                               Math.min(maximumMenuWidth, preferredMenuWidth))
    readonly property bool submenuOpened: submenu.opened

    // Keep public `model` compatible with both JavaScript arrays and QML
    // ListModel instances. Repeater accepts both, so the imperative paths
    // below must use the same abstraction rather than indexing arrays only.
    function modelCount(entries) {
        if (!entries)
            return 0
        if (typeof entries.count === "number")
            return entries.count
        return typeof entries.length === "number" ? entries.length : 0
    }

    function modelItem(entries, index) {
        if (index < 0 || index >= modelCount(entries))
            return null
        return entries && typeof entries.get === "function" ? entries.get(index) : entries[index]
    }

    function itemLabel(item) {
        return item && typeof item === "object" ? (item.label || item.text || "") : String(item || "")
    }

    function itemSupportingText(item) {
        return item && typeof item === "object" ? (item.supportingText || "") : ""
    }

    function itemShortcut(item) {
        return item && typeof item === "object" ? (item.shortcut || item.trailingText || "") : ""
    }

    function itemEnabled(item) {
        return !item || typeof item !== "object" || item.enabled !== false
    }

    function itemHasSubmenu(item) {
        return !!(item && typeof item === "object" && modelCount(item.subItems) > 0)
    }

    function itemType(item) {
        return item && typeof item === "object" ? item.type || "item" : "item"
    }

    function itemIsSelectable(item) {
        return itemType(item) === "item" && itemEnabled(item)
    }

    function itemVisualHeight(item) {
        if (itemType(item) === "separator")
            return Math.max(9 * themeGlobalScale, 1)
        if (itemType(item) === "label")
            return 32 * themeGlobalScale
        return itemSupportingText(item) === "" ? itemHeight : supportingItemHeight
    }

    function menuContentHeight(items) {
        const entries = items || []
        const count = modelCount(entries)
        let total = menuPadding * 2
        for (let index = 0; index < count; ++index) {
            total += itemVisualHeight(modelItem(entries, index))
            if (index < count - 1)
                total += itemSpacing
        }
        return total
    }

    function itemUsesVibrantSelection(item, inheritedVibrant) {
        return !!(vibrant || inheritedVibrant || (item && typeof item === "object" && (item.vibrant || item.isVibrant)))
    }

    function itemIsSelected(item) {
        return !!(item && typeof item === "object" && (item.selected || item.checked))
    }

    function rowContainerColor(item, inheritedVibrant) {
        if (!itemIsSelected(item))
            return "transparent"
        return itemUsesVibrantSelection(item, inheritedVibrant) ? themeTertiary : themeTertiaryContainer
    }

    function rowContentColor(item, inheritedVibrant) {
        if (itemIsSelected(item))
            return itemUsesVibrantSelection(item, inheritedVibrant) ? themeOnTertiary : themeOnTertiaryContainer
        return itemUsesVibrantSelection(item, inheritedVibrant) ? themeOnTertiaryContainer : themeOnSurface
    }

    function rowIconColor(item, inheritedVibrant) {
        if (itemIsSelected(item))
            return rowContentColor(item, inheritedVibrant)
        return itemUsesVibrantSelection(item, inheritedVibrant) ? themeOnTertiaryContainer : themeOnSurfaceVariant
    }

    function rowSupportingContentColor(item, inheritedVibrant) {
        if (itemIsSelected(item))
            return rowContentColor(item, inheritedVibrant)
        return itemUsesVibrantSelection(item, inheritedVibrant) ? themeOnTertiaryContainer : themeOnSurfaceVariant
    }

    function focusMenuItem(startIndex, direction) {
        if (menuRepeater.count <= 0)
            return false
        const directionValue = direction < 0 ? -1 : 1
        let candidate = startIndex
        for (let attempt = 0; attempt < menuRepeater.count; ++attempt) {
            candidate = (candidate + directionValue + menuRepeater.count) % menuRepeater.count
            const loader = menuRepeater.itemAt(candidate)
            if (loader && loader.selectable && loader.item) {
                currentIndex = candidate
                loader.item.forceActiveFocus(Qt.PopupFocusReason)
                return true
            }
        }
        return false
    }

    function menuItemAt(index) {
        const loader = menuRepeater.itemAt(index)
        return loader && loader.item ? loader.item : null
    }

    function openAt(anchor, offsetX, offsetY) {
        if (anchor) {
            const point = anchor.mapToItem(control.parent, offsetX || 0, offsetY || 0)
            control.x = point.x
            control.y = point.y
        }
        control.openFrom(anchor)
    }

    function openSubmenu(index, item, anchor) {
        if (!itemHasSubmenu(item))
            return false
        submenuTimer.stop()
        submenu.model = item.subItems
        submenu.vibrant = vibrant || !!item.vibrant
        submenu.parentMenu = control
        submenu.focusReturnItem = anchor || null
        // The Overlay attached property is populated only after this Popup is
        // opened. Keep the anchor until then; MeoMotionPopup will position it
        // into the window overlay in onAboutToShow.
        submenu.placementAnchor = anchor || null
        submenu.placementMirrored = control.mirrored
        submenu.open()
        submenuRequested(index, item, anchor)
        return true
    }

    function scheduleSubmenu(index, item, anchor) {
        if (!itemHasSubmenu(item))
            return
        submenuTimer.pendingIndex = index
        submenuTimer.pendingItem = item
        submenuTimer.pendingAnchor = anchor
        submenuTimer.restart()
    }

    function cancelScheduledSubmenu() {
        submenuTimer.stop()
    }

    function closeSubmenu() {
        if (submenu.opened || submenu.visible)
            submenu.close()
    }

    function activateItem(index, anchor) {
        const item = modelItem(model, index)
        if (!item)
            return false
        if (!itemIsSelectable(item))
            return false
        if (itemHasSubmenu(item))
            return openSubmenu(index, item, anchor)
        if (item.action)
            item.action()
        close()
        return true
    }

    width: menuWidth
    implicitWidth: menuWidth
    // QML Column does not include Repeater delegates in implicitHeight on all
    // supported Qt 6 versions. Keep popup geometry explicit so its surface
    // and viewport clamp include every menu row.
    implicitHeight: menuContentHeight(model)
    padding: 0
    initialFocusItem: contentColumn
    onOpened: Qt.callLater(function() { focusMenuItem(-1, 1) })
    onClosed: {
        submenuTimer.stop()
        closeSubmenu()
    }

    background: Rectangle {
        color: control.vibrant ? control.themeTertiaryContainer : control.themeSurfaceContainerLow
        radius: MeoTheme.shapeLarge
        border.width: 1 * control.themeGlobalScale
        border.color: Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.20)
    }

    contentItem: Column {
        id: contentColumn
        width: control.availableWidth
        spacing: control.itemSpacing
        topPadding: control.menuPadding
        bottomPadding: control.menuPadding
        focus: true

        Keys.onDownPressed: control.focusMenuItem(control.currentIndex, 1)
        Keys.onUpPressed: control.focusMenuItem(control.currentIndex, -1)
        Keys.onRightPressed: {
            const loader = menuRepeater.itemAt(control.currentIndex)
            if (loader && loader.item && loader.item.hasSubmenu)
                control.openSubmenu(control.currentIndex, control.modelItem(control.model, control.currentIndex), loader.item)
        }
        Keys.onLeftPressed: if (control.parentMenu) control.close()
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Home) {
                control.focusMenuItem(-1, 1)
                event.accepted = true
            } else if (event.key === Qt.Key_End) {
                control.focusMenuItem(0, -1)
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                const loader = menuRepeater.itemAt(control.currentIndex)
                if (loader && loader.item)
                    control.activateItem(control.currentIndex, loader.item)
                event.accepted = true
            }
        }

        Repeater {
            id: menuRepeater
            model: control.model

            delegate: Loader {
                width: contentColumn.width
                property bool selectable: control.itemIsSelectable(modelData)
                sourceComponent: control.itemType(modelData) === "separator" ? separatorComponent
                                 : control.itemType(modelData) === "label" ? labelComponent
                                                                           : itemComponent

                Component {
                    id: separatorComponent
                    Item {
                        width: contentColumn.width
                        height: Math.max(9 * control.themeGlobalScale, 1 * control.themeGlobalScale)
                        MeoDivider {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: control.menuHorizontalInset + 8 * control.themeGlobalScale
                            anchors.rightMargin: control.menuHorizontalInset + 8 * control.themeGlobalScale
                            color: control.themeOutlineVariant
                        }
                    }
                }

                Component {
                    id: labelComponent
                    Item {
                        width: contentColumn.width
                        height: 32 * control.themeGlobalScale
                        MeoText {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: control.menuHorizontalInset + 12 * control.themeGlobalScale
                            anchors.rightMargin: control.menuHorizontalInset + 12 * control.themeGlobalScale
                            text: control.itemLabel(modelData)
                            typeRole: "label"
                            typeSize: "medium"
                            color: control.vibrant ? control.themeOnTertiaryContainer : control.themeOnSurfaceVariant
                            elide: Text.ElideRight
                        }
                    }
                }

                Component {
                    id: itemComponent
                    FocusScope {
                        id: optionRow
                        objectName: "meoMenuItem_" + index
                        readonly property bool hasSubmenu: control.itemHasSubmenu(modelData)
                        readonly property bool selected: control.itemIsSelected(modelData)
                        readonly property bool vibrantSelection: control.itemUsesVibrantSelection(modelData)
                        readonly property color contentColor: control.rowContentColor(modelData)
                        readonly property color iconColor: control.rowIconColor(modelData)
                        width: contentColumn.width
                        height: control.itemSupportingText(modelData) === "" ? control.itemHeight : control.supportingItemHeight
                        activeFocusOnTab: control.itemIsSelectable(modelData)
                        enabled: control.itemEnabled(modelData)
                        opacity: enabled ? 1.0 : 0.38
                        Accessible.role: Accessible.MenuItem
                        Accessible.name: control.itemLabel(modelData)
                        Accessible.description: control.itemSupportingText(modelData)
                        Accessible.focusable: control.itemIsSelectable(modelData)
                        Accessible.onPressAction: control.activateItem(index, optionRow)

                        Keys.onReturnPressed: control.activateItem(index, optionRow)
                        Keys.onEnterPressed: control.activateItem(index, optionRow)
                        Keys.onSpacePressed: control.activateItem(index, optionRow)
                        Keys.onRightPressed: if (hasSubmenu) control.openSubmenu(index, modelData, optionRow)
                        Keys.onLeftPressed: if (control.parentMenu) control.close()

                        Rectangle {
                            id: rowSurface
                            anchors.fill: parent
                            anchors.leftMargin: control.menuHorizontalInset
                            anchors.rightMargin: control.menuHorizontalInset
                            radius: optionRow.selected ? MeoTheme.shapeMedium : MeoTheme.shapeExtraSmall
                            color: control.rowContainerColor(modelData)
                            border.width: optionRow.activeFocus ? Math.max(2 * control.themeGlobalScale, 1) : 0
                            border.color: control.themeSecondary

                            Behavior on color {
                                enabled: !MeoTheme.reduceMotion
                                ColorAnimation { duration: MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasized }
                            }

                            MeoStateLayer {
                                anchors.fill: parent
                                pressed: itemPointer.pressed
                                hovered: itemPointer.containsMouse
                                focused: optionRow.activeFocus
                                focusRingEnabled: false
                                pressX: itemPointer.mouseX
                                pressY: itemPointer.mouseY
                                radius: rowSurface.radius
                                color: optionRow.contentColor
                            }
                        }

                        MouseArea {
                            id: itemPointer
                            anchors.fill: parent
                            anchors.leftMargin: control.menuHorizontalInset
                            anchors.rightMargin: control.menuHorizontalInset
                            enabled: optionRow.enabled
                            hoverEnabled: true
                            onEntered: {
                                optionRow.forceActiveFocus(Qt.MouseFocusReason)
                                if (optionRow.hasSubmenu)
                                    control.scheduleSubmenu(index, modelData, optionRow)
                            }
                            onExited: if (optionRow.hasSubmenu) control.cancelScheduledSubmenu()
                            onClicked: control.activateItem(index, optionRow)
                        }

                        Row {
                            anchors.fill: rowSurface
                            anchors.leftMargin: 12 * control.themeGlobalScale
                            anchors.rightMargin: 12 * control.themeGlobalScale
                            spacing: 12 * control.themeGlobalScale
                            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

                            MeoIcon {
                                id: leadingIcon
                                width: visible ? 24 * control.themeGlobalScale : 0
                                anchors.verticalCenter: parent.verticalCenter
                                icon: modelData.checked ? "check" : (modelData.icon || "")
                                size: 20 * control.themeGlobalScale
                                color: optionRow.iconColor
                                visible: icon !== ""
                            }

                            Column {
                                width: parent.width - leadingIcon.width - (leadingIcon.visible ? parent.spacing : 0) - trailingRow.width - (trailingRow.visible ? parent.spacing : 0)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2 * control.themeGlobalScale

                                MeoText {
                                    width: parent.width
                                    text: control.itemLabel(modelData)
                                    typeRole: "label"
                                    typeSize: "large"
                                    color: optionRow.contentColor
                                    elide: Text.ElideRight
                                }
                                MeoText {
                                    width: parent.width
                                    text: control.itemSupportingText(modelData)
                                    typeRole: "body"
                                    typeSize: "small"
                                    color: control.rowSupportingContentColor(modelData)
                                    visible: text !== ""
                                    elide: Text.ElideRight
                                }
                            }

                            Row {
                                id: trailingRow
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8 * control.themeGlobalScale
                                visible: control.itemShortcut(modelData) !== "" || !!modelData.trailingIcon || optionRow.hasSubmenu
                                layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

                                MeoText {
                                    text: control.itemShortcut(modelData)
                                    typeRole: "label"
                                    typeSize: "small"
                                    color: control.rowIconColor(modelData)
                                    visible: text !== ""
                                }
                                MeoIcon {
                                    icon: optionRow.hasSubmenu ? (control.mirrored ? "chevron_left" : "chevron_right") : (modelData.trailingIcon || "")
                                    size: 20 * control.themeGlobalScale
                                    color: optionRow.iconColor
                                    visible: icon !== ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: submenuTimer
        property int pendingIndex: -1
        property var pendingItem: null
        property Item pendingAnchor: null
        interval: control.submenuDelay
        repeat: false
        onTriggered: control.openSubmenu(pendingIndex, pendingItem, pendingAnchor)
    }

    MeoMotionPopup {
        id: submenu
        // Keep child menus in the window overlay, not in an arbitrary layout
        // that happens to own the parent menu. This also gives viewport
        // clamping the real window dimensions.
        parent: Overlay.overlay
        presentation: MeoMotionPopup.Menu
        property var model: []
        property bool vibrant: false
        property var parentMenu: control
        property Item placementAnchor: null
        property bool placementMirrored: false
        property int currentIndex: -1
        z: control.z + 1
        width: control.menuWidth
        implicitWidth: control.menuWidth
        implicitHeight: control.menuContentHeight(model)
        padding: 0

        function positionForAnchor() {
            if (!placementAnchor || !parent)
                return false
            // Popup content is reparented into the window overlay while open.
            // Mapping through global coordinates is stable across an offset
            // layout host, and `parent` now has the overlay's viewport size.
            const globalPoint = placementAnchor.mapToGlobal(0, 0)
            const point = parent.mapFromGlobal(globalPoint.x, globalPoint.y)
            const popupWidth = Math.max(width, implicitWidth)
            const popupHeight = Math.max(height, implicitHeight, control.menuContentHeight(model))
            const preferredX = placementMirrored ? point.x - popupWidth - 4 * control.themeGlobalScale
                                  : point.x + placementAnchor.width + 4 * control.themeGlobalScale
            const maximumX = Math.max(viewportMargin, parent.width - popupWidth - viewportMargin)
            const maximumY = Math.max(viewportMargin, parent.height - popupHeight - viewportMargin)
            x = Math.max(viewportMargin, Math.min(preferredX, maximumX))
            y = Math.max(viewportMargin, Math.min(point.y, maximumY))
            return true
        }

        function focusMenuItem(startIndex, direction) {
            if (submenuRepeater.count <= 0)
                return false
            const directionValue = direction < 0 ? -1 : 1
            let candidate = startIndex
            for (let attempt = 0; attempt < submenuRepeater.count; ++attempt) {
                candidate = (candidate + directionValue + submenuRepeater.count) % submenuRepeater.count
                const item = submenuRepeater.itemAt(candidate)
                if (item && item.selectable) {
                    currentIndex = candidate
                    item.forceActiveFocus(Qt.PopupFocusReason)
                    return true
                }
            }
            return false
        }

        function menuItemAt(index) {
            return submenuRepeater.itemAt(index)
        }

        function activateItem(index, anchor) {
            const item = control.modelItem(model, index)
            if (!control.itemIsSelectable(item))
                return false
            if (item.action)
                item.action()
            close()
            control.close()
            return true
        }

        onAboutToShow: positionForAnchor()
        onOpened: Qt.callLater(function() {
            // A delegate column can report its final implicit height on the
            // frame after opening. Reposition then, before a person can act
            // on the menu, so the bottom edge is still within the viewport.
            submenuPlacementTimer.restart()
            submenuColumn.forceActiveFocus(Qt.PopupFocusReason)
            submenu.focusMenuItem(-1, 1)
        })

        Timer {
            id: submenuPlacementTimer
            interval: 16
            repeat: false
            onTriggered: submenu.positionForAnchor()
        }

        background: Rectangle {
            color: submenu.vibrant ? control.themeTertiaryContainer : control.themeSurfaceContainerLow
            radius: MeoTheme.shapeLarge
            border.width: control.themeGlobalScale
            border.color: Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.20)
        }

        contentItem: Column {
            id: submenuColumn
            width: submenu.availableWidth
            topPadding: control.menuPadding
            bottomPadding: control.menuPadding
            spacing: control.itemSpacing
            focus: true

            Keys.onDownPressed: submenu.focusMenuItem(submenu.currentIndex, 1)
            Keys.onUpPressed: submenu.focusMenuItem(submenu.currentIndex, -1)
            Keys.onLeftPressed: submenu.close()
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Home) {
                    submenu.focusMenuItem(-1, 1)
                    event.accepted = true
                } else if (event.key === Qt.Key_End) {
                    submenu.focusMenuItem(0, -1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    submenu.activateItem(submenu.currentIndex, submenu.menuItemAt(submenu.currentIndex))
                    event.accepted = true
                }
            }

            Repeater {
                id: submenuRepeater
                model: submenu.model
                delegate: FocusScope {
                    id: submenuOptionRow
                    readonly property bool selectable: control.itemIsSelectable(modelData)
                    readonly property bool selected: control.itemIsSelected(modelData)
                    readonly property color contentColor: control.rowContentColor(modelData, submenu.vibrant)
                    readonly property color iconColor: control.rowIconColor(modelData, submenu.vibrant)
                    width: submenuColumn.width
                    height: control.itemType(modelData) === "separator" ? Math.max(9 * control.themeGlobalScale, 1)
                           : control.itemType(modelData) === "label" ? 32 * control.themeGlobalScale
                           : control.itemSupportingText(modelData) === "" ? control.itemHeight : control.supportingItemHeight
                    activeFocusOnTab: selectable
                    enabled: control.itemEnabled(modelData)
                    opacity: enabled ? 1.0 : 0.38
                    Accessible.role: Accessible.MenuItem
                    Accessible.name: control.itemLabel(modelData)
                    Accessible.description: control.itemSupportingText(modelData)
                    Accessible.focusable: selectable
                    Accessible.onPressAction: submenu.activateItem(index, submenuOptionRow)

                    Keys.onReturnPressed: submenu.activateItem(index, submenuOptionRow)
                    Keys.onEnterPressed: submenu.activateItem(index, submenuOptionRow)
                    Keys.onSpacePressed: submenu.activateItem(index, submenuOptionRow)
                    Keys.onLeftPressed: submenu.close()

                    MeoDivider {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: control.menuHorizontalInset + 8 * control.themeGlobalScale
                        anchors.rightMargin: control.menuHorizontalInset + 8 * control.themeGlobalScale
                        color: control.themeOutlineVariant
                        visible: control.itemType(modelData) === "separator"
                    }

                    MeoText {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: control.menuHorizontalInset + 12 * control.themeGlobalScale
                        anchors.rightMargin: control.menuHorizontalInset + 12 * control.themeGlobalScale
                        text: control.itemLabel(modelData)
                        typeRole: "label"
                        typeSize: "medium"
                        color: submenu.vibrant ? control.themeOnTertiaryContainer : control.themeOnSurfaceVariant
                        visible: control.itemType(modelData) === "label"
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        id: submenuRowSurface
                        anchors.fill: parent
                        anchors.leftMargin: control.menuHorizontalInset
                        anchors.rightMargin: control.menuHorizontalInset
                        radius: control.itemIsSelected(modelData) ? MeoTheme.shapeMedium : MeoTheme.shapeExtraSmall
                        color: control.rowContainerColor(modelData, submenu.vibrant)
                        border.width: submenuOptionRow.activeFocus ? Math.max(2 * control.themeGlobalScale, 1) : 0
                        border.color: control.themeSecondary
                        visible: control.itemType(modelData) === "item"

                        MeoStateLayer {
                            anchors.fill: parent
                            pressed: submenuPointer.pressed
                            hovered: submenuPointer.containsMouse
                            focused: submenuOptionRow.activeFocus
                            focusRingEnabled: false
                            radius: submenuRowSurface.radius
                            color: submenuOptionRow.contentColor
                        }
                    }

                    MouseArea {
                        id: submenuPointer
                        anchors.fill: parent
                        anchors.leftMargin: control.menuHorizontalInset
                        anchors.rightMargin: control.menuHorizontalInset
                        enabled: submenuOptionRow.selectable
                        hoverEnabled: true
                        onEntered: submenuOptionRow.forceActiveFocus(Qt.MouseFocusReason)
                        onClicked: {
                            submenu.activateItem(index, submenuOptionRow)
                        }
                    }

                    Row {
                        anchors.fill: submenuRowSurface
                        anchors.leftMargin: 12 * control.themeGlobalScale
                        anchors.rightMargin: 12 * control.themeGlobalScale
                        spacing: 12 * control.themeGlobalScale
                        visible: control.itemType(modelData) === "item"
                        layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

                        MeoIcon {
                            id: submenuLeadingIcon
                            width: visible ? 24 * control.themeGlobalScale : 0
                            anchors.verticalCenter: parent.verticalCenter
                            icon: modelData.checked ? "check" : (modelData.icon || "")
                            size: 20 * control.themeGlobalScale
                            color: submenuOptionRow.iconColor
                            visible: icon !== ""
                        }
                        Column {
                            width: parent.width - submenuLeadingIcon.width - (submenuLeadingIcon.visible ? parent.spacing : 0) - submenuTrailingRow.width - (submenuTrailingRow.visible ? parent.spacing : 0)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2 * control.themeGlobalScale
                            MeoText {
                                width: parent.width
                                text: control.itemLabel(modelData)
                                typeRole: "label"
                                typeSize: "large"
                                color: submenuOptionRow.contentColor
                                elide: Text.ElideRight
                            }
                            MeoText {
                                width: parent.width
                                text: control.itemSupportingText(modelData)
                                typeRole: "body"
                                typeSize: "small"
                                color: control.rowSupportingContentColor(modelData, submenu.vibrant)
                                visible: text !== ""
                                elide: Text.ElideRight
                            }
                        }
                        Row {
                            id: submenuTrailingRow
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8 * control.themeGlobalScale
                            visible: control.itemShortcut(modelData) !== "" || !!modelData.trailingIcon
                            MeoText {
                                text: control.itemShortcut(modelData)
                                typeRole: "label"
                                typeSize: "small"
                                color: submenuOptionRow.iconColor
                                visible: text !== ""
                            }
                            MeoIcon {
                                icon: modelData.trailingIcon || ""
                                size: 20 * control.themeGlobalScale
                                color: control.rowSupportingContentColor(modelData, submenu.vibrant)
                                visible: icon !== ""
                            }
                        }
                    }
                }
            }
        }
    }
}
