import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

// Quick Control is a semantic composition around MeoSlider. It deliberately
// owns no rail, handle, value geometry, or second slider implementation.
Control {
    id: control

    property string iconName: ""
    property string label: ""
    property string accessibleName: label
    property string iconAccessibleName: accessibleName
    property bool iconActionEnabled: iconName !== "" && iconAccessibleName !== ""
    property real from: 0
    property real to: 100
    property real value: 0
    property bool detailsAvailable: false
    property bool expanded: false
    // Compatibility inputs retained for existing Plasma call sites. Motion is
    // resolved by MeoSlider and MeoTheme rather than by a private profile.
    property string motionProfile: "pixel"
    property bool animateExternalChanges: true
    property bool externalValueChange: false
    property bool tracking: false

    signal moved(real value)
    signal trackingStarted()
    signal trackingEnded(real value)
    signal iconTriggered()
    signal detailsToggled(bool expanded)

    readonly property real clampedValue: Math.max(Math.min(from, to),
                                                  Math.min(Math.max(from, to), value))
    readonly property real valueFraction: to !== from
                                       ? Math.max(0, Math.min(1, (clampedValue - from) / (to - from)))
                                       : 0
    readonly property alias slider: valueSlider

    implicitWidth: 360 * MeoTheme.globalScale
    implicitHeight: 52 * MeoTheme.globalScale
    padding: 0
    opacity: enabled ? 1 : MeoTheme.disabledContentOpacity
    Accessible.ignored: true

    Behavior on opacity {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation {
            duration: MeoTheme.motionDurationState
            easing.type: Easing.BezierSpline
            easing.bezierCurve: MeoTheme.motionEasingStandard
        }
    }

    background: Item {}

    contentItem: RowLayout {
        spacing: detailsButton.visible ? MeoTheme.space4 : 0

        Item {
            id: sliderHost
            Layout.fillWidth: true
            Layout.fillHeight: true

            MeoSlider {
                id: valueSlider
                objectName: "quickControlValueSlider"
                anchors.fill: parent
                from: control.from
                to: control.to
                value: control.value
                enabled: control.enabled
                expressive: true
                // Inset icons start at M in the M3 Expressive matrix:
                // 40dp track, 52dp handle, and a 24dp icon.
                size: "m"
                trackStyle: "split"
                endStopEnabled: true
                insetIcon: control.iconName
                animateExternalChanges: control.animateExternalChanges
                accessibleName: control.accessibleName
                accessibleDescription: qsTr("%1 percent").arg(Math.round(control.valueFraction * 100))

                onMoved: function(nextValue) {
                    control.value = nextValue
                    control.moved(nextValue)
                }
            }

            // The leading icon can retain an independent system action (for
            // example mute) without reimplementing the slider underneath it.
            AbstractButton {
                id: iconButton
                objectName: "quickControlIconButton"
                anchors.left: control.mirrored ? undefined : parent.left
                anchors.right: control.mirrored ? parent.right : undefined
                anchors.verticalCenter: parent.verticalCenter
                width: 48 * MeoTheme.globalScale
                height: 48 * MeoTheme.globalScale
                visible: control.iconName !== "" && control.iconActionEnabled
                enabled: visible && control.enabled
                padding: 0
                activeFocusOnTab: enabled
                Accessible.name: control.iconAccessibleName
                Accessible.description: control.accessibleName
                onClicked: control.iconTriggered()

                PointHandler {
                    acceptedButtons: Qt.LeftButton
                    onActiveChanged: {
                        iconStateLayer._pointerPressActive = active
                        if (active) {
                            const localPoint = iconStateLayer.mapFromItem(iconButton,
                                                                         point.position.x,
                                                                         point.position.y)
                            iconStateLayer.trigger(localPoint.x, localPoint.y)
                        } else {
                            iconStateLayer.releaseRipple()
                        }
                    }
                }

                background: MeoStateLayer {
                    id: iconStateLayer
                    objectName: "quickControlIconStateLayer"
                    shape: "circle"
                    internalPointerTrackingEnabled: false
                    hovered: iconButton.hovered
                    pressed: iconButton.pressed
                    focused: iconButton.visualFocus
                    pressX: iconButton.pressX
                    pressY: iconButton.pressY
                }
                contentItem: Item {}
            }
        }

        MeoIconButton {
            id: detailsButton
            visible: control.detailsAvailable
            Layout.preferredWidth: 44 * MeoTheme.globalScale
            Layout.preferredHeight: 44 * MeoTheme.globalScale
            type: "standard"
            size: "m"
            icon.name: control.expanded ? "expand_less" : "expand_more"
            Accessible.name: control.expanded
                             ? qsTr("Hide advanced controls")
                             : qsTr("Show advanced controls")
            onClicked: {
                control.expanded = !control.expanded
                control.detailsToggled(control.expanded)
            }
        }
    }

    Connections {
        target: valueSlider

        function onPressedChanged() {
            const nextTracking = valueSlider.pressed
            if (control.tracking === nextTracking)
                return
            control.tracking = nextTracking
            if (nextTracking)
                control.trackingStarted()
            else
                control.trackingEnded(control.clampedValue)
        }
    }
}
