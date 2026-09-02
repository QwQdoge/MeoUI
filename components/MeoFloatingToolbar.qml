import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

// Contextual M3 Expressive toolbar. Unlike the docked variant it carries a
// modest elevation and may pair a separate FAB with its action group.
Item {
    id: control

    property list<Component> actions
    property var actionIcons: []
    property int selectedActionIndex: -1
    property Component fab: null
    property string orientation: "horizontal" // "horizontal" | "vertical"
    property string colorStyle: "standard" // "standard" | "vibrant"
    property bool isVibrant: false // Compatibility alias for colorStyle.
    property real actionSpacing: 8 * MeoTheme.globalScale
    property real fabSpacing: 12 * MeoTheme.globalScale
    signal actionTriggered(int index, string iconName)

    readonly property bool horizontal: orientation !== "vertical"
    readonly property bool vibrant: colorStyle === "vibrant" || isVibrant
    // AndroidX FloatingToolbarTokens maps standard to SurfaceContainer and
    // vibrant to PrimaryContainer, with their matching content roles.
    readonly property color containerColor: vibrant ? MeoTheme.primaryContainer : MeoTheme.surfaceContainer
    readonly property color contentColor: vibrant ? MeoTheme.contentOnPrimaryContainer : MeoTheme.contentOnSurface
    readonly property color selectedContainerColor: vibrant
                                                    ? Qt.rgba(MeoTheme.contentOnPrimary.r, MeoTheme.contentOnPrimary.g, MeoTheme.contentOnPrimary.b, 0.16)
                                                    : MeoTheme.secondaryContainer
    readonly property color selectedContentColor: vibrant ? MeoTheme.contentOnSurface : MeoTheme.contentOnSecondaryContainer
    readonly property real surfaceWidth: horizontal ? Math.max(64 * MeoTheme.globalScale, horizontalActions.implicitWidth + 32 * MeoTheme.globalScale)
                                                   : 64 * MeoTheme.globalScale
    readonly property real surfaceHeight: horizontal ? 64 * MeoTheme.globalScale
                                                    : Math.max(64 * MeoTheme.globalScale, verticalActions.implicitHeight + 32 * MeoTheme.globalScale)

    implicitWidth: horizontal ? surfaceWidth + (fabLoader.active ? fabSpacing + fabLoader.implicitWidth : 0)
                              : Math.max(surfaceWidth, fabLoader.active ? fabLoader.implicitWidth : 0)
    implicitHeight: horizontal ? Math.max(surfaceHeight, fabLoader.active ? fabLoader.implicitHeight : 0)
                               : surfaceHeight + (fabLoader.active ? fabSpacing + fabLoader.implicitHeight : 0)
    Accessible.role: Accessible.ToolBar
    Accessible.name: qsTr("Floating toolbar")

    Rectangle {
        id: toolbarSurface
        width: control.surfaceWidth
        height: control.surfaceHeight
        anchors.left: parent.left
        anchors.top: parent.top
        radius: height / 2
        color: control.containerColor

        layer.enabled: visible
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.18
            shadowVerticalOffset: 2 * MeoTheme.globalScale
            shadowOpacity: 0.18
            shadowColor: MeoTheme.shadow
        }

        Row {
            id: horizontalActions
            visible: control.horizontal
            anchors.centerIn: parent
            spacing: control.actionSpacing
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

            Repeater {
                model: control.horizontal ? control.actionIcons : []
                delegate: ToolbarIconAction {
                    required property var modelData
                    required property int index
                    iconName: typeof modelData === "string" ? modelData : (modelData.icon || "")
                    accessibleName: typeof modelData === "string" ? modelData : (modelData.accessibleName || iconName)
                    selected: control.selectedActionIndex === index
                    onClicked: control.actionTriggered(index, iconName)
                }
            }
            Repeater {
                model: control.horizontal ? control.actions : []
                delegate: Loader { required property int index; anchors.verticalCenter: parent.verticalCenter; sourceComponent: modelData }
            }
        }

        Column {
            id: verticalActions
            visible: !control.horizontal
            anchors.centerIn: parent
            spacing: control.actionSpacing

            Repeater {
                model: !control.horizontal ? control.actionIcons : []
                delegate: ToolbarIconAction {
                    required property var modelData
                    required property int index
                    iconName: typeof modelData === "string" ? modelData : (modelData.icon || "")
                    accessibleName: typeof modelData === "string" ? modelData : (modelData.accessibleName || iconName)
                    selected: control.selectedActionIndex === index
                    onClicked: control.actionTriggered(index, iconName)
                }
            }
            Repeater {
                model: !control.horizontal ? control.actions : []
                delegate: Loader { required property int index; anchors.horizontalCenter: parent.horizontalCenter; sourceComponent: modelData }
            }
        }
    }

    Loader {
        id: fabLoader
        active: control.fab !== null
        sourceComponent: control.fab
        // A numeric expression cannot be assigned to an anchor line.  Keep the
        // FAB adjacent to the surface with ordinary geometry so switching the
        // toolbar orientation also cannot leave a stale anchor behind.
        x: control.horizontal
           ? toolbarSurface.x + toolbarSurface.width + control.fabSpacing
           : toolbarSurface.x + (toolbarSurface.width - width) / 2
        y: control.horizontal
           ? toolbarSurface.y + (toolbarSurface.height - height) / 2
           : toolbarSurface.y + toolbarSurface.height + control.fabSpacing
    }

    component ToolbarIconAction: AbstractButton {
        id: actionButton
        property string iconName: ""
        property string accessibleName: iconName
        property bool selected: false

        implicitWidth: 48 * MeoTheme.globalScale
        implicitHeight: implicitWidth
        padding: 0
        activeFocusOnTab: enabled
        Accessible.name: accessibleName

        background: Rectangle {
            radius: width / 2
            color: actionButton.selected ? control.selectedContainerColor : "transparent"
            MeoStateLayer {
                anchors.fill: parent
                radius: parent.radius
                hovered: actionButton.hovered
                pressed: actionButton.pressed
                focused: actionButton.visualFocus
                color: actionButton.selected ? control.selectedContentColor : control.contentColor
            }
        }

        contentItem: MeoIcon {
            anchors.centerIn: parent
            icon: actionButton.iconName
            fill: actionButton.selected
            size: 24 * MeoTheme.globalScale
            color: actionButton.selected ? control.selectedContentColor : control.contentColor
        }
    }
}
