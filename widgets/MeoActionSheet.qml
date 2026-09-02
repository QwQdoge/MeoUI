import QtQuick
import MeoUI

// An action sheet is a content composition of the shared modal bottom-sheet
// primitive. Keeping one sheet surface means width, scrim, focus return,
// motion, and drag-handle tokens cannot drift from MeoBottomSheet.
MeoBottomSheet {
    id: control

    property string title: qsTr("Actions")
    // [{ label: "Action", icon: "add", action: function() {} }]
    property var model: []

    content: Component {
        Item {
            id: sheetContent
            width: control.width
            implicitHeight: contentColumn.implicitHeight

            Column {
                id: contentColumn
                width: parent.width

                Item {
                    width: parent.width
                    implicitHeight: titleLabel.visible
                                    ? titleLabel.implicitHeight + 16 * MeoTheme.globalScale
                                    : 0

                    MeoText {
                        id: titleLabel
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 24 * MeoTheme.globalScale
                        anchors.rightMargin: 24 * MeoTheme.globalScale
                        text: control.title
                        typeRole: "title"
                        typeSize: "large"
                        color: MeoTheme.contentOnSurface
                        visible: text.length > 0
                    }
                }

                Repeater {
                    model: control.model

                    delegate: MeoListItem {
                        width: parent.width
                        headline: modelData.label || ""
                        leadingIcon: modelData.icon || ""
                        onClicked: {
                            const callback = modelData.action
                            if (typeof callback === "function")
                                callback()
                            control.close()
                        }
                    }
                }

                Item {
                    width: parent.width
                    implicitHeight: 24 * MeoTheme.globalScale
                }
            }
        }
    }
}
