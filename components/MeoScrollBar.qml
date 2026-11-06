import QtQuick
import QtQuick.Controls
import MeoUI

ScrollBar {
    id: control

    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionDurationState: MeoTheme.motionDurationState

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 2 * themeGlobalScale

    // Desktop scroll indicator (WinUI 3 / macOS overlay scrollers): a thin
    // pill while content scrolls, expanding to a full-width grabbable thumb
    // with a faint track only when the pointer is over the bar or dragging.
    readonly property bool expanded: hovered || pressed
    readonly property real expandedThickness: 8 * themeGlobalScale
    readonly property real collapsedThickness: 3 * themeGlobalScale

    contentItem: Item {
        objectName: "meoScrollBarThumb"
        implicitWidth: 8 * control.themeGlobalScale
        implicitHeight: 8 * control.themeGlobalScale

        opacity: !control.enabled ? MeoTheme.disabledContentOpacity
                 : (control.policy === ScrollBar.AlwaysOn || control.pressed || control.hovered
                    || (control.active && control.size < 1.0) ? 1.0 : 0.0)

        Rectangle {
            objectName: "meoScrollBarThumbPill"
            property real thickness: control.expanded || control.policy === ScrollBar.AlwaysOn
                                              ? control.expandedThickness : control.collapsedThickness
            // Collapse toward the outer (trailing/bottom) edge, where the
            // pointer approaches from.
            x: control.horizontal ? 0 : (control.mirrored ? 0 : parent.width - width)
            y: control.horizontal ? parent.height - height : 0
            width: control.horizontal ? parent.width : thickness
            height: control.horizontal ? thickness : parent.height
            radius: Math.min(width, height) / 2

            color: control.pressed ? control.themeOnSurface
                 : control.hovered ? control.themeOnSurfaceVariant
                 : control.themeOutline

            Behavior on thickness {
                enabled: !MeoTheme.reduceMotion
                NumberAnimation {
                    duration: control.motionDurationState
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: MeoTheme.motionEasingStandard
                }
            }
            Behavior on color {
                enabled: !MeoTheme.reduceMotion
                ColorAnimation {
                    duration: control.motionDurationState
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: MeoTheme.motionEasingStandard
                }
            }
        }

        Behavior on opacity {
            enabled: !MeoTheme.reduceMotion
            NumberAnimation {
                duration: control.motionDurationState
                easing.type: Easing.BezierSpline
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }

    background: Rectangle {
        objectName: "meoScrollBarBackground"
        implicitWidth: 8 * control.themeGlobalScale
        implicitHeight: 8 * control.themeGlobalScale
        radius: Math.min(width, height) / 2
        color: control.themeOutlineVariant
        opacity: control.enabled && control.expanded && control.size < 1.0 ? 0.35 : 0

        Behavior on opacity {
            enabled: !MeoTheme.reduceMotion
            NumberAnimation {
                duration: control.motionDurationState
                easing.type: Easing.BezierSpline
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }
}
