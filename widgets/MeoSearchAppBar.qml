import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    property string text: ""
    property string placeholder: "Search..."
    property bool active: false
    property string leadingIcon: "search"
    property string trailingIcon: "person"
    property Component menuIcon: null
    property list<Component> actions

    readonly property color themeSurface: MeoTheme.surface
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real horizontalPadding: 16 * themeGlobalScale
    readonly property real actionReservation: !active && actionRow.visible
                                              ? actionRow.width + 8 * themeGlobalScale : 0
    readonly property bool reducedMotion: MeoTheme.reduceMotion

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 64 * themeGlobalScale
    color: themeSurface
    Accessible.role: Accessible.Pane
    Accessible.name: active ? qsTr("Active search") : qsTr("Search")

    // This is a compact app-bar search affordance. Full-screen search results
    // belong to MeoSearchView, which owns its modal and dismiss behaviour.

    MeoSearchBar {
        id: searchBar
        anchors.left: parent.left
        anchors.leftMargin: control.horizontalPadding
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, Math.min(720 * control.themeGlobalScale,
                                    parent.width - control.horizontalPadding * 2
                                    - control.actionReservation))
        height: 56 * control.themeGlobalScale
        active: control.active
        placeholder: control.placeholder
        text: control.text
        leadingIcon: control.leadingIcon
        trailingIcon: control.trailingIcon

        onActivated: control.active = true
        onActiveChanged: control.active = active
        onTextChanged: control.text = text

        Behavior on width {
            enabled: !control.reducedMotion
            NumberAnimation {
                duration: MeoTheme.motionDurationSelection
                easing.bezierCurve: MeoTheme.motionEasingEmphasized
            }
        }
    }

    Row {
        id: actionRow
        anchors.right: parent.right
        anchors.rightMargin: control.horizontalPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4 * control.themeGlobalScale
        visible: !control.active && control.actions.length > 0

        Repeater {
            model: control.actions
            delegate: Loader { sourceComponent: modelData }
        }
    }
}
