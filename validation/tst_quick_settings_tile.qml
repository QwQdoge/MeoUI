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
            tile.busy = false
            tile.unavailable = false
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
            compare(tile.activeContainerColor, MeoTheme.primaryContainer)
            compare(tile.activeContentColor, MeoTheme.contentOnPrimaryContainer)
            compare(tile.focusStrokeWidth, MeoTheme.strokeWidthThick)
            compare(tile.focusStrokeColor, MeoTheme.secondaryFixed)
            compare(tile.inactiveIconShape, "Circle")
            compare(tile.activeIconShape, "Cookie4Sided")
            verify(tile.iconShapeMorphEnabled)
            const morph = findChild(tile, "quickSettingsIconShapeMorph")
            verify(morph !== null)
            tile.active = false
            wait(MeoMotion.maximumDuration(tile.motionProfile, "fast") + 20)
            compare(morph.value, 0)
            tile.active = true
            wait(MeoMotion.maximumDuration(tile.motionProfile, "fast") + 20)
            compare(morph.value, 1)
        }

        function test_detailsButtonAndEditMode() {
            const detailsButton = findChild(tile, "quickSettingsDetailsButton")
            verify(detailsButton !== null)
            verify(detailsButton.visible)
            detailsButton.clicked()
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
            pointer.handleLongPress()
            compare(detailsSpy.count, 1)
            compare(triggeredSpy.count, 0)
        }

        function test_disabledTileUsesSemanticOpacity() {
            tile.enabled = false
            wait(MeoTheme.motionDurationState + 20)
            compare(tile.opacity, MeoTheme.disabledContentOpacity)
        }

        function test_busyAndUnavailableStateBlockActions() {
            tile.busy = true
            tile.unavailable = false
            verify(!tile.activeFocusOnTab)
            tile.busy = false
            tile.unavailable = true
            verify(!tile.activeFocusOnTab)
            wait(MeoTheme.motionDurationState + 20)
            verify(tile.opacity <= MeoTheme.disabledContentOpacity)
        }
    }
}
