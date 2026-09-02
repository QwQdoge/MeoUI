import QtQuick
import QtQuick.Controls
import MeoUI

ToolTip {
    id: control

    // AndroidX PlainTooltipTokens: inverse roles, CornerExtraSmall and BodySmall.
    readonly property color themeInverseSurface: MeoTheme.inverseSurface
    readonly property color themeInverseOnSurface: MeoTheme.contentOnInverseSurface
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real themeFontScale: MeoTheme.fontScale
    readonly property string themeFontFamily: MeoTheme.typefacePlain
    readonly property int motionSpatialFast: MeoTheme.motionDurationSpatialFast
    readonly property int motionEffectFast: MeoTheme.motionDurationEffectFast
    readonly property var fontBodySmall: MeoTheme.bodySmall

    padding: 4 * themeGlobalScale
    leftPadding: 8 * themeGlobalScale
    rightPadding: 8 * themeGlobalScale
    implicitWidth: Math.min(200 * themeGlobalScale,
                            Math.max(40 * themeGlobalScale,
                                     contentItem.implicitWidth + leftPadding + rightPadding))
    implicitHeight: Math.max(24 * themeGlobalScale,
                             contentItem.implicitHeight + topPadding + bottomPadding)

    Accessible.role: Accessible.ToolTip
    Accessible.name: text

    contentItem: Text {
        objectName: "meoTooltipText"
        text: control.text
        font.family: control.themeFontFamily
        font.pixelSize: control.fontBodySmall.size * control.themeFontScale * control.themeGlobalScale
        font.weight: control.fontBodySmall.weight
        font.letterSpacing: control.fontBodySmall.letterSpacing * control.themeGlobalScale
        color: control.themeInverseOnSurface
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }

    background: Rectangle {
        objectName: "meoTooltipBackground"
        implicitWidth: 40 * control.themeGlobalScale
        implicitHeight: 24 * control.themeGlobalScale
        color: control.themeInverseSurface
        radius: MeoTheme.shapeExtraSmall
    }

    enter: Transition {
        enabled: !MeoTheme.reduceMotion
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: control.motionEffectFast
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "scale"
                from: 0.8
                to: 1.0
                duration: control.motionSpatialFast
                easing.type: Easing.OutCubic
            }
        }
    }
    exit: Transition {
        enabled: !MeoTheme.reduceMotion
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: control.motionEffectFast
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "scale"
                from: 1.0
                to: 0.8
                duration: control.motionSpatialFast
                easing.type: Easing.InCubic
            }
        }
    }
}
