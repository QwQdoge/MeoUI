pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property string label: ""
    property var model: []
    property string textRole: ""
    property string valueRole: ""
    property string text: ""
    property int currentIndex: -1
    property var currentValue
    property bool isError: false
    property string errorText: ""
    property string type: "filled"

    signal selected(int index, string value)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int optionCount: model && model.length !== undefined ? model.length : 0
    readonly property bool opened: menu.opened
    readonly property int highlightedIndex: optionList.currentIndex
    property bool _synchronizingSelection: false

    implicitWidth: 280 * themeGlobalScale
    implicitHeight: textField.implicitHeight
    activeFocusOnTab: enabled
    Accessible.role: Accessible.ComboBox
    Accessible.name: label
    Accessible.description: {
        const state = menu.opened ? qsTr("Expanded") : qsTr("Collapsed")
        const value = text !== "" ? text : qsTr("No selection")
        const error = isError && errorText !== "" ? ". " + errorText : ""
        return value + ". " + state + error
    }
    Accessible.focusable: enabled
    Accessible.readOnly: true
    Accessible.onPressAction: toggleMenu()
    Accessible.onIncreaseAction: moveSelection(1)
    Accessible.onDecreaseAction: moveSelection(-1)

    onTextChanged: syncIndexFromText()
    onModelChanged: syncIndexFromText()
    onCurrentIndexChanged: syncSelectionFromIndex()
    onCurrentValueChanged: syncIndexFromValue()
    Component.onCompleted: {
        if (currentValue !== undefined)
            syncIndexFromValue()
        else
            syncIndexFromText()
    }

    function optionText(index) {
        if (index < 0 || index >= optionCount)
            return ""
        const option = model[index]
        if (option === undefined || option === null)
            return ""
        if (textRole !== "" && typeof option === "object")
            return String(option[textRole] === undefined ? "" : option[textRole])
        return String(option)
    }

    function optionValue(index) {
        if (index < 0 || index >= optionCount)
            return undefined
        const option = model[index]
        if (valueRole !== "" && option && typeof option === "object")
            return option[valueRole]
        return option
    }

    function indexOfText(value) {
        for (let index = 0; index < optionCount; ++index) {
            if (optionText(index) === value)
                return index
        }
        return -1
    }

    function syncIndexFromText() {
        if (_synchronizingSelection)
            return
        _synchronizingSelection = true
        currentIndex = indexOfText(text)
        currentValue = currentIndex >= 0 ? optionValue(currentIndex) : undefined
        _synchronizingSelection = false
    }

    function syncSelectionFromIndex() {
        if (_synchronizingSelection || currentIndex < 0 || currentIndex >= optionCount)
            return
        _synchronizingSelection = true
        text = optionText(currentIndex)
        currentValue = optionValue(currentIndex)
        _synchronizingSelection = false
    }

    function syncIndexFromValue() {
        if (_synchronizingSelection || currentValue === undefined)
            return
        _synchronizingSelection = true
        let match = -1
        for (let index = 0; index < optionCount; ++index) {
            if (optionValue(index) === currentValue) {
                match = index
                break
            }
        }
        currentIndex = match
        text = match >= 0 ? optionText(match) : ""
        _synchronizingSelection = false
    }

    function selectIndex(index) {
        if (index < 0 || index >= optionCount)
            return
        const value = optionText(index)
        _synchronizingSelection = true
        currentIndex = index
        text = value
        currentValue = optionValue(index)
        _synchronizingSelection = false
        selected(index, value)
    }

    function moveSelection(offset) {
        if (!enabled || optionCount === 0)
            return
        let target = currentIndex
        if (target < 0)
            target = offset > 0 ? 0 : optionCount - 1
        else
            target = Math.max(0, Math.min(optionCount - 1, target + offset))
        if (target !== currentIndex)
            selectIndex(target)
    }

    function moveHighlight(offset) {
        if (optionCount === 0)
            return
        let target = optionList.currentIndex
        if (target < 0)
            target = offset > 0 ? 0 : optionCount - 1
        else
            target = Math.max(0, Math.min(optionCount - 1, target + offset))
        optionList.currentIndex = target
        optionList.positionViewAtIndex(target, ListView.Contain)
    }

    function activateHighlighted() {
        if (optionList.currentIndex < 0)
            return
        selectIndex(optionList.currentIndex)
        menu.close()
    }

    function openMenu() {
        if (!enabled)
            return
        forceActiveFocus(Qt.ShortcutFocusReason)
        optionList.currentIndex = currentIndex >= 0 ? currentIndex : (optionCount > 0 ? 0 : -1)
        menu.openFrom(control)
    }

    function toggleMenu() {
        if (menu.opened)
            menu.close()
        else
            openMenu()
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            if (menu.opened)
                activateHighlighted()
            else
                openMenu()
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            moveSelection(1)
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            moveSelection(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_Escape && menu.opened) {
            menu.close()
            event.accepted = true
        }
    }

    MeoTextField {
        id: textField
        objectName: "exposedDropdownField"
        width: parent.width
        enabled: control.enabled
        label: control.label
        text: control.text
        isError: control.isError
        errorText: control.errorText
        type: control.type
        readOnly: true
        activeFocusOnTab: false
        Accessible.ignored: true
        trailingIcon: menu.opened ? "arrow_drop_up" : "arrow_drop_down"
    }

    MeoStateLayer {
        id: exposedStateLayer
        objectName: "exposedDropdownStateLayer"
        anchors.left: textField.left
        anchors.right: textField.right
        anchors.top: textField.top
        height: textField.containerHeight
        radius: textField.containerRadius
        internalPointerTrackingEnabled: false
        hovered: dropdownHover.hovered
        focused: control.visualFocus
        color: control.isError ? MeoTheme.error : MeoTheme.onSurface
    }

    MeoShape {
        objectName: "exposedDropdownFocusRing"
        anchors.left: textField.left
        anchors.right: textField.right
        anchors.top: textField.top
        height: textField.containerHeight
        type: "round"
        radius: textField.containerRadius
        color: Qt.rgba(MeoTheme.surface.r, MeoTheme.surface.g, MeoTheme.surface.b, 0)
        strokeWidth: control.visualFocus ? MeoTheme.strokeWidthMedium : 0
        strokeColor: control.isError ? MeoTheme.error : MeoTheme.primary
    }

    HoverHandler {
        id: dropdownHover
        parent: textField
        enabled: control.enabled
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: dropdownTap
        parent: textField
        enabled: control.enabled
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onPressedChanged: {
            if (pressed) {
                const mapped = exposedStateLayer.mapFromItem(
                    dropdownTap.parent,
                    dropdownTap.point.position.x, dropdownTap.point.position.y)
                exposedStateLayer.trigger(mapped.x, mapped.y)
            } else {
                exposedStateLayer.releaseRipple()
            }
        }
        onTapped: {
            control.forceActiveFocus(Qt.MouseFocusReason)
            control.toggleMenu()
        }
    }

    MeoMotionPopup {
        id: menu
        objectName: "exposedDropdownMenu"
        z: 1000
        presentation: MeoMotionPopup.Menu
        width: control.width
        implicitHeight: Math.min(optionList.contentHeight, 280 * control.themeGlobalScale)
                        + topPadding + bottomPadding
        x: 0
        y: textField.containerHeight
        padding: MeoTheme.space8
        initialFocusItem: optionList
        focusReturnItem: control

        onOpened: {
            optionList.currentIndex = control.currentIndex >= 0
                ? control.currentIndex : (control.optionCount > 0 ? 0 : -1)
            if (optionList.currentIndex >= 0)
                optionList.positionViewAtIndex(optionList.currentIndex, ListView.Contain)
        }

        contentItem: ListView {
            id: optionList
            objectName: "exposedDropdownOptions"
            implicitWidth: control.width - menu.leftPadding - menu.rightPadding
            implicitHeight: contentHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            activeFocusOnTab: true
            model: control.model
            currentIndex: -1
            spacing: MeoTheme.space2
            ScrollBar.vertical: ScrollBar { }

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Down) {
                    control.moveHighlight(1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    control.moveHighlight(-1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Home && control.optionCount > 0) {
                    optionList.currentIndex = 0
                    optionList.positionViewAtBeginning()
                    event.accepted = true
                } else if (event.key === Qt.Key_End && control.optionCount > 0) {
                    optionList.currentIndex = control.optionCount - 1
                    optionList.positionViewAtEnd()
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    control.activateHighlighted()
                    event.accepted = true
                } else if (event.key === Qt.Key_Escape) {
                    menu.close()
                    event.accepted = true
                }
            }

            delegate: MeoListItem {
                required property int index
                required property var modelData

                width: ListView.view.width
                headline: String(modelData)
                isDense: true
                isSegmented: true
                roundingStrategy: "all"
                selected: index === optionList.currentIndex
                activeFocusOnTab: false
                Accessible.selected: index === control.currentIndex
                onClicked: {
                    control.selectIndex(index)
                    menu.close()
                }
            }
        }
    }
}
