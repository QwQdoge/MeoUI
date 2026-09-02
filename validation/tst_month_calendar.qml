import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoMonthCalendar {
        id: calendar
        width: 300 * MeoTheme.globalScale
        height: implicitHeight
        selectedDate: new Date(2026, 7, 26)
        displayDate: new Date(2026, 7, 1)
    }

    TestCase {
        name: "MeoMonthCalendar"
        when: windowShown

        function test_dateIndexAndMonthNavigation() {
            compare(calendar.indexForDate(new Date(2026, 7, 26)) >= 0, true)
            calendar.moveMonth(1)
            compare(calendar.displayDate.getMonth(), 8)
        }

        function test_nonInteractiveCalendarDoesNotNavigate() {
            calendar.interactive = false
            const monthBefore = calendar.displayDate.getMonth()
            calendar.moveMonth(1)
            compare(calendar.displayDate.getMonth(), monthBefore)
        }

        function test_selectedDayUsesTheM3FortyDpCircle() {
            calendar.interactive = true
            calendar.displayDate = new Date(2026, 7, 1)
            calendar.selectedDate = new Date(2026, 7, 26)
            const index = calendar.indexForDate(calendar.selectedDate)
            const surface = findChild(calendar, "meoMonthCalendarDaySurface-" + index)
            verify(surface !== null)
            compare(surface.color, MeoTheme.primary)
            compare(surface.strokeWidth, 0)
            compare(surface.width, Math.min(calendar.width / 7, 40 * MeoTheme.globalScale))
        }
    }
}
