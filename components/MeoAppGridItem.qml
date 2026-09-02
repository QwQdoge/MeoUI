import QtQuick
import QtQuick.Controls
import MeoUI

// A launcher-grid primitive.  Hosts can supply a native icon component (for
// example Kirigami.Icon for a Kicker QIcon) without making MeoUI depend on a
// desktop shell module.
Control {
    id: control

    property string title: ""
    property string iconName: "apps"
    property Component iconContent: null
    property bool selected: false
    property bool compact: false
    signal triggered()

    readonly property real uiScale: MeoTheme.globalScale
    readonly property real iconExtent: (compact ? 40 : 48) * uiScale
    // Chromium's dense launcher item itself is 80 × 88 DIP.  The host grid
    // supplies the 104-DIP row pitch and any responsive horizontal spacing;
    // keeping the visual tile separate prevents the hit target from changing
    // the reference geometry.
    readonly property real tileWidth: (compact ? 72 : 80) * uiScale
    readonly property real tileHeight: (compact ? 80 : 88) * uiScale

    implicitWidth: tileWidth
    implicitHeight: tileHeight
    opacity: enabled ? 1.0 : MeoTheme.disabledContentOpacity
    hoverEnabled: true
    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.focusable: activeFocusOnTab
    Accessible.onPressAction: activate()
    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()

    function activate() {
        if (enabled)
            triggered()
    }

    background: Item {
        Rectangle {
            anchors.centerIn: parent
            width: control.tileWidth
            height: control.tileHeight
            radius: MeoTheme.shapeLarge
            color: control.selected ? MeoTheme.secondaryContainer : "transparent"

            MeoStateLayer {
                anchors.fill: parent
                radius: parent.radius
                hovered: control.hovered
                pressed: pointer.pressed
                focused: control.activeFocus
                color: control.selected ? MeoTheme.contentOnSecondaryContainer : MeoTheme.contentOnSurface
            }
        }
    }

    contentItem: Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: (parent.height - control.tileHeight) / 2 + MeoTheme.space4
        width: control.tileWidth
        spacing: MeoTheme.space8

        Item {
            width: parent.width
            height: control.iconExtent

            Loader {
                anchors.centerIn: parent
                width: control.iconExtent
                height: control.iconExtent
                active: control.iconContent !== null
                sourceComponent: control.iconContent
            }

            MeoIcon {
                visible: control.iconContent === null
                anchors.centerIn: parent
                icon: control.iconName
                size: control.iconExtent
                color: control.selected ? MeoTheme.contentOnSecondaryContainer : MeoTheme.contentOnSurface
            }
        }

        MeoText {
            width: parent.width
            text: control.title
            typeRole: "label"
            typeSize: "small"
            color: control.selected ? MeoTheme.contentOnSecondaryContainer : MeoTheme.contentOnSurface
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        enabled: control.enabled
        onClicked: control.activate()
    }
}
