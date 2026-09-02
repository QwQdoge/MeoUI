import QtQuick
import QtTest
import "../components" as Components

Item {
    id: root
    width: 640
    height: 360

    readonly property var columns: [
        { "label": "Name", "property": "name", "width": 180, "sortable": true },
        { "label": "Status", "property": "metadata.status", "width": 180 },
        { "label": "Count", "property": "count", "sortable": true }
    ]

    Components.MeoDataTable {
        id: table
        width: 520
        height: 260
        columns: root.columns
        selectable: true
    }

    SignalSpy {
        id: selectionSpy
        target: table
        signalName: "selectionChanged"
    }

    SignalSpy {
        id: sortSpy
        target: table
        signalName: "sortRequested"
    }

    TestCase {
        name: "MeoDataTable"
        when: windowShown

        function resetRows() {
            table.model = [
                { "name": "Aurora", "metadata": { "status": "Ready" }, "count": 2, "selected": true },
                { "name": "Borealis", "metadata": { "status": "Paused" }, "count": 4 },
                { "name": "Comet", "metadata": { "status": "Locked" }, "count": 1, "enabled": false }
            ]
            wait(0)
        }

        function init() {
            resetRows()
            table.sortProperty = ""
            table.sortAscending = true
            table.LayoutMirroring.enabled = false
            table.LayoutMirroring.childrenInherit = true
            selectionSpy.clear()
            sortSpy.clear()
        }

        function test_selectionKeepsCallerRowsImmutable() {
            const original = table.model[1]
            verify(table.toggleRow(1, true))
            verify(table.rowIsSelected(table.model[1]))
            verify(!table.rowIsSelected(original))
            compare(table.selectedIndices.length, 2)
            compare(selectionSpy.count, 1)
        }

        function test_toggleAllExcludesDisabledRowsAndEmitsOnce() {
            verify(table.toggleAll(true))
            compare(table.selectedIndices.length, 2)
            verify(table.allSelected)
            verify(!table.isIndeterminate)
            verify(!table.rowIsSelected(table.model[2]))
            compare(selectionSpy.count, 1)
        }

        function test_sortContractAndNestedValues() {
            verify(table.requestSort(table.columns[0]))
            compare(table.sortProperty, "name")
            verify(table.sortAscending)
            compare(sortSpy.count, 1)
            compare(sortSpy.signalArguments[0][0], "name")
            verify(table.requestSort(table.columns[0]))
            verify(!table.sortAscending)
            compare(table.valueFor(table.model[0], "metadata.status"), "Ready")
            verify(!table.requestSort(table.columns[1]))
        }

        function test_disabledRowsAndRtlAreSafe() {
            verify(!table.toggleRow(2, true))
            verify(!table.rowIsSelected(table.model[2]))
            table.LayoutMirroring.enabled = true
            verify(table.isMirrored)
            const rows = findChild(root, "meoDataTableRows")
            verify(rows !== null)
            const disabledRow = findChild(root, "meoDataTableRow_2")
            verify(disabledRow !== null)
            compare(disabledRow.opacity, 0.38)
        }
    }
}
