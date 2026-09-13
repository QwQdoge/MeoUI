import QtQuick
import QtQuick.Layouts
import MeoUI

// Presentation-only container for an authentication host. It intentionally
// has no credential, PAM, or transport properties: the platform owns those.
Item {
    id: control

    property bool active: true
    property string title: ""
    property string supportingText: ""
    // idle | password | fingerprint | smartcard | submitting | failed
    property string status: "idle"
    property string statusText: ""
    property string errorText: ""
    property bool showStatusIcon: true
    property real minimumWidth: 320 * MeoTheme.globalScale
    property real maximumWidth: 440 * MeoTheme.globalScale
    readonly property real failureOffset: failureSpring.value

    readonly property bool hasHeader: title !== "" || supportingText !== ""
    readonly property bool hasStatus: statusText !== "" || errorText !== ""
    readonly property string effectiveStatusText: errorText !== "" ? errorText : statusText
    readonly property bool failed: status === "failed" || errorText !== ""
    readonly property string statusIcon: failed ? "error"
                                                : status === "fingerprint" ? "fingerprint"
                                                : status === "smartcard" ? "badge"
                                                : status === "submitting" ? "progress_activity"
                                                : "lock"
    readonly property color statusColor: failed ? MeoTheme.error
                                                : status === "fingerprint" || status === "smartcard"
                                                  ? MeoTheme.primary
                                                  : MeoTheme.contentOnSurfaceVariant
    readonly property int enterDuration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium1
    readonly property int exitDuration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationShort3
    readonly property int failureDuration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium2

    default property alias content: contentLayout.data

    implicitWidth: Math.max(minimumWidth, Math.min(maximumWidth, surfaceContent.implicitWidth))
    implicitHeight: surfaceContent.implicitHeight + 2 * MeoTheme.space24
    transform: Translate { x: control.failureOffset }
    opacity: active ? 1 : 0
    scale: MeoTheme.reduceMotion ? 1 : (active ? 1 : 0.98)
    visible: active || opacity > 0.001

    Accessible.role: Accessible.Pane
    Accessible.name: title !== "" ? title : qsTr("Authentication")
    Accessible.description: effectiveStatusText

    function triggerFailure() {
        if (MeoTheme.reduceMotion) {
            failureSpring.snapTo(0)
            return
        }
        // Start at the documented 8dp maximum, then let the shared analytic
        // spring return to rest. The calm/fast token caps this at 300ms.
        failureSpring.snapTo(8 * MeoTheme.globalScale)
        failureSpring.targetValue = 0
    }

    Behavior on opacity {
        NumberAnimation {
            duration: control.active ? control.enterDuration : control.exitDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: control.active ? MeoTheme.motionEasingEmphasizedDecelerate : MeoTheme.motionEasingEmphasizedAccelerate
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: control.active ? control.enterDuration : control.exitDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: control.active ? MeoTheme.motionEasingEmphasizedDecelerate : MeoTheme.motionEasingEmphasizedAccelerate
        }
    }

    MeoSpringValue {
        id: failureSpring
        motionProfile: "calm"
        speed: "fast"
        enabled: !MeoTheme.reduceMotion
        valueThreshold: 0.01 * MeoTheme.globalScale
        velocityThreshold: 0.02
        targetValue: 0
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: MeoTheme.shapeExtraLarge
        color: MeoTheme.surfaceContainerHigh
        border.width: MeoTheme.strokeWidthThin
        border.color: MeoTheme.outlineVariant
        opacity: 0.97
    }

    ColumnLayout {
        id: surfaceContent
        anchors.fill: parent
        anchors.margins: MeoTheme.space24
        spacing: MeoTheme.space16

        ColumnLayout {
            Layout.fillWidth: true
            visible: control.hasHeader
            spacing: MeoTheme.space4

            MeoText {
                Layout.fillWidth: true
                visible: text !== ""
                text: control.title
                typeRole: "title"
                typeSize: "large"
                emphasized: true
                color: MeoTheme.contentOnSurface
                wrapMode: Text.WordWrap
            }

            MeoText {
                Layout.fillWidth: true
                visible: text !== ""
                text: control.supportingText
                typeRole: "body"
                typeSize: "medium"
                color: MeoTheme.contentOnSurfaceVariant
                wrapMode: Text.WordWrap
            }
        }

        ColumnLayout {
            id: contentLayout
            Layout.fillWidth: true
            spacing: MeoTheme.space12
        }

        RowLayout {
            Layout.fillWidth: true
            visible: control.hasStatus
            spacing: MeoTheme.space8

            MeoIcon {
                visible: control.showStatusIcon
                icon: control.statusIcon
                size: 20
                color: control.statusColor
            }

            MeoText {
                Layout.fillWidth: true
                text: control.effectiveStatusText
                typeRole: "body"
                typeSize: "small"
                color: control.statusColor
                wrapMode: Text.WordWrap
            }
        }
    }
}
