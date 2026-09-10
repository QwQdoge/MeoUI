import QtQuick
import MeoUI

// Material FAB menu. The trigger is a FAB; its actions intentionally use the
// same anchored menu surface, focus model, and exit lifecycle as every other
// Meo dropdown. This replaces the previous private speed-dial popup.
Item {
    id: control

    // model: [{ label: "New document", icon: "note_add", action: function }, ...]
    property var model: []
    property bool opened: false
    property string icon: "add"
    property string activeIcon: "close"
    property string fabType: "regular" // "small" | "regular" | "medium" | "large"
    property string colorStyle: "primary" // "primary" | "secondary" | "tertiary"
    property bool enableScrim: false
    property real menuGap: MeoTheme.space8

    readonly property bool mirrored: LayoutMirroring.enabled
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property string triggerFabType: fabType === "small" || fabType === "medium" || fabType === "large"
                                                 ? fabType : "regular"
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
    // Compatibility aliases for existing users and tests.
    readonly property color color: styleInitialColor
    readonly property color onColor: styleInitialOnColor
    readonly property color itemColor: MeoTheme.surfaceContainer
    readonly property color itemOnColor: MeoTheme.contentOnSurface

    signal itemClicked(int index, var itemData)
    signal toggled(bool opened)

    implicitWidth: mainFab.implicitWidth
    implicitHeight: mainFab.implicitHeight
    width: implicitWidth
    height: implicitHeight

    function modelCount() {
        if (!model)
            return 0
        return typeof model.count === "number" ? model.count
             : typeof model.length === "number" ? model.length : 0
    }

    function modelItem(index) {
        if (index < 0 || index >= modelCount())
            return null
        return typeof model.get === "function" ? model.get(index) : model[index]
    }

    // MeoMenu owns keyboard navigation and action execution. Wrap only the
    // callback so this control retains its public itemClicked signal.
    function menuEntries() {
        const entries = []
        const count = Math.min(modelCount(), 6)
        for (let index = 0; index < count; ++index) {
            const source = modelItem(index)
            const entry = typeof source === "object" && source ? Object.assign({}, source)
                  : { "label": String(source || "") }
            entry.action = (function(itemIndex, itemData, originalAction) {
                return function() {
                    if (typeof originalAction === "function")
                        originalAction()
                    control.itemClicked(itemIndex, itemData)
                }
            })(index, source, source && source.action)
            entries.push(entry)
        }
        return entries
    }

    onOpenedChanged: {
        if (opened && !menuPopup.opened)
            menuPopup.open()
        else if (!opened && menuPopup.opened)
            menuPopup.close()
    }

    MeoMenu {
        id: menuPopup
        objectName: "meoFabMenuPopup"
        parent: control
        x: control.mirrored ? 0 : control.width - width
        y: -height - control.menuGap
        model: control.menuEntries()
        preferredMenuWidth: 224 * control.themeGlobalScale
        maximumMenuWidth: 320 * control.themeGlobalScale
        modal: control.enableScrim
        dim: control.enableScrim
        focusReturnItem: mainFab
        onClosed: {
            if (control.opened) {
                control.opened = false
                control.toggled(false)
            }
        }
    }

    MeoFAB {
        id: mainFab
        objectName: "meoFabMenuTrigger"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        icon.name: control.opened ? control.activeIcon : control.icon
        type: control.triggerFabType
        containerColorOverride: control.opened ? control.styleFinalColor : control.styleInitialColor
        contentColorOverride: control.opened ? control.styleFinalOnColor : control.styleInitialOnColor
        Accessible.name: control.opened ? qsTr("Close actions") : qsTr("Open actions")
        onClicked: {
            control.opened = !control.opened
            control.toggled(control.opened)
        }
    }
}
