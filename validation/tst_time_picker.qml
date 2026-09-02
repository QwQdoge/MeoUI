import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoTimePicker { id: picker }

    TestCase {
        name: "MeoTimePicker"
        when: windowShown

        function test_externalValuesAreNormalized() {
            picker.hours = 33
            picker.minutes = 99
            compare(picker.hours, 12)
            compare(picker.minutes, 59)
            picker.hours = 0
            picker.minutes = -4
            compare(picker.hours, 1)
            compare(picker.minutes, 0)
        }

        function test_24HourValuesAndDialSelection() {
            picker.use24Hour = true
            picker.hours = 42
            picker.minutes = 66
            compare(picker.hours, 23)
            compare(picker.minutes, 59)

            picker.activeUnit = "hour"
            picker.selectFromDial(picker.dialSize / 2, picker.dialSize / 2 - 64)
            compare(picker.hours, 12)
            compare(picker.activeUnit, "minute")

            picker.selectFromDial(picker.dialSize - 12, picker.dialSize / 2)
            compare(picker.minutes, 15)
        }

        function test_modeAndPeriodConfiguration() {
            picker.use24Hour = false
            picker.inputMode = true
            picker.isPM = true
            verify(picker.inputMode)
            verify(picker.isPM)
            verify(!picker.use24Hour)
        }
    }
}
