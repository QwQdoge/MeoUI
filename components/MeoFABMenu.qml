import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Item {
    id: control

    // 🌟 核心对外属性 (M3 Expressive Speed-Dial FAB Menu API)
    // model: [{ label: "New document", icon: "note_add", action: function }, ...]
    property var model: []
    property bool opened: false
    property string icon: "add"
    property string activeIcon: "close"
    property string fabType: "regular" // "regular" | "large" | "small" | "tertiary"
    property color color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    property color onColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    property color itemColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHigh !== 'undefined') ? MeoTheme.surfaceContainerHigh : "#ECE6F0"
    property color itemOnColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1D1B20"
    property bool enableScrim: true

    // 🌟 核心信号
    signal itemClicked(int index, var itemData)
    signal toggled(bool opened)

    // 🌟 主题防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property real themeFontScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontScale !== 'undefined') ? MeoTheme.fontScale : 1.0
    readonly property string themeFontFamily: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontFamily !== 'undefined') ? MeoTheme.fontFamily : "sans-serif"
    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }
    readonly property int motionDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium1 !== 'undefined') ? MeoTheme.motionDurationMedium1 * (MeoTheme.motionScale || 1.0) : 250

    implicitWidth: mainFab.implicitWidth
    implicitHeight: mainFab.implicitHeight

    // 🌟 1. Speed-Dial 弹出层 Popup (支持点选遮罩与跨层渲染)
    Popup {
        id: menuPopup
        x: mainFab.x + mainFab.width - width
        y: mainFab.y - height - 12 * control.themeGlobalScale
        width: contentColumn.implicitWidth + 24 * control.themeGlobalScale
        height: contentColumn.implicitHeight
        padding: 0
        visible: control.opened
        modal: control.enableScrim
        dim: control.enableScrim
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        onClosed: {
            control.opened = false
            control.toggled(false)
        }

        background: Item {
            // Invisible background for speed dial layout
        }

        contentItem: Column {
            id: contentColumn
            spacing: 12 * control.themeGlobalScale
            anchors.right: parent.right

            Repeater {
                model: control.model
                delegate: Row {
                    id: itemRow
                    required property int index
                    required property var modelData
                    anchors.right: parent.right
                    spacing: 12 * control.themeGlobalScale
                    scale: control.opened ? 1.0 : 0.0
                    opacity: control.opened ? 1.0 : 0.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: control.motionDuration + (itemRow.index * 25)
                            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: control.motionDuration + (itemRow.index * 15)
                        }
                    }

                    // 🏷️ Action Label Pill
                    Rectangle {
                        id: labelPill
                        anchors.verticalCenter: miniFab.verticalCenter
                        implicitWidth: labelText.implicitWidth + 24 * control.themeGlobalScale
                        implicitHeight: 32 * control.themeGlobalScale
                        radius: 16 * control.themeGlobalScale
                        color: control.itemColor
                        visible: itemRow.modelData.label !== undefined && itemRow.modelData.label !== ""

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowBlur: 0.15
                            shadowVerticalOffset: 2 * control.themeGlobalScale
                            shadowColor: Qt.rgba(0, 0, 0, 0.16)
                        }

                        Text {
                            id: labelText
                            anchors.centerIn: parent
                            text: itemRow.modelData.label || ""
                            color: control.itemOnColor
                            font.family: control.themeFontFamily
                            font.pixelSize: control.fontLabelLarge.size * control.themeFontScale * control.themeGlobalScale
                            font.weight: control.fontLabelLarge.weight
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: triggerAction()
                        }
                    }

                    // 🔘 Mini FAB Button (40dp x 40dp)
                    Rectangle {
                        id: miniFab
                        width: 40 * control.themeGlobalScale
                        height: 40 * control.themeGlobalScale
                        radius: 20 * control.themeGlobalScale
                        color: itemMouse.pressed
                               ? Qt.darker(control.itemColor, 1.1)
                               : (itemMouse.containsMouse ? Qt.lighter(control.itemColor, 1.05) : control.itemColor)

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowBlur: 0.2
                            shadowVerticalOffset: 3 * control.themeGlobalScale
                            shadowColor: Qt.rgba(0, 0, 0, 0.2)
                        }

                        MeoIcon {
                            anchors.centerIn: parent
                            icon: itemRow.modelData.icon || "arrow_forward"
                            size: 20 * control.themeGlobalScale
                            color: control.itemOnColor
                        }

                        MeoStateLayer {
                            radius: parent.radius
                            pressed: itemMouse.pressed
                            hovered: itemMouse.containsMouse
                            color: control.itemOnColor
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: triggerAction()
                        }
                    }

                    function triggerAction() {
                        if (itemRow.modelData.action && typeof itemRow.modelData.action === "function") {
                            itemRow.modelData.action()
                        }
                        control.itemClicked(itemRow.index, itemRow.modelData)
                        control.opened = false
                        control.toggled(false)
                    }
                }
            }
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: control.motionDuration }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: (typeof MeoTheme !== 'undefined') ? MeoTheme.motionDurationFast : 150 }
        }
    }

    // 🌟 2. 主 FAB 按钮 (Main Trigger FAB)
    MeoFAB {
        id: mainFab
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        icon.name: control.opened ? control.activeIcon : control.icon
        type: control.fabType
        
        // Dynamic Icon Rotation Effect for M3 Expressive morph
        transform: Rotation {
            origin.x: mainFab.width / 2
            origin.y: mainFab.height / 2
            angle: control.opened ? 135 : 0

            Behavior on angle {
                NumberAnimation {
                    duration: control.motionDuration
                    easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
                }
            }
        }

        onClicked: {
            control.opened = !control.opened
            control.toggled(control.opened)
        }
    }
}
