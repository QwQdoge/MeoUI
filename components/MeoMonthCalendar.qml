import QtQuick
import QtQuick.Layouts
import MeoUI

Item {
    id: control

    property date selectedDate: new Date()
    property date displayDate: new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
    property bool interactive: true
    property int firstDayOfWeek: Qt.locale().firstDayOfWeek

    signal dateSelected(date selected)

    implicitWidth: 300 * MeoTheme.globalScale
    implicitHeight: 296 * MeoTheme.globalScale

    function dateAt(index) {
        const first = new Date(displayDate.getFullYear(), displayDate.getMonth(), 1)
        const localeFirstDay = firstDayOfWeek % 7
        const offset = (first.getDay() - localeFirstDay + 7) % 7
        return new Date(first.getFullYear(), first.getMonth(), 1 - offset + index)
    }

    function isSameDay(left, right) {
        return left && right
            && left.getFullYear() === right.getFullYear()
            && left.getMonth() === right.getMonth()
            && left.getDate() === right.getDate()
    }

    function moveMonth(offset) {
        displayDate = new Date(displayDate.getFullYear(), displayDate.getMonth() + offset, 1)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: MeoTheme.space8

        RowLayout {
            Layout.fillWidth: true

            MeoText {
                Layout.fillWidth: true
                text: Qt.formatDate(control.displayDate, "MMMM yyyy")
                typeRole: "title"
                typeSize: "medium"
                emphasized: true
                color: MeoTheme.onSurface
            }

            MeoIconButton {
                type: "standard"
                size: "s"
                icon.name: "chevron_left"
                Accessible.name: qsTr("Previous month")
                onClicked: control.moveMonth(-1)
            }

            MeoIconButton {
                type: "standard"
                size: "s"
                icon.name: "chevron_right"
                Accessible.name: qsTr("Next month")
                onClicked: control.moveMonth(1)
            }
        }

        Grid {
            id: weekdayGrid
            Layout.fillWidth: true
            Layout.preferredHeight: 24 * MeoTheme.globalScale
            columns: 7

            Repeater {
                model: 7

                delegate: MeoText {
                    required property int index
                    width: weekdayGrid.width / 7
                    height: weekdayGrid.height
                    text: Qt.locale().dayName((control.firstDayOfWeek + index - 1) % 7 + 1, Locale.NarrowFormat)
                    typeRole: "label"
                    typeSize: "small"
                    emphasized: true
                    horizontalAlignment: Text.AlignHCenter
                    color: MeoTheme.onSurfaceVariant
                }
            }
        }

        Grid {
            id: dayGrid
            Layout.fillWidth: true
            Layout.preferredHeight: 252 * MeoTheme.globalScale
            columns: 7

            Repeater {
                model: 42

                delegate: Item {
                    required property int index
                    readonly property date day: control.dateAt(index)
                    readonly property bool isCurrentMonth: day.getMonth() === control.displayDate.getMonth()
                    readonly property bool isSelected: control.isSameDay(day, control.selectedDate)
                    readonly property bool isToday: control.isSameDay(day, new Date())

                    width: dayGrid.width / 7
                    height: dayGrid.height / 6
                    Accessible.role: Accessible.Button
                    Accessible.name: Qt.formatDate(day, Qt.DefaultLocaleLongDate)
                    Accessible.checked: isSelected
                    Accessible.focusable: control.interactive

                    MeoShape {
                        id: daySurface
                        anchors.centerIn: parent
                        width: Math.min(parent.width, 36 * MeoTheme.globalScale)
                        height: width
                        type: "circle"
                        color: isSelected ? MeoTheme.primary
                              : (isToday ? MeoTheme.secondaryContainer : Qt.rgba(0, 0, 0, 0))

                        MeoStateLayer {
                            anchors.fill: parent
                            radius: width / 2
                            hovered: dayMouse.containsMouse
                            pressed: dayMouse.pressed
                            focused: parent.activeFocus
                            color: isSelected ? MeoTheme.onPrimary : MeoTheme.onSurface
                        }
                    }

                    MeoText {
                        anchors.centerIn: parent
                        text: day.getDate()
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: isSelected || isToday
                        color: isSelected ? MeoTheme.onPrimary
                              : (isCurrentMonth ? MeoTheme.onSurface : MeoTheme.onSurfaceVariant)
                        opacity: isCurrentMonth ? 1 : 0.55
                    }

                    MouseArea {
                        id: dayMouse
                        anchors.fill: parent
                        enabled: control.interactive
                        hoverEnabled: true
                        onClicked: {
                            control.selectedDate = day
                            if (!isCurrentMonth)
                                control.displayDate = new Date(day.getFullYear(), day.getMonth(), 1)
                            control.dateSelected(day)
                        }
                    }
                }
            }
        }
    }
}
