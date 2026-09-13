import QtQuick
import QtQuick.Layouts
import MeoUI

// A presentation-only notification projection. A platform adapter supplies
// already-sanitized text and chooses the privacy level; this item owns neither
// notification storage nor notification actions.
Item {
    id: control

    // hidden | count | app-name | full-content
    property string privacyLevel: "hidden"
    property int notificationCount: 0
    property string applicationName: ""
    property string summary: ""
    property string body: ""

    readonly property string effectivePrivacyLevel: privacyLevel === "count"
                                                  || privacyLevel === "app-name"
                                                  || privacyLevel === "full-content"
                                                ? privacyLevel : "hidden"
    readonly property int safeNotificationCount: Math.max(0, Math.min(999, notificationCount))
    readonly property string safeApplicationName: boundedText(applicationName, 128)
    readonly property string safeSummary: boundedText(summary, 256)
    readonly property string safeBody: boundedText(body, 512)
    readonly property string countText: safeNotificationCount === 1
                                       ? qsTr("1 notification")
                                       : qsTr("%1 notifications").arg(safeNotificationCount)
    readonly property string primaryText: {
        if (effectivePrivacyLevel === "full-content")
            return safeSummary !== "" ? safeSummary : countText
        if (effectivePrivacyLevel === "app-name" && safeApplicationName !== "")
            return safeNotificationCount > 1
                    ? qsTr("%1 · %2").arg(safeApplicationName).arg(countText)
                    : safeApplicationName
        return countText
    }
    readonly property string secondaryText: effectivePrivacyLevel === "full-content"
                                           ? safeBody : ""

    implicitWidth: Math.max(200 * MeoTheme.globalScale, summaryContent.implicitWidth + 2 * MeoTheme.space12)
    implicitHeight: summaryContent.implicitHeight + 2 * MeoTheme.space12
    visible: effectivePrivacyLevel !== "hidden" && safeNotificationCount > 0
    opacity: visible ? 1 : 0

    Accessible.role: Accessible.StaticText
    Accessible.name: [primaryText, secondaryText].filter(part => part !== "").join(", ")

    function boundedText(value, maximumLength) {
        return String(value || "")
                .replace(/<br\s*\/?\s*>/gi, "\n")
                .replace(/<[^>]*>/g, "")
                .replace(/&nbsp;/gi, " ")
                .replace(/&amp;/gi, "&")
                .replace(/&lt;/gi, "<")
                .replace(/&gt;/gi, ">")
                .replace(/&quot;/gi, "\"")
                .replace(/&#39;/gi, "'")
                .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "")
                .replace(/[\u202A-\u202E\u2066-\u2069]/g, "")
                .slice(0, maximumLength)
                .trim()
    }

    Behavior on opacity {
        NumberAnimation {
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState
            easing.type: Easing.BezierSpline
            easing.bezierCurve: MeoTheme.motionEasingStandard
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: MeoTheme.shapeLarge
        color: MeoTheme.surfaceContainerHigh
        border.width: MeoTheme.strokeWidthThin
        border.color: MeoTheme.outlineVariant
        opacity: 0.94
    }

    RowLayout {
        id: summaryContent
        anchors.fill: parent
        anchors.margins: MeoTheme.space12
        spacing: MeoTheme.space12

        MeoIcon {
            icon: "notifications"
            size: 24
            color: MeoTheme.primary
            Accessible.ignored: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: MeoTheme.space4

            MeoText {
                Layout.fillWidth: true
                text: control.primaryText
                typeRole: "label"
                typeSize: "large"
                emphasized: true
                color: MeoTheme.contentOnSurface
                elide: Text.ElideRight
            }

            MeoText {
                Layout.fillWidth: true
                visible: text !== ""
                text: control.secondaryText
                typeRole: "body"
                typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
                maximumLineCount: 2
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
            }
        }
    }
}
