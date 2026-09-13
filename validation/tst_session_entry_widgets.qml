import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoWeatherStatus {
        id: weather
    }

    Components.MeoPrivacyNotificationSummary {
        id: notifications
    }

    TestCase {
        name: "MeoSessionEntryWidgets"
        when: windowShown

        function test_weatherOnlyAppearsForFreshBoundedData() {
            weather.available = true
            weather.stale = false
            weather.temperatureText = "28 °C"
            weather.condition = "Partly cloudy"
            weather.location = "Singapore\u202E"
            weather.showLocation = true
            verify(weather.visible)
            compare(weather.safeLocation, "Singapore")
            compare(weather.materialIconName, "clear_day")
            verify(weather.implicitWidth > 0)

            weather.stale = true
            verify(!weather.visible)
        }

        function test_notificationPrivacyLevelsDoNotFallThrough() {
            notifications.notificationCount = 2
            notifications.applicationName = "Messages"
            notifications.summary = "A safe summary"
            notifications.body = "A bounded preview"

            notifications.privacyLevel = "unexpected"
            compare(notifications.effectivePrivacyLevel, "hidden")
            verify(!notifications.visible)

            notifications.privacyLevel = "count"
            verify(notifications.visible)
            compare(notifications.primaryText, "2 notifications")

            notifications.privacyLevel = "app-name"
            verify(notifications.primaryText.indexOf("Messages") !== -1)

            notifications.privacyLevel = "full-content"
            compare(notifications.primaryText, "A safe summary")
            compare(notifications.secondaryText, "A bounded preview")
        }
    }
}
