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

    MeoPageHost {
        id: rapidPageHost
        width: parent.width
        height: parent.height
        visible: false
        asynchronous: false
    }

    Component {
        id: alphaPage
        Item { property string marker: "alpha" }
    }

    Component {
        id: betaPage
        Item { property string marker: "beta" }
    }

    Component {
        id: gammaPage
        Item { property string marker: "gamma" }
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

        function test_loadingFeedbackContract() {
            compare(pageHost.loadingPlaceholder, null)
            compare(pageHost.loadingDelay, MeoTheme.loadingFeedbackDelay)
            compare(pageHost.loadingMinimumVisibleDuration, 0)
            compare(pageHost.loading, false)
            compare(pageHost.loadingFeedbackVisible, false)
        }

        function test_motionScaleAndReduceMotionStayCentralized() {
            MeoTheme.motionScale = 2
            compare(pageHost.enterDuration, 700)
            compare(pageHost.exitDuration, 500)

            MeoTheme.reduceMotion = true
            compare(pageHost.enterDuration, 0)
            compare(pageHost.exitDuration, 0)
        }

        function test_rapidNavigationKeepsTheActiveHandoffContinuous() {
            rapidPageHost.showComponent(alphaPage, {}, 1, "alpha")
            tryCompare(rapidPageHost, "currentPageKey", "alpha")
            compare(rapidPageHost.readyPageKey, "alpha")

            rapidPageHost.showComponent(betaPage, {}, 1, "beta")
            tryVerify(function() { return rapidPageHost.transitioning })
            compare(rapidPageHost.transitionDirection, 1)

            wait(30)
            rapidPageHost.showComponent(gammaPage, {}, -1, "gamma")

            // The second request must not call complete() on the active
            // animation. Its direction also cannot rewrite the current
            // handoff while that animation is in flight.
            verify(rapidPageHost.transitioning)
            tryVerify(function() { return rapidPageHost.transitionRequestPending })
            compare(rapidPageHost.transitionDirection, 1)
            compare(rapidPageHost.currentPageKey, "alpha")

            tryCompare(rapidPageHost, "currentPageKey", "beta", 800)
            tryCompare(rapidPageHost, "readyPageKey", "gamma", 800)
            compare(rapidPageHost.transitionDirection, -1)
            tryCompare(rapidPageHost, "currentPageKey", "gamma", 800)
            compare(rapidPageHost.transitionRequestPending, false)
        }
    }
}
