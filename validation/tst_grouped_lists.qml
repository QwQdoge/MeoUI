import QtQuick
import QtTest
import "../patterns" as Patterns
import "../components" as Components

Item {
    id: root
    width: 720
    height: 480

    Patterns.MeoGroupedList {
        id: grouped
        width: 340
        title: "Recent files"
        model: [
            { "label": "Notes", "icon": "article" },
            { "label": "Audit", "icon": "fact_check", "enabled": false },
            { "label": "Archive", "icon": "archive" }
        ]
    }

    Component {
        id: customRow
        Components.MeoListItem {
            property var modelData: null
            property int index: -1
            headline: modelData ? modelData.label : ""
            supportingText: modelData && modelData.supportingText ? modelData.supportingText : ""
            interactive: enabled
        }
    }

    Patterns.MeoSegmentedList {
        id: segmented
        x: 380
        width: 300
        selectedIndex: 1
        delegate: customRow
        model: [
            { "label": "Buttons", "supportingText": "Actions" },
            { "label": "Navigation", "supportingText": "Routes" },
            { "label": "Feedback", "enabled": false }
        ]
    }

    SignalSpy {
        id: groupedSpy
        target: grouped
        signalName: "clicked"
    }

    SignalSpy {
        id: segmentedSpy
        target: segmented
        signalName: "clicked"
    }

    TestCase {
        name: "MeoGroupedLists"
        when: windowShown

        function init() {
            grouped.selectedIndex = -1
            segmented.selectedIndex = 1
            grouped.LayoutMirroring.enabled = false
            groupedSpy.clear()
            segmentedSpy.clear()
        }

        function test_groupedListOnlySelectsEnabledRows() {
            verify(grouped.activate(0))
            compare(grouped.selectedIndex, 0)
            compare(groupedSpy.count, 1)
            verify(!grouped.activate(1))
            compare(grouped.selectedIndex, 0)
            verify(grouped.activate(2))
            compare(grouped.selectedIndex, 2)
        }

        function test_groupedListSupportsStringsAndRtl() {
            compare(grouped.labelFor("Draft"), "Draft")
            compare(grouped.supportingFor("Draft"), "")
            grouped.LayoutMirroring.enabled = true
            verify(grouped.isMirrored)
        }

        function test_customDelegateReceivesDataAndPosition() {
            const firstLoader = findChild(root, "meoSegmentedListItem_0")
            const secondLoader = findChild(root, "meoSegmentedListItem_1")
            const lastLoader = findChild(root, "meoSegmentedListItem_2")
            verify(firstLoader !== null)
            verify(secondLoader !== null)
            verify(lastLoader !== null)
            tryVerify(function() { return firstLoader.item !== null && secondLoader.item !== null && lastLoader.item !== null }, 500)
            compare(firstLoader.item.headline, "Buttons")
            compare(secondLoader.item.headline, "Navigation")
            compare(firstLoader.item.roundingStrategy, "top")
            compare(secondLoader.item.roundingStrategy, "middle")
            compare(lastLoader.item.roundingStrategy, "bottom")
            verify(secondLoader.item.selected)
            verify(!lastLoader.item.enabled)
        }

        function test_segmentedListSelectionAndDisabledContract() {
            verify(segmented.activate(0))
            compare(segmented.selectedIndex, 0)
            compare(segmentedSpy.count, 1)
            const firstLoader = findChild(root, "meoSegmentedListItem_0")
            const secondLoader = findChild(root, "meoSegmentedListItem_1")
            tryVerify(function() { return firstLoader.item.selected && !secondLoader.item.selected }, 500)
            verify(!segmented.activate(2))
            compare(segmented.selectedIndex, 0)
        }
    }
}
