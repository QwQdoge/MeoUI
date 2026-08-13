import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property bool expanded: false
    property Component contentItem: null
    property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && MeoTheme.globalScale !== undefined) ? MeoTheme.globalScale : 1.0

    implicitWidth: parent ? parent.width : 360 * themeGlobalScale
    implicitHeight: header.height + (expanded ? contentArea.height : 0)

    Behavior on implicitHeight {
        NumberAnimation {
            duration: MeoTheme.motionDurationMedium
            easing.bezierCurve: MeoTheme.motionEasingEmphasized
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: expanded ? MeoTheme.surfaceContainerLow : MeoTheme.surface
        radius: MeoTheme.shapeMedium * themeGlobalScale

        Behavior on color {
            ColorAnimation {
                duration: MeoTheme.motionDurationMedium
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }

        Rectangle {
            id: header
            width: parent.width
            height: Math.max(56 * themeGlobalScale, headerContent.implicitHeight + 16 * themeGlobalScale)
            color: "transparent"
            radius: background.radius

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: control.expanded = !control.expanded
            }

            MeoStateLayer {
                anchors.fill: parent
                radius: parent.radius
                pressed: mouseArea.pressed
                hovered: mouseArea.containsMouse
                pressX: mouseArea.mouseX
                pressY: mouseArea.mouseY
                color: MeoTheme.contentOnSurface
            }

            Row {
                id: headerContent
                anchors.left: parent.left
                anchors.right: expandIcon.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16 * themeGlobalScale
                anchors.rightMargin: 16 * themeGlobalScale
                spacing: 16 * themeGlobalScale

                MeoIcon {
                    visible: control.icon !== ""
                    icon: control.icon
                    size: 24 * themeGlobalScale
                    color: MeoTheme.contentOnSurfaceVariant
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - (control.icon !== "" ? (24 + 16) * themeGlobalScale : 0)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4 * themeGlobalScale

                    MeoText {
                        text: control.title
                        typeRole: "title"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurface
                        width: parent.width
                        wrapMode: Text.Wrap
                    }

                    MeoText {
                        visible: control.subtitle !== ""
                        text: control.subtitle
                        typeRole: "body"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                        width: parent.width
                        wrapMode: Text.Wrap
                    }
                }
            }

            MeoIcon {
                id: expandIcon
                icon: "expand_more"
                size: 24 * themeGlobalScale
                color: MeoTheme.contentOnSurfaceVariant
                anchors.right: parent.right
                anchors.rightMargin: 16 * themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                rotation: control.expanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: MeoTheme.motionDurationMedium
                        easing.bezierCurve: MeoTheme.motionEasingEmphasized
                    }
                }
            }
        }

        Item {
            id: contentContainer
            width: parent.width
            anchors.top: header.bottom
            height: control.expanded ? contentArea.height : 0
            clip: true

            Behavior on height {
                NumberAnimation {
                    duration: MeoTheme.motionDurationMedium
                    easing.bezierCurve: MeoTheme.motionEasingEmphasized
                }
            }

            Loader {
                id: contentArea
                width: parent.width
                sourceComponent: control.contentItem
                opacity: control.expanded ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: MeoTheme.motionDurationMedium
                        easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
            }
        }
    }
}