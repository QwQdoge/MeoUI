import QtQuick
import QtTest
import MeoUI
import "../patterns" as Patterns

Item {
    width: 560
    height: 560

    Patterns.MeoQuickSettingsEditor {
        id: editor
        width: 512 * MeoTheme.globalScale
        tiles: [
            { "title": "Wi-Fi", "iconName": "wifi", "span": 2 },
            { "title": "Bluetooth", "iconName": "bluetooth", "span": 2 },
            { "title": "Flashlight", "iconName": "flashlight_on", "span": 1 }
        ]
    }

    TestCase {
        name: "MeoQuickSettingsEditor"
        when: windowShown

        function test_fixedFourUnitCanvasAndSpans() {
            compare(editor.effectiveColumns, 4)
            compare(editor.tileSpan(editor.tiles[0]), 2)
            compare(editor.tileSpan(editor.tiles[2]), 1)
            const wideSlot = findChild(editor, "meoQuickSettingsTileSlot-0")
            const secondWideSlot = findChild(editor, "meoQuickSettingsTileSlot-1")
            const compactSlot = findChild(editor, "meoQuickSettingsTileSlot-2")
            verify(wideSlot !== null)
            verify(secondWideSlot !== null)
            verify(compactSlot !== null)
            compare(Math.round(wideSlot.implicitWidth), Math.round(196 * editor.uiScale))
            compare(Math.round(compactSlot.implicitWidth), Math.round(94 * editor.uiScale))
            compare(Math.round(wideSlot.width), Math.round(secondWideSlot.width))
            // Slots glide to their cells on the shared spring, so wait for rest.
            tryVerify(function() {
                return Math.round(secondWideSlot.x) === Math.round(wideSlot.width + MeoTheme.space8)
            })
            tryVerify(function() {
                return Math.round(compactSlot.y) === Math.round(wideSlot.height + MeoTheme.space8)
            })
        }

        function test_gridAndSelectionSurfaceExist() {
            const grid = findChild(editor, "meoQuickSettingsTileGrid")
            const frame = findChild(editor, "meoQuickSettingsSelectionFrame")
            verify(grid !== null)
            verify(frame !== null)
            verify(frame.implicitHeight >= grid.implicitHeight)
        }
    }
}
