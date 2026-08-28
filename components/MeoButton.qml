import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Button {
    id: control

    property string type: "filled" // "filled" | "tonal" | "outlined" | "elevated" | "text"
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string shape: "round" // "round" | "square" | custom MeoShape type
    property bool isEmphasized: false
    property bool loading: false
    property bool loadingWithContainer: false
    property bool selected: false
    property bool vibrant: false // solid expressive tertiary container; never a gradient
    property bool bouncy: (typeof MeoTheme !== "undefined" && typeof MeoTheme.isExpressive !== "undefined") ? MeoTheme.isExpressive : true
    // An optional, reusable leading visual for identities that cannot be
    // represented by a single Material icon glyph. The loaded item is sized to
    // the same visual slot as `icon` so labels, hit targets, and motion remain
    // consistent with regular icon buttons.
    property Component leadingComponent: null
    property real contentSpacing: (size === "xs" ? 5 : 8) * themeGlobalScale

    readonly property string effectiveType: type === "filledTonal" ? "tonal" : type
    readonly property bool isDarkMode: (typeof MeoTheme !== "undefined" && typeof MeoTheme.isDarkMode !== "undefined") ? MeoTheme.isDarkMode : false
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnPrimary !== "undefined") ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primaryContainer !== "undefined") ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnPrimaryContainer !== "undefined") ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.secondaryContainer !== "undefined") ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSecondaryContainer !== "undefined") ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeTertiaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.tertiaryContainer !== "undefined") ? MeoTheme.tertiaryContainer : "#FFD8E4"
    readonly property color themeOnTertiaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnTertiaryContainer !== "undefined") ? MeoTheme.contentOnTertiaryContainer : "#31111D"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined") ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOutline: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outline !== "undefined") ? MeoTheme.outline : "#79747E"
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 100
    readonly property int motionSelection: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSelection !== "undefined") ? MeoTheme.motionDurationSelection : 220
    readonly property int motionShape: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationShapeSettle !== "undefined") ? MeoTheme.motionDurationShapeSettle : 220

    readonly property real buttonHeight: (typeof MeoTheme !== "undefined"
                                          && typeof MeoTheme.buttonHeightForSize === "function")
                                         ? MeoTheme.buttonHeightForSize(size)
                                         : (size === "xs" ? 32 : size === "s" ? 40
                                            : size === "l" ? 56 : size === "xl" ? 72 : 48) * themeGlobalScale
    readonly property int iconSize: {
        if (size === "xs") return 18
        if (size === "s") return 20
        if (size === "xl") return 32
        return 24
    }
    readonly property real horizontalPad: {
        if (effectiveType === "text") return (size === "xl" ? 20 : 12) * themeGlobalScale
        if (size === "xs") return 14 * themeGlobalScale
        if (size === "s") return 18 * themeGlobalScale
        if (size === "l") return 28 * themeGlobalScale
        if (size === "xl") return 36 * themeGlobalScale
        return 24 * themeGlobalScale
    }
    readonly property bool hasIcon: leadingComponent !== null || icon.name !== "" || icon.source.toString() !== "" || checked || selected
    readonly property var fontToken: {
        if (typeof MeoTheme === "undefined") return ({ "size": 14, "weight": Font.Medium })
        var token = typeof MeoTheme.labelLarge !== "undefined" ? MeoTheme.labelLarge : ({ "size": 14, "weight": Font.Medium })
        if (size === "xs" && typeof MeoTheme.labelSmall !== "undefined") token = MeoTheme.labelSmall
        else if (size === "s" && typeof MeoTheme.labelMedium !== "undefined") token = MeoTheme.labelMedium
        else if (size === "l" && typeof MeoTheme.titleSmall !== "undefined") token = MeoTheme.titleSmall
        else if (size === "xl" && typeof MeoTheme.titleMedium !== "undefined") token = MeoTheme.titleMedium
        if (!isEmphasized) return token
        return ({ "size": token.size, "weight": Font.DemiBold, "lineHeight": token.lineHeight || 20, "letterSpacing": token.letterSpacing || 0 })
    }

    readonly property color baseContainerColor: {
        if (!enabled) return Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, effectiveType === "outlined" || effectiveType === "text" ? 0 : 0.08)
        if (vibrant && effectiveType === "filled") return themeTertiaryContainer
        if (checked || selected) {
            if (effectiveType === "filled") return themePrimaryContainer
            if (effectiveType === "outlined" || effectiveType === "text") return themeSecondaryContainer
        }
        if (effectiveType === "filled") return themePrimary
        if (effectiveType === "tonal") return themeSecondaryContainer
        if (effectiveType === "elevated") return themeSurfaceContainerLow
        return "transparent"
    }
    readonly property color textColor: {
        if (!enabled) return Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.38)
        if (vibrant && effectiveType === "filled") return themeOnTertiaryContainer
        if (checked || selected) {
            if (effectiveType === "filled") return themeOnPrimaryContainer
            if (effectiveType === "outlined" || effectiveType === "text") return themeOnSecondaryContainer
        }
        if (effectiveType === "filled") return themeOnPrimary
        if (effectiveType === "tonal") return themeOnSecondaryContainer
        return themePrimary
    }
    readonly property real restingRadius: {
        if (shape === "square") {
            if (size === "xs" || size === "s")
                return Math.min(buttonHeight / 2, (typeof MeoTheme !== "undefined" ? MeoTheme.controlRadius : 12 * themeGlobalScale))
            return Math.min(buttonHeight / 2, (typeof MeoTheme !== "undefined" ? MeoTheme.windowRadius : 16 * themeGlobalScale))
        }
        return (typeof MeoTheme !== "undefined" && typeof MeoTheme.buttonRadiusForHeight === "function")
                ? MeoTheme.buttonRadiusForHeight(buttonHeight, false) : buttonHeight / 2
    }
    readonly property real activeRadius: pressed && shape === "round"
                                         ? ((typeof MeoTheme !== "undefined" && typeof MeoTheme.buttonRadiusForHeight === "function")
                                            ? MeoTheme.buttonRadiusForHeight(buttonHeight, true)
                                            : Math.max(8 * themeGlobalScale, restingRadius - 8 * themeGlobalScale))
                                         : restingRadius

    implicitHeight: buttonHeight
    implicitWidth: Math.max((effectiveType === "text" ? 48 : 64) * themeGlobalScale,
                            contentRow.implicitWidth + leftPadding + rightPadding)
    leftPadding: horizontalPad * (hasIcon ? 0.72 : 1.0)
    rightPadding: horizontalPad
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: control.buttonHeight

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: control.contentSpacing
            opacity: control.loading ? 0 : 1

            Loader {
                id: leadingComponentLoader
                active: control.leadingComponent !== null && !control.checked && !control.selected
                visible: active
                sourceComponent: control.leadingComponent
                width: control.iconSize * control.themeGlobalScale
                height: width
                opacity: control.enabled ? 1 : 0.38
                anchors.verticalCenter: parent.verticalCenter
            }

            MeoIcon {
                icon: (control.checked || control.selected) ? "check" : (control.icon.name || control.icon.source.toString())
                visible: control.hasIcon && !leadingComponentLoader.active
                fill: control.checked || control.selected
                size: control.iconSize
                color: control.textColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: control.text
                visible: text !== ""
                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: control.fontToken.size * control.themeGlobalScale
                font.weight: control.fontToken.weight
                color: control.textColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Behavior on opacity { NumberAnimation { duration: control.motionFast } }
        }

        MeoLoadingIndicator {
            anchors.centerIn: parent
            visible: control.loading
            opacity: control.loading ? 1 : 0
            scale: control.loading ? 1 : 0.86
            width: (control.iconSize + 8) * control.themeGlobalScale
            height: width
            indeterminate: true
            color: control.textColor
            vibrant: false
            withContainer: control.loadingWithContainer
            Behavior on opacity { NumberAnimation { duration: control.motionFast } }
            Behavior on scale {
                NumberAnimation {
                    duration: control.motionSelection
                    easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                }
            }
        }
    }

    background: Item {
        MeoShape {
            id: buttonShape
            anchors.fill: parent
            type: (control.shape === "round" || control.shape === "square") ? "rect" : control.shape
            radius: control.activeRadius
            color: control.baseContainerColor
            strokeColor: control.effectiveType === "outlined" ? (control.enabled ? control.themeOutline : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.12)) : "transparent"
            strokeWidth: control.effectiveType === "outlined"
                         ? ((typeof MeoTheme !== "undefined" && typeof MeoTheme.strokeWidthThin !== "undefined")
                            ? MeoTheme.strokeWidthThin : 1 * control.themeGlobalScale) : 0
            scale: control.pressed ? (control.bouncy ? 0.975 : 0.99) : 1.0

            layer.enabled: control.visible && control.effectiveType === "elevated" && control.enabled && !control.pressed
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: control.hovered ? 0.22 : 0.14
                shadowVerticalOffset: (control.hovered ? 2 : 1) * control.themeGlobalScale
                shadowOpacity: control.isDarkMode ? 0.18 : 0.12
                shadowColor: Qt.rgba(0, 0, 0, 0.22)
            }

            MeoStateLayer {
                anchors.fill: parent
                radius: buttonShape.radius
                shape: buttonShape.type
                pressed: control.pressed
                hovered: control.hovered
                focused: control.visualFocus
                color: control.textColor
            }

            Behavior on color { ColorAnimation { duration: control.motionFast } }
            Behavior on radius {
                NumberAnimation {
                    duration: control.motionShape
                    easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: control.motionFast
                    easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                }
            }
        }
    }
}
