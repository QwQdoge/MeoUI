import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string label: ""
    property string icon: ""
    property string badgeText: ""
    property bool badgeDot: false
    property bool selected: false
    property string mode: "drawer" // "drawer" | "group"
    property bool roundedTop: true
    property bool roundedBottom: true
    property bool showDivider: false
    property string supportingText: ""
    property string visualStyle: "standard" // standard | settings

    signal clicked()

    // The item is retained for legacy drawer callers. Its colors and motion
    // still come from the same dynamic role table as the Expressive rail.
    readonly property bool isDarkMode: MeoTheme.isDarkMode
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeSurfaceContainerLowest: MeoTheme.surfaceContainerLowest
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property bool settingsStyle: visualStyle === "settings"
    readonly property color selectedContainerColor: settingsStyle ? MeoTheme.primaryContainer : themeSecondaryContainer
    readonly property color selectedContentColor: settingsStyle ? MeoTheme.contentOnPrimaryContainer : themeOnSecondaryContainer
    readonly property real themeGlobalScale: MeoTheme.globalScale

    readonly property var fontLabelLarge: MeoTheme.labelLarge
    readonly property var fontBodyLarge: MeoTheme.bodyLarge
    readonly property var fontBodyMedium: MeoTheme.bodyMedium
    readonly property int animationDuration: MeoTheme.motionDurationSelection
    readonly property var emphasizedCurve: MeoTheme.motionEasingEmphasized

    implicitWidth: 336 * themeGlobalScale
    implicitHeight: mode === "group" && supportingText !== ""
                    ? MeoTheme.settingsRowHeight : MeoTheme.settingsSidebarItemHeight
    activeFocusOnTab: enabled
    // AndroidX NavigationDrawerItem exposes a tab role because each row is a
    // destination, not a transient command. Reuse QML's matching PageTab
    // role so assistive technologies receive the same relationship.
    // Source: androidx-main NavigationDrawer.kt 8f8c02618f5d29d9ae6fb71c949ebe0a7290cd0a
    // (Apache-2.0).
    Accessible.role: Accessible.PageTab
    Accessible.name: label
    Accessible.focusable: true
    Accessible.selected: selected
    Accessible.onPressAction: activate()

    function activate() {
        if (!enabled)
            return
        forceActiveFocus(Qt.MouseFocusReason)
        clicked()
    }

    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()

    background: Item {
        Rectangle {
            id: groupSurface
            anchors.fill: parent
            visible: control.mode === "group"
            color: control.themeSurfaceContainerLowest
            radius: 24 * control.themeGlobalScale

            Rectangle { visible: !control.roundedTop; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: parent.radius; color: parent.color }
            Rectangle { visible: !control.roundedBottom; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: parent.radius; color: parent.color }
        }

        Rectangle {
            id: selectedLayer
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: control.mode === "group" ? 8 * control.themeGlobalScale : 0
            anchors.rightMargin: control.mode === "group" ? 8 * control.themeGlobalScale : 0
            height: control.mode === "group" ? 48 * control.themeGlobalScale : 56 * control.themeGlobalScale
            radius: height / 2
            color: control.selected ? control.selectedContainerColor : "transparent"
            clip: true

            MeoStateLayer {
                radius: selectedLayer.radius
                shape: "pill"
                pressed: mouseArea.pressed
                hovered: mouseArea.containsMouse
                pressX: mouseArea.mouseX - selectedLayer.x
                pressY: mouseArea.mouseY - selectedLayer.y
                color: control.selected ? control.selectedContentColor : control.themeOnSurface
                focused: control.activeFocus
            }

            Behavior on color { ColorAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
            Behavior on height { NumberAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
            Behavior on anchors.leftMargin { NumberAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
            Behavior on anchors.rightMargin { NumberAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
        }

        Rectangle {
            visible: control.mode === "group" && control.showDivider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 72 * control.themeGlobalScale
            height: Math.max(1, 1 * control.themeGlobalScale)
            color: control.themeOutlineVariant
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: control.activate()
    }

    contentItem: Row {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: control.mode === "group" ? 32 * control.themeGlobalScale
                                                    : (control.settingsStyle ? 20 * control.themeGlobalScale : 24 * control.themeGlobalScale)
        anchors.rightMargin: control.mode === "group" ? 24 * control.themeGlobalScale
                                                     : (control.settingsStyle ? 20 * control.themeGlobalScale : 24 * control.themeGlobalScale)
        spacing: 16 * control.themeGlobalScale

        MeoIcon {
            icon: control.icon
            fill: control.selected
            size: 24
            color: control.selected ? control.selectedContentColor : control.themeOnSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - (control.icon !== "" ? 40 * control.themeGlobalScale : 0) - (control.badgeText !== "" ? badge.implicitWidth + 16 * control.themeGlobalScale : 0)
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: control.label
                width: parent.width
                font.family: MeoTheme.typefacePlain
                font.pixelSize: (control.mode === "group" ? fontBodyLarge.size : fontLabelLarge.size) * control.themeGlobalScale
                font.weight: control.mode === "group" ? fontBodyLarge.weight : (control.selected ? Font.DemiBold : fontLabelLarge.weight)
                lineHeightMode: Text.FixedHeight
                lineHeight: (control.mode === "group" ? fontBodyLarge.lineHeight : 20) * control.themeGlobalScale
                font.letterSpacing: ((control.mode === "group" ? fontBodyLarge.letterSpacing : fontLabelLarge.letterSpacing) || 0) * control.themeGlobalScale
                color: control.selected ? control.selectedContentColor : (control.mode === "group" ? control.themeOnSurface : control.themeOnSurfaceVariant)
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                Behavior on color {
                    ColorAnimation {
                        duration: MeoTheme.motionDurationState
                        easing.bezierCurve: control.selected ? MeoTheme.motionEasingEnter : MeoTheme.motionEasingExit
                    }
                }
            }

            Text {
                text: control.supportingText
                width: parent.width
                visible: text !== ""
                font.family: MeoTheme.typefacePlain
                font.pixelSize: fontBodyMedium.size * control.themeGlobalScale
                font.weight: fontBodyMedium.weight
                lineHeightMode: Text.FixedHeight
                lineHeight: fontBodyMedium.lineHeight * control.themeGlobalScale
                verticalAlignment: Text.AlignVCenter
                font.letterSpacing: (fontBodyMedium.letterSpacing || 0) * control.themeGlobalScale
                color: control.themeOnSurfaceVariant
                elide: Text.ElideRight
            }
        }

        MeoBadge {
            id: badge
            text: control.badgeText
            isDot: control.badgeDot
            visible: text !== "" || isDot
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
