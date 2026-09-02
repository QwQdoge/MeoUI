import QtQuick
import QtTest
import "../components" as Components

Item {
    id: root
    width: 640
    height: 240

    Components.MeoButtonGroup {
        id: buttonGroup
        model: [{ "label": "Day" }, { "label": "Week" }, { "label": "Month" }]
        currentIndex: 1
    }

    Components.MeoSegmentedButtons {
        id: segmented
        y: 96
        width: 360
        model: [{ "label": "List", "icon": "view_list" },
                { "label": "Grid", "icon": "grid_view" },
                { "label": "Map", "icon": "map" }]
        currentIndex: 0
    }

    ListModel {
        id: buttonGroupListModel
        ListElement { label: "Day" }
        ListElement { label: "Week"; enabled: false }
        ListElement { label: "Month" }
    }

    ListModel {
        id: segmentedListModel
        ListElement { label: "Day"; icon: "calendar_today" }
        ListElement { label: "Week"; icon: "date_range"; enabled: false }
        ListElement { label: "Month"; icon: "calendar_month" }
    }

    TestCase {
        name: "MeoSelectionGroups"
        when: windowShown

        function init() {
            buttonGroup.enabled = true
            buttonGroup.variant = "standard"
            buttonGroup.currentIndex = 1
            buttonGroup.multiSelect = false
            buttonGroup.selectionRequired = false
            buttonGroup.selectedIndices = []
            buttonGroup.pressedIndex = -1
            buttonGroup.pressExpansionRatio = 0.15
            buttonGroup.baseShape = "round"
            buttonGroup.selectedShape = "square"
            buttonGroup.LayoutMirroring.enabled = false
            segmented.enabled = true
            segmented.multiSelect = false
            segmented.currentIndex = 0
            segmented.selectedIndices = []
            segmented.LayoutMirroring.enabled = false
        }

        function test_standardGroupReservesSpaceAndAnimatesSelectedWidth() {
            const initialWidth = buttonGroup.implicitWidth
            const initialHeight = buttonGroup.implicitHeight
            const first = findChild(root, "meoButtonGroupButton_0")
            const second = findChild(root, "meoButtonGroupButton_1")
            verify(first !== null)
            verify(second !== null)

            buttonGroup.currentIndex = -1
            const idleWidth = first.implicitWidth
            buttonGroup.currentIndex = 0
            verify(first.implicitWidth > idleWidth)
            verify(first.segmentRadius < first.height / 2)
            buttonGroup.currentIndex = 2
            compare(buttonGroup.implicitWidth, initialWidth)
            compare(buttonGroup.implicitHeight, initialHeight)

            buttonGroup.pressedIndex = 0
            const endpointExpansion = buttonGroup.pressedExpansionFor(0)
            verify(endpointExpansion <= first.standardRestingWidth * buttonGroup.pressExpansionRatio)
            verify(endpointExpansion <= second.compressionLimit)
            verify(Math.abs(buttonGroup.adjacentCompressionFor(1) - endpointExpansion) < 0.1)
            buttonGroup.pressedIndex = -1

            buttonGroup.pressedIndex = 1
            const middleExpansion = buttonGroup.pressedExpansionFor(1)
            verify(middleExpansion <= second.standardRestingWidth * buttonGroup.pressExpansionRatio)
            verify(middleExpansion / 2 <= first.compressionLimit)
            const third = findChild(root, "meoButtonGroupButton_2")
            verify(third !== null)
            verify(middleExpansion / 2 <= third.compressionLimit)
            verify(Math.abs(buttonGroup.adjacentCompressionFor(0) - middleExpansion / 2) < 0.1)
            buttonGroup.pressedIndex = -1

            compare(buttonGroup.selectedContainer.a, 1)

            buttonGroup.enabled = false
            compare(buttonGroup.selectedContainer.a, 0.12)
            compare(buttonGroup.idleForeground.a, 0.38)
        }

        function test_standardGroupUsesM3ExpressiveSizeSpacing() {
            buttonGroup.size = "xs"
            compare(buttonGroup.standardSpacing, 18 * buttonGroup.themeGlobalScale)
            compare(buttonGroup.standardPadding, 18 * buttonGroup.themeGlobalScale)
            buttonGroup.size = "s"
            compare(buttonGroup.standardSpacing, 12 * buttonGroup.themeGlobalScale)
            buttonGroup.size = "m"
            compare(buttonGroup.standardSpacing, 8 * buttonGroup.themeGlobalScale)
            buttonGroup.size = "l"
            compare(buttonGroup.standardSpacing, 8 * buttonGroup.themeGlobalScale)
            buttonGroup.size = "xl"
            compare(buttonGroup.standardSpacing, 8 * buttonGroup.themeGlobalScale)
            buttonGroup.size = "m"
        }

        function test_connectedGroupKeepsSegmentBoundsStable() {
            buttonGroup.variant = "connected"
            const first = findChild(root, "meoButtonGroupButton_0")
            const firstWidth = first.implicitWidth
            buttonGroup.currentIndex = 2
            compare(first.implicitWidth, firstWidth)
            verify(buttonGroup.activateIndex(0))
            compare(buttonGroup.currentIndex, 0)

            buttonGroup.multiSelect = true
            buttonGroup.selectedIndices = []
            verify(buttonGroup.activateIndex(0))
            verify(buttonGroup.activateIndex(2))
            compare(buttonGroup.selectedIndices.length, 2)
            verify(buttonGroup.isIndexSelected(0))
            verify(buttonGroup.isIndexSelected(2))

            buttonGroup.selectionRequired = true
            buttonGroup.selectedIndices = [0]
            verify(buttonGroup.activateIndex(0))
            compare(buttonGroup.selectedIndices.length, 1)
            verify(buttonGroup.isIndexSelected(0))

            buttonGroup.multiSelect = false
            buttonGroup.variant = "connected"
            buttonGroup.currentIndex = 1
            const selectedMiddle = findChild(root, "meoButtonGroupButton_1")
            compare(selectedMiddle.segmentRadius, selectedMiddle.height / 2)

            buttonGroup.baseShape = "square"
            compare(buttonGroup.groupRadius, 8 * buttonGroup.themeGlobalScale)
        }

        function test_buttonGroupHonorsDisabledAndListModelEntries() {
            buttonGroup.model = buttonGroupListModel
            wait(0)
            compare(buttonGroup.itemCount, 3)
            buttonGroup.currentIndex = 0
            verify(!buttonGroup.activateIndex(1))
            compare(buttonGroup.currentIndex, 0)
            verify(buttonGroup.activateIndex(2))
            compare(buttonGroup.currentIndex, 2)
            buttonGroup.enabled = false
            verify(!buttonGroup.activateIndex(0))
            compare(buttonGroup.currentIndex, 2)
            buttonGroup.enabled = true
            buttonGroup.model = [{ "label": "Day" }, { "label": "Week" }, { "label": "Month" }]
        }

        function test_segmentedSingleAndMultiSelectionContracts() {
            const initialWidth = segmented.implicitWidth
            const initialHeight = segmented.implicitHeight
            segmented.activateIndex(2, segmented.model[2])
            compare(segmented.currentIndex, 2)
            compare(segmented.implicitWidth, initialWidth)
            compare(segmented.implicitHeight, initialHeight)

            segmented.multiSelect = true
            segmented.activateIndex(0, segmented.model[0])
            segmented.activateIndex(2, segmented.model[2])
            compare(segmented.selectedIndices.length, 2)
            verify(segmented.isIndexSelected(0))
            verify(segmented.isIndexSelected(2))
        }

        function test_segmentedHonorsDisabledAndListModelEntries() {
            segmented.model = segmentedListModel
            wait(0)
            compare(segmented.itemCount, 3)
            compare(segmented.implicitHeight, 40 * segmented.themeGlobalScale)
            compare(segmented.accessibleName, "Segmented buttons")

            segmented.multiSelect = false
            segmented.currentIndex = 0
            verify(!segmented.activateIndex(1))
            compare(segmented.currentIndex, 0)
            verify(segmented.activateIndex(2))
            compare(segmented.currentIndex, 2)

            segmented.enabled = false
            verify(!segmented.activateIndex(0))
            compare(segmented.currentIndex, 2)
            segmented.enabled = true
            segmented.model = [{ "label": "List", "icon": "view_list" },
                               { "label": "Grid", "icon": "grid_view" },
                               { "label": "Map", "icon": "map" }]
        }

        function test_groupsHonorLayoutMirroring() {
            buttonGroup.LayoutMirroring.enabled = true
            segmented.LayoutMirroring.enabled = true
            wait(0)
            verify(buttonGroup.mirrored)
            verify(segmented.mirrored)
        }
    }
}
