import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property string type: "assist" // "assist" | "filter" | "input" | "suggestion"
    property string label: ""
    property string icon: ""
    property string leadingIcon: icon
    property string avatarSource: ""
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property bool selected: false
    property bool closable: type === "input"
    property bool elevated: false
    property bool isEmphasized: false
    property string shape: "pill" // "pill" | "rounded"
    property string visualStyle: "tonal" // "tonal" | "outlined"

    property color selectedContainerColor: themeSecondaryContainer
    property color selectedContentColor: themeOnSecondaryContainer
    property color contentColor: selected ? selectedContentColor : themeOnSurfaceVariant
    property color outlineColor: themeOutline

    signal clicked()
    signal closed()
    signal deleted()

    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outline !== "undefined") ? MeoTheme.outline : "#79747E"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.secondaryContainer !== "undefined") ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSecondaryContainer !== "undefined") ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined") ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainer !== "undefined") ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property real themeFontScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.fontScale !== "undefined") ? MeoTheme.fontScale : 1.0
    readonly property string themeFontFamily: (typeof MeoTheme !== "undefined" && typeof MeoTheme.fontFamily !== "undefined") ? MeoTheme.fontFamily : "Roboto"
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 100
    readonly property int motionSelection: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSelection !== "undefined") ? MeoTheme.motionDurationSelection : 220

    readonly property var fontToken: {
        if (typeof MeoTheme === "undefined") return ({ "size": 14, "weight": Font.Medium })
        var token = typeof MeoTheme.labelLarge !== "undefined" ? MeoTheme.labelLarge : ({ "size": 14, "weight": Font.Medium })
        if (size === "xs" && typeof MeoTheme.labelSmall !== "undefined") token = MeoTheme.labelSmall
        else if (size === "s" && typeof MeoTheme.labelMedium !== "undefined") token = MeoTheme.labelMedium
        else if (size === "l" && typeof MeoTheme.labelLarge !== "undefined") token = MeoTheme.labelLarge
        else if (size === "xl" && typeof MeoTheme.titleSmall !== "undefined") token = MeoTheme.titleSmall
        if (!isEmphasized) return token
        return ({ "size": token.size, "weight": Font.DemiBold, "lineHeight": token.lineHeight || 20, "letterSpacing": token.letterSpacing || 0 })
    }

    readonly property string effectiveLeadingIcon: leadingIcon !== "" ? leadingIcon : icon
    readonly property string activeIcon: {
        if (type === "filter" && selected) return "check"
        return effectiveLeadingIcon
    }
    readonly property real chipHeight: {
        if (size === "xs") return 32 * themeGlobalScale
        if (size === "s") return 36 * themeGlobalScale
        if (size === "l") return 44 * themeGlobalScale
        if (size === "xl") return 52 * themeGlobalScale
        return 40 * themeGlobalScale
    }
    readonly property real chipRadius: shape === "pill" ? chipHeight / 2 : Math.min(16 * themeGlobalScale, chipHeight * 0.36)

    implicitHeight: chipHeight
    implicitWidth: Math.max(48 * themeGlobalScale, contentRow.implicitWidth + leftPadding + rightPadding)
    activeFocusOnTab: enabled
    padding: 0
    leftPadding: (activeIcon !== "" || avatarSource !== "" ? 10 : 18) * themeGlobalScale
    rightPadding: (closable ? 10 : 18) * themeGlobalScale
    opacity: enabled ? 1.0 : 0.38

    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.checkable: type === "filter"
    Accessible.checked: selected
    Accessible.onPressAction: activate()
    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()

    function activate() {
        if (!enabled) return
        clicked()
    }

    background: Rectangle {
        id: chipBg
        radius: control.chipRadius
        color: {
            if (control.selected) return control.selectedContainerColor
            if (control.visualStyle === "outlined") return "transparent"
            return control.elevated ? control.themeSurfaceContainer : control.themeSurfaceContainerLow
        }
        border.width: {
            if (control.activeFocus) return 2 * control.themeGlobalScale
            if (control.visualStyle === "outlined" && !control.selected) return 1 * control.themeGlobalScale
            return 0
        }
        border.color: control.activeFocus ? control.themePrimary : control.outlineColor

        scale: hitArea.pressed ? 0.975 : 1.0
        Behavior on color { ColorAnimation { duration: control.motionFast } }
        Behavior on scale {
            NumberAnimation {
                duration: control.motionFast
                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
            }
        }

        MeoStateLayer {
            anchors.fill: parent
            radius: chipBg.radius
            shape: "rect"
            pressed: hitArea.pressed
            hovered: hitArea.containsMouse
            focused: control.activeFocus
            pressX: hitArea.mouseX
            pressY: hitArea.mouseY
            color: control.selected ? control.selectedContentColor : control.themeOnSurface
        }

        MouseArea {
            id: hitArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: control.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                control.forceActiveFocus(Qt.MouseFocusReason)
                control.activate()
            }
        }
    }

    contentItem: Row {
        id: contentRow
        spacing: (control.size === "xs" ? 5 : 8) * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            visible: control.avatarSource !== ""
            width: (control.size === "xl" ? 32 : 24) * control.themeGlobalScale
            height: width
            radius: width / 2
            clip: true
            color: control.themeSurfaceContainer
            anchors.verticalCenter: parent.verticalCenter
            Image {
                anchors.fill: parent
                source: control.avatarSource
                fillMode: Image.PreserveAspectCrop
            }
        }

        MeoIcon {
            id: leadingGlyph
            icon: control.activeIcon
            fill: control.selected
            visible: icon !== "" && control.avatarSource === ""
            size: control.size === "xl" ? 24 : control.size === "xs" ? 18 : 20
            color: control.contentColor
            anchors.verticalCenter: parent.verticalCenter

            Behavior on scale {
                NumberAnimation { duration: control.motionFast }
            }
            onIconChanged: {
                scale = 0.86
                iconReturn.restart()
            }
            NumberAnimation {
                id: iconReturn
                target: leadingGlyph
                property: "scale"
                to: 1.0
                duration: control.motionSelection
                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
            }
        }

        Text {
            text: control.label
            font.family: control.themeFontFamily
            font.pixelSize: control.fontToken.size * control.themeFontScale * control.themeGlobalScale
            font.weight: control.fontToken.weight
            color: control.contentColor
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            visible: control.closable
            width: 24 * control.themeGlobalScale
            height: width
            anchors.verticalCenter: parent.verticalCenter

            MeoIcon {
                anchors.centerIn: parent
                icon: "close"
                size: 18
                color: closeMouse.containsMouse ? control.themePrimary : control.contentColor
            }
            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: control.enabled
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mouse.accepted = true
                    control.closed()
                    control.deleted()
                }
            }
        }
    }
}
