import QtQuick
import QtQuick.Controls
import MeoUI

ScrollBar {
    id: control

    readonly property color themeOutline: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outline !== "undefined") ? MeoTheme.outline : "#79747E"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outlineVariant !== "undefined") ? MeoTheme.outlineVariant : "#CAC4D0"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.onSurfaceVariant !== "undefined") ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0

    readonly property int motionDurationState: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 150

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 2 * themeGlobalScale

    contentItem: Rectangle {
        implicitWidth: 8 * control.themeGlobalScale
        implicitHeight: 8 * control.themeGlobalScale
        radius: width / 2

        color: control.pressed ? control.themeOutline
             : control.hovered ? control.themeOnSurfaceVariant
             : control.themeOutlineVariant

        opacity: control.policy === ScrollBar.AlwaysOn || (control.active && control.size < 1.0) ? 1.0 : 0.0

        Behavior on color {
            ColorAnimation {
                duration: control.motionDurationState
                easing.type: Easing.BezierSpline
                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0.0, 0.0, 1.0]
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: control.motionDurationState
                easing.type: Easing.BezierSpline
                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0.0, 0.0, 1.0]
            }
        }
    }

    background: Rectangle {
        implicitWidth: 8 * control.themeGlobalScale
        implicitHeight: 8 * control.themeGlobalScale
        color: "transparent"
    }
}
