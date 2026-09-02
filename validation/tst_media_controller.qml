import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoMediaController { id: controller }

    TestCase {
        name: "MeoMediaController"
        when: windowShown

        function test_externalPlaybackStateIsNormalized() {
            controller.duration = 1000
            controller.position = 1500
            compare(controller.position, 1000)
            controller.bufferedPosition = -1
            compare(controller.bufferedPosition, 0)
            controller.volume = 2
            compare(controller.volume, 1)
            controller.repeatMode = "unexpected"
            compare(controller.repeatMode, "off")
        }

        function test_durationClampsExistingPositions() {
            controller.position = 900
            controller.bufferedPosition = 950
            controller.duration = 500
            compare(controller.position, 500)
            compare(controller.bufferedPosition, 500)
        }
    }
}
