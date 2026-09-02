import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

MeoMotionPopup {
    id: control
    presentation: MeoMotionPopup.Dialog

    property string title: ""
    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property string icon: ""
    property bool showAcceptButton: true
    property bool showRejectButton: true
    property bool showDivider: false
    property Component supportingContent: null
    property real preferredDialogWidth: 400 * themeGlobalScale
    // Applications with an interactive supporting-content slot can nominate
    // its first control. Otherwise the first visible dialog action receives
    // focus when the popup opens, as required by the M3 dialog contract.
    property Item initialFocusTarget: null
    // Matches Material's onDismissRequest for Escape, outside press, and
    // programmatic close without conflating those paths with an explicit
    // reject text action.
    property bool dismissedByAction: false

    signal confirmed()
    signal cancelled()
    signal dismissed()

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real contentPadding: 24 * themeGlobalScale
    readonly property real contentGap: 16 * themeGlobalScale
    readonly property real actionsGap: 24 * themeGlobalScale
    readonly property real actionSpacing: 8 * themeGlobalScale
    readonly property real minimumDialogWidth: 280 * themeGlobalScale
    readonly property real maximumDialogWidth: 560 * themeGlobalScale
    readonly property real availableDialogWidth: parent ? Math.max(0, parent.width - 2 * viewportMargin) : maximumDialogWidth
    readonly property bool hasActions: showAcceptButton || showRejectButton
    readonly property bool hasBody: message !== "" || supportingContent !== null

    initialFocusItem: initialFocusTarget
                      || (showRejectButton ? rejectButton
                                           : (showAcceptButton ? acceptButton : null))

    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0
    width: Math.min(maximumDialogWidth,
                    Math.max(Math.min(minimumDialogWidth, availableDialogWidth),
                             Math.min(availableDialogWidth, preferredDialogWidth)))
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    onAboutToShow: dismissedByAction = false
    onClosed: {
        if (!dismissedByAction)
            dismissed()
    }

    background: Rectangle {
        color: MeoTheme.surfaceContainerHigh
        radius: MeoTheme.dialogRadius
        layer.enabled: control.visible
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.55
            shadowVerticalOffset: 8 * control.themeGlobalScale
            shadowColor: MeoTheme.shadow
        }
    }

    contentItem: Item {
        objectName: "meoDialogSurface"
        // Popup itself is not an Item. Attach dialog semantics to the actual
        // modal surface so Qt exposes it to assistive technology at runtime.
        Accessible.role: Accessible.Dialog
        Accessible.name: control.title !== "" ? control.title : control.message
        Accessible.description: control.title !== "" ? control.message : ""

        implicitWidth: control.width
        implicitHeight: dialogColumn.implicitHeight + 2 * control.contentPadding

        Column {
            id: dialogColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: control.contentPadding
            spacing: 0

            MeoIcon {
                visible: control.icon !== ""
                anchors.horizontalCenter: parent.horizontalCenter
                icon: control.icon
                color: MeoTheme.secondary
                size: 24 * control.themeGlobalScale
            }

            Item {
                width: parent.width
                height: control.icon !== "" && control.title !== "" ? control.contentGap : 0
            }

            Text {
                width: parent.width
                visible: text !== ""
                text: control.title
                font.pixelSize: MeoTheme.headlineSmall.size * control.themeGlobalScale
                font.weight: MeoTheme.headlineSmall.weight
                color: MeoTheme.contentOnSurface
                wrapMode: Text.WordWrap
                horizontalAlignment: control.icon !== "" ? Text.AlignHCenter : Text.AlignLeft
            }

            Item {
                width: parent.width
                height: control.title !== "" && control.hasBody ? control.contentGap : 0
            }

            Text {
                width: parent.width
                visible: control.message !== ""
                text: control.message
                font.pixelSize: MeoTheme.bodyMedium.size * control.themeGlobalScale
                font.weight: MeoTheme.bodyMedium.weight
                color: MeoTheme.contentOnSurfaceVariant
                wrapMode: Text.WordWrap
                horizontalAlignment: control.icon !== "" && control.supportingContent === null ? Text.AlignHCenter : Text.AlignLeft
            }

            Loader {
                width: parent.width
                active: control.supportingContent !== null
                visible: active
                sourceComponent: control.supportingContent
            }

            Item {
                width: parent.width
                height: control.showDivider && control.hasBody ? control.contentGap : 0
            }

            Rectangle {
                width: parent.width
                height: control.showDivider && control.hasBody ? Math.max(1, MeoTheme.strokeWidthThin) : 0
                visible: height > 0
                color: MeoTheme.outlineVariant
            }

            Item {
                width: parent.width
                height: control.hasActions && (control.hasBody || control.title !== "") ? control.actionsGap : 0
            }

            Row {
                anchors.right: parent.right
                spacing: control.actionSpacing
                visible: control.hasActions
                layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

                MeoButton {
                    id: rejectButton
                    objectName: "meoDialogRejectButton"
                    visible: control.showRejectButton
                    text: control.cancelText
                    type: "text"
                    onClicked: {
                        control.dismissedByAction = true
                        control.cancelled()
                        control.close()
                    }
                }

                MeoButton {
                    id: acceptButton
                    objectName: "meoDialogAcceptButton"
                    visible: control.showAcceptButton
                    text: control.confirmText
                    type: "text"
                    onClicked: {
                        control.dismissedByAction = true
                        control.confirmed()
                        control.close()
                    }
                }
            }
        }
    }
}
