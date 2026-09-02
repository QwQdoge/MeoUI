import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string headline: ""
    property string supportingText: ""
    property string overline: ""
    property int supportingTextLines: 1 // 1, 2 or 3
    property string leadingIcon: ""
    property string leadingImage: "" // 🖼️ New: MD3 Expressive Large Image/Avatar
    property string leadingImageVariant: "square" // "square" | "circle"
    property real leadingImageSize: 40 // 40 (Avatar) | 56 (Small Image) | 64 (Large Image)

    // Trailing Area Properties
    property string badgeText: ""
    property color badgeColor: MeoTheme.error
    property Component leadingComponent: null
    property Component trailingComponent: null
    property list<Component> actions

    property bool interactive: true
    property bool isSegmented: false // MD3 Expressive: Segmented list style
    property string roundingStrategy: "all" // "all" | "top" | "bottom" | "middle" | "none"
    property bool isDense: false // MD3 Expressive: Compact list style
    property bool isEmphasized: false // MD3 Expressive: Use bold typography
    property bool vibrant: false // 🌟 MD3 Expressive: Vibrant selection style
    property bool selected: false
    readonly property bool pressed: mouseArea.pressed
    property string shape: "rect" // 🌟 MD3 Expressive: "rect" | "squircle" | "hexagon" | ...

    signal clicked()

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool usesVibrantPrimary: vibrant && MeoTheme.isExpressive
    readonly property color selectedContainerColor: usesVibrantPrimary ? themePrimary
                                                                        : (vibrant ? themePrimaryContainer : themeSecondaryContainer)
    readonly property color selectedContentColor: usesVibrantPrimary ? themeOnPrimary
                                                                      : (vibrant ? themeOnPrimaryContainer : themeOnSecondaryContainer)
    // AndroidX ListTokens resolves a disabled selected item from OnSurface at
    // the shared disabled-content opacity, instead of retaining the enabled
    // secondary/primary container. Keep that state semantic and centralised.
    readonly property color resolvedSelectedContainerColor: !enabled ? themeOnSurface : selectedContainerColor
    readonly property real resolvedSelectedContainerOpacity: !enabled ? MeoTheme.disabledContentOpacity : 1.0
    readonly property var fontBodyLarge: isEmphasized ? MeoTheme.bodyLargeEmphasized : MeoTheme.bodyLarge
    readonly property var fontBodyMedium: isEmphasized ? MeoTheme.bodyMediumEmphasized : MeoTheme.bodyMedium

    implicitWidth: 360 * themeGlobalScale
    // MD3 Heights: 1-line (56/72), 2-line (72/88), 3-line (88)
    implicitHeight: {
        let h = isDense ? 48 : 56;
        // AndroidX ListItem treats either an overline or supporting text as a
        // two-line template. Both together form the three-line template.
        if (overline !== "" || supportingText !== "") {
            const hasThreeLines = overline !== "" && supportingText !== ""
                                  || (supportingText !== "" && supportingTextLines > 1)
            h = hasThreeLines ? (isDense ? 72 : 88) : (isDense ? 64 : 72);
        }
        if (leadingImage !== "" && leadingImageSize > 40) h = Math.max(h, leadingImageSize + (isDense ? 8 : 16));
        if (isSegmented) h += 8;
        return Math.max(h * themeGlobalScale, contentRow.implicitHeight + padding * 2);
    }

    padding: {
        if (isDense) return 8 * themeGlobalScale;
        return isSegmented ? 12 * themeGlobalScale : 16 * themeGlobalScale;
    }
    spacing: 16 * themeGlobalScale // Standardized MD3 spacing
    activeFocusOnTab: interactive && enabled
    Accessible.role: Accessible.ListItem
    Accessible.name: headline
    Accessible.description: supportingText
    Accessible.selected: selected
    Accessible.focusable: interactive && enabled
    Accessible.onPressAction: if (interactive && enabled) control.clicked()
    Keys.onReturnPressed: if (interactive && enabled) control.clicked()
    Keys.onEnterPressed: if (interactive && enabled) control.clicked()
    Keys.onSpacePressed: if (interactive && enabled) control.clicked()

    background: Item {
        width: control.width - (control.isSegmented ? 16 * control.themeGlobalScale : 0)
        height: control.height
        x: control.isSegmented ? 8 * control.themeGlobalScale : 0

        Rectangle {
            id: shapeBg
            objectName: "meoListItemSurface"
            anchors.fill: parent
            radius: {
                if (!isSegmented) return 0;
                if (MeoTheme.isExpressive && selected) return MeoTheme.shapeLargeIncreased;
                return MeoTheme.shapeLarge;
            }
            color: {
                if (!isSegmented || !selected) return "transparent";
                return control.resolvedSelectedContainerColor;
            }
            opacity: control.isSegmented && control.selected
                     ? control.resolvedSelectedContainerOpacity : 1.0

            // MD3 Expressive: Rounding strategies for connected items in a group
            topLeftRadius: (roundingStrategy === "all" || roundingStrategy === "top") ? radius : 0
            topRightRadius: (roundingStrategy === "all" || roundingStrategy === "top") ? radius : 0
            bottomLeftRadius: (roundingStrategy === "all" || roundingStrategy === "bottom") ? radius : 0
            bottomRightRadius: (roundingStrategy === "all" || roundingStrategy === "bottom") ? radius : 0

            MeoStateLayer {
                anchors.fill: parent
                visible: control.interactive
                enabled: control.enabled
                pressed: mouseArea.pressed
                hovered: mouseArea.containsMouse
                focused: control.activeFocus
                pressX: mouseArea.mouseX
                pressY: mouseArea.mouseY
                radius: (control.isSegmented && control.roundingStrategy === "all" && control.shape === "rect") ? shapeBg.radius : 0
                color: selected ? control.selectedContentColor : control.themeOnSurface
            }

            Behavior on color {
                enabled: !MeoTheme.reduceMotion
                ColorAnimation { duration: MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasized }
            }
        }

        // Overlay for complex shapes if using MeoShape (Note: MeoShape doesn't support partial rounding as easily as Rectangle)
        MeoShape {
            anchors.fill: parent
            visible: isSegmented && control.shape !== "rect"
            type: control.shape
            radius: shapeBg.radius
            color: shapeBg.color
            opacity: selected ? 1.0 : 0.0
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: control.interactive && control.enabled
        hoverEnabled: true
        onClicked: {
            control.forceActiveFocus(Qt.MouseFocusReason)
            control.clicked()
        }
    }

    contentItem: Row {
        id: contentRow
        spacing: control.spacing
        width: control.availableWidth
        height: control.availableHeight
        layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight
        opacity: control.enabled ? 1.0 : MeoTheme.disabledContentOpacity

        // 🖼️ Leading Visuals Area
        Item {
            width: {
                if (control.leadingImage !== "") return control.leadingImageSize * control.themeGlobalScale;
                if (control.leadingIcon !== "" || control.leadingComponent !== null) return 24 * control.themeGlobalScale;
                return 0;
            }
            height: width > 0 ? Math.max(24 * control.themeGlobalScale, control.leadingImageSize * control.themeGlobalScale) : 0
            anchors.verticalCenter: parent.verticalCenter
            visible: width > 0

            Loader {
                anchors.centerIn: parent
                sourceComponent: control.leadingComponent
                visible: control.leadingComponent !== null
            }

            MeoIcon {
                anchors.centerIn: parent
                icon: control.leadingIcon
                size: isDense ? 20 : 24
                color: control.selected && control.isSegmented
                       ? control.selectedContentColor : control.themeOnSurfaceVariant
                visible: control.leadingIcon !== "" && control.leadingComponent === null && control.leadingImage === ""
            }

            MeoShape {
                anchors.fill: parent
                type: control.leadingImageVariant === "circle" ? "circle" : control.leadingImageVariant
                radius: 8 * control.themeGlobalScale
                clip: true
                visible: control.leadingImage !== ""
                color: control.themeSecondaryContainer

                Image {
                    anchors.fill: parent
                    source: control.leadingImage
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }

        // 🔤 Content Area
        Column {
            width: parent.width - (leadingRowItemWidth() > 0 ? leadingRowItemWidth() + control.spacing : 0) - trailingRowItemWidth()
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: control.overline
                width: parent.width
                font.family: MeoTheme.typefacePlain
                font.pixelSize: MeoTheme.labelSmall.size * control.themeGlobalScale
                font.weight: Font.Normal
                color: control.themeOnSurfaceVariant
                visible: text !== ""
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            Text {
                text: control.headline
                width: parent.width
                font.family: MeoTheme.typefacePlain
                font.pixelSize: fontBodyLarge.size * control.themeGlobalScale
                font.weight: (control.selected && !isSegmented) ? Font.Bold : fontBodyLarge.weight
                font.letterSpacing: (fontBodyLarge.letterSpacing || 0) * control.themeGlobalScale
                lineHeight: (fontBodyLarge.lineHeight ? (fontBodyLarge.lineHeight / fontBodyLarge.size) : 1.2)
                color: {
                    if (control.selected && isSegmented)
                        return control.selectedContentColor;
                    return control.themeOnSurface;
                }
                elide: Text.ElideRight
                Behavior on color {
                    enabled: !MeoTheme.reduceMotion
                    ColorAnimation {
                        duration: MeoTheme.motionDurationEffectDefault
                        easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
            }

            Text {
                text: control.supportingText
                width: parent.width
                font.family: MeoTheme.typefacePlain
                font.pixelSize: fontBodyMedium.size * control.themeGlobalScale
                font.weight: fontBodyMedium.weight
                font.letterSpacing: (fontBodyMedium.letterSpacing || 0) * control.themeGlobalScale
                lineHeight: (fontBodyMedium.lineHeight ? (fontBodyMedium.lineHeight / fontBodyMedium.size) : 1.2)
                color: control.selected && control.isSegmented
                       ? control.selectedContentColor : control.themeOnSurfaceVariant
                visible: text !== ""
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: Math.min(3, control.supportingTextLines)
            }
        }

        // 🏷️ Trailing Area
        Row {
            id: trailingActionsRow
            spacing: 12 * control.themeGlobalScale // Keeping 12 for compact action row
            anchors.verticalCenter: parent.verticalCenter
            visible: control.badgeText !== "" || control.trailingComponent !== null || control.actions.length > 0

            MeoBadge {
                text: control.badgeText
                visible: control.badgeText !== ""
                color: control.badgeColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Loader {
                width: item ? item.implicitWidth : 24 * control.themeGlobalScale
                height: item ? item.implicitHeight : 24 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: control.trailingComponent
                visible: control.trailingComponent !== null
            }

            // 🌟 Multiple Actions
            Repeater {
                model: control.actions
                delegate: Loader {
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: modelData
                }
            }
        }
    }

    // Helper functions for dynamic width calculation
    function leadingRowItemWidth() {
        if (control.leadingImage !== "") return control.leadingImageSize * control.themeGlobalScale;
        if (control.leadingIcon !== "" || control.leadingComponent !== null) return 24 * control.themeGlobalScale;
        return 0;
    }

    function trailingRowItemWidth() {
        return trailingActionsRow.visible
            ? trailingActionsRow.implicitWidth + control.spacing
            : 0;
    }
}
