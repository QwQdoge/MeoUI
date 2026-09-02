import QtQuick
import QtQuick.Controls
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 240
    height: 240

    Components.MeoScrollBar {
        id: verticalBar
        height: 160
        orientation: Qt.Vertical
        policy: ScrollBar.AlwaysOn
        size: 0.35
        position: 0.28
    }

    Components.MeoScrollBar {
        id: horizontalBar
        y: 180
        width: 160
        orientation: Qt.Horizontal
        policy: ScrollBar.AlwaysOn
        size: 0.35
        position: 0.28
    }

    TestCase {
        name: "MeoScrollBar"
        when: windowShown

        function test_orientationAndAlwaysOnVisibility() {
            verticalBar.enabled = true
            wait(MeoTheme.motionDurationState + 20)
            const thumb = findChild(verticalBar, "meoScrollBarThumb")
            verify(thumb !== null)
            compare(verticalBar.orientation, Qt.Vertical)
            compare(horizontalBar.orientation, Qt.Horizontal)
            compare(Math.round(thumb.implicitWidth), Math.round(8 * MeoTheme.globalScale))
            compare(thumb.opacity, 1)
        }

        function test_disabledUsesSemanticOpacity() {
            verticalBar.enabled = false
            wait(MeoTheme.motionDurationState + 20)
            const thumb = findChild(verticalBar, "meoScrollBarThumb")
            compare(thumb.opacity, MeoTheme.disabledContentOpacity)
            verticalBar.enabled = true
            wait(MeoTheme.motionDurationState + 20)
        }
    }
}
