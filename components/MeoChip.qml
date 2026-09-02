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
    // Avatar initials provide a local fallback when an entity has no image.
    // This keeps Input and Filter chips useful without introducing image assets.
    property string avatarInitials: ""
    // M3 chips default to the 32dp XS container; larger values remain the
    // existing explicit Expressive extension.
    property string size: "xs" // "xs" | "s" | "m" | "l" | "xl"
    property bool selected: false
    property bool closable: type === "input"
    property bool elevated: false
    property bool isEmphasized: false
    property string shape: "rounded" // "pill" | "rounded"
    property string visualStyle: "tonal" // "tonal" | "outlined"

    property color selectedContainerColor: themeSecondaryContainer
    property color selectedContentColor: themeOnSecondaryContainer
    property color contentColor: selected ? selectedContentColor
                                          : (type === "assist" ? themeOnSurface : themeOnSurfaceVariant)
    property color outlineColor: themeOutlineVariant

    signal clicked()
    signal closed()
    signal deleted()

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real themeFontScale: MeoTheme.fontScale
    readonly property string themeFontFamily: MeoTheme.fontFamily
    readonly property int motionFast: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState
    readonly property int motionSelection: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection

    readonly property var fontToken: {
        var token = MeoTheme.labelLarge
        if (size === "xs") token = MeoTheme.labelSmall
        else if (size === "s") token = MeoTheme.labelMedium
        else if (size === "xl") token = MeoTheme.titleSmall
        if (!isEmphasized) return token
        return ({ "size": token.size, "weight": Font.DemiBold, "lineHeight": token.lineHeight || 20, "letterSpacing": token.letterSpacing || 0 })
    }

    readonly property string effectiveLeadingIcon: leadingIcon !== "" ? leadingIcon : icon
    readonly property bool hasAvatar: avatarSource !== "" || avatarInitials !== ""
    readonly property string activeIcon: {
        if (type === "filter" && selected) return "check"
        return effectiveLeadingIcon
    }
    readonly property color leadingIconColor: {
        // Input chips intentionally retain a primary leading icon when
        // selected; their trailing remove affordance uses contentColor.
        if (type === "input") return selected ? themePrimary : contentColor
        return selected ? selectedContentColor
                        : (type === "assist" || type === "filter" || type === "suggestion")
                          ? themePrimary : contentColor
    }
    // Elevated chips use their own filled surface treatment even when the
    // baseline wrapper defaults to the outlined variant.
    readonly property bool usesOutlinedContainer: visualStyle === "outlined" && !elevated
    readonly property real chipHeight: {
        if (size === "xs") return 32 * themeGlobalScale
        if (size === "s") return 36 * themeGlobalScale
        if (size === "l") return 44 * themeGlobalScale
        if (size === "xl") return 52 * themeGlobalScale
        return 40 * themeGlobalScale
    }
    readonly property real chipRadius: shape === "pill" ? chipHeight / 2 : 8 * themeGlobalScale

    implicitHeight: chipHeight
    implicitWidth: Math.max(48 * themeGlobalScale, contentRow.implicitWidth + leftPadding + rightPadding)
    activeFocusOnTab: enabled
    padding: 0
    leftPadding: hasAvatar ? 4 * themeGlobalScale
                                      : (activeIcon !== "" ? 8 : 16) * themeGlobalScale
    rightPadding: closable ? 8 * themeGlobalScale
                           : ((activeIcon !== "" || hasAvatar) ? 8 : 16) * themeGlobalScale
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
        if (type === "filter")
            selected = !selected
        clicked()
    }

    background: Rectangle {
        id: chipBg
        objectName: "meoChipBackground"
        radius: control.chipRadius
        color: {
            if (control.selected) return control.selectedContainerColor
            if (control.usesOutlinedContainer) return "transparent"
            return control.elevated ? control.themeSurfaceContainer : control.themeSurfaceContainerLow
        }
        border.width: {
            if (control.activeFocus) return 2 * control.themeGlobalScale
            if (control.usesOutlinedContainer && !control.selected) return 1 * control.themeGlobalScale
            return 0
        }
        border.color: control.activeFocus ? control.themePrimary : control.outlineColor

        scale: hitArea.pressed ? 0.975 : 1.0
        Behavior on color { ColorAnimation { duration: control.motionFast } }
        Behavior on scale {
            NumberAnimation {
                duration: control.motionFast
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
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
            visible: control.hasAvatar
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
                visible: source !== ""
            }
            Text {
                anchors.centerIn: parent
                visible: control.avatarSource === "" && control.avatarInitials !== ""
                text: control.avatarInitials.slice(0, 2).toUpperCase()
                font.family: control.themeFontFamily
                font.pixelSize: (control.size === "xl" ? 14 : 12) * control.themeFontScale * control.themeGlobalScale
                font.weight: Font.DemiBold
                color: control.contentColor
            }
        }

        MeoIcon {
            id: leadingGlyph
            icon: control.activeIcon
            fill: control.selected
            visible: icon !== "" && !control.hasAvatar
            size: control.size === "xl" ? 24 : control.size === "xs" ? 18 : 20
            color: control.leadingIconColor
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
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
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
            objectName: "meoChipCloseButton"
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
                objectName: "meoChipCloseTarget"
                width: 48 * control.themeGlobalScale
                height: width
                anchors.centerIn: parent
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
