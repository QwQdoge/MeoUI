import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoStatusCenter {
        id: statusCenter
        width: 720
        height: 432
        updateTimeAutomatically: false
        currentDateTime: new Date(2026, 8, 2, 10, 24)
        unreadCount: 3
    }

    TestCase {
        name: "MeoStatusCenter"
        when: windowShown

        function test_staticPreviewAndResponsiveThreshold() {
            verify(!statusCenter.updateTimeAutomatically)
            compare(statusCenter.unreadCount, 3)
            verify(statusCenter.timeText.length > 0)
            verify(statusCenter.dateText.length > 0)
            verify(!statusCenter.compact)
            statusCenter.width = 600
            verify(statusCenter.compact)
            statusCenter.width = 720
        }
    }
}
