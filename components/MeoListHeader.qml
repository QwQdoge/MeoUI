import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string text: ""
    property string type: "standard" // "standard" | "emphasized"
    property real topPadding: 0
    property real bottomPadding: 0
    property real leftPadding: 16 * themeGlobalScale
    property real rightPadding: 16 * themeGlobalScale

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontLabelLarge: MeoTheme.labelLarge

    implicitWidth: parent ? parent.width : 360 * themeGlobalScale
    implicitHeight: 40 * themeGlobalScale + topPadding + bottomPadding
    width: implicitWidth
    height: implicitHeight

    Accessible.role: Accessible.StaticText
    Accessible.name: text

    Text {
        objectName: "meoListHeaderText"
        anchors.fill: parent
        anchors.leftMargin: control.leftPadding
        anchors.rightMargin: control.rightPadding
        anchors.topMargin: control.topPadding
        anchors.bottomMargin: control.bottomPadding
        text: control.text
        textFormat: Text.PlainText
        font.family: MeoTheme.typefacePlain
        font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
        font.weight: fontLabelLarge.weight
        color: control.type === "emphasized" ? control.themePrimary : control.themeOnSurfaceVariant
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        Behavior on color {
            enabled: !MeoTheme.reduceMotion
            ColorAnimation {
                duration: MeoTheme.motionDurationEffectDefault
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }
}
