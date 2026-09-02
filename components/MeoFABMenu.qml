import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Item {
    id: control

    // Material 3 FAB menu. Each menu item is one action surface; it is not a
    // speed-dial made from a separate label chip and mini FAB.
    // model: [{ label: "New document", icon: "note_add", action: function }, ...]
    property var model: []
    property bool opened: false
    property string icon: "add"
    property string activeIcon: "close"
    property string fabType: "regular" // "small" | "regular" | "medium" | "large"
    // The menu uses a matching initial container and final close-button color
    // pair: primaryContainer -> primary, secondaryContainer -> secondary, or
    // tertiaryContainer -> tertiary. Direct role properties remain available
    // for a dynamic scheme or an application-specific override.
    property string colorStyle: "primary" // "primary" | "secondary" | "tertiary"
    readonly property color styleInitialColor: colorStyle === "secondary" ? MeoTheme.secondaryContainer
                                              : colorStyle === "tertiary" ? MeoTheme.tertiaryContainer
                                              : MeoTheme.primaryContainer
    readonly property color styleInitialOnColor: colorStyle === "secondary" ? MeoTheme.contentOnSecondaryContainer
                                                : colorStyle === "tertiary" ? MeoTheme.contentOnTertiaryContainer
                                                : MeoTheme.contentOnPrimaryContainer
    readonly property color styleFinalColor: colorStyle === "secondary" ? MeoTheme.secondary
                                            : colorStyle === "tertiary" ? MeoTheme.tertiary
                                            : MeoTheme.primary
    readonly property color styleFinalOnColor: colorStyle === "secondary" ? MeoTheme.contentOnSecondary
                                              : colorStyle === "tertiary" ? MeoTheme.contentOnTertiary
                                              : MeoTheme.contentOnPrimary
    property color color: styleInitialColor
    property color onColor: styleInitialOnColor
    property color itemColor: styleInitialColor
    property color itemOnColor: styleInitialOnColor
    property bool enableScrim: false
    readonly property bool mirrored: LayoutMirroring.enabled

    // 🌟 核心信号
    signal itemClicked(int index, var itemData)
    signal toggled(bool opened)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real themeFontScale: MeoTheme.fontScale
    readonly property string themeFontFamily: MeoTheme.typefacePlain
    readonly property var fontTitleMedium: MeoTheme.titleMedium
    readonly property int motionDuration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium1
    readonly property string triggerFabType: fabType === "small" || fabType === "medium" || fabType === "large"
                                                 ? fabType : "regular"
    readonly property real initialTriggerSize: triggerFabType === "small" ? 40 * themeGlobalScale
                                               : triggerFabType === "medium" ? 80 * themeGlobalScale
                                               : triggerFabType === "large" ? 96 * themeGlobalScale
                                               : 56 * themeGlobalScale
    readonly property real initialTriggerRadius: triggerFabType === "small" ? 12 * themeGlobalScale
                                                 : triggerFabType === "medium" ? 20 * themeGlobalScale
                                                 : triggerFabType === "large" ? 28 * themeGlobalScale
                                                 : 16 * themeGlobalScale
    readonly property real initialTriggerIconSize: triggerFabType === "medium" ? 28 * themeGlobalScale
                                                   : triggerFabType === "large" ? 36 * themeGlobalScale
                                                   : 24 * themeGlobalScale
    // ToggleFloatingActionButton uses a 56dp, fully round close affordance.
    readonly property real finalTriggerSize: 56 * themeGlobalScale
    readonly property real finalTriggerIconSize: 20 * themeGlobalScale
    readonly property real openProgress: opened ? 1 : 0

    function blendedColor(from, to, progress) {
        return Qt.rgba(from.r + (to.r - from.r) * progress,
                       from.g + (to.g - from.g) * progress,
                       from.b + (to.b - from.b) * progress,
                       from.a + (to.a - from.a) * progress)
    }

    implicitWidth: mainFab.implicitWidth
    implicitHeight: mainFab.implicitHeight
    // A FAB menu is also commonly placed directly in a visual Item rather
    // than a Layout. Give it a concrete trigger rect in that case so the
    // trigger background and popup anchor never collapse to 0x0.
    width: implicitWidth
    height: implicitHeight

    // Popup is the Qt overlay adaptation. Its contents retain the current M3
    // action-surface geometry and do not introduce a separate menu container.
    Popup {
        id: menuPopup
        x: control.mirrored ? mainFab.x : mainFab.x + mainFab.width - width
        // AndroidX uses an 8dp gap between the nearest item and the close
        // affordance; the external 16dp FAB page margin remains the caller's
        // placement responsibility.
        y: mainFab.y - height - 8 * control.themeGlobalScale
        width: contentColumn.implicitWidth
        height: contentColumn.implicitHeight
        padding: 0
        visible: control.opened
        modal: control.enableScrim
        dim: control.enableScrim
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        onClosed: {
            control.opened = false
            control.toggled(false)
        }

        background: Item {
            // Invisible background for speed dial layout
        }

        contentItem: Column {
            id: contentColumn
            spacing: 4 * control.themeGlobalScale
            anchors.right: parent.right

            Repeater {
                id: actionRepeater
                // A Material FAB menu has two to six related actions. The
                // public array model is clipped defensively to six instead of
                // creating an inaccessible speed-dial overflow.
                model: Array.isArray(control.model) ? control.model.slice(0, 6) : control.model
                delegate: Button {
                    id: actionButton
                    objectName: "meoFabMenuAction" + index
                    required property int index
                    required property var modelData
                    anchors.right: parent.right
                    implicitWidth: Math.max(56 * control.themeGlobalScale,
                                            actionContent.implicitWidth + 48 * control.themeGlobalScale)
                    implicitHeight: 56 * control.themeGlobalScale
                    property real reveal: control.opened ? 1.0 : 0.0
                    width: implicitWidth * reveal
                    height: implicitHeight
                    clip: true
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    hoverEnabled: true
                    activeFocusOnTab: enabled
                    Accessible.name: typeof modelData === "object" ? (modelData.label || modelData.icon || "Action") : "Action"
                    opacity: reveal

                    Behavior on reveal {
                        SequentialAnimation {
                            PauseAnimation {
                                duration: control.motionDuration === 0 ? 0
                                         : Math.max(0, actionRepeater.count - actionButton.index - 1)
                                           * MeoTheme.motionStaggerDelay
                            }
                            NumberAnimation {
                                duration: control.motionDuration
                                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                            }
                        }
                    }

                    background: Item {
                        visible: true
                        Rectangle {
                            objectName: "meoFabMenuActionBackground_" + actionButton.index
                            anchors.fill: parent
                            radius: height / 2
                            color: control.itemColor
                            layer.enabled: actionButton.visible && actionButton.enabled
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowBlur: MeoTheme.elevationLevel3 * 0.12
                                shadowVerticalOffset: MeoTheme.elevationLevel3 * control.themeGlobalScale
                                shadowOpacity: 0.12
                                shadowColor: MeoTheme.shadow
                            }

                            MeoStateLayer {
                                anchors.fill: parent
                                radius: parent.radius
                                pressed: actionButton.pressed
                                hovered: actionButton.hovered
                                focused: actionButton.visualFocus
                                pressX: actionButton.pressX
                                pressY: actionButton.pressY
                                color: control.itemOnColor
                            }
                        }
                    }

                    contentItem: Item {
                        z: 2
                        Row {
                            id: actionContent
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8 * control.themeGlobalScale
                            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

                            MeoIcon {
                                icon: actionButton.modelData.icon || "arrow_forward"
                                size: 24 * control.themeGlobalScale
                                color: control.itemOnColor
                            }

                            Text {
                                text: actionButton.modelData.label || ""
                                visible: text.length > 0
                                font.family: control.themeFontFamily
                                font.pixelSize: control.fontTitleMedium.size * control.themeFontScale * control.themeGlobalScale
                                font.weight: control.fontTitleMedium.weight
                                color: control.itemOnColor
                                lineHeightMode: Text.FixedHeight
                                lineHeight: (control.fontTitleMedium.lineHeight || 24) * control.themeGlobalScale
                            }
                        }
                    }

                    onClicked: {
                        if (actionButton.modelData.action && typeof actionButton.modelData.action === "function") {
                            actionButton.modelData.action()
                        }
                        control.itemClicked(actionButton.index, actionButton.modelData)
                        control.opened = false
                        control.toggled(false)
                    }
                }
            }
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: control.motionDuration; easing.bezierCurve: MeoTheme.motionEasingStandardDecelerate }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationEffectDefault; easing.bezierCurve: MeoTheme.motionEasingStandardAccelerate }
        }
    }

    // 🌟 2. 主 FAB 按钮 (Main Trigger FAB)
    MeoFAB {
        id: mainFab
        objectName: "meoFabMenuTrigger"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        icon.name: control.opened ? control.activeIcon : control.icon
        type: control.triggerFabType
        containerSizeOverride: control.initialTriggerSize
                               + (control.finalTriggerSize - control.initialTriggerSize) * control.openProgress
        containerRadiusOverride: control.initialTriggerRadius
                                 + (control.finalTriggerSize / 2 - control.initialTriggerRadius) * control.openProgress
        iconSizeOverride: control.initialTriggerIconSize
                          + (control.finalTriggerIconSize - control.initialTriggerIconSize) * control.openProgress
        containerColorOverride: control.blendedColor(control.color, control.styleFinalColor, control.openProgress)
        contentColorOverride: control.blendedColor(control.onColor, control.styleFinalOnColor, control.openProgress)
        Accessible.name: control.opened ? control.activeIcon : control.icon

        onClicked: {
            control.opened = !control.opened
            control.toggled(control.opened)
        }
    }
}
