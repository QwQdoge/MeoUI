import QtQuick
import QtTest
import "../components" as Components

Item {
    id: root
    width: 560
    height: 240

    Components.MeoFilterGroup {
        id: filters
        width: 480
        model: [
            { "label": "All", "icon": "apps" },
            { "label": "Open" },
            { "label": "Archived", "enabled": false },
            "Drafts"
        ]
    }

    ListModel {
        id: listModel
        ListElement { label: "Images"; icon: "image" }
        ListElement { label: "Documents" }
    }

    SignalSpy {
        id: selectedSpy
        target: filters
        signalName: "selected"
    }

    SignalSpy {
        id: changedSpy
        target: filters
        signalName: "selectionChanged"
    }

    TestCase {
        name: "MeoFilterGroup"
        when: windowShown

        function init() {
            filters.model = [
                { "label": "All", "icon": "apps" },
                { "label": "Open" },
                { "label": "Archived", "enabled": false },
                "Drafts"
            ]
            filters.multiSelect = false
            filters.allowEmptySelection = true
            filters.currentIndex = -1
            filters.selectedIndices = []
            filters.enabled = true
            filters.LayoutMirroring.enabled = false
            selectedSpy.clear()
            changedSpy.clear()
        }

        function test_singleSelectionCanToggleOff() {
            verify(filters.activate(0))
            compare(filters.currentIndex, 0)
            verify(filters.isSelected(0))
            verify(filters.activate(0))
            compare(filters.currentIndex, -1)
            compare(selectedSpy.count, 2)
            compare(changedSpy.count, 2)
        }

        function test_requiredSingleSelectionCannotToggleOff() {
            filters.allowEmptySelection = false
            filters.currentIndex = 1
            verify(filters.activate(1))
            compare(filters.currentIndex, 1)
            verify(filters.activate(0))
            compare(filters.currentIndex, 0)
        }

        function test_multiSelectionNormalizesAndSorts() {
            filters.multiSelect = true
            filters.selectedIndices = [3, 3, 2, -1]
            verify(filters.activate(0))
            compare(filters.selectedIndices.length, 2)
            compare(filters.selectedIndices[0], 0)
            compare(filters.selectedIndices[1], 3)
            verify(filters.activate(3))
            compare(filters.selectedIndices.length, 1)
            compare(filters.selectedIndices[0], 0)
        }

        function test_disabledItemsNeverChangeSelection() {
            verify(!filters.enabledFor(filters.model[2]))
            verify(!filters.activate(2))
            compare(filters.currentIndex, -1)
            compare(selectedSpy.count, 0)

            filters.enabled = false
            verify(!filters.activate(0))
            compare(filters.currentIndex, -1)
        }

        function test_listModelAndGroupAccessibilityAreSupported() {
            filters.model = listModel
            compare(filters.itemCount, 2)
            compare(filters.entryAt(0).label, "Images")
            verify(filters.activate(1))
            compare(filters.currentIndex, 1)
            compare(filters.Accessible.name, "Filters")
            verify(filters.Accessible.description.indexOf("Documents") !== -1)
        }

        function test_stringModelAndRtlAreSupported() {
            compare(filters.labelFor("Drafts"), "Drafts")
            compare(filters.iconFor("Drafts"), "")
            filters.LayoutMirroring.enabled = true
            verify(filters.mirrored)
        }
    }
}
