import QtQuick
import QtQuick.Controls
import MeoUI

// M3 Expressive replacement for the legacy bottom app bar. This is a docked
// action surface, not navigation: hosts should not show it alongside a
// navigation bar for the same hierarchy level.
Control {
    id: control

    // `actions` remains the extensibility slot for arbitrary controls such as
    // MeoButton, MeoIconButton, or MeoTextField. `actionIcons` is the concise
    // option for common icon-only toolbar actions.
    property list<Component> actions
    property var actionIcons: []
    property int selectedActionIndex: -1
    property Component primaryAction: null
    property string colorStyle: "standard" // "standard" | "vibrant"
    property bool isVibrant: false // Compatibility alias for colorStyle.
    property real actionSpacing: 8 * MeoTheme.globalScale
    signal actionTriggered(int index, string iconName)

    readonly property bool vibrant: colorStyle === "vibrant" || isVibrant
    // AndroidX FloatingToolbarTokens: standard SurfaceContainer; vibrant
    // PrimaryContainer. This docked M3E action surface shares those roles.
    readonly property color containerColor: vibrant ? MeoTheme.primaryContainer : MeoTheme.surfaceContainer
    readonly property color contentColor: vibrant ? MeoTheme.contentOnPrimaryContainer : MeoTheme.contentOnSurface
    readonly property color selectedContainerColor: vibrant
                                                    ? Qt.rgba(MeoTheme.contentOnPrimary.r, MeoTheme.contentOnPrimary.g, MeoTheme.contentOnPrimary.b, 0.16)
                                                    : MeoTheme.secondaryContainer
    readonly property color selectedContentColor: vibrant ? MeoTheme.contentOnSurface : MeoTheme.contentOnSecondaryContainer

    implicitWidth: 360 * MeoTheme.globalScale
    implicitHeight: 64 * MeoTheme.globalScale
    padding: 0
    Accessible.role: Accessible.ToolBar
    Accessible.name: qsTr("Docked toolbar")

    background: Rectangle {
        color: control.containerColor
        radius: 0
    }

    contentItem: Item {
        id: toolbarContent
        anchors.fill: parent

        Row {
            id: toolbarRow
            anchors.left: parent.left
            anchors.leftMargin: 16 * MeoTheme.globalScale
            anchors.right: primaryLoader.left
            anchors.rightMargin: primaryLoader.visible ? control.actionSpacing : 16 * MeoTheme.globalScale
            anchors.verticalCenter: parent.verticalCenter
            height: implicitHeight
            spacing: control.actionSpacing
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

            Repeater {
                model: control.actionIcons

                delegate: ToolbarIconAction {
                    required property var modelData
                    required property int index
                    objectName: "meoDockedToolbarAction_" + index
                    iconName: typeof modelData === "string" ? modelData : (modelData.icon || "")
                    accessibleName: typeof modelData === "string" ? modelData : (modelData.accessibleName || iconName)
                    enabled: typeof modelData === "string" || modelData.enabled === undefined || modelData.enabled
                    selected: control.selectedActionIndex === index
                    onClicked: control.actionTriggered(index, iconName)
                }
            }

            Repeater {
                model: control.actions
                delegate: Loader {
                    required property int index
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: modelData
                }
            }
        }

        Loader {
            id: primaryLoader
            anchors.right: parent.right
            anchors.rightMargin: 16 * MeoTheme.globalScale
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: control.primaryAction
            visible: sourceComponent !== null
        }
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
