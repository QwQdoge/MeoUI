import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    property string message: ""
    property string actionText: ""
    property string icon: ""
    property bool dismissible: false
    property int duration: 4000
    property real edgeMargin: 20 * themeGlobalScale

    signal actionClicked()
    signal dismissed()

    readonly property bool isDarkMode: (typeof MeoTheme !== "undefined" && typeof MeoTheme.isDarkMode !== "undefined") ? MeoTheme.isDarkMode : false
    readonly property color themeInverseSurface: isDarkMode ? "#E6E1E5" : "#313033"
    readonly property color themeInverseOnSurface: isDarkMode ? "#313033" : "#F4F0F4"
    readonly property color themeInversePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? (isDarkMode ? MeoTheme.primary : "#D0BCFF") : "#D0BCFF"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property int motionEnter: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSheetEnter !== "undefined") ? MeoTheme.motionDurationSheetEnter : 320
    readonly property int motionExit: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSheetExit !== "undefined") ? MeoTheme.motionDurationSheetExit : 220
    readonly property var fontBodyMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyMedium !== "undefined") ? MeoTheme.bodyMedium : ({ "size": 14, "weight": Font.Normal })
    readonly property var fontLabelLarge: (typeof MeoTheme !== "undefined" && typeof MeoTheme.labelLarge !== "undefined") ? MeoTheme.labelLarge : ({ "size": 14, "weight": Font.Medium })

    x: parent ? Math.max(edgeMargin, (parent.width - width) / 2) : 0
    y: parent ? Math.max(edgeMargin, parent.height - height - edgeMargin) : 0
    width: parent ? Math.min(parent.width - edgeMargin * 2, 560 * themeGlobalScale) : 360 * themeGlobalScale
    padding: 0
    closePolicy: dismissible ? Popup.CloseOnEscape | Popup.CloseOnPressOutside : Popup.NoAutoClose

    background: Rectangle {
        radius: 20 * control.themeGlobalScale
        color: control.themeInverseSurface
    }

    contentItem: Item {
        implicitHeight: Math.max(52 * control.themeGlobalScale, contentRow.implicitHeight + 20 * control.themeGlobalScale)

        Row {
            id: contentRow
            anchors.fill: parent
            anchors.leftMargin: 16 * control.themeGlobalScale
            anchors.rightMargin: 8 * control.themeGlobalScale
            anchors.topMargin: 10 * control.themeGlobalScale
            anchors.bottomMargin: 10 * control.themeGlobalScale
            spacing: 10 * control.themeGlobalScale

            MeoIcon {
                visible: control.icon !== ""
                icon: control.icon
                size: 22
                color: control.themeInverseOnSurface
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                width: Math.max(0, parent.width
                                - (control.icon !== "" ? 32 * control.themeGlobalScale : 0)
                                - (control.actionText !== "" ? actionButton.implicitWidth + 12 * control.themeGlobalScale : 0)
                                - (control.dismissible ? dismissButton.width + 8 * control.themeGlobalScale : 0))
                text: control.message
                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: control.fontBodyMedium.size * control.themeGlobalScale
                font.weight: control.fontBodyMedium.weight
                color: control.themeInverseOnSurface
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                anchors.verticalCenter: parent.verticalCenter
            }

            Button {
                id: actionButton
                visible: control.actionText !== ""
                text: control.actionText
                height: 40 * control.themeGlobalScale
                padding: 12 * control.themeGlobalScale
                hoverEnabled: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    control.actionClicked()
                    control.close()
                }
                background: Rectangle {
                    radius: height / 2
                    color: actionButton.pressed ? Qt.rgba(control.themeInversePrimary.r, control.themeInversePrimary.g, control.themeInversePrimary.b, 0.16)
                                                : actionButton.hovered ? Qt.rgba(control.themeInversePrimary.r, control.themeInversePrimary.g, control.themeInversePrimary.b, 0.10)
                                                                       : "transparent"
                }
                contentItem: Text {
                    text: actionButton.text
                    color: control.themeInversePrimary
                    font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                    font.pixelSize: control.fontLabelLarge.size * control.themeGlobalScale
                    font.weight: control.fontLabelLarge.weight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MeoIconButton {
                id: dismissButton
                visible: control.dismissible
                icon.name: "close"
                size: "s"
                type: "standard"
                width: 36 * control.themeGlobalScale
                height: width
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    control.dismissed()
                    control.close()
                }
            }
        }
    }

    Timer {
        id: autoCloseTimer
        interval: Math.max(1000, control.duration)
        onTriggered: control.close()
    }

    onOpened: autoCloseTimer.restart()
    onClosed: autoCloseTimer.stop()

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: control.motionEnter }
            NumberAnimation { property: "scale"; from: 0.94; to: 1; duration: control.motionEnter; easing.type: Easing.OutCubic }
        }
    }
    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: control.motionExit }
            NumberAnimation { property: "scale"; from: 1; to: 0.97; duration: control.motionExit; easing.type: Easing.InCubic }
        }
    }
}
