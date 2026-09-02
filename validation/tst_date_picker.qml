import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoDatePicker {
        id: picker
        selectedDate: new Date(2026, 7, 26)
        displayDate: new Date(2026, 7, 1)
    }

    TestCase {
        name: "MeoDatePicker"
        when: windowShown

        function test_monthAndYearNavigation() {
            picker.moveMonth(1)
            compare(picker.displayDate.getMonth(), 8)
            picker.chooseMonth(1)
            compare(picker.displayDate.getMonth(), 1)
            picker.chooseYear(2028)
            compare(picker.displayDate.getFullYear(), 2028)
        }

        function test_calendarSelectionSynchronizesPicker() {
            const picked = new Date(2028, 1, 29)
            picker.calendar.selectDay(picked, null)
            compare(picker.selectedDate.getFullYear(), 2028)
            compare(picker.selectedDate.getMonth(), 1)
            compare(picker.selectedDate.getDate(), 29)
            compare(picker.displayDate.getMonth(), 1)
        }

        function test_nonInteractiveDoesNotNavigate() {
            picker.interactive = false
            const before = picker.displayDate.getMonth()
            picker.moveMonth(1)
            compare(picker.displayDate.getMonth(), before)
        }
    }
}
