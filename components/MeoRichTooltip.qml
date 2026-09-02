import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Popup {
    id: control

    // 🌟 核心对外属性
    property string title: ""
    property string text: ""
    property string icon: "" // 🌟 New: Illustrative Icon
    property string image: "" // 🌟 New: Illustrative Image
    property string shape: "rect" // 🌟 MD3 Expressive Shape
    property var actions: [] // Array of { text: "", action: function }

    // AndroidX RichTooltipTokens; icon/image/shape remain explicit MeoUI extensions.
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontTitleSmall: MeoTheme.titleSmall
    readonly property var fontBodyMedium: MeoTheme.bodyMedium

    Accessible.role: Accessible.ToolTip
    Accessible.name: title.length > 0 ? title : text
    Accessible.description: title.length > 0 ? text : ""

    padding: 0
    // Rich tooltips use the Material maximum as their preferred surface width.
    // A Popup's immediate parent can be a small trigger item, so sizing from it
    // makes the text wrap into an unusable narrow column.
    readonly property real maximumWidth: 320 * themeGlobalScale
    width: maximumWidth
    focus: actions.length > 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: MeoShape {
        id: shapeBg
        type: control.shape
        color: control.themeSurfaceContainer
        radius: MeoTheme.shapeMedium
        // AndroidX RichTooltipTokens.ContainerElevation = Level2.

        layer.enabled: control.visible
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: 2 * control.themeGlobalScale
            shadowColor: Qt.rgba(0,0,0,0.2)
        }
    }

    contentItem: Column {
        padding: 0
        spacing: 0

        // Illustrative Image/Icon
        Rectangle {
            width: parent.width
            height: 120 * control.themeGlobalScale
            visible: control.image !== "" || control.icon !== ""
            color: control.themeSurfaceContainer
            radius: shapeBg.radius
            clip: true

            Image {
                anchors.fill: parent
                source: control.image
                fillMode: Image.PreserveAspectCrop
                visible: control.image !== ""
            }

            MeoIcon {
                anchors.centerIn: parent
                icon: control.icon
                size: 48
                color: control.themeOnSurfaceVariant
                visible: control.icon !== "" && control.image === ""
            }

            layer.enabled: control.visible
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: Item {
                    width: shapeBg.width
                    height: shapeBg.height
                    MeoShape {
                        anchors.fill: parent
                        type: control.shape
                        radius: shapeBg.radius
                    }
                }
            }
        }

        Column {
            width: parent.width
            padding: 16 * control.themeGlobalScale
            spacing: 12 * control.themeGlobalScale

            Text {
                objectName: "meoRichTooltipTitle"
                text: control.title
                visible: text !== ""
                width: parent.width - 32 * control.themeGlobalScale
                font.family: MeoTheme.typefacePlain
                font.pixelSize: control.fontTitleSmall.size * control.themeGlobalScale
                font.weight: control.fontTitleSmall.weight
                font.letterSpacing: control.fontTitleSmall.letterSpacing * control.themeGlobalScale
                color: control.themeOnSurfaceVariant
                wrapMode: Text.WordWrap
            }

            Text {
                objectName: "meoRichTooltipText"
                text: control.text
                width: parent.width - 32 * control.themeGlobalScale
                font.family: MeoTheme.typefacePlain
                font.pixelSize: control.fontBodyMedium.size * control.themeGlobalScale
                font.weight: control.fontBodyMedium.weight
                font.letterSpacing: control.fontBodyMedium.letterSpacing * control.themeGlobalScale
                color: control.themeOnSurfaceVariant
                wrapMode: Text.WordWrap
            }

            Row {
                visible: control.actions.length > 0
                width: parent.width - 32 * control.themeGlobalScale
                layoutDirection: Qt.RightToLeft
                spacing: 8 * control.themeGlobalScale

                Repeater {
                    model: control.actions
                    MeoButton {
                        objectName: "meoRichTooltipAction_" + index
                        text: modelData.text
                        type: "text"
                        onClicked: {
                            if (modelData.action) modelData.action()
                            control.close()
                        }
                    }
                }
            }
        }
    }

    enter: Transition {
        enabled: !MeoTheme.reduceMotion
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: MeoTheme.motionDurationEffectFast; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.8; to: 1.0; duration: MeoTheme.motionDurationSpatialFast; easing.type: Easing.OutCubic }
        }
    }
    exit: Transition {
        enabled: !MeoTheme.reduceMotion
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: MeoTheme.motionDurationEffectFast; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.8; duration: MeoTheme.motionDurationSpatialFast; easing.type: Easing.InCubic }
        }
    }
}
