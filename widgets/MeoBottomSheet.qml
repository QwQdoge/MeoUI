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
    property real minimumHeight: 176 * themeGlobalScale

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property real sheetAvailableHeight: parent ? parent.height : 640 * themeGlobalScale
    readonly property real resolvedHeight: preferredHeight > 0
                                          ? preferredHeight
                                          : contentLoader.implicitHeight + 48 * themeGlobalScale

    x: parent ? (parent.width - width) / 2 : 0
    y: sheetAvailableHeight - height
    width: parent ? parent.width : 360 * themeGlobalScale
    height: Math.min(sheetAvailableHeight * maximumHeightRatio,
                     Math.max(minimumHeight, resolvedHeight))

    modal: true
    focus: true
    closePolicy: control.dismissible
                 ? (Popup.CloseOnEscape | Popup.CloseOnPressOutside)
                 : Popup.NoAutoClose

    background: Rectangle {
        color: control.themeSurfaceContainerLow
        radius: 28 * control.themeGlobalScale
        // Only round top corners
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 28 * control.themeGlobalScale
            color: parent.color
        }

        // Drag handle
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 22 * control.themeGlobalScale
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32 * control.themeGlobalScale
            height: 4 * control.themeGlobalScale
            radius: 2 * control.themeGlobalScale
            color: control.themeOutlineVariant
        }
    }

    contentItem: Item {
        Loader {
            id: contentLoader
            anchors.top: parent.top
            anchors.topMargin: 48 * control.themeGlobalScale
            anchors.left: parent.left
            anchors.right: parent.right
            // Forms that opt into preferredHeight need a real viewport so
            // their own Flickable can scroll rather than being clipped by a
            // content-sized popup.
            height: control.preferredHeight > 0
                    ? Math.max(0, control.height - 48 * control.themeGlobalScale)
                    : implicitHeight
            sourceComponent: control.content
        }
    }

}
