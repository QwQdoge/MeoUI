import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoDateInput {
        id: isoInput
        value: new Date(2024, 1, 29)
    }

    Components.MeoDateInput {
        id: slashInput
        format: "yyyy/MM/dd"
        value: new Date(2026, 7, 31)
    }

    Components.MeoDateInput {
        id: optionalInput
        allowEmpty: true
        value: new Date(0)
    }

    TestCase {
        name: "MeoDateInput"
        when: windowShown

        function test_formatsAndParsesExactlyTwoDigitFields() {
            compare(isoInput.type, "outlined")
            compare(isoInput.text, "2024-02-29")
            compare(slashInput.text, "2026/08/31")
            verify(isoInput.parseDate("2024-02-29") !== null)
            compare(isoInput.parseDate("2024-2-29"), null)
            compare(isoInput.parseDate("2024-02-9"), null)
            compare(isoInput.parseDate("2024-02-30"), null)
            verify(slashInput.parseDate("2026/08/31") !== null)
            compare(slashInput.parseDate("2026-08-31"), null)
        }

        function test_optionalEmptyStateIsExposed() {
            compare(optionalInput.text, "")
            compare(optionalInput.hasValue, false)
            optionalInput.text = ""
            optionalInput.commit()
            compare(optionalInput.isError, false)
        }

        function test_invalidDateStaysVisibleUntilCorrected() {
            isoInput.text = "2024-02-30"
            isoInput.commit()
            verify(isoInput.isError)
            compare(isoInput.errorText, "Invalid date")
            compare(isoInput.text, "2024-02-30")
            isoInput.text = "2024-02-29"
            isoInput.commit()
            verify(!isoInput.isError)
        }
    }
}
