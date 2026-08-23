import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Popup {
    id: control
    width: 360 * themeGlobalScale
    height: parent ? parent.height : 0
    padding: 0
    margins: 0
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var model: []
    property int currentIndex: 0
    property Component header: null
    signal clicked(int index)

    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // MD3 Modal Drawer appearance
    background: Rectangle {
        color: themeSurfaceContainerLow
        radius: 0
        // Rounded corner on the right side only
        Rectangle {
            width: 16 * control.themeGlobalScale
            height: parent.height
            anchors.right: parent.right
            color: "transparent"
            Rectangle {
                width: 32 * control.themeGlobalScale
                height: parent.height
                anchors.right: parent.right
                color: themeSurfaceContainerLow
                radius: 16 * control.themeGlobalScale
                clip: true
                Item { anchors.fill: parent } // Trick to hide left side radius
            }
        }
    }

    // Windows/WinUI-style directional motion. Motion is disabled centrally for
    // users that request reduced motion.
    enter: Transition {
        NumberAnimation {
            property: "x"
            from: -control.width
            to: 0
            duration: MeoTheme.motionDurationSheetEnter
            easing.bezierCurve: MeoTheme.motionEasingEnter
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "x"
            from: 0
            to: -control.width
            duration: MeoTheme.motionDurationSheetExit
            easing.bezierCurve: MeoTheme.motionEasingExit
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12 * control.themeGlobalScale
        spacing: 0

        Loader {
            Layout.fillWidth: true
            sourceComponent: control.header
            visible: control.header !== null
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 17 * control.themeGlobalScale
            visible: control.header !== null

            MeoDivider {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: parent.width
                spacing: 0

                Repeater {
                    model: control.model

                    delegate: Loader {
                        id: rowLoader
                        required property int index
                        required property var modelData

                        width: parent.width
                        sourceComponent: modelData.type === "header" ? groupHeader : destinationItem
                        height: item ? item.implicitHeight : 0

                        Component {
                            id: groupHeader

                            MeoListHeader {
                                width: rowLoader.width
                                text: rowLoader.modelData.label || ""
                                topPadding: 16 * control.themeGlobalScale
                                bottomPadding: 8 * control.themeGlobalScale
                            }
                        }

                        Component {
                            id: destinationItem

                            MeoNavigationDrawerItem {
                                width: rowLoader.width
                                icon: rowLoader.modelData.icon || ""
                                label: rowLoader.modelData.label || ""
                                badgeText: rowLoader.modelData.badgeText
                                           || (rowLoader.modelData.badgeCount !== undefined
                                               ? rowLoader.modelData.badgeCount.toString() : "")
                                badgeDot: rowLoader.modelData.badgeDot || false
                                selected: control.currentIndex === rowLoader.index
                                onClicked: control.clicked(rowLoader.index)
                            }
                        }
                    }
                }
            }
        }
    }
}
