import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // Standard Material tabs are the default. The expressive pill is opt-in so
    // ordinary application navigation does not turn into a quick-settings row.
    property var model: [] // strings or { label/text, icon, badgeText, badgeDot, enabled }
    property int currentIndex: 0
    property string type: "primary" // "primary" | "secondary"
    property string style: "standard" // "standard" | "expressive"; "underline" remains a standard alias
    property bool isScrollable: false

    signal clicked(int index)

    readonly property bool expressive: style === "expressive" && type === "primary"
    readonly property bool hasIcons: {
        for (let index = 0; index < model.length; ++index) {
            if (tabIcon(model[index]) !== "")
                return true
        }
        return false
    }
    // AndroidX TabRowDefaults.ScrollableTabRowEdgeStartPadding = 52dp.
    readonly property real edgeInset: isScrollable
                                      ? (expressive ? 4 : 52) * MeoTheme.globalScale
                                      : 0
    // AndroidX TabBaselineLayout uses 72dp when a standard primary tab stacks
    // an icon above its label; 48dp remains the text-only/icon-only height.
    readonly property real tabHeight: expressive ? (hasIcons ? 72 : 56) * MeoTheme.globalScale
                                                 : (type === "primary" && hasIcons ? 72 : 48) * MeoTheme.globalScale

    function tabLabel(item) {
        return item && typeof item === "object" ? (item.label || item.text || "") : String(item || "")
    }

    function tabIcon(item) {
        return item && typeof item === "object" ? (item.icon || "") : ""
    }

    function tabEnabled(item) {
        return !item || typeof item !== "object" || item.enabled === undefined ? true : item.enabled
    }

    function activate(index) {
        if (index < 0 || index >= model.length || !tabEnabled(model[index]))
            return false
        currentIndex = index
        clicked(index)
        return true
    }

    function focusTab(startIndex, direction) {
        if (tabRepeater.count <= 0)
            return false
        const step = direction < 0 ? -1 : 1
        let candidate = startIndex
        for (let attempt = 0; attempt < tabRepeater.count; ++attempt) {
            candidate = (candidate + step + tabRepeater.count) % tabRepeater.count
            const tab = tabRepeater.itemAt(candidate)
            if (tab && tab.enabled) {
                tab.forceActiveFocus(Qt.TabFocusReason)
                return activate(candidate)
            }
        }
        return false
    }

    implicitWidth: 360 * MeoTheme.globalScale
    implicitHeight: tabHeight
    padding: 0

    background: Rectangle {
        color: control.expressive ? MeoTheme.surfaceContainerLow : MeoTheme.surface
        radius: control.expressive ? MeoTheme.shapeFull : 0

        Rectangle {
            visible: !control.expressive
            anchors.bottom: parent.bottom
            width: parent.width
            height: Math.max(1, MeoTheme.globalScale)
            color: MeoTheme.outlineVariant
        }
    }

    contentItem: ScrollView {
        id: scrollView
        clip: true
        contentWidth: control.isScrollable ? tabsRow.implicitWidth + control.edgeInset * 2 : control.availableWidth
        ScrollBar.horizontal.policy: control.isScrollable ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Row {
            id: tabsRow
            x: control.edgeInset
            height: control.availableHeight
            width: control.isScrollable ? implicitWidth : Math.max(0, control.availableWidth - control.edgeInset * 2)
            spacing: control.expressive ? 4 * MeoTheme.globalScale : 0
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

            Repeater {
                id: tabRepeater
                model: control.model

                delegate: Item {
                    id: tabItem
                    required property int index
                    required property var modelData
                    objectName: "meoTab_" + index

                    readonly property string label: control.tabLabel(modelData)
                    readonly property string iconName: control.tabIcon(modelData)
                    readonly property string badgeText: modelData && typeof modelData === "object" ? (modelData.badgeText || "") : ""
                    readonly property bool badgeDot: !!(modelData && typeof modelData === "object" && modelData.badgeDot)
                    readonly property bool selected: control.currentIndex === index
                    readonly property bool interactionEmphasis: tabPointer.containsMouse || tabPointer.pressed || activeFocus
                    readonly property color selectedContentColor: control.expressive
                                                                 ? MeoTheme.contentOnSecondaryContainer
                                                                 : (control.type === "secondary"
                                                                    ? MeoTheme.contentOnSurface
                                                                    : MeoTheme.primary)
                    readonly property color unselectedContentColor: interactionEmphasis
                                                                   ? MeoTheme.contentOnSurface
                                                                   : MeoTheme.contentOnSurfaceVariant
                    enabled: control.tabEnabled(modelData)
                    activeFocusOnTab: enabled
                    opacity: enabled ? 1.0 : 0.38
                    width: control.isScrollable
                           ? Math.max(90 * MeoTheme.globalScale, tabContent.implicitWidth + 32 * MeoTheme.globalScale)
                           : Math.max(0, (tabsRow.width - tabsRow.spacing * Math.max(0, control.model.length - 1)) / Math.max(1, control.model.length))
                    height: tabsRow.height

                    Accessible.role: Accessible.PageTab
                    Accessible.name: label
                    Accessible.selected: selected
                    Accessible.onPressAction: control.activate(index)

                    Rectangle {
                        visible: control.expressive && tabItem.selected
                        anchors.centerIn: parent
                        width: Math.min(parent.width - 8 * MeoTheme.globalScale,
                                        Math.max(64 * MeoTheme.globalScale, tabContent.implicitWidth + 28 * MeoTheme.globalScale))
                        height: control.hasIcons ? 56 * MeoTheme.globalScale : 40 * MeoTheme.globalScale
                        radius: MeoTheme.shapeFull
                        color: MeoTheme.secondaryContainer

                        Behavior on width {
                            enabled: !MeoTheme.reduceMotion
                            NumberAnimation {
                                duration: MeoTheme.motionDurationSelection
                                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                            }
                        }
                    }

                    Column {
                        id: tabContent
                        anchors.centerIn: parent
                        spacing: tabItem.iconName === "" ? 0 : 2 * MeoTheme.globalScale

                        Item {
                            visible: tabItem.iconName !== ""
                            width: 28 * MeoTheme.globalScale
                            height: 26 * MeoTheme.globalScale
                            anchors.horizontalCenter: parent.horizontalCenter

                            MeoIcon {
                                anchors.centerIn: parent
                                icon: tabItem.iconName
                                fill: tabItem.selected
                                size: 24 * MeoTheme.globalScale
                                color: tabItem.selected
                                       ? tabItem.selectedContentColor
                                       : tabItem.unselectedContentColor
                            }

                            MeoBadge {
                                text: tabItem.badgeText
                                isDot: tabItem.badgeDot
                                visible: text !== "" || isDot
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: -3 * MeoTheme.globalScale
                                anchors.rightMargin: -3 * MeoTheme.globalScale
                            }
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4 * MeoTheme.globalScale
                            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

                            Text {
                                text: tabItem.label
                                font.family: MeoTheme.typefacePlain
                                font.pixelSize: MeoTheme.titleSmall.size * MeoTheme.fontScale * MeoTheme.globalScale
                                font.weight: MeoTheme.titleSmall.weight
                                color: tabItem.selected
                                       ? tabItem.selectedContentColor
                                       : tabItem.unselectedContentColor
                                Behavior on color {
                                    enabled: !MeoTheme.reduceMotion
                                    ColorAnimation { duration: MeoTheme.motionDurationState }
                                }
                            }

                            MeoBadge {
                                visible: tabItem.iconName === "" && (tabItem.badgeText !== "" || tabItem.badgeDot)
                                text: tabItem.badgeText
                                isDot: tabItem.badgeDot
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        visible: !control.expressive && tabItem.selected
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: control.type === "secondary" ? parent.width : Math.max(24 * MeoTheme.globalScale, tabContent.implicitWidth)
                        height: 3 * MeoTheme.globalScale
                        radius: 3 * MeoTheme.globalScale
                        color: MeoTheme.primary

                        Behavior on width {
                            enabled: !MeoTheme.reduceMotion
                            NumberAnimation {
                                duration: MeoTheme.motionDurationSelection
                                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                            }
                        }
                    }

                    MeoStateLayer {
                        anchors.fill: parent
                        anchors.margins: control.expressive ? 4 * MeoTheme.globalScale : 0
                        radius: control.expressive ? MeoTheme.shapeFull : 8 * MeoTheme.globalScale
                        pressed: tabPointer.pressed
                        hovered: tabPointer.containsMouse
                        focused: tabItem.activeFocus
                        pressX: tabPointer.mouseX
                        pressY: tabPointer.mouseY
                        color: tabItem.selected && control.expressive ? MeoTheme.contentOnSecondaryContainer : MeoTheme.contentOnSurface
                    }

                    MouseArea {
                        id: tabPointer
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: tabItem.enabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            tabItem.forceActiveFocus(Qt.MouseFocusReason)
                            control.activate(index)
                        }
                    }

                    Keys.onLeftPressed: control.focusTab(index, control.mirrored ? 1 : -1)
                    Keys.onRightPressed: control.focusTab(index, control.mirrored ? -1 : 1)
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Home) {
                            control.focusTab(-1, 1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_End) {
                            control.focusTab(0, -1)
                            event.accepted = true
                        }
                    }
                    Keys.onReturnPressed: control.activate(index)
                    Keys.onEnterPressed: control.activate(index)
                    Keys.onSpacePressed: control.activate(index)
                }
            }
        }
    }
}
