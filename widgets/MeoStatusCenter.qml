import QtQuick
import QtQuick.Layouts
import MeoUI

MeoMotionSurface {
    id: control

    enum Mode {
        TimeCalendar,
        Notifications,
        TimeCalendarNotifications
    }

    // `mode` is the canonical status-center contract.  Keep the former
    // string API for one compatibility cycle so an installed shell can update
    // MeoUI before its plasmoid package is replaced.
    property int mode: MeoStatusCenter.TimeCalendarNotifications
    property string centerMode: ""
    property Component notificationContent: null
    property Component calendarContent: null
    property Component headerContent: null

    property date currentDateTime: new Date()
    // Keep the live desktop clock current without overwriting applications
    // that supply a fixed date for a preview, history view, or test.
    property bool updateTimeAutomatically: true
    property string timeText: Qt.formatTime(currentDateTime, Qt.DefaultLocaleShortDate)
    property string dateText: Qt.formatDate(currentDateTime, Qt.DefaultLocaleLongDate)
    property int unreadCount: 0
    property string notificationsTitle: qsTr("Notifications")
    // Hosts with retained popup content set this false while closed.  That
    // prevents a hidden status center from retaining a minute clock timer.
    property bool contentActive: visible
    readonly property bool compact: width < 640 * MeoTheme.globalScale
    readonly property int effectiveMode: {
        switch (centerMode) {
        case "timeCalendar":
            return MeoStatusCenter.TimeCalendar
        case "notificationsOnly":
            return MeoStatusCenter.Notifications
        case "timeNotifications":
        case "timeCalendarNotifications":
            return MeoStatusCenter.TimeCalendarNotifications
        default:
            return mode
        }
    }
    readonly property bool showsTime: effectiveMode !== MeoStatusCenter.Notifications
    readonly property bool showsCalendar: effectiveMode !== MeoStatusCenter.Notifications
    readonly property bool showsNotifications: effectiveMode !== MeoStatusCenter.TimeCalendar

    color: MeoTheme.surfaceContainerLow
    // Status Center is a transient Pixel-style surface rather than a generic
    // card.  Its larger semantic corner stays tied to MeoTheme.cornerScale,
    // so desktop accessibility and dynamic-shape preferences reach it too.
    radius: MeoTheme.shapeExtraLargeIncreased
    elevation: 3
    implicitWidth: 720 * MeoTheme.globalScale
    implicitHeight: 432 * MeoTheme.globalScale

    Timer {
        interval: 60000
        repeat: true
        running: control.updateTimeAutomatically && control.contentActive
        triggeredOnStart: false
        onTriggered: control.currentDateTime = new Date()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: MeoTheme.space24
        spacing: MeoTheme.space16

        Loader {
            visible: control.headerContent !== null
            Layout.fillWidth: true
            sourceComponent: control.headerContent
        }

        RowLayout {
            visible: control.headerContent === null && control.showsTime
            Layout.fillWidth: true
            spacing: MeoTheme.space16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MeoText {
                    text: control.timeText
                    typeRole: "title"
                    typeSize: "large"
                    emphasized: true
                    color: MeoTheme.contentOnSurface
                }

                MeoText {
                    Layout.fillWidth: true
                    text: control.dateText
                    typeRole: "body"
                    typeSize: "medium"
                    color: MeoTheme.contentOnSurfaceVariant
                    elide: Text.ElideRight
                }
            }

            MeoText {
                visible: control.unreadCount > 0
                text: control.unreadCount === 1
                      ? qsTr("1 unread")
                      : qsTr("%1 unread").arg(control.unreadCount)
                typeRole: "label"
                typeSize: "medium"
                emphasized: true
                color: MeoTheme.primary
            }
        }

        MeoDivider {
            visible: control.showsTime && (control.showsCalendar || control.showsNotifications)
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: MeoTheme.space24

            Loader {
                // A time-and-calendar-only center must not become blank at a
                // narrow width.  Combined centers leave narrow-page selection
                // to their host and keep the notification slot visible here.
                visible: control.showsCalendar && (!control.compact || !control.showsNotifications)
                Layout.preferredWidth: 300 * MeoTheme.globalScale
                Layout.fillHeight: true
                sourceComponent: control.calendarContent || defaultCalendar
            }

            MeoDivider {
                visible: control.showsCalendar && control.showsNotifications && !control.compact
                Layout.fillHeight: true
                orientation: "vertical"
            }

            ColumnLayout {
                visible: control.showsNotifications
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: MeoTheme.space8

                MeoText {
                    Layout.fillWidth: true
                    text: control.notificationsTitle
                    typeRole: "title"
                    typeSize: "medium"
                    emphasized: true
                    color: MeoTheme.contentOnSurface
                }

                Item {
                    id: notificationSlot
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Loader {
                        anchors.fill: parent
                        sourceComponent: control.notificationContent
                    }
                }
            }
        }
    }

    Component {
        id: defaultCalendar

        MeoMonthCalendar {
            selectedDate: control.currentDateTime
            displayDate: control.currentDateTime
        }
    }
}
