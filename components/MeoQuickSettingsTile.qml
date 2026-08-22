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
    property bool detailsEnabled: false
    property string detailsAccessibleName: title !== ""
        ? qsTr("Open %1 settings").arg(title)
        : qsTr("Open settings")
    property bool editMode: false
    property bool showCompactLabel: false
    property int modelIndex: -1
    readonly property real visualHeight: (wide ? 72 : 56) * MeoTheme.globalScale
    signal triggered()
    signal detailsRequested()
    signal resizeRequested()

    implicitWidth: (wide ? 176 : 84) * MeoTheme.globalScale
    implicitHeight: (wide ? 72 : 96) * MeoTheme.globalScale
    activeFocusOnTab: enabled && !busy && !editMode
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
        if (enabled && !busy && !editMode)
            triggered()
    }

    function requestDetails() {
        if (enabled && !busy && !editMode && detailsEnabled)
            detailsRequested()
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
            radius: MeoTheme.shapeFull
            color: control.active ? MeoTheme.primaryContainer : MeoTheme.surfaceContainerHighest
            strokeWidth: control.activeFocus ? MeoTheme.strokeWidthMedium : 0
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
            visible: control.wide
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

        MeoIcon {
            visible: !control.wide
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
            type: "filled"
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
        enabled: control.enabled && !control.busy && !control.editMode
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            control.forceActiveFocus(Qt.MouseFocusReason)
            if (control.detailsEnabled && mouse.button === Qt.RightButton)
                control.requestDetails()
            else
                control.activateMain()
        }
    }
    DragHandler { id: dragHandler; enabled: control.editMode; target: null }
}
