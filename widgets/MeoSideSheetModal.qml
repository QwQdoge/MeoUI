import QtQuick
import QtQuick.Controls
import MeoUI

MeoMotionPopup {
    id: control

    property string title: ""
    property Component content: null
    property bool showCloseButton: true
    property bool dismissible: true

    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontTitleLarge: MeoTheme.titleLarge

    x: parent ? parent.width - width : 0
    y: 0
    width: Math.min(parent ? parent.width : 400 * themeGlobalScale, 400 * themeGlobalScale)
    height: parent ? parent.height : 600 * themeGlobalScale

    presentation: MeoMotionPopup.SideSheet
    surfaceRadius: MeoTheme.shapeLarge
    surfaceColor: control.themeSurfaceContainerLow
    modal: true
    focus: true
    closePolicy: control.dismissible
                 ? (Popup.CloseOnEscape | Popup.CloseOnPressOutside)
                 : Popup.NoAutoClose

    contentItem: Column {
        anchors.fill: parent

        // Header
        Item {
            width: parent.width
            height: 64 * control.themeGlobalScale
            visible: control.title !== "" || control.showCloseButton

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16 * control.themeGlobalScale
                anchors.rightMargin: 16 * control.themeGlobalScale
                spacing: 12 * control.themeGlobalScale

                MeoIconButton {
                    icon.name: "close"
                    visible: control.showCloseButton
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: control.close()
                }

                Text {
                    text: control.title
                    visible: text !== ""
                    font.pixelSize: fontTitleLarge.size * control.themeGlobalScale
                    font.weight: fontTitleLarge.weight
                    color: control.themeOnSurface
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Content
        Loader {
            id: contentLoader
            width: parent.width
            height: parent.height - (control.title !== "" || control.showCloseButton ? 64 * control.themeGlobalScale : 0)
            sourceComponent: control.content
        }
    }

}
