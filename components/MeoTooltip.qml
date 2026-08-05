import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

ToolTip {
    id: control

    // 🌟 MD3 Plain Tooltip Specification
    readonly property color themeInverseSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.inverseSurface !== 'undefined') ? MeoTheme.inverseSurface : "#313033"
    readonly property color themeInverseOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnInverseSurface !== 'undefined') ? MeoTheme.contentOnInverseSurface : "#F4F0F4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property real themeFontScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontScale !== 'undefined') ? MeoTheme.fontScale : 1.0
    readonly property string themeFontFamily: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontFamily !== 'undefined') ? MeoTheme.fontFamily : "sans-serif"
    readonly property int motionDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationFast !== 'undefined') ? MeoTheme.motionDurationFast * (MeoTheme.motionScale || 1.0) : 150
    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    padding: 8 * themeGlobalScale
    leftPadding: 12 * themeGlobalScale
    rightPadding: 12 * themeGlobalScale

    contentItem: Text {
        text: control.text
        font.family: control.themeFontFamily
        font.pixelSize: control.fontLabelLarge.size * control.themeFontScale * control.themeGlobalScale
        font.weight: control.fontLabelLarge.weight
        font.letterSpacing: (control.fontLabelLarge.letterSpacing || 0) * control.themeGlobalScale
        color: control.themeInverseOnSurface
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    background: Rectangle {
        implicitHeight: 24 * control.themeGlobalScale
        color: control.themeInverseSurface
        radius: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeExtraSmall !== 'undefined') ? MeoTheme.shapeExtraSmall : 8 * control.themeGlobalScale

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.15
            shadowVerticalOffset: 2 * control.themeGlobalScale
            shadowColor: Qt.rgba(0, 0, 0, 0.2)
        }
    }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: control.motionDuration
            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: (typeof MeoTheme !== 'undefined') ? MeoTheme.motionDurationShort2 : 100
        }
    }
}
