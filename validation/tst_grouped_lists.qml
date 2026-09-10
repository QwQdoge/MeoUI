import QtQuick
import QtTest
import MeoUI
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

    Patterns.MeoSettingsGroup {
        id: settingsGroup
        x: 0
        y: 300
        width: 340
        model: [
            { "id": "settings-first", "title": "Internet", "leadingIcon": "wifi" },
            { "id": "settings-middle", "title": "Bluetooth", "leadingIcon": "bluetooth" },
            { "id": "settings-last", "title": "Battery", "leadingIcon": "battery_full" }
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
            grouped.separatorStyle = "gap"
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

        function test_connectedGeometryUsesPixelGroupContract() {
            compare(grouped.containerRadius, MeoTheme.connectedGroupOuterRadius)
            compare(grouped.innerCornerRadius, MeoTheme.connectedGroupInnerRadius)
            compare(grouped.memberGap, MeoTheme.connectedGroupGap)

            const first = findChild(grouped, "meoGroupedListItem_0")
            const middle = findChild(grouped, "meoGroupedListItem_1")
            const last = findChild(grouped, "meoGroupedListItem_2")
            verify(first !== null)
            verify(middle !== null)
            verify(last !== null)
            const firstSurface = findChild(first, "meoListItemSurface")
            const middleSurface = findChild(middle, "meoListItemSurface")
            const lastSurface = findChild(last, "meoListItemSurface")
            compare(firstSurface.topLeftRadius, MeoTheme.connectedGroupOuterRadius)
            compare(firstSurface.bottomLeftRadius, MeoTheme.connectedGroupInnerRadius)
            compare(middleSurface.topLeftRadius, MeoTheme.connectedGroupInnerRadius)
            compare(middleSurface.bottomLeftRadius, MeoTheme.connectedGroupInnerRadius)
            compare(lastSurface.topLeftRadius, MeoTheme.connectedGroupInnerRadius)
            compare(lastSurface.bottomLeftRadius, MeoTheme.connectedGroupOuterRadius)
        }

        function test_groupedAndSettingsListsShareOneSurfaceEngine() {
            const groupedSurface = findChild(grouped, "meoSegmentedListSurface")
            const settingsSurface = findChild(settingsGroup, "meoSegmentedListSurface")
            verify(groupedSurface !== null)
            verify(settingsSurface !== null)
            compare(groupedSurface.radius, MeoTheme.connectedGroupOuterRadius)
            compare(settingsSurface.radius, groupedSurface.radius)
            compare(settingsGroup.memberGap, grouped.memberGap)
            compare(settingsGroup.innerCornerRadius, grouped.innerCornerRadius)

            const first = findChild(settingsGroup, "settings-first")
            const middle = findChild(settingsGroup, "settings-middle")
            const last = findChild(settingsGroup, "settings-last")
            compare(first.positionInGroup, "first")
            compare(middle.positionInGroup, "middle")
            compare(last.positionInGroup, "last")
        }

        function test_lineSeparatorIsOptionalAndUsesSharedRowContract() {
            grouped.separatorStyle = "line"
            wait(0)
            compare(grouped.itemSpacing, 0)
            const first = findChild(grouped, "meoGroupedListItem_0")
            const last = findChild(grouped, "meoGroupedListItem_2")
            const firstDivider = findChild(first, "meoListItemDivider")
            const lastDivider = findChild(last, "meoListItemDivider")
            verify(firstDivider.visible)
            verify(!lastDivider.visible)
            compare(firstDivider.opacity, grouped.dividerOpacity)
        }

        function test_eachRowUsesTheSharedClippedPointerFeedback() {
            const first = findChild(grouped, "meoGroupedListItem_0")
            const middle = findChild(grouped, "meoGroupedListItem_1")
            const firstStateLayer = findChild(first, "meoListItemStateLayer")
            const middleStateLayer = findChild(middle, "meoListItemStateLayer")
            verify(firstStateLayer !== null)
            verify(middleStateLayer !== null)
            verify(firstStateLayer.rippleEnabled)
            compare(firstStateLayer.topLeftRadius, MeoTheme.connectedGroupOuterRadius)
            compare(firstStateLayer.bottomLeftRadius, MeoTheme.connectedGroupInnerRadius)
            compare(middleStateLayer.topLeftRadius, MeoTheme.connectedGroupInnerRadius)
            compare(middleStateLayer.bottomLeftRadius, MeoTheme.connectedGroupInnerRadius)
            compare(firstStateLayer.hoverOpacity, MeoTheme.stateOpacityHover)
            compare(firstStateLayer.pressedOpacity, MeoTheme.stateOpacityPressed)
            compare(firstStateLayer.pressDuration, MeoTheme.motionDurationPress)
            compare(firstStateLayer.rippleExpandDuration, MeoTheme.motionDurationRippleExpand)
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
