import QtQuick
import QtQuick.Controls
import MeoUI

MeoMotionPopup {
    id: control
    presentation: MeoMotionPopup.BottomSheet

    // 🌟 核心属性
    property Component content: null
    property bool dismissible: true
    // Callers with a scrolling or form-like task can request a stable visible
    // height. The default remains content-sized, preserving the behavior of
    // existing lightweight action sheets.
    property real preferredHeight: 0
    property real maximumHeightRatio: 0.72
    property real minimumHeight: 176 * MeoTheme.globalScale
    // AndroidX BottomSheetDefaults.SheetMaxWidth is 640dp. This sheet keeps
    // its centered desktop treatment instead of stretching past that width.
    property real maximumWidth: 640 * MeoTheme.globalScale

    readonly property real sheetAvailableHeight: parent ? parent.height : 640 * MeoTheme.globalScale
    readonly property real resolvedHeight: preferredHeight > 0
                                          ? preferredHeight
                                          : contentLoader.implicitHeight + 48 * MeoTheme.globalScale

    x: parent ? (parent.width - width) / 2 : 0
    y: sheetAvailableHeight - height
    width: parent ? Math.min(parent.width, maximumWidth) : 360 * MeoTheme.globalScale
    height: Math.min(sheetAvailableHeight * maximumHeightRatio,
                     Math.max(minimumHeight, resolvedHeight))

    modal: true
    focus: true
    closePolicy: control.dismissible
                 ? (Popup.CloseOnEscape | Popup.CloseOnPressOutside)
                 : Popup.NoAutoClose

    background: Rectangle {
        color: MeoTheme.surfaceContainerLow
        radius: MeoTheme.shapeExtraLarge
        // Only round top corners
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: MeoTheme.shapeExtraLarge
            color: parent.color
        }

        // Drag handle
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 22 * MeoTheme.globalScale
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32 * MeoTheme.globalScale
            height: 4 * MeoTheme.globalScale
            radius: 2 * MeoTheme.globalScale
            color: MeoTheme.contentOnSurfaceVariant
        }
    }

    contentItem: Item {
        Loader {
            id: contentLoader
            anchors.top: parent.top
            anchors.topMargin: 48 * MeoTheme.globalScale
            anchors.left: parent.left
            anchors.right: parent.right
            // Forms that opt into preferredHeight need a real viewport so
            // their own Flickable can scroll rather than being clipped by a
            // content-sized popup.
            height: control.preferredHeight > 0
                    ? Math.max(0, control.height - 48 * MeoTheme.globalScale)
                    : implicitHeight
            sourceComponent: control.content
        }
    }

}
