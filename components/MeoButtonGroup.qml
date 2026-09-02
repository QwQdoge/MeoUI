import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // Material 3 Expressive offers two deliberately different group modes.
    // Standard groups animate adjacent buttons; connected groups are stable
    // selection controls for view/filter choices.
    property var model: []
    property string type: "tonal" // filled | tonal | outlined | elevated
    property string variant: "standard" // standard | connected
    property string size: "m" // xs | s | m | l | xl
    property int currentIndex: 0
    property bool multiSelect: false
    // For multi-select groups, keep one destination selected when requested.
    // This maps the M3 Expressive selection-required configuration.
    property bool selectionRequired: false
    property var selectedIndices: []
    property int pressedIndex: -1
    // AndroidX ButtonGroup grows a pressed standard button by up to 15% of
    // its resting width, limited by the neighbouring buttons' content
    // padding. This prevents a press response from crushing button content.
    // Keep the value configurable so applications can explicitly opt out with
    // 0 while preserving the Material default.
    property real pressExpansionRatio: 0.15
    // M3 Expressive standard-group padding is size-specific. It forms the
    // visible gap between sibling controls and preserves the XS/S target area.
    property real standardSpacing: {
        if (size === "xs") return 18 * MeoTheme.globalScale
        if (size === "s") return 12 * MeoTheme.globalScale
        return 8 * MeoTheme.globalScale
    }
    property real standardPadding: standardSpacing
    property real selectionWidthDelta: 24 * MeoTheme.globalScale
    property string baseShape: "round" // round | square
    property string selectedShape: "square" // round | square
    property string accessibleName: qsTr("Button group")
    signal selected(int index, var data)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property int itemCount: groupRepeater.count
    readonly property real inset: 2 * themeGlobalScale
    readonly property bool outlined: type === "outlined"
    readonly property bool isStandard: variant !== "connected"
    readonly property real squareRadius: 12 * themeGlobalScale
    // M3 Expressive connected groups use this square corner scale for both
    // the outer square configuration and the unselected inner corners.
    readonly property real connectedSquareCornerRadius: {
        if (size === "xs") return 4 * themeGlobalScale
        if (size === "s" || size === "m") return 8 * themeGlobalScale
        if (size === "l") return 16 * themeGlobalScale
        return 20 * themeGlobalScale // XL
    }
    readonly property real connectedInnerCornerRadius: connectedSquareCornerRadius
    readonly property real groupRadius: !isStandard && baseShape === "square"
                                       ? connectedSquareCornerRadius : height / 2

    readonly property var fontToken: {
        if (size === "xs") return MeoTheme.labelSmall;
        if (size === "s") return MeoTheme.labelMedium;
        if (size === "l") return MeoTheme.titleSmall;
        if (size === "xl") return MeoTheme.titleMedium;
        return MeoTheme.labelLarge;
    }

    readonly property color idleBackground: {
        if (!enabled) return type === "outlined" ? "transparent" : Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.12)
        if (type === "filled") return themePrimaryContainer
        if (type === "tonal") return themeSecondaryContainer
        if (type === "elevated") return themeSurfaceContainerLow
        return type === "outlined" ? "transparent" : themeSurfaceContainer
    }
    readonly property color idleForeground: !enabled ? Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.38)
                                        : type === "tonal" ? themeOnSecondaryContainer
                                        : type === "filled" ? themeOnPrimaryContainer
                                        : themePrimary
    readonly property color selectedContainer: !enabled ? Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.12)
                                           : type === "filled" || type === "tonal" ? themePrimary
                                           : themePrimaryContainer
    readonly property color selectedForeground: !enabled ? Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.38)
                                            : type === "filled" || type === "tonal" ? themeOnPrimary
                                            : themeOnPrimaryContainer

    Accessible.role: Accessible.Grouping
    Accessible.name: accessibleName
    Accessible.description: variant === "connected"
                            ? (multiSelect ? qsTr("Multiple selections allowed") : qsTr("Choose one option"))
                            : qsTr("Related actions")

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

    function activateIndex(index) {
        if (!enabled || index < 0 || index >= itemCount)
            return false
        const data = itemAt(index)
        if (typeof data === "object" && data && data.enabled === false)
            return false
        if (multiSelect) {
            const next = selectedIndices.slice(0)
            const selectedAt = next.indexOf(index)
            if (selectedAt === -1)
                next.push(index)
            else if (!(selectionRequired && next.length === 1))
                next.splice(selectedAt, 1)
            selectedIndices = next
        } else {
            currentIndex = index
        }
        if (typeof data === "object" && data.action)
            data.action()
        selected(index, data)
        return true
    }

    function pressedExpansionFor(index) {
        if (!isStandard || itemCount < 2 || index < 0 || index >= itemCount)
            return 0
        const pressedButton = buttonAt(index)
        if (!pressedButton)
            return 0
        const requestedGrowth = pressedButton.standardRestingWidth
                              * Math.max(0, pressExpansionRatio)
        if (index === 0)
            return Math.min(requestedGrowth, compressionLimitFor(1))
        if (index === itemCount - 1)
            return Math.min(requestedGrowth, compressionLimitFor(itemCount - 2))
        // AndroidX divides a middle item's requested growth across both
        // neighbours, then clamps each half to their available padding.
        return 2 * Math.min(requestedGrowth / 2,
                            compressionLimitFor(index - 1),
                            compressionLimitFor(index + 1))
    }

    function buttonAt(index) {
        for (let i = 0; i < groupRow.children.length; ++i) {
            const child = groupRow.children[i]
            if (child && child.index === index)
                return child
        }
        return null
    }

    function compressionLimitFor(index) {
        const button = buttonAt(index)
        return button && button.compressionLimit !== undefined
               ? button.compressionLimit : 0
    }

    function adjacentCompressionFor(index) {
        if (!isStandard || pressedIndex < 0 || Math.abs(index - pressedIndex) !== 1)
            return 0
        const neighbourCount = pressedIndex === 0 || pressedIndex === itemCount - 1 ? 1 : 2
        return pressedExpansionFor(pressedIndex) / neighbourCount
    }

    implicitHeight: {
        return MeoTheme.buttonHeightForSize(size)
    }
    // Reserve one selected button's width delta. Selection can therefore move
    // inside the group without causing the surrounding layout to jump.
    readonly property real standardReservedWidth: {
        let total = 2 * standardPadding + Math.max(0, itemCount - 1) * standardSpacing
        let largestDelta = 0
        for (let i = 0; i < itemCount; ++i) {
            const item = itemAt(i)
            const label = typeof item === "string" ? item : (item.label || "")
            const icon = typeof item === "object" ? (item.icon || "") : ""
            const base = Math.max((size === "xs" ? 48 : 64) * themeGlobalScale,
                                  label.length * fontToken.size * 0.66 * themeGlobalScale
                                  + (icon.length > 0 ? 44 : 28) * themeGlobalScale)
            total += base
            largestDelta = Math.max(largestDelta, item && item.selectionWidthDelta !== undefined
                                               ? item.selectionWidthDelta * themeGlobalScale
                                               : selectionWidthDelta)
        }
        return total + largestDelta
    }
    // The reservation prevents a selected item from moving its parent. The
    // Row fallback additionally protects labels whose actual font metrics are
    // wider than the conservative pre-layout estimate.
    implicitWidth: isStandard ? Math.max(standardReservedWidth, groupRow.implicitWidth) : groupRow.implicitWidth
    padding: 0

    contentItem: Item {
        implicitWidth: control.implicitWidth
        implicitHeight: control.implicitHeight
        clip: true

        Rectangle {
            id: groupSurface
            anchors.fill: parent
            radius: control.groupRadius
            visible: !control.isStandard
            color: control.idleBackground
            border.width: control.outlined ? Math.max(1, control.themeGlobalScale) : 0
            border.color: control.themeOutline

            layer.enabled: !control.isStandard && control.type === "elevated" && control.enabled
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.16
                shadowVerticalOffset: control.themeGlobalScale
                shadowOpacity: 0.12
                shadowColor: MeoTheme.shadow
            }

            Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationEffectDefault } }
        }

        Row {
            id: groupRow
            x: control.isStandard ? Math.max(0, (parent.width - width) / 2) : 0
            y: 0
            width: control.isStandard ? implicitWidth : parent.width
            height: parent.height
            spacing: control.isStandard ? control.standardSpacing : 0
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

            Repeater {
                id: groupRepeater
                model: control.model

                delegate: Button {
                    id: groupButton
                    objectName: "meoButtonGroupButton_" + index
                    required property int index
                    required property var modelData
                    property var itemData: modelData
                    readonly property string itemLabel: typeof itemData === "string" ? itemData : (itemData.label || "")
                    readonly property string displayLabel: typeof itemData === "object" && itemData.compactWhenUnselected && !selected
                                                               ? ""
                                                               : (selected && typeof itemData === "object" && itemData.selectedLabel
                                                                  ? itemData.selectedLabel : itemLabel)
                    readonly property string itemIcon: typeof itemData === "object" ? (itemData.icon || "") : ""
                    readonly property bool selected: control.isIndexSelected(index)
                    readonly property bool isFirst: index === 0
                    readonly property bool isLast: index === control.itemCount - 1
                    readonly property bool adjacentPressed: Math.abs(index - control.pressedIndex) === 1
                    readonly property real segmentRadius: control.isStandard
                                                       ? (selected ? (control.selectedShape === "round" ? height / 2 : control.squareRadius)
                                                                   : (control.baseShape === "square" ? control.squareRadius : height / 2))
                                                       // AndroidX uses CornerFull for checked connected
                                                       // buttons. The selected item must therefore not
                                                       // retain a small middle/inner corner radius.
                                                       : (selected ? height / 2
                                                                   : (isFirst || isLast ? control.groupRadius
                                                                                       : control.connectedInnerCornerRadius))
                    readonly property color foreground: selected ? control.selectedForeground : control.idleForeground

                    enabled: control.enabled && !(typeof itemData === "object" && itemData.enabled === false)

                    // This is the trailing content padding that AndroidX
                    // passes to animateWidth() as its compression limit.
                    // It may be overridden per item for custom delegates.
                    readonly property real compressionLimit: typeof itemData === "object" && itemData.compressionLimit !== undefined
                                                             ? itemData.compressionLimit * control.themeGlobalScale
                                                             : (control.size === "xs" ? 14
                                                                : control.size === "s" ? 18
                                                                : control.size === "l" ? 28
                                                                : control.size === "xl" ? 36 : 24) * control.themeGlobalScale
                    readonly property real baseWidth: Math.max((control.size === "xs" ? 56 : 72) * control.themeGlobalScale,
                                                                groupButtonContent.implicitWidth + (control.size === "xs" ? 20 : 28) * control.themeGlobalScale)
                    readonly property real selectedWidthDelta: typeof itemData === "object" && itemData.selectionWidthDelta !== undefined
                                                             ? itemData.selectionWidthDelta * control.themeGlobalScale
                                                             : control.selectionWidthDelta
                    readonly property real standardRestingWidth: baseWidth
                                                                + (control.isStandard && selected ? selectedWidthDelta : 0)
                    readonly property real pressExpansion: control.isStandard && pressed
                                                         ? control.pressedExpansionFor(index) : 0
                    readonly property real adjacentCompression: control.adjacentCompressionFor(index)
                    // Standard groups communicate selection with shape and
                    // width. AndroidX defines the press change as a percentage
                    // of the pressed control's resting width; its neighbours
                    // absorb the same total width. Connected groups deliberately
                    // keep all segment bounds stable.
                    implicitWidth: Math.max(36 * control.themeGlobalScale, baseWidth
                                             + (control.isStandard && selected ? selectedWidthDelta : 0)
                                             + pressExpansion - adjacentCompression)
                    width: control.isStandard ? implicitWidth
                                              : Math.max(1, groupRow.width / Math.max(1, control.itemCount))
                    implicitHeight: control.implicitHeight
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    hoverEnabled: true
                    activeFocusOnTab: enabled
                    Accessible.name: groupButton.itemLabel
                    Accessible.role: control.variant === "connected"
                                     ? (control.multiSelect ? Accessible.CheckBox : Accessible.RadioButton)
                                     : Accessible.Button
                    Accessible.checked: control.variant === "connected" && groupButton.selected

                    onPressedChanged: {
                        if (pressed)
                            control.pressedIndex = index
                        else if (control.pressedIndex === index)
                            control.pressedIndex = -1
                    }

                    background: Item {
                        clip: true

                        Rectangle {
                            anchors.fill: parent
                            visible: control.isStandard
                            radius: groupButton.segmentRadius
                            color: groupButton.selected ? control.selectedContainer : control.idleBackground
                            border.width: control.outlined ? Math.max(1, control.themeGlobalScale) : 0
                            border.color: control.themeOutline

                            Behavior on radius {
                                enabled: !MeoTheme.reduceMotion
                                NumberAnimation { duration: MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasized }
                            }
                            Behavior on color {
                                enabled: !MeoTheme.reduceMotion
                                ColorAnimation { duration: MeoTheme.motionDurationState }
                            }
                        }

                        Rectangle {
                            id: selectionSurface
                            anchors.fill: parent
                            anchors.margins: control.isStandard ? 0 : control.inset
                            radius: groupButton.segmentRadius
                            color: control.selectedContainer
                            opacity: !control.isStandard && groupButton.selected ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: MeoTheme.motionDurationEffectDefault
                                    easing.bezierCurve: MeoTheme.motionEasingStandard
                                }
                            }
                        }

                        MeoStateLayer {
                            anchors.fill: parent
                            radius: groupButton.segmentRadius
                            pressed: groupButton.pressed
                            hovered: groupButton.hovered
                            focused: groupButton.visualFocus
                            pressX: groupButton.pressX
                            pressY: groupButton.pressY
                            color: groupButton.foreground
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(1, control.themeGlobalScale)
                            height: parent.height - 16 * control.themeGlobalScale
                            color: control.outlined ? control.themeOutline : control.themeOutlineVariant
                            opacity: !control.isStandard && groupButton.index > 0 && !groupButton.selected ? 0.78 : 0
                            Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }
                        }
                    }

                    contentItem: Item {
                        Row {
                            id: groupButtonContent
                            anchors.centerIn: parent
                            spacing: (control.size === "xs" ? 4 : 8) * control.themeGlobalScale

                            MeoIcon {
                                icon: groupButton.itemIcon
                                visible: icon.length > 0
                                size: control.size === "xs" ? 16 * control.themeGlobalScale
                                      : control.size === "xl" ? 24 * control.themeGlobalScale
                                      : 18 * control.themeGlobalScale
                                color: groupButton.foreground
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: groupButton.displayLabel
                                visible: text.length > 0
                                font.family: MeoTheme.typefacePlain
                                font.pixelSize: control.fontToken.size * MeoTheme.fontScale * control.themeGlobalScale
                                font.weight: groupButton.selected ? Font.Bold : control.fontToken.weight
                                color: groupButton.foreground
                                lineHeightMode: Text.FixedHeight
                                lineHeight: (control.fontToken.lineHeight || 20) * control.themeGlobalScale
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationState } }
                            }
                        }
                    }

                    onClicked: {
                        control.activateIndex(groupButton.index)
                    }
                }
            }
        }
    }
}
