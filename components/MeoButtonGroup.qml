import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 M3E Elastic Physical Button Group API
    property var model: []
    property string type: "tonal" // filled | tonal | outlined | elevated
    property string size: "m" // xs | s | m | l | xl
    property int currentIndex: 0
    signal selected(int index, var data)

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real groupRadius: height / 2
    readonly property real inset: 2 * themeGlobalScale
    readonly property bool outlined: type === "outlined"

    readonly property var fontToken: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        if (size === "xs") return MeoTheme.labelSmall;
        if (size === "s") return MeoTheme.labelMedium;
        if (size === "l") return MeoTheme.titleSmall;
        if (size === "xl") return MeoTheme.titleMedium;
        return MeoTheme.labelLarge;
    }

    readonly property color idleBackground: {
        if (!enabled) return (typeof MeoTheme !== 'undefined' && MeoTheme.isDarkMode) ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
        if (type === "filled") return themePrimaryContainer
        if (type === "tonal") return themeSecondaryContainer
        if (type === "elevated") return themeSurfaceContainerLow
        return themeSurfaceContainer
    }
    readonly property color idleForeground: type === "tonal" ? themeOnSecondaryContainer
                                        : type === "filled" ? themeOnPrimaryContainer
                                        : themePrimary

    implicitHeight: {
        if (size === "xs") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.buttonHeightXS !== 'undefined') ? MeoTheme.buttonHeightXS : 32 * themeGlobalScale
        if (size === "s") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.buttonHeightS !== 'undefined') ? MeoTheme.buttonHeightS : 40 * themeGlobalScale
        if (size === "l") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.buttonHeightL !== 'undefined') ? MeoTheme.buttonHeightL : 56 * themeGlobalScale
        if (size === "xl") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.buttonHeightXL !== 'undefined') ? MeoTheme.buttonHeightXL : 72 * themeGlobalScale
        return 48 * themeGlobalScale
    }
    implicitWidth: groupRow.implicitWidth
    padding: 0

    contentItem: Item {
        implicitWidth: groupRow.implicitWidth
        implicitHeight: control.implicitHeight
        clip: true

        Rectangle {
            id: groupSurface
            anchors.fill: parent
            radius: control.groupRadius
            color: control.idleBackground
            border.width: control.outlined ? Math.max(1, control.themeGlobalScale) : 0
            border.color: control.themeOutline

            layer.enabled: control.type === "elevated" && control.enabled
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.16
                shadowVerticalOffset: control.themeGlobalScale
                shadowOpacity: 0.16
                shadowColor: Qt.rgba(0, 0, 0, 0.22)
            }

            Behavior on color { ColorAnimation { duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationEffectDefault !== 'undefined') ? MeoTheme.motionDurationEffectDefault : 150 } }
        }

        Row {
            id: groupRow
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: control.model

                delegate: Button {
                    id: groupButton
                    required property int index
                    required property var modelData
                    property var itemData: modelData
                    readonly property string itemLabel: typeof itemData === "string" ? itemData : (itemData.label || "")
                    readonly property string itemIcon: typeof itemData === "object" ? (itemData.icon || "") : ""
                    readonly property bool selected: index === control.currentIndex
                    readonly property bool isFirst: index === 0
                    readonly property bool isLast: index === control.model.length - 1
                    readonly property real segmentRadius: isFirst || isLast ? control.groupRadius - control.inset : (size === "xs" ? 6 : 10) * control.themeGlobalScale
                    readonly property color foreground: selected ? control.themeOnPrimary : control.idleForeground

                    // 🌟 M3E Elastic Conserved-Width Layout Calculation
                    // Base width per button
                    readonly property real baseWidth: Math.max((control.size === "xs" ? 56 : 72) * control.themeGlobalScale,
                                                                groupButtonContent.implicitWidth + (control.size === "xs" ? 20 : 28) * control.themeGlobalScale)
                    
                    // Expansion delta for Selected / Hover / Press states
                    readonly property real expansionDelta: {
                        if (groupButton.pressed) return 20 * control.themeGlobalScale;
                        if (groupButton.selected) return 16 * control.themeGlobalScale;
                        if (groupButton.hovered) return 6 * control.themeGlobalScale;
                        return 0;
                    }

                    // Symmetrical shrinkage for neighboring unselected items
                    readonly property real shrinkageDelta: {
                        if (groupButton.selected || groupButton.pressed || groupButton.hovered) return 0;
                        let count = control.model.length;
                        if (count <= 1) return 0;
                        let selectedCount = 1;
                        let unselectedCount = count - selectedCount;
                        return (16 * control.themeGlobalScale) / unselectedCount;
                    }

                    implicitWidth: Math.max(36 * control.themeGlobalScale, baseWidth + expansionDelta - shrinkageDelta)
                    implicitHeight: control.implicitHeight
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    hoverEnabled: true

                    // 🌟 Shared Group Spring Animation on Button Width Morph
                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: groupButton.pressed
                                      ? (typeof MeoTheme !== 'undefined' ? MeoTheme.motionDurationSpatialFast : 120)
                                      : (typeof MeoTheme !== 'undefined' ? MeoTheme.motionDurationSpatialDefault : 220)
                            easing.bezierCurve: groupButton.pressed
                                                ? ((typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSpringStiff !== 'undefined') ? MeoTheme.motionEasingSpringStiff : [0.18, 0.89, 0.32, 1.25])
                                                : ((typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSpringBouncy !== 'undefined') ? MeoTheme.motionEasingSpringBouncy : [0.34, 1.35, 0.64, 1.0])
                        }
                    }

                    background: Item {
                        clip: true

                        Rectangle {
                            id: selectionSurface
                            anchors.fill: parent
                            anchors.margins: control.inset
                            radius: groupButton.segmentRadius
                            color: control.themePrimary
                            opacity: groupButton.selected ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationEffectDefault !== 'undefined') ? MeoTheme.motionDurationEffectDefault : 150
                                    easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                                }
                            }
                        }

                        MeoStateLayer {
                            anchors.fill: parent
                            radius: groupButton.segmentRadius
                            pressed: groupButton.pressed
                            hovered: groupButton.hovered
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
                            opacity: groupButton.index > 0 && !groupButton.selected ? 0.78 : 0
                            Behavior on opacity { NumberAnimation { duration: 100 } }
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
                                text: groupButton.itemLabel
                                visible: text.length > 0
                                font.family: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontFamily !== 'undefined') ? MeoTheme.fontFamily : "sans-serif"
                                font.pixelSize: control.fontToken.size * (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontScale !== 'undefined' ? MeoTheme.fontScale * control.themeGlobalScale : control.themeGlobalScale)
                                font.weight: groupButton.selected ? Font.Bold : control.fontToken.weight
                                color: groupButton.foreground
                                lineHeightMode: Text.FixedHeight
                                lineHeight: (control.fontToken.lineHeight || 20) * control.themeGlobalScale
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }

                    onClicked: {
                        control.currentIndex = groupButton.index
                        if (typeof groupButton.itemData === "object" && groupButton.itemData.action)
                            groupButton.itemData.action()
                        control.selected(groupButton.index, groupButton.itemData)
                    }
                }
            }
        }
    }
}
