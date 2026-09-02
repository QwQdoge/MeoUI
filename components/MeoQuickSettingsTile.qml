pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Control {
    id: control
    property string title: ""
    property string supportingText: ""
    property string iconName: ""
    property bool active: false
    property bool wide: false
    property bool busy: false
    // "pixel" mirrors the large, touch-first Android quick-settings editor
    // without changing the compact desktop surface that already uses this
    // component.  It is intentionally a geometry variant, not a second color
    // system: both variants continue to consume the active Meo dynamic roles.
    property string visualStyle: "standard" // "standard" | "pixel"
    readonly property bool pixelStyle: visualStyle === "pixel"
    readonly property color activeContainerColor: pixelStyle ? MeoTheme.primary : MeoTheme.primaryContainer
    readonly property color activeContentColor: pixelStyle ? MeoTheme.contentOnPrimary : MeoTheme.contentOnPrimaryContainer
    property bool detailsEnabled: false
    // AOSP quick-settings tiles use the secondary action for a long press.
    // Keep this opt-out so hosts that reserve long press for another command
    // can retain their existing interaction contract.
    property bool detailsOnLongPress: true
    property string detailsAccessibleName: title !== ""
        ? qsTr("Open %1 settings").arg(title)
        : qsTr("Open settings")
    property bool editMode: false
    property bool removable: false
    property bool resizeEnabled: true
    property bool editSelectable: false
    property bool editSelected: false
    property string removeAccessibleName: title !== ""
        ? qsTr("Remove %1 from Quick Settings").arg(title)
        : qsTr("Remove tile from Quick Settings")
    property bool showCompactLabel: false
    property int modelIndex: -1
    // AOSP Android 16 QPR2 defines 80dp quick-settings tiles with 28dp corners.
    // The Pixel-like variant keeps those logical values without claiming that
    // its host-specific arrangement is a generic Material component.
    readonly property real visualHeight: (pixelStyle ? 80 : (wide ? 72 : 56))
                                       * MeoTheme.globalScale
    readonly property real focusStrokeWidth: pixelStyle
                                             ? MeoTheme.strokeWidthThick
                                             : MeoTheme.strokeWidthMedium
    readonly property color focusStrokeColor: pixelStyle
                                              ? MeoTheme.secondaryFixed
                                              : MeoTheme.primary
    signal triggered()
    signal detailsRequested()
    signal resizeRequested()
    signal removeRequested()
    signal editSelectionRequested()

    implicitWidth: (pixelStyle ? (wide ? 224 : 108) : (wide ? 176 : 84))
                   * MeoTheme.globalScale
    implicitHeight: (pixelStyle ? 80 : (wide ? 72 : 96)) * MeoTheme.globalScale
    // Keep the tab-focus capability stable while entering edit mode. The
    // focused control is redirected before its visual action changes.
    activeFocusOnTab: enabled && !busy
    z: dragHandler.active ? 100 : 0
    opacity: !enabled ? MeoTheme.disabledContentOpacity : (dragHandler.active ? 0.76 : 1)
    Behavior on opacity {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: MeoTheme.motionDurationState }
    }
    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.description: supportingText
    Accessible.checkable: true
    Accessible.checked: active
    Accessible.focusable: activeFocusOnTab
    Accessible.onPressAction: activateMain()
    Keys.onReturnPressed: activateMain()
    Keys.onEnterPressed: activateMain()
    Keys.onSpacePressed: activateMain()
    Drag.active: dragHandler.active
    Drag.source: control
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    transform: Translate {
        x: dragHandler.activeTranslation.x
        y: dragHandler.activeTranslation.y
    }

    function activateMain() {
        if (enabled && !busy && editMode && editSelectable)
            editSelectionRequested()
        else if (enabled && !busy && !editMode)
            triggered()
    }

    function requestDetails() {
        if (enabled && !busy && !editMode && detailsEnabled)
            detailsRequested()
    }

    function requestRemove() {
        if (enabled && !busy && editMode && removable)
            removeRequested()
    }

    onEditModeChanged: {
        if (editMode && detailsButton.activeFocus)
            control.forceActiveFocus(Qt.OtherFocusReason)
    }

    background: Item {
        MeoShape {
            id: stateShape
            objectName: "meoQuickSettingsSurface"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: control.wide ? (parent.height - height) / 2 : 0
            width: parent.width
            height: control.visualHeight
            type: "round"
            radius: control.pixelStyle ? MeoTheme.shapeExtraLarge : MeoTheme.shapeFull
            color: control.active ? control.activeContainerColor : MeoTheme.surfaceContainerHighest
            strokeWidth: control.activeFocus || (control.editMode && control.editSelected)
                         ? control.focusStrokeWidth : 0
            strokeColor: control.focusStrokeColor
            Behavior on color {
                ColorAnimation {
                    duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection
                    easing.bezierCurve: MeoTheme.motionEasingEmphasized
                }
            }
            MeoStateLayer {
                anchors.fill: parent
                radius: stateShape.radius
                hovered: pointer.containsMouse
                pressed: pointer.pressed
                focused: control.activeFocus
                color: control.active ? control.activeContentColor : MeoTheme.contentOnSurface
            }
        }
    }

    contentItem: Item {
        z: 2

        RowLayout {
            visible: control.wide && !control.pixelStyle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: control.visualHeight
            anchors.leftMargin: MeoTheme.space16
            anchors.rightMargin: MeoTheme.space8
            spacing: MeoTheme.space12

            MeoIcon {
                icon: control.iconName
                size: 24
                fill: control.active
                color: control.active ? control.activeContentColor : MeoTheme.contentOnSurfaceVariant
            }
            ColumnLayout {
                visible: control.wide
                Layout.fillWidth: true
                spacing: 0
                MeoText {
                    Layout.fillWidth: true
                    text: control.title
                    typeRole: "label"
                    typeSize: "medium"
                    emphasized: true
                    color: control.active ? control.activeContentColor : MeoTheme.contentOnSurface
                    elide: Text.ElideRight
                }
                MeoText {
                    Layout.fillWidth: true
                    text: control.supportingText
                    visible: text !== ""
                    typeRole: "body"
                    typeSize: "small"
                    color: control.active ? control.activeContentColor : MeoTheme.contentOnSurfaceVariant
                    elide: Text.ElideRight
                }
            }
        }

        // Android-style wide tile used by the shared editor.  The large
        // circular glyph field keeps the visual hierarchy of the supplied
        // reference while the title/supporting text remain real data supplied
        // by the host application.
        RowLayout {
            visible: control.wide && control.pixelStyle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: control.visualHeight
            anchors.leftMargin: MeoTheme.space12
            anchors.rightMargin: MeoTheme.space12
            spacing: MeoTheme.space12

            Rectangle {
                Layout.preferredWidth: 56 * MeoTheme.globalScale
                Layout.preferredHeight: width
                radius: width / 2
                color: control.active
                       ? Qt.rgba(control.activeContentColor.r, control.activeContentColor.g,
                                 control.activeContentColor.b, 0.16)
                       : MeoTheme.surfaceContainerHigh

                MeoIcon {
                    anchors.centerIn: parent
                    icon: control.iconName
                    size: 20
                    fill: control.active
                    color: control.active ? control.activeContentColor : MeoTheme.contentOnSurfaceVariant
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1 * MeoTheme.globalScale

                MeoText {
                    Layout.fillWidth: true
                    text: control.title
                    typeRole: "label"
                    typeSize: "medium"
                    emphasized: true
                    color: control.active ? control.activeContentColor : MeoTheme.contentOnSurface
                    elide: Text.ElideRight
                }

                MeoText {
                    Layout.fillWidth: true
                    text: control.supportingText
                    visible: text !== ""
                    typeRole: "body"
                    typeSize: "small"
                    color: control.active ? control.activeContentColor : MeoTheme.contentOnSurfaceVariant
                    elide: Text.ElideRight
                }
            }

        }

        MeoIcon {
            visible: !control.wide && !control.pixelStyle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: control.detailsEnabled && !control.editMode
                ? -22 * MeoTheme.globalScale : 0
            anchors.top: parent.top
            anchors.topMargin: (control.visualHeight - height) / 2
            icon: control.iconName
            size: 24
            fill: control.active
            color: control.active ? control.activeContentColor : MeoTheme.contentOnSurface
        }

        ColumnLayout {
            visible: !control.wide && control.pixelStyle
            anchors.centerIn: parent
            width: parent.width - 2 * MeoTheme.space12
            spacing: MeoTheme.space8

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 48 * MeoTheme.globalScale
                Layout.preferredHeight: width
                radius: width / 2
                color: control.active
                       ? Qt.rgba(control.activeContentColor.r, control.activeContentColor.g,
                                 control.activeContentColor.b, 0.16)
                       : MeoTheme.surfaceContainerHigh

                MeoIcon {
                    anchors.centerIn: parent
                    icon: control.iconName
                    size: 20
                    fill: control.active
                    color: control.active ? control.activeContentColor : MeoTheme.contentOnSurfaceVariant
                }
            }

            MeoText {
                Layout.fillWidth: true
                visible: control.title !== ""
                text: control.title
                typeRole: "label"
                typeSize: "medium"
                emphasized: true
                color: control.active ? control.activeContentColor : MeoTheme.contentOnSurface
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        MeoText {
            visible: !control.wide && control.showCompactLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: MeoTheme.space4
            text: control.title
            typeRole: "label"
            typeSize: "small"
            emphasized: control.active
            horizontalAlignment: Text.AlignHCenter
            color: control.active ? control.activeContentColor : MeoTheme.contentOnSurface
            elide: Text.ElideRight
        }
        MeoIconButton {
            objectName: "quickSettingsRemoveButton"
            visible: control.editMode && control.removable
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: control.pixelStyle ? -MeoTheme.space4 : 0
            anchors.topMargin: control.pixelStyle ? MeoTheme.space4 : 0
            type: "filled"
            size: control.pixelStyle ? "m" : "xs"
            icon.name: "remove"
            Accessible.name: control.removeAccessibleName
            onClicked: control.requestRemove()
        }

        MeoIconButton {
            objectName: "quickSettingsResizeButton"
            visible: control.editMode && control.editSelected && control.resizeEnabled
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: control.pixelStyle ? MeoTheme.space4 : 0
            anchors.bottomMargin: control.pixelStyle ? MeoTheme.space4 : 0
            type: "tonal"
            size: "xs"
            icon.name: control.wide ? "width_normal" : "width_wide"
            Accessible.name: control.wide ? qsTr("Make tile small") : qsTr("Make tile wide")
            onClicked: control.resizeRequested()
        }
    }

    AbstractButton {
        id: detailsButton
        objectName: "quickSettingsDetailsButton"
        visible: control.detailsEnabled && !control.editMode
        anchors.right: parent.right
        anchors.rightMargin: control.wide
                            ? (control.pixelStyle ? MeoTheme.space12 : MeoTheme.space8)
                            : 0
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: control.visualHeight / 2
        width: 44 * MeoTheme.globalScale
        height: width
        z: 4
        enabled: control.enabled && !control.busy
        // Qt already excludes invisible and disabled items from tab traversal.
        // Keeping this stable avoids changing the flag while this button owns
        // focus during an edit-mode transition.
        activeFocusOnTab: true
        padding: 0
        Accessible.name: control.detailsAccessibleName
        Accessible.description: control.supportingText
        Keys.onReturnPressed: control.requestDetails()
        Keys.onEnterPressed: control.requestDetails()
        onClicked: control.requestDetails()

        background: MeoStateLayer {
            radius: width / 2
            hovered: detailsButton.hovered
            pressed: detailsButton.pressed
            focused: detailsButton.visualFocus
            color: control.active ? control.activeContentColor : MeoTheme.contentOnSurface
        }

        contentItem: MeoIcon {
            icon: "chevron_right"
            size: 18
            color: control.active ? control.activeContentColor : MeoTheme.contentOnSurfaceVariant
        }
    }

    MouseArea {
        id: pointer
        objectName: "quickSettingsPointer"
        property bool longPressConsumed: false
        z: 1
        anchors.fill: parent
        enabled: control.enabled && !control.busy && (!control.editMode || control.editSelectable)
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: longPressConsumed = false
        onPressAndHold: function(mouse) {
            if (mouse.button === Qt.LeftButton && control.detailsEnabled
                    && control.detailsOnLongPress && !control.editMode) {
                longPressConsumed = true
                control.requestDetails()
            }
        }
        onClicked: function(mouse) {
            if (longPressConsumed) {
                longPressConsumed = false
                return
            }
            control.forceActiveFocus(Qt.MouseFocusReason)
            if (control.editMode && control.editSelectable)
                control.editSelectionRequested()
            else if (control.detailsEnabled && mouse.button === Qt.RightButton)
                control.requestDetails()
            else
                control.activateMain()
        }
    }
    DragHandler { id: dragHandler; enabled: control.enabled && control.editMode; target: null }
}
