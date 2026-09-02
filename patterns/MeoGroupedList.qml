import QtQuick
import QtQuick.Controls
import MeoUI

Column {
    id: control

    property string title: ""
    property string subtitle: ""
    property var model: [] // strings or { label/title, supportingText/subtitle, icon, trailingText, badgeText, enabled }
    property int selectedIndex: -1
    property bool showDividers: true
    property bool showChevron: true
    property real dividerInset: 56 * MeoTheme.globalScale
    property real containerRadius: MeoTheme.shapeLarge
    property color containerColor: MeoTheme.surfaceContainerLowest
    readonly property bool isMirrored: LayoutMirroring.enabled

    signal clicked(int index)

    function labelFor(item) {
        return item && typeof item === "object" ? (item.label || item.title || "") : String(item || "")
    }

    function supportingFor(item) {
        return item && typeof item === "object" ? (item.supportingText || item.subtitle || "") : ""
    }

    function iconFor(item) {
        return item && typeof item === "object" ? (item.icon || "") : ""
    }

    function enabledFor(item) {
        return !item || typeof item !== "object" || item.enabled === undefined ? true : item.enabled
    }

    function activate(index) {
        if (index < 0 || index >= model.length || !enabledFor(model[index]))
            return false
        selectedIndex = index
        clicked(index)
        return true
    }

    width: parent ? parent.width : 420 * MeoTheme.globalScale
    spacing: 8 * MeoTheme.globalScale

    Column {
        width: parent.width
        visible: control.title !== "" || control.subtitle !== ""
        spacing: 2 * MeoTheme.globalScale

        MeoText {
            width: parent.width
            text: control.title
            visible: text !== ""
            typeRole: "title"
            typeSize: "small"
            emphasized: true
            color: MeoTheme.contentOnSurface
        }

        MeoText {
            width: parent.width
            text: control.subtitle
            visible: text !== ""
            typeRole: "body"
            typeSize: "medium"
            color: MeoTheme.contentOnSurfaceVariant
            wrapMode: Text.WordWrap
        }
    }

    Item {
        id: listSurface
        width: parent.width
        implicitHeight: rows.implicitHeight
        visible: control.model.length > 0

        Rectangle {
            anchors.fill: parent
            radius: control.containerRadius
            color: control.containerColor
        }

        Column {
            id: rows
            width: parent.width
            spacing: 0

            Repeater {
                model: control.model

                delegate: MeoListItem {
                    id: rowItem
                    required property int index
                    required property var modelData
                    objectName: "meoGroupedListItem_" + index
                    width: rows.width
                    headline: control.labelFor(modelData)
                    supportingText: control.supportingFor(modelData)
                    leadingIcon: control.iconFor(modelData)
                    selected: control.selectedIndex === index
                    enabled: control.enabledFor(modelData)
                    interactive: enabled
                    isSegmented: true
                    roundingStrategy: control.model.length === 1 ? "all"
                                      : index === 0 ? "top"
                                      : index === control.model.length - 1 ? "bottom" : "middle"

                    trailingComponent: Component {
                        Row {
                            spacing: 8 * MeoTheme.globalScale
                            layoutDirection: control.isMirrored ? Qt.RightToLeft : Qt.LeftToRight
                            visible: !!(modelData && typeof modelData === "object"
                                        && (modelData.badgeText || modelData.trailingText)) || control.showChevron

                            MeoBadge {
                                text: modelData && typeof modelData === "object" ? (modelData.badgeText || "") : ""
                                visible: text !== ""
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            MeoText {
                                text: modelData && typeof modelData === "object" ? (modelData.trailingText || "") : ""
                                visible: text !== ""
                                typeRole: "label"
                                typeSize: "medium"
                                color: rowItem.selected ? MeoTheme.contentOnSecondaryContainer : MeoTheme.contentOnSurfaceVariant
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            MeoIcon {
                                visible: control.showChevron
                                icon: control.isMirrored ? "chevron_left" : "chevron_right"
                                size: 20 * MeoTheme.globalScale
                                color: rowItem.selected ? MeoTheme.contentOnSecondaryContainer : MeoTheme.contentOnSurfaceVariant
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    onClicked: control.activate(index)

                    Rectangle {
                        visible: control.showDividers && index < control.model.length - 1
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: control.isMirrored ? 0 : control.dividerInset
                        anchors.rightMargin: control.isMirrored ? control.dividerInset : 0
                        height: Math.max(1, MeoTheme.globalScale)
                        color: MeoTheme.outlineVariant
                    }
                }
            }
        }
    }
}
