import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

// A transient third-level task surface.  It is deliberately a popup, not a
// navigation destination: accepting, rejecting, or handing the user to a new
// destination retracts the sheet so Settings keeps its normal two-level flow.
Item {
    id: control

    property Item popupParent: null
    property string title: ""
    property string subtitle: ""
    property Component content: null
    property bool showCloseButton: true

    property string acceptText: ""
    property string rejectText: ""
    property bool acceptEnabled: true
    property bool rejectEnabled: true
    // Authentication and other security-sensitive tasks must not disappear
    // behind an accidental outside click or Escape key while the backend is
    // waiting for an explicit response.  The caller can disable dismissal and
    // provide a deliberate reject action instead.
    property bool dismissible: true
    property bool closeOnAccept: true
    property bool closeOnReject: true
    property bool closeOnNavigation: true
    // A task detail remains a right side sheet on desktop. At compact widths
    // it becomes a bottom sheet, so a phone-sized Settings window never tries
    // to reserve a narrow desktop panel beside its page.
    property string compactPresentation: "bottomSheet" // bottomSheet | sideSheet
    property real compactPreferredHeight: 560 * MeoTheme.globalScale

    readonly property bool useBottomSheet: compactPresentation === "bottomSheet"
                                             && popupParent !== null
                                             && popupParent.width < 680 * MeoTheme.globalScale
    readonly property bool isOpen: sideSheet.opened || bottomSheet.opened

    signal accepted()
    signal rejected()
    signal navigationRequested(string destination)
    signal opened()
    signal closed()

    implicitWidth: 0
    implicitHeight: 0

    function open() {
        if (useBottomSheet)
            bottomSheet.open()
        else
            sideSheet.open()
    }

    function close() {
        sideSheet.close()
        bottomSheet.close()
    }

    function accept() {
        if (!acceptEnabled)
            return
        accepted()
        if (closeOnAccept)
            close()
    }

    function reject() {
        if (!rejectEnabled)
            return
        rejected()
        if (closeOnReject)
            close()
    }

    // Use this when a task opens a second-level page or a system-owned handoff.
    // It is intentionally not a persistent third-level route.
    function navigate(destination) {
        navigationRequested(destination)
        if (closeOnNavigation)
            close()
    }

    onUseBottomSheetChanged: {
        if (sideSheet.opened && useBottomSheet) {
            sideSheet.close()
            bottomSheet.open()
        } else if (bottomSheet.opened && !useBottomSheet) {
            bottomSheet.close()
            sideSheet.open()
        }
    }

    MeoSideSheetModal {
        id: sideSheet
        parent: control.popupParent !== null ? control.popupParent : control.parent
        title: control.title
        showCloseButton: control.showCloseButton
        dismissible: control.dismissible
        content: sideTaskContent

        onOpened: control.opened()
        onClosed: control.closed()
    }

    MeoBottomSheet {
        id: bottomSheet
        parent: control.popupParent !== null ? control.popupParent : control.parent
        preferredHeight: control.compactPreferredHeight
        dismissible: control.dismissible
        content: bottomTaskContent

        onOpened: control.opened()
        onClosed: control.closed()
    }

    Component {
        id: sideTaskContent

        Item {
            id: taskSurface

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24 * MeoTheme.globalScale
                    Layout.rightMargin: 24 * MeoTheme.globalScale
                    Layout.topMargin: control.subtitle !== "" ? 8 * MeoTheme.globalScale : 0
                    Layout.bottomMargin: control.subtitle !== "" ? 16 * MeoTheme.globalScale : 0
                    text: control.subtitle
                    visible: text !== ""
                    font.family: MeoTheme.typefacePlain
                    font.pixelSize: MeoTheme.bodyMedium.size * MeoTheme.globalScale
                    font.weight: MeoTheme.bodyMedium.weight
                    color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                }

                Loader {
                    id: contentLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: control.content
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(1, MeoTheme.globalScale)
                    visible: actionRow.visible
                    color: MeoTheme.outlineVariant
                }

                RowLayout {
                    id: actionRow
                    Layout.fillWidth: true
                    Layout.leftMargin: 16 * MeoTheme.globalScale
                    Layout.rightMargin: 16 * MeoTheme.globalScale
                    Layout.topMargin: 12 * MeoTheme.globalScale
                    Layout.bottomMargin: 16 * MeoTheme.globalScale
                    layoutDirection: Qt.RightToLeft
                    spacing: 8 * MeoTheme.globalScale
                    visible: control.acceptText !== "" || control.rejectText !== ""

                    MeoButton {
                        text: control.acceptText
                        type: "filled"
                        enabled: control.acceptEnabled
                        visible: text !== ""
                        onClicked: control.accept()
                    }

                    MeoButton {
                        text: control.rejectText
                        type: "text"
                        enabled: control.rejectEnabled
                        visible: text !== ""
                        onClicked: control.reject()
                    }
                }
            }
        }
    }

    Component {
        id: bottomTaskContent

        Item {
            id: taskSurface
            implicitHeight: control.compactPreferredHeight - 48 * MeoTheme.globalScale

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64 * MeoTheme.globalScale
                    visible: control.title !== "" || control.showCloseButton

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 16 * MeoTheme.globalScale
                        anchors.rightMargin: 16 * MeoTheme.globalScale
                        spacing: 12 * MeoTheme.globalScale

                        MeoIconButton {
                            id: compactCloseButton
                            icon.name: "close"
                            visible: control.showCloseButton
                            anchors.verticalCenter: parent.verticalCenter
                            Accessible.name: qsTr("Close %1").arg(control.title)
                            onClicked: control.close()
                        }

                        Text {
                            width: parent.width - (compactCloseButton.visible
                                                    ? compactCloseButton.width + 12 * MeoTheme.globalScale
                                                    : 0)
                            text: control.title
                            visible: text !== ""
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: MeoTheme.typefacePlain
                            font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                            font.weight: MeoTheme.titleLarge.weight
                            color: MeoTheme.contentOnSurface
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24 * MeoTheme.globalScale
                    Layout.rightMargin: 24 * MeoTheme.globalScale
                    Layout.topMargin: control.subtitle !== "" ? 4 * MeoTheme.globalScale : 0
                    Layout.bottomMargin: control.subtitle !== "" ? 12 * MeoTheme.globalScale : 0
                    text: control.subtitle
                    visible: text !== ""
                    font.family: MeoTheme.typefacePlain
                    font.pixelSize: MeoTheme.bodyMedium.size * MeoTheme.globalScale
                    font.weight: MeoTheme.bodyMedium.weight
                    color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: control.content
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(1, MeoTheme.globalScale)
                    visible: compactActionRow.visible
                    color: MeoTheme.outlineVariant
                }

                RowLayout {
                    id: compactActionRow
                    Layout.fillWidth: true
                    Layout.leftMargin: 16 * MeoTheme.globalScale
                    Layout.rightMargin: 16 * MeoTheme.globalScale
                    Layout.topMargin: 12 * MeoTheme.globalScale
                    Layout.bottomMargin: 16 * MeoTheme.globalScale
                    layoutDirection: Qt.RightToLeft
                    spacing: 8 * MeoTheme.globalScale
                    visible: control.acceptText !== "" || control.rejectText !== ""

                    MeoButton {
                        text: control.acceptText
                        type: "filled"
                        enabled: control.acceptEnabled
                        visible: text !== ""
                        onClicked: control.accept()
                    }

                    MeoButton {
                        text: control.rejectText
                        type: "text"
                        enabled: control.rejectEnabled
                        visible: text !== ""
                        onClicked: control.reject()
                    }
                }
            }
        }
    }
}
