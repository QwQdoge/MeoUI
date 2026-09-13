import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 420
    height: 220

    Component {
        id: detailedPlaceholder
        Item {
            objectName: "declaredLoadingLayout"
            MeoSkeleton { objectName: "declaredAvatar"; type: "avatar" }
            MeoSkeleton { objectName: "declaredText"; type: "text"; x: 56; width: 180 }
        }
    }

    MeoLoadingFeedback {
        id: feedback
        anchors.fill: parent
        minimumVisibleDuration: 0
    }

    TestCase {
        name: "MeoLoadingFeedback"
        when: windowShown

        function init() {
            feedback.active = false
            feedback.placeholder = null
            feedback.delay = 30
            feedback.minimumVisibleDuration = 0
            wait(MeoTheme.motionDurationLoadingFeedbackFade + 20)
        }

        function test_unknownPositionUsesDelayedCompactIndicator() {
            feedback.active = true
            compare(feedback.usesDetailedPlaceholder, false)
            compare(feedback.feedbackVisible, false)
            wait(40)
            compare(feedback.feedbackVisible, true)
            verify(findChild(feedback, "meoLoadingCompactIndicator").visible)
            feedback.active = false
        }

        function test_declaredPositionsShowDetailedPlaceholderImmediately() {
            feedback.placeholder = detailedPlaceholder
            feedback.delay = 0
            feedback.active = true
            compare(feedback.usesDetailedPlaceholder, true)
            compare(feedback.feedbackVisible, true)
            tryVerify(function() {
                return findChild(feedback, "declaredLoadingLayout") !== null
            })
            compare(findChild(feedback, "meoLoadingCompactIndicator").visible, false)
            feedback.active = false
        }

        function test_minimumVisibleTimePreventsSingleFrameFlash() {
            feedback.delay = 0
            feedback.minimumVisibleDuration = 80
            feedback.active = true
            compare(feedback.feedbackVisible, true)
            feedback.active = false
            compare(feedback.feedbackVisible, true)
            // CI and software scenegraph timers may be serviced one event-loop
            // turn after the 80ms deadline. Assert the contract with bounded
            // scheduling tolerance instead of requiring an exact 10ms window.
            tryCompare(feedback, "feedbackVisible", false, 250)
        }
    }
}
