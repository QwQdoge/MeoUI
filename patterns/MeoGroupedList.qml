import QtQuick
import QtQuick.Controls
import MeoUI

// Compatibility-facing grouped list built on the same connected-surface
// engine as MeoSettingsGroup. It owns no second container, separator, corner,
// selection, or pointer-state implementation.
MeoSegmentedList {
    id: control

    property bool showChevron: true

    dividerInset: 56 * MeoTheme.globalScale
    loaderObjectNamePrefix: "meoGroupedListLoader_"
    itemObjectNamePrefix: "meoGroupedListItem_"
    delegate: groupedRowDelegate

    Component {
        id: groupedRowDelegate

        MeoListItem {
            id: rowItem
            property int index: -1
            property var modelData: null

            headline: control.labelFor(modelData)
            supportingText: control.supportingFor(modelData)
            leadingIcon: control.iconFor(modelData)
            badgeText: modelData && typeof modelData === "object"
                       ? (modelData.badgeText || "") : ""
            interactive: enabled

            trailingComponent: Component {
                Row {
                    spacing: 8 * MeoTheme.globalScale
                    layoutDirection: control.isMirrored ? Qt.RightToLeft : Qt.LeftToRight
                    visible: !!(rowItem.modelData && typeof rowItem.modelData === "object"
                                && rowItem.modelData.trailingText) || control.showChevron

                    MeoText {
                        text: rowItem.modelData && typeof rowItem.modelData === "object"
                              ? (rowItem.modelData.trailingText || "") : ""
                        visible: text !== ""
                        typeRole: "label"
                        typeSize: "medium"
                        color: rowItem.selected
                               ? MeoTheme.contentOnSecondaryContainer
                               : MeoTheme.contentOnSurfaceVariant
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    MeoIcon {
                        visible: control.showChevron
                        icon: control.isMirrored ? "chevron_left" : "chevron_right"
                        size: 20 * MeoTheme.globalScale
                        color: rowItem.selected
                               ? MeoTheme.contentOnSecondaryContainer
                               : MeoTheme.contentOnSurfaceVariant
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
