import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoMediaController { id: controller }

    TestCase {
        name: "MeoMediaController"
        when: windowShown

        function test_defaultsDoNotFabricatePlaybackProgress() {
            compare(controller.duration, 0)
            compare(controller.position, 0)
        }

        function test_dashboardPresentationIsExplicit() {
            controller.presentation = "dashboard"
            compare(controller.resolvedPresentation, "dashboard")
            controller.presentation = "adaptive"
        }

        function test_optionalActionsDoNotFabricateBackends() {
            compare(controller.outputDevice, "")
            compare(controller.showFavoriteAction, false)
            compare(controller.showOutputAction, false)
        }

        function test_lockScreenUsesCompactPresentationHeight() {
            controller.presentation = "lockScreen"
            compare(controller.resolvedPresentation, "lockScreen")
            verify(controller.implicitHeight < 240 * controller.themeGlobalScale)
            controller.presentation = "adaptive"
        }

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
