import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 520
    height: 180

    Components.MeoQuickSettingsTile {
        id: tile
        width: 224 * MeoTheme.globalScale
        title: "Wi-Fi"
        supportingText: "Connected"
        iconName: "wifi"
        active: true
        wide: true
        visualStyle: "pixel"
        detailsEnabled: true
    }

    SignalSpy { id: detailsSpy; target: tile; signalName: "detailsRequested" }
    SignalSpy { id: triggeredSpy; target: tile; signalName: "triggered" }

    TestCase {
        name: "MeoQuickSettingsTile"
        when: windowShown

        function init() {
            tile.enabled = true
            tile.active = true
            tile.wide = true
            tile.visualStyle = "pixel"
            tile.detailsEnabled = true
            tile.detailsOnLongPress = true
            tile.editMode = false
            tile.editSelected = false
            detailsSpy.clear()
            triggeredSpy.clear()
        }

        function test_pixelGeometryAndDynamicRoles() {
            const surface = findChild(tile, "meoQuickSettingsSurface")
            verify(surface !== null)
            verify(tile.pixelStyle)
            compare(Math.round(tile.visualHeight), Math.round(80 * MeoTheme.globalScale))
            compare(tile.activeContainerColor, MeoTheme.primary)
            compare(tile.activeContentColor, MeoTheme.contentOnPrimary)
            compare(tile.focusStrokeWidth, MeoTheme.strokeWidthThick)
            compare(tile.focusStrokeColor, MeoTheme.secondaryFixed)
        }

        function test_detailsButtonAndEditMode() {
            const detailsButton = findChild(tile, "quickSettingsDetailsButton")
            verify(detailsButton !== null)
            verify(detailsButton.visible)
            mouseClick(detailsButton, detailsButton.width / 2, detailsButton.height / 2, Qt.LeftButton)
            compare(detailsSpy.count, 1)

            tile.editMode = true
            verify(!detailsButton.visible)

            const removeButton = findChild(tile, "quickSettingsRemoveButton")
            const resizeButton = findChild(tile, "quickSettingsResizeButton")
            verify(removeButton !== null)
            verify(resizeButton !== null)
            verify(!removeButton.visible)
            verify(!resizeButton.visible)

            tile.editSelected = true
            verify(resizeButton.visible)
        }

        function test_longPressRequestsDetailsWithoutActivatingTile() {
            const pointer = findChild(tile, "quickSettingsPointer")
            verify(pointer !== null)
            mousePress(tile, tile.width / 2, tile.height / 2, Qt.LeftButton)
            wait(900)
            mouseRelease(tile, tile.width / 2, tile.height / 2, Qt.LeftButton)
            compare(detailsSpy.count, 1)
            compare(triggeredSpy.count, 0)
        }

        function test_disabledTileUsesSemanticOpacity() {
            tile.enabled = false
            wait(MeoTheme.motionDurationState + 20)
            compare(tile.opacity, MeoTheme.disabledContentOpacity)
        }
    }
}
