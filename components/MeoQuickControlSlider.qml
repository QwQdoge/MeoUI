import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Control {
    id: control
    // Active quick controls use primary/onPrimary, not a pale tonal surface.
    readonly property color activeContainerColor: MeoTheme.primary
    readonly property color activeContentColor: MeoTheme.contentOnPrimary
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
    // Mirrors the user-facing tracking boundary used by SystemUI brightness
    // controllers. Hosts can use the end signal to persist a final value
    // without conflating it with every in-progress `moved` update.
    property bool tracking: false
    signal moved(real value)
    signal trackingStarted()
    signal trackingEnded(real value)
    signal iconTriggered()
    signal detailsToggled(bool expanded)

    readonly property real clampedValue: Math.max(Math.min(from, to), Math.min(Math.max(from, to), value))
    readonly property real valueFraction: to !== from
                                       ? Math.max(0, Math.min(1, (clampedValue - from) / (to - from)))
                                       : 0

    implicitWidth: 360 * MeoTheme.globalScale
    implicitHeight: 56 * MeoTheme.globalScale
    padding: 0
    opacity: enabled ? 1 : MeoTheme.disabledContentOpacity
    Behavior on opacity {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: MeoTheme.motionDurationState }
    }
    // The actual Qt Slider owns the slider semantic, matching AOSP's
    // ToggleSeekBar rather than exposing a duplicate slider on this wrapper.
    Accessible.ignored: true
    background: MeoShape {
        objectName: "meoQuickControlBackground"
        type: "round"
        radius: height / 2
        color: MeoTheme.surfaceContainerHighest
    }

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
                    color: control.activeContainerColor
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
                    color: control.activeContentColor
                }
            }

            contentItem: MeoIcon {
                icon: control.iconName
                size: 22
                color: control.activeContentColor
                opacity: control.enabled ? 1 : MeoTheme.disabledContentOpacity
            }
        }
        Item {
            id: sliderArea
            objectName: "meoQuickControlSliderArea"
            Layout.fillWidth: true
            Layout.fillHeight: true
            readonly property real fraction: control.valueFraction
            Rectangle {
                id: activeTrack
                objectName: "meoQuickControlActiveTrack"
                anchors.left: control.mirrored ? undefined : parent.left
                anchors.right: control.mirrored ? parent.right : undefined
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(4 * MeoTheme.globalScale, sliderArea.fraction * parent.width)
                height: parent.height
                color: control.activeContainerColor
            }
            Rectangle {
                id: dividerHandle
                objectName: "meoQuickControlDivider"
                x: Math.max(0, Math.min(parent.width - width,
                                        (control.mirrored ? parent.width * (1 - sliderArea.fraction)
                                                          : parent.width * sliderArea.fraction) - width / 2))
                anchors.verticalCenter: parent.verticalCenter
                width: 6 * MeoTheme.globalScale
                height: 44 * MeoTheme.globalScale
                radius: width / 2
                color: MeoTheme.primary
            }
            MeoText {
                anchors.left: control.mirrored ? undefined : parent.left
                anchors.right: control.mirrored ? parent.right : undefined
                anchors.leftMargin: control.mirrored ? 0 : MeoTheme.space8
                anchors.rightMargin: control.mirrored ? MeoTheme.space8 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: control.label !== ""
                text: control.label
                typeRole: "label"
                typeSize: "small"
                emphasized: true
                color: sliderArea.fraction > 0.42 ? control.activeContentColor : MeoTheme.contentOnSurface
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
                enabled: control.enabled
                activeFocusOnTab: enabled
                Accessible.name: control.accessibleName
                Accessible.description: qsTr("%1 percent").arg(Math.round(control.valueFraction * 100))
                background: Item {}
                handle: Item {}
                onPressedChanged: {
                    control.tracking = pressed
                    if (pressed)
                        control.trackingStarted()
                    else
                        control.trackingEnded(control.clampedValue)
                }
                onMoved: {
                    control.value = value
                    control.moved(value)
                }
            }
            MeoStateLayer {
                objectName: "meoQuickControlStateLayer"
                anchors.fill: parent
                shape: "rect"
                radius: MeoTheme.shapeSmall
                hovered: valueSlider.hovered
                pressed: valueSlider.pressed
                dragged: valueSlider.pressed
                focused: valueSlider.activeFocus
                color: MeoTheme.contentOnSurface
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
