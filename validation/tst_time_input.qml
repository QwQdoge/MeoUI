import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoTimeInput { id: input; value: "09:30" }
    Components.MeoTimeInput { id: optional; allowEmpty: true }

    TestCase {
        name: "MeoTimeInput"
        when: windowShown

        function test_strictTimeParsingAndValueSync() {
            compare(input.text, "09:30")
            compare(input.parseTime("23:59"), "23:59")
            compare(input.parseTime("9:30"), "")
            compare(input.parseTime("24:00"), "")
            compare(input.parseTime("12:60"), "")
            input.text = "18:45"
            input.commit()
            compare(input.value, "18:45")
        }

        function test_optionalEmptyStateIsAccepted() {
            compare(optional.hasValue, false)
            optional.text = ""
            optional.commit()
            compare(optional.value, "")
            compare(optional.isError, false)
        }

        function test_invalidTimeStaysVisibleUntilCorrected() {
            input.text = "25:80"
            input.commit()
            verify(input.isError)
            compare(input.errorText, "Invalid time")
            compare(input.text, "25:80")
            input.text = "23:59"
            input.commit()
            verify(!input.isError)
            compare(input.value, "23:59")
        }
    }
}
