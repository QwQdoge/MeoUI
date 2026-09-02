import QtQuick
import MeoUI

Rectangle {
    id: control

    property var model: []
    property int currentIndex: 0
    // Semantic selection is useful when a caller's model can be reordered.
    // Keep currentIndex for compatibility, but always expose the stable id too.
    property string currentId: ""
    property string labelType: "always" // "always" | "selected" | "none"
    // Kept for source compatibility. M3 navigation-bar indicators are always
    // pill-shaped, rather than using the general expressive-shape catalogue.
    property string shape: "pill"
    property bool compact: false
    signal clicked(int index)
    signal activated(var item, int index)

    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themeSecondary: MeoTheme.secondary
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionSelection: MeoTheme.motionDurationSelection
    readonly property int motionState: MeoTheme.motionDurationState
    readonly property var fontLabel: MeoTheme.labelMedium

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: (compact ? 64 : 80) * themeGlobalScale
    radius: 0
    color: themeSurfaceContainer

    function selectedIdForIndex(index) {
        if (index < 0 || index >= model.length)
            return ""
        const entry = model[index]
        return entry && entry.id !== undefined ? String(entry.id) : ""
    }

    function indexForId(id) {
        for (let i = 0; i < model.length; ++i) {
            if (model[i] && model[i].id !== undefined && String(model[i].id) === id)
                return i
        }
        return -1
    }

    onCurrentIndexChanged: {
        const nextId = selectedIdForIndex(currentIndex)
        if (currentId !== nextId)
            currentId = nextId
    }

    onCurrentIdChanged: {
        if (currentId === "")
            return
        const nextIndex = indexForId(currentId)
        if (nextIndex >= 0 && currentIndex !== nextIndex)
            currentIndex = nextIndex
    }

    onModelChanged: {
        if (currentId !== "") {
            const nextIndex = indexForId(currentId)
            if (nextIndex >= 0)
                currentIndex = nextIndex
        } else if (currentIndex >= model.length) {
            currentIndex = Math.max(0, model.length - 1)
        }
    }

    Component.onCompleted: {
        if (currentId === "")
            currentId = selectedIdForIndex(currentIndex)
    }

    Row {
        id: destinationsRow
        anchors.fill: parent
        anchors.leftMargin: 8 * control.themeGlobalScale
        anchors.rightMargin: 8 * control.themeGlobalScale
        // NavigationBarTokens.ItemBetweenSpace is 0dp; item hit targets divide
        // the full available width without a visual gutter.
        spacing: 0

        Repeater {
            model: control.model

            delegate: Item {
                id: destination
                objectName: "meoNavigationBarDestination_" + index
                required property int index
                required property var modelData
                width: Math.max(0, (destinationsRow.width - destinationsRow.spacing * Math.max(0, control.model.length - 1)) / Math.max(1, control.model.length))
                height: destinationsRow.height
                activeFocusOnTab: true

                readonly property bool isSelected: control.currentIndex === index
                readonly property bool isEnabled: modelData.enabled === undefined || modelData.enabled
                readonly property string itemLabel: modelData.label || modelData.text || ""
                readonly property string itemIcon: modelData.icon || ""
                opacity: isEnabled ? 1.0 : 0.38

                Accessible.role: Accessible.PageTab
                Accessible.name: itemLabel
                Accessible.selected: isSelected
                Accessible.focusable: true
                Accessible.onPressAction: activate()

                function activate() {
                    if (!isEnabled)
                        return
                    control.currentIndex = index
                    control.clicked(index)
                    control.activated(modelData, index)
                }

                Column {
                    anchors.centerIn: parent
                    // NavigationBarTokens.ItemActiveIndicatorIconLabelSpace.
                    spacing: 4 * control.themeGlobalScale

                    Item {
                        width: 56 * control.themeGlobalScale
                        height: 32 * control.themeGlobalScale
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: indicator
                            objectName: "meoNavigationBarIndicator_" + destination.index
                            anchors.centerIn: parent
                            // AndroidX lays out a fixed 56x32dp ripple target,
                            // while the selected indicator itself grows from
                            // 0 to 56dp. Unselected hover/press feedback is
                            // confined to that target; it is not a separate
                            // 32dp container fill.
                            // Source: androidx-main NavigationBar.kt 46315709ff02b6658781a182cf68a5bfb2301a3a
                            // and NavigationBarVerticalItemTokens.kt ccaa2bfa93304db4cb35216ea2076e1de13129e0
                            // (Apache-2.0); rendered with existing MeoStateLayer.
                            width: destination.isSelected ? parent.width : 0
                            height: parent.height
                            radius: height / 2
                            color: destination.isSelected ? control.themeSecondaryContainer : "transparent"

                            Behavior on width {
                                NumberAnimation {
                                    duration: control.motionSelection
                                    easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: control.motionState
                                    easing.bezierCurve: destination.isSelected
                                                        ? MeoTheme.motionEasingEnter
                                                        : MeoTheme.motionEasingExit
                                }
                            }
                        }

                        // Compose maps the whole destination interaction into
                        // this 56x32dp pill. Keeping the state layer here
                        // prevents a hover or press fill across the full item
                        // target while preserving that target's semantics.
                        MeoStateLayer {
                            anchors.fill: parent
                            radius: parent.height / 2
                            shape: "pill"
                            hovered: hitArea.containsMouse
                            pressed: hitArea.pressed
                            focused: destination.activeFocus
                            pressX: hitArea.mouseX - parent.x
                            pressY: hitArea.mouseY - parent.y
                            color: destination.isSelected
                                   ? control.themeOnSecondaryContainer
                                   : control.themeOnSurface
                        }

                        MeoIcon {
                            anchors.centerIn: parent
                            icon: destination.itemIcon
                            fill: destination.isSelected
                            size: 24
                            color: destination.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                        }

                        MeoBadge {
                            text: modelData.badgeText || (modelData.badgeCount !== undefined ? modelData.badgeCount.toString() : "")
                            isDot: modelData.badgeDot || false
                            visible: text !== "" || isDot
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: -3 * control.themeGlobalScale
                            anchors.rightMargin: -3 * control.themeGlobalScale
                        }

                    }

                    Text {
                        text: destination.itemLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: MeoTheme.typefacePlain
                        font.pixelSize: control.fontLabel.size * control.themeGlobalScale
                        font.weight: destination.isSelected ? Font.DemiBold : control.fontLabel.weight
                        color: destination.isSelected ? control.themeSecondary : control.themeOnSurfaceVariant
                        visible: control.labelType === "always" || (control.labelType === "selected" && destination.isSelected)
                    }
                }

                MouseArea {
                    id: hitArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: destination.isEnabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        destination.forceActiveFocus(Qt.MouseFocusReason)
                        destination.activate()
                    }
                }
                Keys.onReturnPressed: activate()
                Keys.onEnterPressed: activate()
                Keys.onSpacePressed: activate()
            }
        }
    }
}
