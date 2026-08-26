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
    property bool detailsEnabled: false
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
    // Android 16 QPR1 QS tiles are 80dp tall with 28dp rounded corners.
    // The supplied 1080px reference is captured at a higher device scale, so
    // this logical size—not its sampled physical pixels—is the reusable API.
    readonly property real visualHeight: (pixelStyle ? 80 : (wide ? 72 : 56))
                                       * MeoTheme.globalScale
    signal triggered()
    signal detailsRequested()
    signal resizeRequested()
    signal removeRequested()
    signal editSelectionRequested()

    implicitWidth: (pixelStyle ? (wide ? 224 : 108) : (wide ? 176 : 84))
                   * MeoTheme.globalScale
    implicitHeight: (pixelStyle ? 80 : (wide ? 72 : 96)) * MeoTheme.globalScale
    activeFocusOnTab: enabled && !busy && (!editMode || editSelectable)
    z: dragHandler.active ? 100 : 0
    opacity: dragHandler.active ? 0.76 : 1
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

    Component {
        id: detailsButtonComponent

        AbstractButton {
            id: detailsButton
            objectName: "quickSettingsDetailsButton"
            anchors.fill: parent
            enabled: control.enabled && !control.busy && !control.editMode
            activeFocusOnTab: visible && enabled
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
                color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurface
            }

            contentItem: MeoIcon {
                icon: "chevron_right"
                size: 18
                color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurfaceVariant
            }
        }
    }

    background: Item {
        MeoShape {
            id: stateShape
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: control.wide ? (parent.height - height) / 2 : 0
            width: parent.width
            height: control.visualHeight
            type: "round"
            radius: control.pixelStyle ? MeoTheme.shapeExtraLarge : MeoTheme.shapeFull
            color: control.active ? MeoTheme.primaryContainer : MeoTheme.surfaceContainerHighest
            strokeWidth: control.activeFocus || (control.editMode && control.editSelected)
                         ? MeoTheme.strokeWidthMedium : 0
            strokeColor: MeoTheme.primary
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
                color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurface
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
                color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurfaceVariant
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
                    color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurface
                    elide: Text.ElideRight
                }
                MeoText {
                    Layout.fillWidth: true
                    text: control.supportingText
                    visible: text !== ""
                    typeRole: "body"
                    typeSize: "small"
                    color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurfaceVariant
                    elide: Text.ElideRight
                }
            }
            Loader {
                visible: control.detailsEnabled && !control.editMode
                active: visible
                Layout.preferredWidth: 44 * MeoTheme.globalScale
                Layout.preferredHeight: 44 * MeoTheme.globalScale
                sourceComponent: detailsButtonComponent
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
                       ? Qt.rgba(MeoTheme.onPrimaryContainer.r, MeoTheme.onPrimaryContainer.g,
                                 MeoTheme.onPrimaryContainer.b, 0.16)
                       : MeoTheme.surfaceContainerHigh

                MeoIcon {
                    anchors.centerIn: parent
                    icon: control.iconName
                    size: 24
                    fill: control.active
                    color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurfaceVariant
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1 * MeoTheme.globalScale

                MeoText {
                    Layout.fillWidth: true
                    text: control.title
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                    color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurface
                    elide: Text.ElideRight
                }

                MeoText {
                    Layout.fillWidth: true
                    text: control.supportingText
                    visible: text !== ""
                    typeRole: "body"
                    typeSize: "small"
                    color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurfaceVariant
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
            color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurface
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
                       ? Qt.rgba(MeoTheme.onPrimaryContainer.r, MeoTheme.onPrimaryContainer.g,
                                 MeoTheme.onPrimaryContainer.b, 0.16)
                       : MeoTheme.surfaceContainerHigh

                MeoIcon {
                    anchors.centerIn: parent
                    icon: control.iconName
                    size: 24
                    fill: control.active
                    color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurfaceVariant
                }
            }

            MeoText {
                Layout.fillWidth: true
                visible: control.title !== ""
                text: control.title
                typeRole: "label"
                typeSize: "medium"
                emphasized: true
                color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurface
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        Loader {
            visible: !control.wide && control.detailsEnabled && !control.editMode
            active: visible
            anchors.right: parent.right
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: control.visualHeight / 2
            width: 44 * MeoTheme.globalScale
            height: width
            sourceComponent: detailsButtonComponent
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
            color: control.active ? MeoTheme.onPrimaryContainer : MeoTheme.onSurface
            elide: Text.ElideRight
        }
        MeoIconButton {
            visible: control.editMode
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: control.pixelStyle ? -MeoTheme.space4 : 0
            anchors.topMargin: control.pixelStyle ? MeoTheme.space4 : 0
            type: "filled"
            size: control.pixelStyle ? "m" : "xs"
            icon.name: control.removable ? "remove" : (control.wide ? "width_normal" : "width_wide")
            Accessible.name: control.removable ? control.removeAccessibleName
                                               : (control.wide ? qsTr("Make tile small") : qsTr("Make tile wide"))
            onClicked: {
                if (control.removable)
                    control.requestRemove()
                else
                    control.resizeRequested()
            }
        }

        MeoIconButton {
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

    MouseArea {
        id: pointer
        z: 1
        anchors.fill: parent
        enabled: control.enabled && !control.busy && (!control.editMode || control.editSelectable)
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            control.forceActiveFocus(Qt.MouseFocusReason)
            if (control.editMode && control.editSelectable)
                control.editSelectionRequested()
            else if (control.detailsEnabled && mouse.button === Qt.RightButton)
                control.requestDetails()
            else
                control.activateMain()
        }
    }
    DragHandler { id: dragHandler; enabled: control.editMode; target: null }
}
