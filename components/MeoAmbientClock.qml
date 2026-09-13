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

    readonly property string effectiveTimeText: timeText !== ""
                                               ? timeText
                                               : Qt.formatTime(dateTime,
                                                               showSeconds ? "HH:mm:ss" : "HH:mm")
    readonly property string effectiveDateText: dateText !== ""
                                               ? dateText
                                               : Qt.formatDate(dateTime, "dddd, MMMM d")
    readonly property real timePixelSize: (showSeconds ? 72 : 96) * MeoTheme.globalScale

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
            font.pixelSize: control.timePixelSize
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
        }
    }
}
