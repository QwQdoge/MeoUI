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
            if (interactive && enabled && hoverHandler.hovered)
                return Math.max(2 * themeGlobalScale, baseElevation)
            return baseElevation
        }
        if (interactive && enabled && hoverHandler.hovered)
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
                if (tapHandler.pressed) return Math.max(14 * control.themeGlobalScale, control.effectiveRadius - 8 * control.themeGlobalScale)
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

            scale: control.interactive && control.bouncy && !control.reducedMotion ? (tapHandler.pressed ? 0.985 : 1.0) : 1.0

            layer.enabled: control.visible && control.elevation > 0
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: control.elevation * 0.12
                shadowVerticalOffset: control.elevation * control.themeGlobalScale
                shadowOpacity: control.isDarkMode ? 0.18 : 0.12
                shadowColor: control.themeShadow
            }

            MeoStateLayer {
                id: cardStateLayer
                objectName: "meoCardStateLayer"
                anchors.fill: parent
                radius: shapeBg.radius
                shape: shapeBg.type
                visible: control.interactive
                internalPointerTrackingEnabled: false
                hovered: hoverHandler.hovered
                focused: control.activeFocus
                color: control.themeOnSurface
            }

            Behavior on color {
                enabled: !control.reducedMotion
                ColorAnimation { duration: control.motionFast; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
            }
            Behavior on radius {
                enabled: !control.reducedMotion
                NumberAnimation {
                    duration: control.motionShape
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                }
            }
            Behavior on scale {
                enabled: !control.reducedMotion
                NumberAnimation {
                    duration: control.motionFast
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                }
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        enabled: control.interactive && control.enabled
        cursorShape: control.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    TapHandler {
        id: tapHandler
        enabled: control.interactive && control.enabled
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onPressedChanged: {
            if (pressed) {
                const mapped = cardStateLayer.mapFromItem(
                    tapHandler.parent,
                    tapHandler.point.position.x, tapHandler.point.position.y)
                cardStateLayer.trigger(mapped.x, mapped.y)
            } else {
                cardStateLayer.releaseRipple()
            }
        }
        onTapped: {
            control.forceActiveFocus(Qt.MouseFocusReason)
            control.activate()
        }
    }
}
