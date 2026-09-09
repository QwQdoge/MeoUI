import QtQuick
import QtQuick.Controls
import MeoUI

// Continuous activation for an intentional, session-ending action. Releasing,
// losing focus, disabling the control, or pressing Escape always cancels.
Button {
    id: control

    property string confirmationText: qsTr("Hold to confirm")
    property string holdingText: qsTr("Keep holding…")
    property int holdDuration: 5000
    property string iconName: ""
    property string tone: "error" // error | primary | neutral

    readonly property bool holding: holdTimer.running
    readonly property real progress: holdDuration > 0 ? Math.min(1, elapsed / holdDuration) : 1
    readonly property string accessibleProgress: holding
                                             ? qsTr("Confirmation in %1 percent").arg(Math.round(progress * 100))
                                             : confirmationText

    signal confirmed()
    signal cancelled()

    property int elapsed: 0
    property bool completed: false

    implicitWidth: Math.max(176 * MeoTheme.globalScale, contentRow.implicitWidth + 48 * MeoTheme.globalScale)
    implicitHeight: 56 * MeoTheme.globalScale
    hoverEnabled: true
    Accessible.name: confirmationText
    Accessible.description: accessibleProgress

    function beginHold() {
        if (!enabled || completed)
            return
        completed = false
        elapsed = 0
        holdTimer.restart()
        progressTimer.start()
    }

    function cancelHold(announce) {
        const wasHolding = holdTimer.running || elapsed > 0
        holdTimer.stop()
        progressTimer.stop()
        elapsed = 0
        if (wasHolding && announce)
            cancelled()
    }

    onPressed: beginHold()
    onReleased: {
        if (!completed)
            cancelHold(true)
        else
            completed = false
    }
    onEnabledChanged: if (!enabled) cancelHold(false)
    onActiveFocusChanged: if (!activeFocus && holding) cancelHold(true)
    Keys.onEscapePressed: function(event) {
        if (holding) {
            cancelHold(true)
            event.accepted = true
        }
    }

    Timer {
        id: progressTimer
        interval: 40
        repeat: true
        onTriggered: elapsed = Math.min(control.holdDuration, elapsed + interval)
    }

    Timer {
        id: holdTimer
        interval: Math.max(0, control.holdDuration)
        repeat: false
        onTriggered: {
            control.elapsed = control.holdDuration
            progressTimer.stop()
            control.completed = true
            control.confirmed()
        }
    }

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: control.implicitHeight
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 8 * MeoTheme.globalScale
            MeoIcon {
                visible: control.iconName !== ""
                icon: control.iconName
                size: 20
                color: control.foregroundColor
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: control.holding ? control.holdingText : control.confirmationText
                color: control.foregroundColor
                font.family: MeoTheme.typefacePlain
                font.pixelSize: MeoTheme.labelLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    readonly property color containerColor: {
        if (!enabled)
            return Qt.rgba(MeoTheme.contentOnSurface.r, MeoTheme.contentOnSurface.g, MeoTheme.contentOnSurface.b, 0.12)
        if (tone === "error") return MeoTheme.error
        if (tone === "primary") return MeoTheme.primary
        return MeoTheme.surfaceContainerHighest
    }
    readonly property color foregroundColor: {
        if (!enabled)
            return Qt.rgba(MeoTheme.contentOnSurface.r, MeoTheme.contentOnSurface.g, MeoTheme.contentOnSurface.b, 0.38)
        if (tone === "error") return MeoTheme.contentOnError
        if (tone === "primary") return MeoTheme.contentOnPrimary
        return MeoTheme.contentOnSurface
    }

    background: Item {
        MeoShape {
            anchors.fill: parent
            type: "rect"
            radius: control.holding && !MeoTheme.reduceMotion ? MeoTheme.shapeMedium : control.height / 2
            color: control.containerColor
            Behavior on radius {
                NumberAnimation {
                    duration: MeoTheme.motionDurationSelection
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasized
                }
            }
        }
        Rectangle {
            width: parent.width * control.progress
            height: parent.height
            radius: control.height / 2
            color: Qt.rgba(control.foregroundColor.r, control.foregroundColor.g, control.foregroundColor.b, 0.18)
            visible: control.holding && control.progress > 0
            Behavior on width { NumberAnimation { duration: MeoTheme.motionDurationHoldRelease; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate } }
        }
        MeoStateLayer {
            anchors.fill: parent
            radius: control.height / 2
            color: control.foregroundColor
            enabled: control.enabled && !control.holding
            hovered: control.hovered
            pressed: control.down
            focused: control.visualFocus
        }
    }
}
