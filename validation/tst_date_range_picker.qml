import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoDateRangePicker {
        id: picker
        startDate: new Date(2026, 6, 12)
        endDate: new Date(2026, 6, 20)
        displayDate: new Date(2026, 6, 1)
    }

    TestCase {
        name: "MeoDateRangePicker"
        when: windowShown

        function test_reversedEndInputIsNormalized() {
            picker.setRangeDate(false, new Date(2026, 6, 8))
            compare(picker.startDate.getDate(), 8)
            compare(picker.endDate.getDate(), 12)
        }

        function test_nonInteractivePickerRejectsChanges() {
            picker.interactive = false
            const startBefore = picker.startDate.getTime()
            picker.handleDateClick(new Date(2026, 6, 30))
            compare(picker.startDate.getTime(), startBefore)
        }

        function test_monthAndYearSelection() {
            picker.interactive = true
            picker.chooseMonth(1)
            compare(picker.displayDate.getMonth(), 1)
            picker.chooseYear(2028)
            compare(picker.displayDate.getFullYear(), 2028)
        }
    }
}
