import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Button {
    id: control

    property string type: "filled" // "filled" | "tonal" | "outlined" | "elevated" | "text"
    property string size: "s" // "xs" | "s" | "m" | "l" | "xl"
    property string shape: "round" // "round" | "square" | custom MeoShape type
    property bool isEmphasized: false
    property bool loading: false
    property bool loadingWithContainer: false
    property bool selected: false
    // Marks an otherwise-unselected checkable button as a toggle button.
    // It is needed for the M3 filled-toggle unselected surface treatment.
    property bool toggle: false
    // Material does not inject a check glyph into a selected text button.
    // Applications can opt in with a semantic selected icon when appropriate.
    property string selectedIcon: ""
    property bool vibrant: false // solid expressive tertiary container; never a gradient
    // Compatibility switch for callers that need to suppress expressive shape
    // interpolation. Pressed buttons change corner shape, never layout size.
    property bool bouncy: MeoTheme.isExpressive
    // An optional, reusable leading visual for identities that cannot be
    // represented by a single Material icon glyph. The loaded item is sized to
    // the same visual slot as `icon` so labels, hit targets, and motion remain
    // consistent with regular icon buttons.
    property Component leadingComponent: null
    property real contentSpacing: {
        if (size === "l") return 12 * themeGlobalScale
        if (size === "xl") return 16 * themeGlobalScale
        return 8 * themeGlobalScale
    }

    readonly property string effectiveType: type === "filledTonal" ? "tonal" : type
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themeSecondary: MeoTheme.secondary
    readonly property color themeOnSecondary: MeoTheme.contentOnSecondary
    readonly property color themeTertiaryContainer: MeoTheme.tertiaryContainer
    readonly property color themeOnTertiaryContainer: MeoTheme.contentOnTertiaryContainer
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property color themeInverseSurface: MeoTheme.inverseSurface
    readonly property color themeOnInverseSurface: MeoTheme.contentOnInverseSurface
    readonly property int motionFast: MeoTheme.motionDurationState
    readonly property int motionSelection: MeoTheme.motionDurationSelection
    readonly property int motionShape: MeoTheme.motionDurationShapeSettle

    readonly property real buttonHeight: MeoTheme.buttonHeightForSize(size)
    readonly property int iconSize: {
        if (size === "xs" || size === "s") return 20
        if (size === "m") return 24
        if (size === "l") return 32
        return 40
    }
    readonly property real horizontalPad: {
        if (effectiveType === "text") return 12 * themeGlobalScale
        if (size === "xs" || size === "s") return 16 * themeGlobalScale
        if (size === "l") return 48 * themeGlobalScale
        if (size === "xl") return 64 * themeGlobalScale
        return 24 * themeGlobalScale
    }
    readonly property bool isSelected: checked || selected
    readonly property bool isToggleButton: effectiveType !== "text" && (toggle || checkable || selected)
    readonly property bool hasIcon: leadingComponent !== null || icon.name !== "" || icon.source.toString() !== "" || (isSelected && selectedIcon !== "")
    readonly property var fontToken: {
        var token = MeoTheme.labelLarge
        if (size === "m") token = MeoTheme.titleMedium
        else if (size === "l") token = MeoTheme.headlineSmall
        else if (size === "xl") token = MeoTheme.headlineLarge
        if (!isEmphasized) return token
        return ({ "size": token.size, "weight": Font.DemiBold, "lineHeight": token.lineHeight || 20, "letterSpacing": token.letterSpacing || 0 })
    }

    readonly property color baseContainerColor: {
        if (!enabled) {
            if (effectiveType === "outlined" || effectiveType === "text") return "transparent"
            const opacity = effectiveType === "tonal" ? 0.12 : 0.10
            return Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, opacity)
        }
        if (vibrant && effectiveType === "filled") return themeTertiaryContainer
        if (isToggleButton) {
            if (isSelected) {
                if (effectiveType === "filled" || effectiveType === "elevated") return themePrimary
                if (effectiveType === "tonal") return themeSecondary
                if (effectiveType === "outlined") return themeInverseSurface
            }
            if (effectiveType === "filled") return themeSurfaceContainer
        }
        if (effectiveType === "filled") return themePrimary
        if (effectiveType === "tonal") return themeSecondaryContainer
        if (effectiveType === "elevated") return themeSurfaceContainerLow
        return "transparent"
    }
    readonly property color textColor: {
        if (!enabled) {
            const disabledRole = effectiveType === "tonal" ? themeOnSurface : themeOnSurfaceVariant
            return Qt.rgba(disabledRole.r, disabledRole.g, disabledRole.b, 0.38)
        }
        if (vibrant && effectiveType === "filled") return themeOnTertiaryContainer
        if (isToggleButton) {
            if (isSelected) {
                if (effectiveType === "filled" || effectiveType === "elevated") return themeOnPrimary
                if (effectiveType === "tonal") return themeOnSecondary
                if (effectiveType === "outlined") return themeOnInverseSurface
            }
            if (effectiveType === "filled" || effectiveType === "outlined") return themeOnSurfaceVariant
        }
        if (effectiveType === "filled") return themeOnPrimary
        if (effectiveType === "tonal") return themeOnSecondaryContainer
        if (effectiveType === "outlined") return themeOnSurfaceVariant
        return themePrimary
    }
    // Unlike disabled content color, this remains an opaque semantic role.
    // MeoStateLayer itself suppresses feedback when the control is disabled.
    readonly property color stateColor: {
        if (vibrant && effectiveType === "filled") return themeOnTertiaryContainer
        if (isToggleButton) {
            if (isSelected) {
                if (effectiveType === "filled" || effectiveType === "elevated") return themeOnPrimary
                if (effectiveType === "tonal") return themeOnSecondary
                if (effectiveType === "outlined") return themeOnInverseSurface
            }
            if (effectiveType === "filled" || effectiveType === "outlined") return themeOnSurfaceVariant
        }
        if (effectiveType === "filled") return themeOnPrimary
        if (effectiveType === "tonal") return themeOnSecondaryContainer
        if (effectiveType === "outlined") return themeOnSurfaceVariant
        return themePrimary
    }
    readonly property real squareRadius: {
        if (size === "xs" || size === "s") return MeoTheme.shapeMedium
        if (size === "m") return MeoTheme.shapeLarge
        return MeoTheme.shapeExtraLarge
    }
    readonly property real pressedRadius: {
        if (size === "xs" || size === "s") return MeoTheme.shapeSmall
        if (size === "m") return MeoTheme.shapeMedium
        return MeoTheme.shapeLarge
    }
    readonly property bool usesRoundSquareShape: shape === "round" || shape === "square"
    readonly property bool selectedSquare: shape === "round" ? isSelected
                                                               : shape === "square" ? !isSelected : false
    readonly property real restingRadius: !usesRoundSquareShape
                                          ? MeoTheme.buttonRadiusForHeight(buttonHeight, false)
                                          : (isToggleButton && selectedSquare ? squareRadius
                                                                               : buttonHeight / 2)
    readonly property real activeRadius: usesRoundSquareShape && pressed
                                        ? pressedRadius : restingRadius

    implicitHeight: buttonHeight
    implicitWidth: Math.max((effectiveType === "text" ? 48 : 64) * themeGlobalScale,
                            contentRow.implicitWidth + leftPadding + rightPadding)
    leftPadding: horizontalPad
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
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight
            opacity: control.loading ? 0 : 1

            Loader {
                id: leadingComponentLoader
                active: control.leadingComponent !== null
                visible: active
                sourceComponent: control.leadingComponent
                width: control.iconSize * control.themeGlobalScale
                height: width
                opacity: control.enabled ? 1 : 0.38
                anchors.verticalCenter: parent.verticalCenter
            }

            MeoIcon {
                icon: control.isSelected && control.selectedIcon !== ""
                      ? control.selectedIcon : (control.icon.name || control.icon.source.toString())
                visible: control.hasIcon && !leadingComponentLoader.active
                fill: control.isSelected && control.selectedIcon !== ""
                size: control.iconSize
                color: control.textColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: control.text
                visible: text !== ""
                font.family: MeoTheme.typefacePlain
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
            scale: MeoTheme.reduceMotion ? 1 : (control.loading ? 1 : 0.86)
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
            strokeColor: control.effectiveType === "outlined" && !(control.isToggleButton && control.isSelected)
                         ? (control.enabled ? control.themeOutlineVariant
                                            : Qt.rgba(control.themeOutlineVariant.r, control.themeOutlineVariant.g, control.themeOutlineVariant.b, 0.10))
                         : "transparent"
            strokeWidth: control.effectiveType === "outlined"
                         ? (control.size === "l" ? 2 * control.themeGlobalScale
                                                : control.size === "xl" ? 3 * control.themeGlobalScale
                                                                        : MeoTheme.strokeWidthThin)
                         : 0
            layer.enabled: control.visible && control.effectiveType === "elevated" && control.enabled
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: control.hovered ? 0.22 : 0.14
                shadowVerticalOffset: (control.hovered ? 2 : 1) * control.themeGlobalScale
                shadowOpacity: 0.12
                shadowColor: MeoTheme.shadow
            }

            MeoStateLayer {
                anchors.fill: parent
                radius: buttonShape.radius
                shape: buttonShape.type
                pressed: control.pressed
                hovered: control.hovered
                focused: control.visualFocus
                color: control.stateColor
            }

            Behavior on color { ColorAnimation { duration: control.motionFast } }
            Behavior on radius {
                enabled: control.bouncy && !MeoTheme.reduceMotion
                NumberAnimation {
                    duration: control.motionShape
                    easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                }
            }
        }
    }
}
