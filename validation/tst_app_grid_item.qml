import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoAppGridItem { id: gridItem; title: "Settings" }

    TestCase {
        name: "MeoAppGridItem"
        when: windowShown

        function test_activationRespectsEnabledState() {
            var activations = 0
            gridItem.triggered.connect(function() { ++activations })
            gridItem.activate()
            compare(activations, 1)
            gridItem.enabled = false
            gridItem.activate()
            compare(activations, 1)
            gridItem.enabled = true
        }

        function test_compactTileIsSmallerThanRegularTile() {
            gridItem.compact = false
            var regularWidth = gridItem.tileWidth
            gridItem.compact = true
            verify(gridItem.tileWidth < regularWidth)
            gridItem.compact = false
        }
    }
}
