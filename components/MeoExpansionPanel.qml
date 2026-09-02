import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property bool expanded: false
    property bool interactive: true
    property Component contentItem: null
    readonly property bool isMirrored: LayoutMirroring.enabled

    signal toggled(bool expanded)

    function toggle() {
        if (!interactive || !enabled)
            return false
        expanded = !expanded
        toggled(expanded)
        return true
    }

    implicitWidth: parent ? parent.width : 420 * MeoTheme.globalScale
    implicitHeight: header.implicitHeight + contentClip.height
    activeFocusOnTab: interactive && enabled

    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.description: subtitle
    Accessible.focusable: interactive && enabled
    Accessible.onPressAction: toggle()
    Keys.onReturnPressed: toggle()
    Keys.onEnterPressed: toggle()
    Keys.onSpacePressed: toggle()

    Rectangle {
        id: panelBackground
        anchors.fill: parent
        color: control.expanded ? MeoTheme.surfaceContainerLow : MeoTheme.surfaceContainerLowest
        radius: MeoTheme.shapeLarge
        border.width: 1 * MeoTheme.globalScale
        border.color: control.expanded ? "transparent" : MeoTheme.outlineVariant

        Behavior on color {
            enabled: !MeoTheme.reduceMotion
            ColorAnimation {
                duration: MeoTheme.motionDurationSelection
                easing.bezierCurve: MeoTheme.motionEasingEmphasized
            }
        }
    }

    Column {
        id: layout
        width: control.width
        spacing: 0

        Item {
            id: header
            width: parent.width
            implicitHeight: Math.max(56 * MeoTheme.globalScale, headerContent.implicitHeight + 24 * MeoTheme.globalScale)

            Row {
                id: headerContent
                anchors.left: parent.left
                anchors.right: expansionIcon.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16 * MeoTheme.globalScale
                anchors.rightMargin: 12 * MeoTheme.globalScale
                spacing: 16 * MeoTheme.globalScale
                layoutDirection: control.isMirrored ? Qt.RightToLeft : Qt.LeftToRight

                MeoIcon {
                    visible: control.icon !== ""
                    icon: control.icon
                    size: 24 * MeoTheme.globalScale
                    color: MeoTheme.contentOnSurfaceVariant
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - (control.icon !== "" ? 40 * MeoTheme.globalScale : 0)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2 * MeoTheme.globalScale

                    MeoText {
                        width: parent.width
                        text: control.title
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                        color: MeoTheme.contentOnSurface
                        wrapMode: Text.WordWrap
                    }

                    MeoText {
                        width: parent.width
                        visible: text !== ""
                        text: control.subtitle
                        typeRole: "body"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                        wrapMode: Text.WordWrap
                    }
                }
            }

            MeoIcon {
                id: expansionIcon
                icon: "expand_more"
                size: 24 * MeoTheme.globalScale
                color: MeoTheme.contentOnSurfaceVariant
                anchors.right: parent.right
                anchors.rightMargin: 16 * MeoTheme.globalScale
                anchors.verticalCenter: parent.verticalCenter
                rotation: control.expanded ? 180 : 0

                Behavior on rotation {
                    enabled: !MeoTheme.reduceMotion
                    NumberAnimation {
                        duration: MeoTheme.motionDurationSelection
                        easing.bezierCurve: MeoTheme.motionEasingEmphasized
                    }
                }
            }

            MeoStateLayer {
                anchors.fill: parent
                radius: MeoTheme.shapeLarge
                pressed: headerPointer.pressed
                hovered: headerPointer.containsMouse && control.interactive && control.enabled
                focused: control.activeFocus && control.interactive && control.enabled
                pressX: headerPointer.mouseX
                pressY: headerPointer.mouseY
                color: MeoTheme.contentOnSurface
            }

            MouseArea {
                id: headerPointer
                anchors.fill: parent
                enabled: control.interactive && control.enabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    control.forceActiveFocus(Qt.MouseFocusReason)
                    control.toggle()
                }
            }
        }

        Item {
            id: contentClip
            width: parent.width
            readonly property real loadedHeight: contentLoader.item
                                              ? Math.max(contentLoader.item.implicitHeight, contentLoader.item.height) : 0
            height: control.expanded ? loadedHeight + 16 * MeoTheme.globalScale : 0
            clip: true

            Behavior on height {
                enabled: !MeoTheme.reduceMotion
                NumberAnimation {
                    duration: MeoTheme.motionDurationSelection
                    easing.bezierCurve: MeoTheme.motionEasingEmphasized
                }
            }

            Loader {
                id: contentLoader
                x: 16 * MeoTheme.globalScale
                y: 0
                width: Math.max(0, parent.width - 32 * MeoTheme.globalScale)
                sourceComponent: control.contentItem
                opacity: control.expanded ? 1.0 : 0.0

                Behavior on opacity {
                    enabled: !MeoTheme.reduceMotion
                    NumberAnimation { duration: MeoTheme.motionDurationState }
                }
            }
        }
    }
}
