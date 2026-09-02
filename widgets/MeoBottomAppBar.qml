import QtQuick
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property Component fab: null
    property var navigationIcons: []

    // AndroidX BottomAppBarTokens: 80dp SurfaceContainer, CornerNone. This
    // legacy baseline is intentionally distinct from the M3 Expressive
    // MeoDockedToolbar replacement.
    width: parent ? parent.width : 360 * MeoTheme.globalScale
    height: 80 * MeoTheme.globalScale
    color: MeoTheme.surfaceContainer
    radius: MeoTheme.shapeNone
    clip: true

    Item {
        anchors.fill: parent
        // BottomAppBarDefaults.ContentPadding resolves to 4dp around a 48dp
        // touch target. The optional FAB itself has a 12dp end inset.
        anchors.leftMargin: 4 * MeoTheme.globalScale
        anchors.rightMargin: 4 * MeoTheme.globalScale
        anchors.topMargin: 4 * MeoTheme.globalScale
        anchors.bottomMargin: 4 * MeoTheme.globalScale

        Row {
            id: navigationRow
            anchors.left: parent.left
            anchors.right: control.fab ? fabSlot.left : parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Repeater {
                model: control.navigationIcons
                delegate: Item {
                    width: 48 * MeoTheme.globalScale
                    height: 48 * MeoTheme.globalScale

                    Loader {
                        anchors.centerIn: parent
                        sourceComponent: typeof modelData === "string" ? null : modelData
                    }

                    MeoIconButton {
                        anchors.centerIn: parent
                        visible: typeof modelData === "string"
                        icon.name: visible ? modelData : ""
                        type: "standard"
                    }
                }
            }
        }

        Item {
            id: fabSlot
            visible: control.fab !== null
            width: Math.max(56 * MeoTheme.globalScale, fabLoader.implicitWidth)
            height: Math.max(56 * MeoTheme.globalScale, fabLoader.implicitHeight)
            anchors.right: parent.right
            anchors.rightMargin: 12 * MeoTheme.globalScale
            anchors.top: parent.top
            anchors.topMargin: 8 * MeoTheme.globalScale

            Loader {
                id: fabLoader
                anchors.centerIn: parent
                sourceComponent: control.fab
                asynchronous: false
            }
        }
    }
}
