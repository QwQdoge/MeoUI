import QtQuick
import QtTest
import MeoUI 1.0
import "../components" as Components

Item {
    Components.MeoAmbientClock {
        id: clock
        dateTime: new Date(2026, 7, 21, 14, 30, 45)
    }

    TestCase {
        name: "MeoAmbientClock"
        when: windowShown

        function init() {
            clock.timeText = ""
            clock.dateText = ""
            clock.showDate = true
            clock.showSeconds = false
        }

        function test_usesLocalizedFallbackTimeAndDate() {
            compare(clock.effectiveTimeText, "14:30")
            verify(clock.effectiveDateText.length > 0)
            verify(findChild(clock, "meoAmbientClockTime") !== null)
            verify(findChild(clock, "meoAmbientClockDate").visible)
        }

        function test_hostTextOverridesSystemFormatting() {
            clock.timeText = "2:30 PM"
            clock.dateText = "Monday, August 21"
            compare(clock.effectiveTimeText, "2:30 PM")
            compare(clock.effectiveDateText, "Monday, August 21")
            verify(clock.Accessible.name.indexOf("2:30 PM") !== -1)
        }

        function test_secondsAnd_date_visibility_are_explicit() {
            clock.showSeconds = true
            compare(clock.effectiveTimeText, "14:30:45")
            clock.showDate = false
            verify(!findChild(clock, "meoAmbientClockDate").visible)
        }
    }
}
