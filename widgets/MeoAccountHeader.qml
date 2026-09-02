import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string name: "User Name"
    property string email: "user@example.com"
    property string avatarSource: ""
    property string avatarInitials: ""
    property bool showDropdown: true
    property bool interactive: true

    signal clicked()
    signal dropdownClicked()

    // Reuse the shared color, typography, and density contracts.
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property real themeGlobalScale: MeoTheme.globalScale

    readonly property var fontTitleMedium: MeoTheme.titleMedium
    readonly property var fontBodySmall: MeoTheme.bodySmall

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 72 * themeGlobalScale
    activeFocusOnTab: enabled && interactive
    Accessible.role: Accessible.Button
    Accessible.name: email !== "" ? qsTr("%1, %2").arg(name).arg(email) : name
    Accessible.focusable: activeFocusOnTab
    Accessible.onPressAction: activate()
    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()

    function activate() {
        if (enabled && interactive)
            clicked()
    }

    Row {
        z: 1
        anchors.fill: parent
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.rightMargin: 16 * control.themeGlobalScale
        spacing: 16 * control.themeGlobalScale

        // 🖼️ Avatar
        MeoAvatar {
            width: 40 * control.themeGlobalScale
            height: 40 * control.themeGlobalScale
            size: 40
            color: control.themeSecondaryContainer
            textColor: control.themeOnSecondaryContainer
            source: control.avatarSource
            initials: control.avatarInitials
            anchors.verticalCenter: parent.verticalCenter
        }

        // 🔤 Info
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 40 * control.themeGlobalScale - (control.showDropdown ? 32 * control.themeGlobalScale : 0) - (parent.spacing * 2)

            Text {
                text: control.name
                font.pixelSize: fontTitleMedium.size * control.themeGlobalScale
                font.weight: fontTitleMedium.weight
                color: control.themeOnSurface
                width: parent.width
                elide: Text.ElideRight
            }

            Text {
                text: control.email
                font.pixelSize: fontBodySmall.size * control.themeGlobalScale
                font.weight: fontBodySmall.weight
                color: control.themeOnSurfaceVariant
                width: parent.width
                elide: Text.ElideRight
            }
        }

        // 🔽 Dropdown Icon
        MeoIconButton {
            icon.name: "arrow_drop_down"
            visible: control.showDropdown
            anchors.verticalCenter: parent.verticalCenter
            width: 32 * control.themeGlobalScale
            height: 32 * control.themeGlobalScale
            onClicked: control.dropdownClicked()
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: control.enabled && control.interactive
        onClicked: control.activate()
        z: 0
    }
}
