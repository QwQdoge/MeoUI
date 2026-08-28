import QtQuick
import MeoUI

Rectangle {
    id: control

    property var model: []
    property int currentIndex: 0
    property string labelType: "always" // "always" | "selected" | "none"
    property string shape: "pill"
    property bool compact: false
    signal clicked(int index)

    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined") ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.secondaryContainer !== "undefined") ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSecondaryContainer !== "undefined") ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainer !== "undefined") ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primaryContainer !== "undefined") ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnPrimaryContainer !== "undefined") ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property int motionSelection: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSelection !== "undefined") ? MeoTheme.motionDurationSelection : 220
    readonly property int motionState: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 100
    readonly property var fontLabel: (typeof MeoTheme !== "undefined" && typeof MeoTheme.labelMedium !== "undefined") ? MeoTheme.labelMedium : ({ "size": 12, "weight": Font.Medium })

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 80 * themeGlobalScale
    radius: 0
    color: themeSurfaceContainer

    Row {
        id: destinationsRow
        anchors.fill: parent
        anchors.leftMargin: 8 * control.themeGlobalScale
        anchors.rightMargin: 8 * control.themeGlobalScale
        spacing: 4 * control.themeGlobalScale

        Repeater {
            model: control.model

            delegate: Item {
                id: destination
                required property int index
                required property var modelData
                width: Math.max(0, (destinationsRow.width - destinationsRow.spacing * Math.max(0, control.model.length - 1)) / Math.max(1, control.model.length))
                height: destinationsRow.height
                activeFocusOnTab: true

                readonly property bool isSelected: control.currentIndex === index
                readonly property string itemLabel: modelData.label || modelData.text || ""
                readonly property string itemIcon: modelData.icon || ""

                Accessible.role: Accessible.PageTab
                Accessible.name: itemLabel
                Accessible.selected: isSelected
                Accessible.focusable: true
                Accessible.onPressAction: activate()

                function activate() {
                    control.currentIndex = index
                    control.clicked(index)
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 3 * control.themeGlobalScale

                    Item {
                        width: 64 * control.themeGlobalScale
                        height: 32 * control.themeGlobalScale
                        anchors.horizontalCenter: parent.horizontalCenter

                        MeoShape {
                            id: indicator
                            anchors.centerIn: parent
                            width: destination.isSelected ? parent.width : (hitArea.containsMouse ? parent.width * 0.82 : 36 * control.themeGlobalScale)
                            height: parent.height
                            radius: height / 2
                            type: control.shape
                            color: destination.isSelected ? control.themeSecondaryContainer
                                                          : hitArea.containsMouse ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.06)
                                                                                  : "transparent"

                            Behavior on width {
                                NumberAnimation {
                                    duration: control.motionSelection
                                    easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                                }
                            }
                            Behavior on color { ColorAnimation { duration: control.motionState } }
                        }

                        MeoIcon {
                            anchors.centerIn: parent
                            icon: destination.itemIcon
                            fill: destination.isSelected
                            size: 24
                            color: destination.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                        }

                        MeoBadge {
                            text: modelData.badgeText || (modelData.badgeCount !== undefined ? modelData.badgeCount.toString() : "")
                            isDot: modelData.badgeDot || false
                            visible: text !== "" || isDot
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: -3 * control.themeGlobalScale
                            anchors.rightMargin: -3 * control.themeGlobalScale
                        }
                    }

                    Text {
                        text: destination.itemLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                        font.pixelSize: control.fontLabel.size * control.themeGlobalScale
                        font.weight: destination.isSelected ? Font.DemiBold : control.fontLabel.weight
                        color: destination.isSelected ? control.themeOnSurface : control.themeOnSurfaceVariant
                        visible: control.labelType === "always" || (control.labelType === "selected" && destination.isSelected)
                    }
                }

                MeoStateLayer {
                    anchors.fill: parent
                    anchors.margins: 4 * control.themeGlobalScale
                    radius: 24 * control.themeGlobalScale
                    hovered: hitArea.containsMouse
                    pressed: hitArea.pressed
                    focused: destination.activeFocus
                    pressX: hitArea.mouseX
                    pressY: hitArea.mouseY
                    color: destination.isSelected ? control.themeOnPrimaryContainer : control.themeOnSurface
                }

                MouseArea {
                    id: hitArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        destination.forceActiveFocus(Qt.MouseFocusReason)
                        destination.activate()
                    }
                }
                Keys.onReturnPressed: activate()
                Keys.onEnterPressed: activate()
                Keys.onSpacePressed: activate()
            }
        }
    }
}
