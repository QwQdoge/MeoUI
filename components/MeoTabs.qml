import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property var model: []
    property int currentIndex: 0
    property string type: "primary" // "primary" | "secondary"
    property string style: "expressive" // "expressive" | "underline"
    property bool isScrollable: false

    signal clicked(int index)

    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primaryContainer !== "undefined") ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnPrimaryContainer !== "undefined") ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined") ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outlineVariant !== "undefined") ? MeoTheme.outlineVariant : "#CAC4D0"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property int motionSelection: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSelection !== "undefined") ? MeoTheme.motionDurationSelection : 220
    readonly property int motionState: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 100
    readonly property var fontTitleSmall: (typeof MeoTheme !== "undefined" && typeof MeoTheme.titleSmall !== "undefined") ? MeoTheme.titleSmall : ({ "size": 14, "weight": Font.Medium })

    readonly property bool useExpressivePills: style === "expressive" && type === "primary"
    readonly property bool hasIcons: {
        for (var i = 0; i < model.length; ++i) {
            if (typeof model[i] === "object" && model[i].icon)
                return true
        }
        return false
    }

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: useExpressivePills ? (hasIcons ? 72 : 56) * themeGlobalScale
                                       : (hasIcons && type === "primary" ? 72 : 48) * themeGlobalScale

    background: Rectangle {
        radius: control.useExpressivePills ? 24 * control.themeGlobalScale : 0
        color: control.useExpressivePills ? control.themeSurfaceContainerLow : "transparent"

        Rectangle {
            visible: !control.useExpressivePills && control.type === "secondary"
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1 * control.themeGlobalScale
            color: control.themeOutlineVariant
        }
    }

    contentItem: ScrollView {
        id: scrollView
        clip: true
        contentWidth: tabsRow.implicitWidth
        ScrollBar.horizontal.policy: control.isScrollable ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Row {
            id: tabsRow
            height: control.availableHeight
            width: control.isScrollable ? implicitWidth : control.availableWidth
            spacing: control.useExpressivePills ? 4 * control.themeGlobalScale : 0
            leftPadding: control.useExpressivePills ? 4 * control.themeGlobalScale : 0
            rightPadding: leftPadding

            Repeater {
                model: control.model

                delegate: Item {
                    id: tabItem
                    required property int index
                    required property var modelData

                    readonly property var itemData: modelData
                    readonly property string label: typeof itemData === "string" ? itemData : (itemData.label || itemData.text || "")
                    readonly property string icon: typeof itemData === "object" ? (itemData.icon || "") : ""
                    readonly property string badgeText: typeof itemData === "object" ? (itemData.badgeText || "") : ""
                    readonly property bool badgeDot: typeof itemData === "object" ? (itemData.badgeDot || false) : false
                    readonly property bool isSelected: control.currentIndex === index

                    width: control.isScrollable
                           ? Math.max(96 * control.themeGlobalScale, contentColumn.implicitWidth + 36 * control.themeGlobalScale)
                           : Math.max(0, (tabsRow.width - tabsRow.leftPadding - tabsRow.rightPadding - tabsRow.spacing * Math.max(0, control.model.length - 1)) / Math.max(1, control.model.length))
                    height: tabsRow.height
                    activeFocusOnTab: true

                    Accessible.role: Accessible.PageTab
                    Accessible.name: label
                    Accessible.selected: isSelected
                    Accessible.onPressAction: activate()

                    function activate() {
                        control.currentIndex = index
                        control.clicked(index)
                    }

                    Rectangle {
                        id: pill
                        visible: control.useExpressivePills
                        anchors.centerIn: parent
                        width: tabItem.isSelected ? Math.max(64 * control.themeGlobalScale, contentColumn.implicitWidth + 28 * control.themeGlobalScale)
                                                   : hitArea.containsMouse ? Math.max(56 * control.themeGlobalScale, contentColumn.implicitWidth + 20 * control.themeGlobalScale)
                                                                           : Math.max(48 * control.themeGlobalScale, contentColumn.implicitWidth + 12 * control.themeGlobalScale)
                        height: control.hasIcons ? 58 * control.themeGlobalScale : 44 * control.themeGlobalScale
                        radius: height / 2
                        color: tabItem.isSelected ? control.themePrimaryContainer
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

                    Column {
                        id: contentColumn
                        anchors.centerIn: parent
                        spacing: 3 * control.themeGlobalScale

                        Item {
                            visible: tabItem.icon !== ""
                            width: 28 * control.themeGlobalScale
                            height: 26 * control.themeGlobalScale
                            anchors.horizontalCenter: parent.horizontalCenter

                            MeoIcon {
                                anchors.centerIn: parent
                                icon: tabItem.icon
                                fill: tabItem.isSelected
                                size: 24
                                color: tabItem.isSelected
                                       ? (control.useExpressivePills ? control.themeOnPrimaryContainer : control.themePrimary)
                                       : control.themeOnSurfaceVariant
                            }

                            MeoBadge {
                                text: tabItem.badgeText
                                isDot: tabItem.badgeDot
                                visible: text !== "" || isDot
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: -3 * control.themeGlobalScale
                                anchors.rightMargin: -3 * control.themeGlobalScale
                            }
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4 * control.themeGlobalScale

                            Text {
                                text: tabItem.label
                                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                                font.pixelSize: control.fontTitleSmall.size * control.themeGlobalScale
                                font.weight: tabItem.isSelected ? Font.DemiBold : control.fontTitleSmall.weight
                                color: tabItem.isSelected
                                       ? (control.useExpressivePills ? control.themeOnPrimaryContainer : control.themePrimary)
                                       : control.themeOnSurfaceVariant
                                Behavior on color { ColorAnimation { duration: control.motionState } }
                            }

                            MeoBadge {
                                visible: tabItem.icon === "" && (tabItem.badgeText !== "" || tabItem.badgeDot)
                                text: tabItem.badgeText
                                isDot: tabItem.badgeDot
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        visible: !control.useExpressivePills && tabItem.isSelected
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: control.type === "secondary" ? parent.width : Math.max(32 * control.themeGlobalScale, contentColumn.implicitWidth)
                        height: control.type === "secondary" ? 2 * control.themeGlobalScale : 3 * control.themeGlobalScale
                        radius: height / 2
                        color: control.themePrimary
                        Behavior on width {
                            NumberAnimation {
                                duration: control.motionSelection
                                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                            }
                        }
                    }

                    MeoStateLayer {
                        anchors.fill: parent
                        anchors.margins: control.useExpressivePills ? 4 * control.themeGlobalScale : 0
                        radius: control.useExpressivePills ? 24 * control.themeGlobalScale : 8 * control.themeGlobalScale
                        pressed: hitArea.pressed
                        hovered: hitArea.containsMouse
                        focused: tabItem.activeFocus
                        pressX: hitArea.mouseX
                        pressY: hitArea.mouseY
                        color: tabItem.isSelected ? control.themePrimary : control.themeOnSurfaceVariant
                    }

                    MouseArea {
                        id: hitArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            tabItem.forceActiveFocus(Qt.MouseFocusReason)
                            tabItem.activate()
                        }
                    }
                    Keys.onReturnPressed: activate()
                    Keys.onEnterPressed: activate()
                    Keys.onSpacePressed: activate()
                }
            }
        }
    }
}
