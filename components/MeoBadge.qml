import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property string text: ""
    property int maxCount: 99
    property bool isDot: false
    // The default is the Material count/dot badge. Other shape names are an
    // explicit expressive opt-in and retain the same measured badge bounds.
    property string shape: "circle" // "circle" | "squircle" | "hexagon" ...

    property Item target: null
    readonly property color themeError: MeoTheme.error
    readonly property color themeOnError: MeoTheme.contentOnError
    readonly property real themeGlobalScale: MeoTheme.globalScale

    implicitWidth: isDot ? 6 * themeGlobalScale : Math.max(16 * themeGlobalScale, label.implicitWidth + 8 * themeGlobalScale)
    implicitHeight: isDot ? 6 * themeGlobalScale : 16 * themeGlobalScale
    radius: height / 2
    color: themeError
    readonly property string displayText: {
        // Badge content can be arbitrary text. Only a complete integer label
        // participates in the material count-overflow presentation.
        const numericLabel = /^\d+$/.test(text)
        const count = numericLabel ? Number(text) : NaN
        if (!isNaN(count) && count > maxCount)
            return maxCount + "+"
        return text
    }

    Accessible.role: Accessible.StaticText
    Accessible.name: isDot ? qsTr("New notification") : (displayText === "" ? qsTr("Notification") : qsTr("%1 notifications").arg(displayText))

    // Auto anchoring
    x: target ? target.width - width/2 : 0
    y: target ? -height/2 : 0
    onTargetChanged: if (target) parent = target

    MeoShape {
        anchors.fill: parent
        type: control.shape
        radius: control.radius
        color: control.color
        visible: control.shape !== "circle"
    }

    MeoText {
        id: label
        anchors.centerIn: parent
        text: control.displayText
        visible: !control.isDot
        typeRole: "label"
        typeSize: "small"
        emphasized: true
        color: control.themeOnError
    }
}
