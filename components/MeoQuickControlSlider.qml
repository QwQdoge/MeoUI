import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Control {
    id: control
    property string iconName: ""
    property string label: ""
    property string accessibleName: label
    property string iconAccessibleName: accessibleName
    property bool iconActionEnabled: iconAccessibleName !== ""
    property real from: 0
    property real to: 100
    property real value: 0
    property bool detailsAvailable: false
    property bool expanded: false
    signal moved(real value)
    signal iconTriggered()
    signal detailsToggled(bool expanded)

    implicitWidth: 360 * MeoTheme.globalScale
    implicitHeight: 56 * MeoTheme.globalScale
    padding: 0
    background: MeoShape { type: "round"; radius: height / 2; color: MeoTheme.surfaceContainerHighest }

    contentItem: RowLayout {
        spacing: 0
        AbstractButton {
            id: iconButton
            objectName: "quickControlIconButton"
            Layout.preferredWidth: 52 * MeoTheme.globalScale
            Layout.fillHeight: true
            enabled: control.enabled && control.iconActionEnabled
            padding: 0
            activeFocusOnTab: enabled
            Accessible.name: control.iconAccessibleName
            Accessible.description: control.accessibleName
            onClicked: control.iconTriggered()

            background: Item {
                Rectangle {
                    anchors.fill: parent
                    color: MeoTheme.primaryContainer
                    topLeftRadius: height / 2
                    bottomLeftRadius: height / 2
                    topRightRadius: MeoTheme.shapeSmall
                    bottomRightRadius: MeoTheme.shapeSmall
                }
                MeoStateLayer {
                    anchors.fill: parent
                    radius: MeoTheme.shapeSmall
                    hovered: iconButton.hovered
                    pressed: iconButton.pressed
                    focused: iconButton.visualFocus
                    color: MeoTheme.onPrimaryContainer
                }
            }

            contentItem: MeoIcon {
                icon: control.iconName
                size: 22
                color: MeoTheme.onPrimaryContainer
                opacity: control.enabled ? 1 : MeoTheme.disabledContentOpacity
            }
        }
        Item {
            id: sliderArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            readonly property real fraction: control.to > control.from
                ? Math.max(0, Math.min(1, (control.value - control.from) / (control.to - control.from))) : 0
            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(4 * MeoTheme.globalScale, sliderArea.fraction * parent.width)
                height: parent.height
                color: MeoTheme.primaryContainer
            }
            Rectangle {
                x: Math.max(0, Math.min(parent.width - width, sliderArea.fraction * parent.width - width / 2))
                anchors.verticalCenter: parent.verticalCenter
                width: 6 * MeoTheme.globalScale
                height: 44 * MeoTheme.globalScale
                radius: width / 2
                color: MeoTheme.primary
            }
            MeoText {
                anchors.left: parent.left
                anchors.leftMargin: MeoTheme.space8
                anchors.verticalCenter: parent.verticalCenter
                visible: control.label !== ""
                text: control.label
                typeRole: "label"
                typeSize: "small"
                emphasized: true
                color: sliderArea.fraction > 0.42 ? MeoTheme.onPrimaryContainer : MeoTheme.onSurface
                elide: Text.ElideRight
                width: Math.min(112 * MeoTheme.globalScale, parent.width * 0.36)
            }
            Slider {
                id: valueSlider
                objectName: "quickControlValueSlider"
                anchors.fill: parent
                from: control.from
                to: control.to
                value: control.value
                activeFocusOnTab: enabled
                Accessible.name: control.accessibleName
                Accessible.description: control.label !== control.accessibleName ? control.label : ""
                background: Item {}
                handle: Item {}
                onMoved: control.moved(value)
            }
        }
        MeoIconButton {
            visible: control.detailsAvailable
            Layout.preferredWidth: 44 * MeoTheme.globalScale
            type: "standard"
            size: "m"
            icon.name: control.expanded ? "expand_less" : "expand_more"
            Accessible.name: control.expanded ? qsTr("Hide advanced controls") : qsTr("Show advanced controls")
            onClicked: {
                control.expanded = !control.expanded
                control.detailsToggled(control.expanded)
            }
        }
    }
}
