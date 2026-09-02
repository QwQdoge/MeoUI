pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Item {
    id: control

    property date selectedDate: new Date()
    property date displayDate: new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
    property date focusedDate: selectedDate
    property bool interactive: true
    // Consumers with their own M3 picker header can reuse the accessible
    // weekday/day grid without duplicating the calendar implementation.
    property bool showHeader: true
    property int firstDayOfWeek: Qt.locale().firstDayOfWeek
    property var _dayItems: []
    property int _dayItemsRevision: 0

    readonly property int focusedIndex: indexForDate(focusedDate)
    readonly property Item focusedDayItem: {
        const revision = _dayItemsRevision
        return focusedIndex >= 0 && focusedIndex < _dayItems.length
            ? (_dayItems[focusedIndex] || null) : null
    }

    signal dateSelected(date selected)

    implicitWidth: 300 * MeoTheme.globalScale
    implicitHeight: (showHeader ? 324 : 268) * MeoTheme.globalScale

    onSelectedDateChanged: {
        const moveActiveFocus = focusedDayItem && focusedDayItem.activeFocus
        if (!isSameDay(focusedDate, selectedDate))
            focusedDate = normalizedDate(selectedDate)
        if (moveActiveFocus)
            Qt.callLater(focusFocusedDay)
    }

    onDisplayDateChanged: {
        if (indexForDate(focusedDate) >= 0)
            return
        const selected = normalizedDate(selectedDate)
        const lastDay = new Date(displayDate.getFullYear(), displayDate.getMonth() + 1, 0).getDate()
        focusedDate = new Date(displayDate.getFullYear(), displayDate.getMonth(),
                               Math.min(selected.getDate(), lastDay))
    }

    function normalizedDate(value) {
        if (!value || isNaN(value.getTime()))
            return new Date()
        return new Date(value.getFullYear(), value.getMonth(), value.getDate())
    }

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

    function indexForDate(value) {
        if (!value || isNaN(value.getTime()))
            return -1
        const first = dateAt(0)
        const firstUtc = Date.UTC(first.getFullYear(), first.getMonth(), first.getDate())
        const valueUtc = Date.UTC(value.getFullYear(), value.getMonth(), value.getDate())
        const index = Math.round((valueUtc - firstUtc) / 86400000)
        return index >= 0 && index < 42 ? index : -1
    }

    function focusFocusedDay(reason) {
        const item = focusedDayItem
        if (item && item.visible && item.enabled)
            item.forceActiveFocus(reason === undefined ? Qt.TabFocusReason : reason)
    }

    function selectDay(value, focusItem) {
        if (!interactive)
            return
        const day = normalizedDate(value)
        focusedDate = day
        selectedDate = day
        if (day.getFullYear() !== displayDate.getFullYear()
                || day.getMonth() !== displayDate.getMonth()) {
            displayDate = new Date(day.getFullYear(), day.getMonth(), 1)
        }
        if (focusItem && !focusItem.activeFocus)
            focusItem.forceActiveFocus(Qt.MouseFocusReason)
        dateSelected(day)
    }

    function moveDayFocus(value, offset) {
        if (!interactive)
            return
        const day = normalizedDate(value)
        const target = new Date(day.getFullYear(), day.getMonth(), day.getDate() + offset)
        focusedDate = target
        if (target.getFullYear() !== displayDate.getFullYear()
                || target.getMonth() !== displayDate.getMonth()) {
            displayDate = new Date(target.getFullYear(), target.getMonth(), 1)
        }
        Qt.callLater(focusFocusedDay)
    }

    function moveMonth(offset) {
        if (!interactive)
            return
        const targetDisplay = new Date(displayDate.getFullYear(), displayDate.getMonth() + offset, 1)
        const focus = normalizedDate(focusedDate)
        const lastDay = new Date(targetDisplay.getFullYear(), targetDisplay.getMonth() + 1, 0).getDate()
        focusedDate = new Date(targetDisplay.getFullYear(), targetDisplay.getMonth(),
                               Math.min(focus.getDate(), lastDay))
        displayDate = targetDisplay
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: MeoTheme.space8

        RowLayout {
            visible: control.showHeader
            Layout.preferredHeight: control.showHeader ? implicitHeight : 0
            Layout.fillWidth: true

            MeoText {
                Layout.fillWidth: true
                text: Qt.formatDate(control.displayDate, "MMMM yyyy")
                typeRole: "title"
                typeSize: "medium"
                emphasized: true
                color: MeoTheme.contentOnSurface
            }

            MeoIconButton {
                type: "standard"
                size: "s"
                icon.name: "chevron_left"
                enabled: control.interactive
                Accessible.name: qsTr("Previous month")
                onClicked: control.moveMonth(-1)
            }

            MeoIconButton {
                type: "standard"
                size: "s"
                icon.name: "chevron_right"
                enabled: control.interactive
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
                    text: Qt.formatDate(control.dateAt(index), "ddd")
                    typeRole: "label"
                    typeSize: "small"
                    emphasized: true
                    horizontalAlignment: Text.AlignHCenter
                    color: MeoTheme.contentOnSurfaceVariant
                }
            }
        }

        Grid {
            id: dayGrid
            Layout.fillWidth: true
            Layout.preferredHeight: 252 * MeoTheme.globalScale
            columns: 7

            Repeater {
                id: dayRepeater
                model: 42
                onItemAdded: function(index, item) {
                    control._dayItems[index] = item
                    control._dayItemsRevision += 1
                }
                onItemRemoved: function(index) {
                    control._dayItems[index] = null
                    control._dayItemsRevision += 1
                }

                delegate: AbstractButton {
                    id: dayButton
                    required property int index
                    readonly property date day: control.dateAt(index)
                    readonly property bool isCurrentMonth: day.getMonth() === control.displayDate.getMonth()
                    readonly property bool isSelected: control.isSameDay(day, control.selectedDate)
                    readonly property bool isToday: control.isSameDay(day, new Date())

                    width: dayGrid.width / 7
                    height: dayGrid.height / 6
                    padding: 0
                    enabled: control.interactive
                    activeFocusOnTab: enabled && (activeFocus || index === control.focusedIndex)
                    Accessible.role: Accessible.Button
                    Accessible.name: Qt.formatDate(day, Locale.LongFormat)
                    Accessible.checkable: true
                    Accessible.checked: isSelected
                    Accessible.focusable: enabled

                    onActiveFocusChanged: {
                        if (activeFocus)
                            control.focusedDate = day
                    }
                    onClicked: control.selectDay(day, dayButton)
                    Keys.onReturnPressed: control.selectDay(day, dayButton)
                    Keys.onEnterPressed: control.selectDay(day, dayButton)
                    Keys.onLeftPressed: control.moveDayFocus(day, -1)
                    Keys.onRightPressed: control.moveDayFocus(day, 1)
                    Keys.onUpPressed: control.moveDayFocus(day, -7)
                    Keys.onDownPressed: control.moveDayFocus(day, 7)

                    background: Item {
                        MeoShape {
                            id: daySurface
                            objectName: "meoMonthCalendarDaySurface-" + dayButton.index
                            anchors.centerIn: parent
                            // DatePickerModalTokens fixes both the date container and
                            // its state layer at 40dp.  The day grid may shrink this on
                            // deliberately narrow hosts, but its normal visual target
                            // remains the M3 40dp circle.
                            width: Math.min(parent.width, 40 * MeoTheme.globalScale)
                            height: width
                            type: "circle"
                            color: dayButton.isSelected ? MeoTheme.primary
                                  : Qt.rgba(MeoTheme.surface.r, MeoTheme.surface.g, MeoTheme.surface.b, 0)
                            // M3 distinguishes today from a selection: it uses a
                            // 1dp primary outline rather than a tonal filled circle.
                            strokeColor: dayButton.isToday && !dayButton.isSelected
                                         ? MeoTheme.primary : "transparent"
                            strokeWidth: dayButton.isToday && !dayButton.isSelected
                                         ? Math.max(1, MeoTheme.strokeWidthThin) : 0

                            MeoStateLayer {
                                anchors.fill: parent
                                radius: width / 2
                                hovered: dayButton.hovered
                                pressed: dayButton.pressed
                                focused: dayButton.visualFocus
                                color: dayButton.isSelected ? MeoTheme.contentOnPrimary : MeoTheme.contentOnSurface
                            }
                        }
                    }

                    contentItem: MeoText {
                        text: dayButton.day.getDate()
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: dayButton.isSelected || dayButton.isToday
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: dayButton.isSelected ? MeoTheme.contentOnPrimary
                              : (dayButton.isToday ? MeoTheme.primary
                                                   : (dayButton.isCurrentMonth ? MeoTheme.contentOnSurface
                                                                               : MeoTheme.contentOnSurfaceVariant))
                        opacity: dayButton.isCurrentMonth ? 1 : 0.55
                    }
                }
            }
        }
    }
}
