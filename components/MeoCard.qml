import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Frame {
    id: control

    property string type: "elevated" // "elevated" | "filled" | "outlined"
    property int level: type === "elevated" ? 1 : 0
    property real radius: MeoTheme.cardRadius
    property string shape: "rect"
    property bool interactive: false
    property bool selected: false
    // Baseline M3 cards use state/elevation feedback rather than a scale
    // transform. Keep the earlier MeoUI treatment available as an opt-in.
    property bool bouncy: false
    property bool compact: false

    signal clicked()

    readonly property bool isDarkMode: MeoTheme.isDarkMode
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeSurfaceVariant: MeoTheme.surfaceVariant
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeSurfaceContainerHighest: MeoTheme.surfaceContainerHighest
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property color themeShadow: MeoTheme.shadow
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionFast: MeoTheme.motionDurationState
    readonly property int motionShape: MeoTheme.motionDurationShapeSettle
    readonly property bool reducedMotion: MeoTheme.reduceMotion

    readonly property real effectiveRadius: compact ? Math.min(radius, 20 * themeGlobalScale) : radius
    function compositeColor(foreground, opacity, background) {
        // AndroidX resolves disabled Card tokens by compositing a translucent
        // token over the card surface. Theme colors are opaque, so the result
        // is an opaque color suitable for MeoShape and MultiEffect.
        return Qt.rgba(foreground.r * opacity + background.r * (1 - opacity),
                       foreground.g * opacity + background.g * (1 - opacity),
                       foreground.b * opacity + background.b * (1 - opacity),
                       1)
    }
    readonly property color containerColor: {
        if (selected) return themePrimaryContainer
        if (!enabled) {
            if (type === "filled")
                return compositeColor(themeSurfaceVariant, MeoTheme.disabledContentOpacity, themeSurfaceContainerHighest)
            if (type === "elevated")
                return compositeColor(themeSurface, MeoTheme.disabledContentOpacity, themeSurface)
            return themeSurface
        }
        if (type === "filled") return themeSurfaceContainerHighest
        if (type === "elevated") return themeSurfaceContainerLow
        return themeSurface
    }
    readonly property real elevation: {
        if (type === "elevated") {
            const baseElevation = Math.max(0, level) * themeGlobalScale
            if (interactive && enabled && hitArea.containsMouse)
                return Math.max(2 * themeGlobalScale, baseElevation)
            return baseElevation
        }
        if (interactive && enabled && hitArea.containsMouse)
            return 1 * themeGlobalScale
        return 0
    }

    padding: (compact ? 12 : 16) * themeGlobalScale
    activeFocusOnTab: interactive
    Accessible.role: interactive ? Accessible.Button : Accessible.Pane
    Accessible.focusable: interactive
    Accessible.selected: selected
    Accessible.onPressAction: if (interactive) activate()
    Keys.onReturnPressed: if (interactive) activate()
    Keys.onEnterPressed: if (interactive) activate()
    Keys.onSpacePressed: if (interactive) activate()

    function activate() {
        if (!interactive || !enabled)
            return
        clicked()
    }

    background: Item {
        MeoShape {
            id: shapeBg
            objectName: "meoCardShape"
            anchors.fill: parent
            type: control.shape
            radius: {
                if (!control.interactive) return control.effectiveRadius
                if (hitArea.pressed) return Math.max(14 * control.themeGlobalScale, control.effectiveRadius - 8 * control.themeGlobalScale)
                return control.effectiveRadius
            }
            color: control.containerColor
            strokeColor: {
                if (control.selected) return control.themePrimary
                if (control.type === "outlined") {
                    if (!control.enabled)
                        return control.compositeColor(control.themeOutline,
                                                      MeoTheme.disabledContainerOpacity,
                                                      control.themeSurfaceContainerLow)
                    return control.themeOutlineVariant
                }
                return "transparent"
            }
            strokeWidth: control.selected ? 2 * control.themeGlobalScale
                                          : control.type === "outlined" ? 1 * control.themeGlobalScale : 0

            scale: control.interactive && control.bouncy && !control.reducedMotion ? (hitArea.pressed ? 0.985 : 1.0) : 1.0

            layer.enabled: control.visible && control.elevation > 0
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: control.elevation * 0.12
                shadowVerticalOffset: control.elevation * control.themeGlobalScale
                shadowOpacity: control.isDarkMode ? 0.18 : 0.12
                shadowColor: control.themeShadow
            }

            MeoStateLayer {
                anchors.fill: parent
                radius: shapeBg.radius
                shape: shapeBg.type
                visible: control.interactive
                pressed: hitArea.pressed
                hovered: hitArea.containsMouse
                focused: control.activeFocus
                pressX: hitArea.mouseX
                pressY: hitArea.mouseY
                color: control.themeOnSurface
            }

            Behavior on color {
                enabled: !control.reducedMotion
                ColorAnimation { duration: control.motionFast }
            }
            Behavior on radius {
                enabled: !control.reducedMotion
                NumberAnimation {
                    duration: control.motionShape
                    easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                }
            }
            Behavior on scale {
                enabled: !control.reducedMotion
                NumberAnimation {
                    duration: control.motionFast
                    easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                }
            }
        }

        MouseArea {
            id: hitArea
            anchors.fill: parent
            enabled: control.interactive && control.enabled
            hoverEnabled: true
            cursorShape: control.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                control.forceActiveFocus(Qt.MouseFocusReason)
                control.activate()
            }
        }
    }
}
