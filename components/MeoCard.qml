import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Frame {
    id: control

    property string type: "elevated" // "elevated" | "filled" | "outlined"
    property int level: type === "elevated" ? 1 : 0
    property real radius: (typeof MeoTheme !== "undefined" && typeof MeoTheme.shapeExtraLarge !== "undefined") ? MeoTheme.shapeExtraLarge : 28 * themeGlobalScale
    property string shape: "rect"
    property bool interactive: false
    property bool selected: false
    property bool bouncy: true
    property bool compact: false

    signal clicked()

    readonly property bool isDarkMode: (typeof MeoTheme !== "undefined" && typeof MeoTheme.isDarkMode !== "undefined") ? MeoTheme.isDarkMode : false
    readonly property color themeSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surface !== "undefined") ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined") ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainer !== "undefined") ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themeSurfaceContainerHigh: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerHigh !== "undefined") ? MeoTheme.surfaceContainerHigh : "#ECE6F0"
    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primaryContainer !== "undefined") ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outlineVariant !== "undefined") ? MeoTheme.outlineVariant : "#CAC4D0"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 100
    readonly property int motionShape: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationShapeSettle !== "undefined") ? MeoTheme.motionDurationShapeSettle : 220

    readonly property real effectiveRadius: compact ? Math.min(radius, 20 * themeGlobalScale) : radius
    readonly property color containerColor: {
        if (selected) return themePrimaryContainer
        if (type === "filled") return themeSurfaceContainerHigh
        if (type === "elevated") return themeSurfaceContainerLow
        return themeSurface
    }
    readonly property real elevation: {
        if (type !== "elevated" || !enabled) return 0
        if (interactive && hitArea.pressed) return 0
        if (interactive && hitArea.containsMouse) return 2
        return Math.max(0, Math.min(2, level))
    }

    padding: (compact ? 12 : 20) * themeGlobalScale
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
                if (control.type === "outlined") return control.themeOutlineVariant
                return "transparent"
            }
            strokeWidth: control.selected ? 2 * control.themeGlobalScale
                                          : control.type === "outlined" ? 1 * control.themeGlobalScale : 0

            scale: control.interactive && control.bouncy ? (hitArea.pressed ? 0.985 : 1.0) : 1.0

            layer.enabled: control.visible && control.elevation > 0
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: control.elevation * 0.12
                shadowVerticalOffset: control.elevation * control.themeGlobalScale
                shadowOpacity: control.isDarkMode ? 0.18 : 0.12
                shadowColor: Qt.rgba(0, 0, 0, 0.22)
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
