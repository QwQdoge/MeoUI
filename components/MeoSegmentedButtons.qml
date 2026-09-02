import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property var model: ["option1", "option2", "option3"]
    property int currentIndex: 0
    property bool multiSelect: false
    property var selectedIndices: []
    property string size: "m" // xs | s | m | l | xl
    property string accessibleName: qsTr("Segmented buttons")
    signal selected(int index, var data)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOutline: MeoTheme.outline
    readonly property real groupRadius: height / 2
    readonly property int itemCount: segmentRepeater.count
    readonly property bool hasAnyIcon: {
        for (let i = 0; i < itemCount; ++i) {
            const item = itemAt(i)
            if (typeof item === "object" && item.icon)
                return true
        }
        return false
    }
    readonly property var fontToken: size === "xs" ? MeoTheme.labelSmall
                                     : size === "s" ? MeoTheme.labelMedium
                                     : size === "l" ? MeoTheme.titleSmall
                                     : size === "xl" ? MeoTheme.titleMedium
                                     : MeoTheme.labelLarge

    // The M3 outlined segmented-button token is 40dp. Keep the historical
    // non-default size options for compatibility, but make the default match
    // the source component rather than the general button height.
    implicitHeight: size === "xs" ? MeoTheme.buttonHeightXS
                  : size === "s" || size === "m" ? MeoTheme.buttonHeightS
                  : size === "l" ? MeoTheme.buttonHeightL
                  : size === "xl" ? MeoTheme.buttonHeightXL
                  : MeoTheme.buttonHeightS
    implicitWidth: {
        let total = 0
        for (let i = 0; i < itemCount; ++i) {
            const item = itemAt(i)
            const label = typeof item === "string" ? item : (item.label || "")
            total += Math.max(58 * themeGlobalScale,
                              label.length * control.fontToken.size * 0.72 * themeGlobalScale
                              + (hasAnyIcon ? 50 : 24) * themeGlobalScale)
        }
        return Math.max(1, total)
    }
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    Accessible.role: Accessible.Grouping
    Accessible.name: accessibleName
    Accessible.description: multiSelect
                            ? qsTr("Multiple selections allowed")
                            : qsTr("Choose one option")

    function itemAt(index) {
        if (index < 0 || index >= itemCount || !model)
            return null
        if (typeof model.get === "function")
            return model.get(index)
        return model[index]
    }

    function isIndexSelected(index) {
        return multiSelect ? selectedIndices.indexOf(index) !== -1 : currentIndex === index
    }

    function activateIndex(index, itemData) {
        if (!enabled || index < 0 || index >= itemCount)
            return false
        const data = itemData === undefined ? itemAt(index) : itemData
        if (typeof data === "object" && data && data.enabled === false)
            return false
        if (multiSelect) {
            const next = selectedIndices.slice(0)
            const selectedAt = next.indexOf(index)
            if (selectedAt === -1)
                next.push(index)
            else
                next.splice(selectedAt, 1)
            selectedIndices = next
        } else {
            currentIndex = index
        }
        selected(index, data)
        return true
    }

    background: Rectangle {
        radius: control.groupRadius
        color: "transparent"
        border.color: control.enabled ? control.themeOutline
                                      : Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.12)
        border.width: Math.max(1, control.themeGlobalScale)
    }

    contentItem: Row {
        id: segmentRow
        spacing: 0
        clip: true
        layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        Repeater {
            id: segmentRepeater
            model: control.model

            delegate: Button {
                id: segmentButton
                property var itemData: modelData
                readonly property string itemLabel: typeof itemData === "string" ? itemData : (itemData.label || "")
                readonly property string itemIcon: typeof itemData === "object" ? (itemData.icon || "") : ""
                readonly property bool selected: control.isIndexSelected(index)
                readonly property bool previousSelected: index > 0 && control.isIndexSelected(index - 1)
                readonly property bool isFirst: index === 0
                readonly property bool isLast: index === control.itemCount - 1
                readonly property bool startsRow: control.mirrored ? isLast : isFirst
                readonly property bool endsRow: control.mirrored ? isFirst : isLast
                readonly property real segmentRadius: startsRow || endsRow ? control.groupRadius : 0
                readonly property color foreground: !control.enabled ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.38)
                                                   : selected ? control.themeOnSecondaryContainer
                                                   : control.themeOnSurface

                width: Math.max(1, segmentRow.width / Math.max(1, control.itemCount))
                height: control.height
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                hoverEnabled: true
                enabled: control.enabled && !(typeof itemData === "object" && itemData && itemData.enabled === false)
                activeFocusOnTab: enabled

                Accessible.role: control.multiSelect ? Accessible.CheckBox : Accessible.RadioButton
                Accessible.name: segmentButton.itemLabel
                Accessible.checked: segmentButton.selected
                Accessible.onPressAction: control.activateIndex(index, segmentButton.itemData)

                background: Item {
                    clip: true

                    Rectangle {
                        id: selectedSurface
                        anchors.fill: parent
                        radius: segmentButton.segmentRadius
                        color: control.themeSecondaryContainer
                        border.color: control.enabled ? control.themeOutline
                                                      : Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.12)
                        border.width: Math.max(1, control.themeGlobalScale)
                        opacity: segmentButton.selected ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: segmentButton.selected ? MeoTheme.motionDurationSelection : MeoTheme.motionDurationState
                                easing.bezierCurve: segmentButton.selected ? MeoTheme.motionEasingEmphasizedDecelerate : MeoTheme.motionEasingEmphasizedAccelerate
                            }
                        }
                    }

                    MeoStateLayer {
                        anchors.fill: parent
                        radius: segmentButton.segmentRadius
                        pressed: segmentButton.pressed
                        hovered: segmentButton.hovered
                        focused: segmentButton.visualFocus
                        pressX: segmentButton.pressX
                        pressY: segmentButton.pressY
                        color: segmentButton.foreground
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.max(1, control.themeGlobalScale)
                        height: parent.height
                        color: control.enabled ? control.themeOutline
                                               : Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.12)
                        opacity: index > 0 && !segmentButton.selected && !segmentButton.previousSelected ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }
                    }
                }

                contentItem: Item {
                    Row {
                        anchors.centerIn: parent
                        spacing: 8 * control.themeGlobalScale

                        Item {
                            width: control.hasAnyIcon || segmentButton.selected ? 18 * control.themeGlobalScale : 0
                            height: width
                            clip: true

                            MeoIcon {
                                anchors.centerIn: parent
                                icon: segmentButton.selected ? "check" : segmentButton.itemIcon
                                size: control.size === "xl" ? 24 * control.themeGlobalScale : 18 * control.themeGlobalScale
                                color: segmentButton.foreground
                                opacity: segmentButton.selected || segmentButton.itemIcon.length > 0 ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }
                            }
                        }

                        Text {
                            text: segmentButton.itemLabel
                            font.family: MeoTheme.typefacePlain
                            font.pixelSize: control.fontToken.size * control.themeGlobalScale
                            font.weight: segmentButton.selected ? Font.Medium : control.fontToken.weight
                            color: segmentButton.foreground
                            lineHeightMode: Text.FixedHeight
                            lineHeight: (control.fontToken.lineHeight || 20) * control.themeGlobalScale
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationState } }
                        }
                    }
                }

                onClicked: control.activateIndex(index, segmentButton.itemData)
            }
        }
    }
}
