import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 480
    height: 260

    MeoPageHost {
        id: pageHost
        anchors.fill: parent
    }

    TestCase {
        name: "MeoPageHost"
        when: windowShown

        property real originalMotionScale: 1
        property bool originalReduceMotion: false

        function initTestCase() {
            originalMotionScale = MeoTheme.motionScale
            originalReduceMotion = MeoTheme.reduceMotion
        }

        function init() {
            MeoTheme.motionScale = 1
            MeoTheme.reduceMotion = false
        }

        function cleanupTestCase() {
            MeoTheme.motionScale = originalMotionScale
            MeoTheme.reduceMotion = originalReduceMotion
        }

        function test_asymmetricSemanticDurations() {
            compare(pageHost.enterDuration, MeoTheme.motionDurationPageEnter)
            compare(pageHost.exitDuration, MeoTheme.motionDurationPageExit)
            compare(pageHost.enterDuration, 350)
            compare(pageHost.exitDuration, 250)
        }

        function test_motionScaleAndReduceMotionStayCentralized() {
            MeoTheme.motionScale = 2
            compare(pageHost.enterDuration, 700)
            compare(pageHost.exitDuration, 500)

            MeoTheme.reduceMotion = true
            compare(pageHost.enterDuration, 0)
            compare(pageHost.exitDuration, 0)
        }
    }
}
