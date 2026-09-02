import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Button {
    id: control

    // 🌟 核心属性
    property string type: "filled" // "standard" | "filled" | "tonal" | "outlined"
    property string size: "s" // "xs" | "s" | "m" | "l" | "xl"
    property string widthOption: "uniform" // "narrow" | "uniform" | "wide"
    property string shape: "circle" // "circle" | "square" | "squircle" | "hexagon" | ...
    // Set this for a controllable selection. A selected button is always
    // treated as a toggle, which preserves existing selected-only callers.
    property bool toggle: false
    property bool selected: false
    property string selectedIcon: ""
    property string badgeText: ""
    property bool badgeDot: false
    readonly property string effectiveType: type === "filledTonal" ? "tonal" : type

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themeSecondary: MeoTheme.secondary
    readonly property color themeOnSecondary: MeoTheme.contentOnSecondary
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property color themeInverseSurface: MeoTheme.inverseSurface
    readonly property color themeOnInverseSurface: MeoTheme.contentOnInverseSurface
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool isSelected: selected || checked
    readonly property bool isToggle: toggle || checkable || isSelected

    readonly property int iconSize: size === "xs" ? 20
                                  : (size === "l" ? 32 : size === "xl" ? 40 : 24)
    readonly property real containerWidth: MeoTheme.iconButtonWidthForSize(size, widthOption)
    readonly property real containerHeight: MeoTheme.iconButtonSizeForSize(size)
    readonly property real minimumTouchTarget: 48 * themeGlobalScale

    // AndroidX keeps the visual container independent from the accessibility
    // target. XS and S therefore retain their 32/40dp appearance inside a
    // 48dp target instead of visually growing to meet that requirement.
    implicitWidth: Math.max(containerWidth, minimumTouchTarget)
    implicitHeight: Math.max(containerHeight, minimumTouchTarget)

    padding: 0
    Accessible.name: isSelected && selectedIcon !== "" ? selectedIcon
                                                         : (icon.name || icon.source.toString())
    Accessible.role: isToggle ? Accessible.CheckBox : Accessible.Button
    Accessible.checked: isToggle ? isSelected : false

    background: Item {
        objectName: "meoIconButtonBackground"
        width: control.containerWidth
        height: control.containerHeight
        anchors.centerIn: parent

        readonly property bool usesRoundSquareShape: control.shape === "circle" || control.shape === "square"
        readonly property bool selectedSquare: control.shape === "circle" ? control.isSelected
                                               : control.shape === "square" ? !control.isSelected
                                                                            : false
        readonly property real squareRadius: {
            if (control.size === "xs" || control.size === "s") return 12 * control.themeGlobalScale
            if (control.size === "l" || control.size === "xl") return 28 * control.themeGlobalScale
            return 16 * control.themeGlobalScale
        }
        readonly property real pressedRadius: {
            if (control.size === "xs" || control.size === "s") return 8 * control.themeGlobalScale
            if (control.size === "l" || control.size === "xl") return 16 * control.themeGlobalScale
            return 12 * control.themeGlobalScale
        }

        MeoShape {
            id: shapeBg
            objectName: "meoIconButtonShape"
            anchors.fill: parent
            type: (control.shape === "circle" || control.shape === "square") ? "rect" : control.shape
            radius: parent.usesRoundSquareShape
                    ? (control.pressed ? parent.pressedRadius
                                       : (parent.selectedSquare ? parent.squareRadius : height / 2))
                    : height / 2
            color: {
                if (!control.enabled) {
                    if (control.effectiveType === "standard" || control.effectiveType === "outlined")
                        return "transparent";
                    return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.10);
                }
                if (control.isSelected) {
                    if (control.effectiveType === "filled") return control.themePrimary;
                    if (control.effectiveType === "tonal") return control.themeSecondary;
                    if (control.effectiveType === "outlined") return control.themeInverseSurface;
                    return "transparent";
                }
                if (control.effectiveType === "filled") {
                    return control.isToggle ? control.themeSurfaceContainer : control.themePrimary;
                }
                if (control.effectiveType === "tonal") return control.themeSecondaryContainer;
                return "transparent";
            }

            strokeColor: {
                if (control.effectiveType !== "outlined") return "transparent";
                if (control.isSelected) return "transparent";
                if (!control.enabled) return Qt.rgba(control.themeOutlineVariant.r, control.themeOutlineVariant.g, control.themeOutlineVariant.b, 0.10);
                return control.themeOutlineVariant;
            }
            strokeWidth: control.effectiveType === "outlined" && !control.isSelected
                         ? MeoTheme.strokeWidthThin : 0

            Behavior on radius {
                enabled: !MeoTheme.reduceMotion
                NumberAnimation {
                    duration: MeoTheme.motionDurationShapeEnter
                    easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                }
            }
            Behavior on color {
                enabled: !MeoTheme.reduceMotion
                ColorAnimation { duration: MeoTheme.motionDurationSelection }
            }

            MeoStateLayer {
                radius: shapeBg.radius
                shape: shapeBg.type
                pressed: control.pressed
                hovered: control.hovered
                focused: control.visualFocus
                color: {
                    if (control.isSelected) {
                        if (control.effectiveType === "filled") return control.themeOnPrimary;
                        if (control.effectiveType === "tonal") return control.themeOnSecondary;
                        if (control.effectiveType === "outlined") return control.themeOnInverseSurface;
                        return control.themePrimary;
                    }
                    if (control.effectiveType === "filled") return control.isToggle
                                                                  ? control.themeOnSurfaceVariant
                                                                  : control.themeOnPrimary;
                    if (control.effectiveType === "tonal") return control.themeOnSecondaryContainer;
                    return control.themeOnSurfaceVariant;
                }

                layer.enabled: control.shape !== "circle" && control.shape !== "square" && control.shape !== "rect"
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: shapeBg.width
                        height: shapeBg.height
                        MeoShape {
                            anchors.fill: parent
                            type: shapeBg.type
                            radius: shapeBg.radius
                        }
                    }
                }
            }
        }

    }

    contentItem: Item {
        objectName: "meoIconButtonContent"
        MeoIcon {
            anchors.centerIn: parent
            icon: control.isSelected ? (control.selectedIcon || control.icon.name || control.icon.source.toString()) : (control.icon.name || control.icon.source.toString())
            fill: control.isSelected
            size: control.iconSize
            color: {
                if (!control.enabled) {
                    const disabledRole = control.effectiveType === "tonal"
                                         ? control.themeOnSurface : control.themeOnSurfaceVariant;
                    return Qt.rgba(disabledRole.r, disabledRole.g, disabledRole.b, 0.38);
                }
                if (control.isSelected) {
                    if (control.effectiveType === "filled") return control.themeOnPrimary;
                    if (control.effectiveType === "tonal") return control.themeOnSecondary;
                    if (control.effectiveType === "outlined") return control.themeOnInverseSurface;
                    return control.themePrimary;
                }
                if (control.effectiveType === "filled") {
                    return control.isToggle ? control.themeOnSurfaceVariant : control.themeOnPrimary;
                }
                if (control.effectiveType === "tonal") return control.themeOnSecondaryContainer;
                return control.themeOnSurfaceVariant;
            }
            Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationFast } }
        }

        MeoBadge {
            text: control.badgeText
            isDot: control.badgeDot
            visible: text !== "" || isDot
            x: (parent.width + control.containerWidth - width) / 2 - 4 * control.themeGlobalScale
            y: (parent.height - control.containerHeight - height) / 2 + 4 * control.themeGlobalScale
        }
    }
}
