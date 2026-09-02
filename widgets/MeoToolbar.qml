import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property string title: ""
    property list<Component> actions
    property bool isCompact: false

    // Reuse the library's semantic surface, type, and density contracts.
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontTitleMedium: MeoTheme.titleMedium

    implicitWidth: Math.max(160 * themeGlobalScale,
                            titleText.implicitWidth + actionsRow.implicitWidth + 48 * themeGlobalScale)
    implicitHeight: (isCompact ? 48 : 56) * themeGlobalScale
    color: themeSurface
    Accessible.role: Accessible.ToolBar
    Accessible.name: title !== "" ? title : qsTr("Toolbar")

    // Implementation using anchors for better reliability without RowLayout
    Row {
        id: actionsRow
        anchors.right: parent.right
        anchors.rightMargin: 16 * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8 * control.themeGlobalScale

        Repeater {
            model: control.actions
            delegate: Loader { sourceComponent: modelData }
        }
    }

    Text {
        id: titleText
        text: control.title
        visible: text !== ""
        anchors.left: parent.left
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: actionsRow.left
        anchors.rightMargin: 16 * control.themeGlobalScale
        font.pixelSize: fontTitleMedium.size * control.themeGlobalScale
        font.weight: fontTitleMedium.weight
        color: control.themeOnSurface
        elide: Text.ElideRight
    }
}
