import QtQuick
import MeoUI

// Backend-agnostic ambient clock for session-entry and low-distraction views.
// Hosts can pass localized text from their platform clock service; otherwise
// the system locale formats `dateTime`. It deliberately owns no system state.
Item {
    id: control

    property date dateTime: new Date()
    property string timeText: ""
    property string dateText: ""
    property bool showDate: true
    property bool showSeconds: false
    property color timeColor: MeoTheme.contentOnSurface
    property color dateColor: MeoTheme.contentOnSurfaceVariant

    // Qt.formatDate() otherwise uses the runtime's ambient locale, which can
    // disagree with a host application's resolved UI language in an isolated
    // preview. Tie the fallback clock to the same language that resolves
    // qsTr(), while still allowing a platform clock service to supply text.
    readonly property var displayLocale: Qt.locale(Qt.uiLanguage)

    function shortTimeFormatWithoutSeconds() {
        // Locale.ShortFormat is allowed to contain seconds on some systems.
        // showSeconds is an explicit MeoUI contract, so preserve locale
        // hour/AM-PM conventions while removing only the seconds field.
        var format = String(displayLocale.timeFormat(Locale.ShortFormat))
        format = format.replace(/([:.])?ss?/g, "")
        return format.replace(/\\s{2,}/g, " ").trim()
    }

    readonly property string effectiveTimeText: timeText !== ""
                                               ? timeText
                                               // Long locale time formats may append a time-zone
                                               // label. Keep the explicit seconds view compact,
                                               // while ordinary clocks still follow the resolved
                                               // locale's preferred short-time convention.
                                               : (showSeconds
                                                  ? Qt.formatTime(dateTime, "HH:mm:ss")
                                                  : Qt.formatTime(dateTime,
                                                                  shortTimeFormatWithoutSeconds()))
    readonly property string effectiveDateText: dateText !== ""
                                               ? dateText
                                               // dateFormat() is date-only; a bare LongFormat on a
                                               // date-time would append the time and the time zone.
                                               : displayLocale.toString(dateTime,
                                                                        displayLocale.dateFormat(Locale.LongFormat))
    readonly property real timePixelSize: (showSeconds ? 72 : 96) * MeoTheme.globalScale

    // The clock shrinks to fit the box a widget gives it instead of being cut
    // off: by width always, and by height when the host sized it.
    TextMetrics {
        id: timeMetrics
        font.family: MeoTheme.typefaceBrand
        font.pixelSize: control.timePixelSize
        font.letterSpacing: -0.8 * MeoTheme.globalScale
        text: control.effectiveTimeText
    }
    readonly property real fitScale: {
        let scale = 1
        if (control.width > 0 && timeMetrics.advanceWidth > control.width)
            scale = Math.min(scale, control.width / timeMetrics.advanceWidth)
        if (control.height > 0 && timeMetrics.height > 0) {
            const share = control.showDate && control.effectiveDateText !== "" ? 0.62 : 0.92
            scale = Math.min(scale, control.height * share / timeMetrics.height)
        }
        return Math.max(0.12, scale)
    }

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Accessible.role: Accessible.StaticText
    Accessible.name: showDate && effectiveDateText !== ""
                     ? effectiveTimeText + ", " + effectiveDateText
                     : effectiveTimeText

    Column {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: MeoTheme.space8

        Text {
            objectName: "meoAmbientClockTime"
            anchors.horizontalCenter: parent.horizontalCenter
            text: control.effectiveTimeText
            color: control.timeColor
            font.family: MeoTheme.typefaceBrand
            font.pixelSize: control.timePixelSize * control.fitScale
            font.weight: Font.Normal
            font.letterSpacing: -0.8 * MeoTheme.globalScale
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        MeoText {
            objectName: "meoAmbientClockDate"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: control.showDate && text !== ""
            text: control.effectiveDateText
            typeRole: "title"
            typeSize: "medium"
            color: control.dateColor
            horizontalAlignment: Text.AlignHCenter
            width: control.width > 0 ? Math.min(implicitWidth, control.width) : implicitWidth
            elide: Text.ElideRight
        }
    }
}
