import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 320
    height: 240

    ListModel {
        id: model
        ListElement { label: "One" }
        ListElement { label: "Two" }
    }

    MeoListView {
        id: list
        width: parent.width
        height: parent.height
        model: model
        delegate: Rectangle {
            required property string label
            width: ListView.view.width
            height: 48
        }
    }

    TestCase {
        name: "MeoListTransitions"
        when: windowShown

        function test_semanticTimingAndReducedMotionNullTransitions() {
            compare(MeoListTransitions.staggerDelay, MeoTheme.motionListStaggerDelay)
            compare(MeoListTransitions.staggerCap, MeoTheme.motionListStaggerCap)
            verify(MeoListTransitions.add !== null)
            verify(MeoListTransitions.remove !== null)
            verify(MeoListTransitions.displaced !== null)
            const previousReduceMotion = MeoTheme.reduceMotion
            MeoTheme.reduceMotion = true
            tryCompare(MeoListTransitions, "enabled", false)
            compare(MeoListTransitions.add, null)
            compare(MeoListTransitions.remove, null)
            MeoTheme.reduceMotion = previousReduceMotion
            tryCompare(MeoListTransitions, "enabled", true)
        }

        function test_viewAppliesTheSharedTransitions() {
            verify(list.add === MeoListTransitions.add)
            verify(list.remove === MeoListTransitions.remove)
            verify(list.displaced === MeoListTransitions.displaced)
            model.append({ "label": "Three" })
            tryCompare(list, "count", 3)
        }
    }
}
