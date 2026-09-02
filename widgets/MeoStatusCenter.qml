import QtQuick
import QtQuick.Layouts
import MeoUI

MeoMotionSurface {
    id: control

    property Component notificationContent: null

    property date currentDateTime: new Date()
    // Keep the live desktop clock current without overwriting applications
    // that supply a fixed date for a preview, history view, or test.
    property bool updateTimeAutomatically: true
    property string timeText: Qt.formatTime(currentDateTime, Qt.DefaultLocaleShortDate)
    property string dateText: Qt.formatDate(currentDateTime, Qt.DefaultLocaleLongDate)
    property int unreadCount: 0
    property string notificationsTitle: qsTr("Notifications")
    readonly property bool compact: width < 640 * MeoTheme.globalScale

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
        running: control.updateTimeAutomatically
        triggeredOnStart: false
        onTriggered: control.currentDateTime = new Date()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: MeoTheme.space24
        spacing: MeoTheme.space16

        RowLayout {
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
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: MeoTheme.space24

            MeoMonthCalendar {
                visible: !control.compact
                Layout.preferredWidth: 300 * MeoTheme.globalScale
                Layout.fillHeight: true
                selectedDate: control.currentDateTime
                displayDate: control.currentDateTime
            }

            MeoDivider {
                visible: !control.compact
                Layout.fillHeight: true
                orientation: "vertical"
            }

            ColumnLayout {
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
}
