import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    property string icon: ""
    property string title: ""
    property string description: ""
    property string actionText: ""
    property Component customContent: null

    signal actionClicked()

    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontHeadlineSmall: MeoTheme.headlineSmall
    readonly property var fontBodyMedium: MeoTheme.bodyMedium

    implicitWidth: 320 * themeGlobalScale
    implicitHeight: mainColumn.implicitHeight

    Column {
        id: mainColumn
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, 400 * control.themeGlobalScale)
        spacing: 24 * control.themeGlobalScale

        // Illustration / Icon
        MeoIcon {
            icon: control.icon
            visible: icon !== ""
            size: 64 * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Text Group
        Column {
            width: parent.width
            spacing: 8 * control.themeGlobalScale

            Text {
                text: control.title
                visible: text !== ""
                width: parent.width
                font.pixelSize: fontHeadlineSmall.size * control.themeGlobalScale
                font.weight: fontHeadlineSmall.weight
                color: control.themeOnSurface
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Text {
                text: control.description
                visible: text !== ""
                width: parent.width
                font.pixelSize: fontBodyMedium.size * control.themeGlobalScale
                font.weight: fontBodyMedium.weight
                color: control.themeOnSurfaceVariant
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        // Custom Content Slot
        Loader {
            id: customLoader
            width: parent.width
            sourceComponent: control.customContent
            visible: control.customContent !== null
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Primary Action
        MeoButton {
            objectName: "meoEmptyStateAction"
            text: control.actionText
            type: "filled"
            visible: text !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: control.actionClicked()
        }
    }
}
