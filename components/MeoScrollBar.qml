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

    contentItem: Rectangle {
        objectName: "meoScrollBarThumb"
        implicitWidth: 8 * control.themeGlobalScale
        implicitHeight: 8 * control.themeGlobalScale
        radius: width / 2

        color: control.pressed ? control.themeOnSurface
             : control.hovered ? control.themeOnSurfaceVariant
             : control.themeOutlineVariant

        opacity: !control.enabled ? MeoTheme.disabledContentOpacity
                 : (control.policy === ScrollBar.AlwaysOn || control.pressed || control.hovered
                    || (control.active && control.size < 1.0) ? 1.0 : 0.0)

        Behavior on color {
            enabled: !MeoTheme.reduceMotion
            ColorAnimation {
                duration: control.motionDurationState
                easing.type: Easing.BezierSpline
                easing.bezierCurve: MeoTheme.motionEasingStandard
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
        color: "transparent"
    }
}
