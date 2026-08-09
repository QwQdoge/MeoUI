import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 核心 MD3 Chip 规范属性
    // type: "assist" | "filter" | "input" | "suggestion"
    property string type: "assist"
    property string label: ""
    property string icon: ""
    property string leadingIcon: icon // 别名兼容
    property string avatarSource: "" // 🖼️ MD3 Avatar 支持
    property string size: "m" // 🌟 MD3 Expressive: "xs" | "s" | "m" | "l" | "xl"
    property bool selected: false
    property bool closable: type === "input"
    property bool elevated: false // 🌟 MD3 Elevated vs Flat Surface
    property bool isEmphasized: false // MD3 Expressive Font Weight
    property string shape: "rounded" // "rounded" | "pill"
    
    // 自定义与扩展颜色绑定
    property color selectedContainerColor: themeSecondaryContainer
    property color selectedContentColor: themeOnSecondaryContainer
    property color contentColor: selected ? selectedContentColor : themeOnSurfaceVariant
    property color outlineColor: themeOutline

    // 🌟 核心信号
    signal clicked()
    signal closed()
    signal deleted() // 别名兼容

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property real themeFontScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontScale !== 'undefined') ? MeoTheme.fontScale : 1.0
    readonly property string themeFontFamily: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontFamily !== 'undefined') ? MeoTheme.fontFamily : "sans-serif"
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationFast !== "undefined") ? MeoTheme.motionDurationFast * (MeoTheme.motionScale || 1.0) : 120

    readonly property var fontToken: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        let token;
        if (size === "xs") token = MeoTheme.labelSmall;
        else if (size === "s") token = MeoTheme.labelMedium;
        else if (size === "l") token = MeoTheme.titleSmall;
        else if (size === "xl") token = MeoTheme.titleMedium;
        else token = MeoTheme.labelLarge;

        if (isEmphasized) {
            if (size === "xs") return MeoTheme.labelSmallEmphasized || token;
            if (size === "s") return MeoTheme.labelMediumEmphasized || token;
            if (size === "l") return MeoTheme.titleSmallEmphasized || token;
            if (size === "xl") return MeoTheme.titleMediumEmphasized || token;
            return MeoTheme.labelLargeEmphasized || token;
        }
        return token;
    }

    readonly property string activeIcon: {
        if (effectiveLeadingIcon !== "") return effectiveLeadingIcon;
        if (type === "filter" && selected) return "check";
        return "";
    }
    readonly property string effectiveLeadingIcon: leadingIcon !== "" ? leadingIcon : icon

    implicitHeight: {
        if (size === "xs" || size === "s") return 32 * themeGlobalScale;
        if (size === "l") return 40 * themeGlobalScale;
        if (size === "xl") return 48 * themeGlobalScale;
        return 32 * themeGlobalScale;
    }
    implicitWidth: contentRow.implicitWidth + leftPadding + rightPadding
    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.checkable: type === "filter"
    Accessible.checked: selected
    Accessible.onPressAction: control.clicked()
    Keys.onReturnPressed: control.clicked()
    Keys.onEnterPressed: control.clicked()
    Keys.onSpacePressed: control.clicked()

    padding: 0
    leftPadding: (activeIcon !== "" || avatarSource !== "" ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale
    rightPadding: (closable ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale
    opacity: enabled ? 1.0 : 0.62
    scale: (enabled && mouseArea.pressed && (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive)) ? 0.98 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: control.motionFast
            easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
        }
    }
    Behavior on opacity { NumberAnimation { duration: control.motionFast } }

    background: Rectangle {
        radius: shape === "pill" ? height / 2 : (size === "xl" ? 16 : 8) * themeGlobalScale
        color: {
            if (control.selected) return control.selectedContainerColor;
            if (control.elevated) return control.themeSurfaceContainerLow;
            return "transparent";
        }
        border.color: {
            if (control.selected || control.elevated) return "transparent";
            if (!control.enabled) return Qt.rgba(control.outlineColor.r, control.outlineColor.g, control.outlineColor.b, 0.12);
            if (control.activeFocus) return control.themePrimary;
            return control.outlineColor;
        }
        border.width: (control.activeFocus && !control.selected && !control.elevated) ? 2 * themeGlobalScale : 1 * themeGlobalScale

        // Elevated Drop Shadow
        layer.enabled: control.elevated && control.enabled
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.15
            shadowVerticalOffset: 1 * themeGlobalScale
            shadowColor: Qt.rgba(0, 0, 0, 0.16)
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: control.enabled
            onClicked: {
                control.forceActiveFocus(Qt.MouseFocusReason)
                control.clicked()
            }
        }

        MeoStateLayer {
            anchors.fill: parent
            radius: parent.radius
            shape: "rect"
            pressed: mouseArea.pressed
            hovered: mouseArea.containsMouse
            focused: control.visualFocus
            pressX: mouseArea.mouseX
            pressY: mouseArea.mouseY
            color: control.selected ? control.selectedContentColor : control.themeOnSurface
        }

        Behavior on color { ColorAnimation { duration: control.motionFast } }
    }

    contentItem: Row {
        id: contentRow
        spacing: (size === "xs" ? 4 : 8) * themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter

        // 🖼️ Avatar Image (if provided)
        Rectangle {
            visible: control.avatarSource !== ""
            width: (size === "xl" ? 32 : 24) * themeGlobalScale
            height: width
            radius: width / 2
            color: "transparent"
            clip: true
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.fill: parent
                source: control.avatarSource
                fillMode: Image.PreserveAspectCrop
            }
        }

        // 🔘 Leading / Checkmark Icon
        MeoIcon {
            icon: control.activeIcon
            fill: control.selected
            visible: control.activeIcon !== "" && control.avatarSource === ""
            size: {
                if (control.size === "xs" || control.size === "s") return 18 * themeGlobalScale;
                if (control.size === "xl") return 28 * themeGlobalScale;
                return 20 * themeGlobalScale;
            }
            color: control.contentColor
            anchors.verticalCenter: parent.verticalCenter

            Behavior on icon {
                SequentialAnimation {
                    NumberAnimation { target: parent; property: "scale"; to: 0; duration: 80 }
                    PropertyAction { target: parent; property: "icon" }
                    NumberAnimation { target: parent; property: "scale"; to: 1; duration: 80 }
                }
            }
        }

        // 🏷️ Label Text
        Text {
            text: control.label
            font.family: control.themeFontFamily
            font.pixelSize: fontToken.size * control.themeFontScale * control.themeGlobalScale
            font.weight: fontToken.weight
            font.letterSpacing: (fontToken.letterSpacing || 0) * control.themeGlobalScale
            lineHeightMode: Text.FixedHeight
            lineHeight: fontToken.lineHeight ? fontToken.lineHeight * control.themeFontScale * control.themeGlobalScale : font.pixelSize * 1.2
            color: control.contentColor
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        // ❌ Trailing Close Icon (for Input Chips / Closable Chips)
        Item {
            visible: control.closable
            width: (size === "xl" ? 28 : 18) * control.themeGlobalScale
            height: width
            anchors.verticalCenter: parent.verticalCenter

            MeoIcon {
                anchors.centerIn: parent
                icon: "close"
                size: control.size === "xl" ? 22 * themeGlobalScale : 16 * themeGlobalScale
                color: closeMouse.containsMouse ? control.themePrimary : control.contentColor
            }
            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: control.enabled
                onClicked: {
                    control.closed()
                    control.deleted()
                }
            }
        }
    }
}
