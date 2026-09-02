import QtQuick
import QtQuick.Controls
import MeoUI

MeoMotionPopup {
    id: control
    presentation: MeoMotionPopup.FullScreen
    // A full-screen dialog always occupies the application overlay.  Without
    // this, a declaration inside a narrow layout inherits that layout's width
    // and becomes an accidental inline sheet.
    parent: Overlay.overlay

    property string title: ""
    property Component content: null
    property var actions: [] // Header actions: { text: "", action: function }
    property var bottomActions: [] // Bottom actions: { text: "", action: function }
    property bool showDivider: false

    signal closedByUser()
    signal actionTriggered(int index)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real maximumDialogWidth: 560 * themeGlobalScale
    readonly property real headerHeight: 56 * themeGlobalScale
    readonly property real bottomActionHeight: 56 * themeGlobalScale
    readonly property real inlinePadding: 24 * themeGlobalScale
    readonly property bool hasBottomActions: bottomActions && bottomActions.length > 0

    // The close affordance is the first interactive control in the 56dp
    // header, so it is the default focus landing point on open.
    initialFocusItem: closeButton

    x: parent ? Math.max(0, (parent.width - width) / 2) : 0
    y: 0
    width: parent ? Math.min(parent.width, maximumDialogWidth) : maximumDialogWidth
    height: parent ? parent.height : 0
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    background: Rectangle {
        color: MeoTheme.surfaceContainerHigh
        radius: MeoTheme.shapeNone
    }

    contentItem: Item {
        objectName: "meoFullScreenDialogSurface"
        // Popup itself is not an Item. Attach dialog semantics to the actual
        // full-height modal surface so the role is not ignored by Qt.
        Accessible.role: Accessible.Dialog
        Accessible.name: control.title

        anchors.fill: parent

        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: control.headerHeight

            MeoIconButton {
                id: closeButton
                objectName: "meoFullScreenDialogCloseButton"
                // The dialog spec calls for a 24dp close icon inside a 48dp
                // target. MeoIconButton's small 40dp visual container keeps
                // that target without promoting this affordance to the 96dp
                // large expressive button.
                size: "s"
                icon.name: "close"
                anchors.left: parent.left
                // The 48dp action target extends 12dp beyond the 24dp visual
                // icon inset required by the full-screen dialog spec.
                anchors.leftMargin: 12 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                Accessible.name: "Close dialog"
                onClicked: {
                    control.closedByUser()
                    control.close()
                }
            }

            Text {
                anchors.left: closeButton.right
                anchors.leftMargin: 8 * control.themeGlobalScale
                anchors.right: headerActions.left
                anchors.rightMargin: 8 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                text: control.title
                elide: Text.ElideRight
                font.pixelSize: MeoTheme.titleLarge.size * control.themeGlobalScale
                font.weight: MeoTheme.titleLarge.weight
                color: MeoTheme.contentOnSurface
                verticalAlignment: Text.AlignVCenter
            }

            Row {
                id: headerActions
                anchors.right: parent.right
                anchors.rightMargin: control.inlinePadding - 12 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8 * control.themeGlobalScale
                layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

                Repeater {
                    model: control.actions ? control.actions.length : 0

                    MeoButton {
                        readonly property var actionEntry: control.actions[index] || ({})
                        text: actionEntry.text || ""
                        type: "text"
                        onClicked: {
                            if (actionEntry.action)
                                actionEntry.action()
                            control.actionTriggered(index)
                        }
                    }
                }
            }
        }

        Rectangle {
            id: headerDivider
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: control.showDivider ? Math.max(1, MeoTheme.strokeWidthThin) : 0
            visible: height > 0
            color: MeoTheme.outlineVariant
        }

        Loader {
            anchors.top: headerDivider.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: bottomBar.top
            anchors.leftMargin: control.inlinePadding
            anchors.rightMargin: control.inlinePadding
            anchors.topMargin: control.inlinePadding
            anchors.bottomMargin: control.hasBottomActions ? 0 : control.inlinePadding
            sourceComponent: control.content
        }

        Item {
            id: bottomBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: control.hasBottomActions ? control.bottomActionHeight : 0
            visible: height > 0

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: Math.max(1, MeoTheme.strokeWidthThin)
                color: MeoTheme.outlineVariant
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: control.inlinePadding - 12 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8 * control.themeGlobalScale
                layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

                Repeater {
                    model: control.bottomActions ? control.bottomActions.length : 0

                    MeoButton {
                        readonly property var actionEntry: control.bottomActions[index] || ({})
                        text: actionEntry.text || ""
                        type: "text"
                        onClicked: {
                            if (actionEntry.action)
                                actionEntry.action()
                            control.actionTriggered(index)
                        }
                    }
                }
            }
        }
    }
}
