import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 900
    height: 900

    MeoQuickSettingsTile {
        id: tile
        x: 20
        y: 20
        width: 176 * MeoTheme.globalScale
        title: "Wi-Fi"
        supportingText: "Connected"
        iconName: "wifi"
        active: true
        wide: true
        visualStyle: "pixel"
        detailsEnabled: true
    }

    SignalSpy { id: tileTriggeredSpy; target: tile; signalName: "triggered" }
    SignalSpy { id: tileDetailsSpy; target: tile; signalName: "detailsRequested" }

    MeoExposedDropdown {
        id: dropdown
        x: 20
        y: 130
        width: 280 * MeoTheme.globalScale
        label: "Output device"
        model: ["Speakers", "Headphones", "HDMI"]
        text: "Headphones"
    }

    SignalSpy { id: dropdownSelectedSpy; target: dropdown; signalName: "selected" }

    MeoQuickControlSlider {
        id: quickSlider
        x: 20
        y: 230
        width: 360 * MeoTheme.globalScale
        iconName: "volume_up"
        label: "Built-in audio"
        accessibleName: "Output volume"
        iconAccessibleName: "Mute output"
        value: 48
        detailsAvailable: true
    }

    SignalSpy { id: sliderIconSpy; target: quickSlider; signalName: "iconTriggered" }

    MeoSteppedSlider {
        id: steppedSlider
        x: 20
        y: 340
        width: 360 * MeoTheme.globalScale
        title: "Font size"
        supportingText: "Make text bigger or smaller"
        from: 0
        to: 4
        value: 2
        stepSize: 1
        discrete: true
        valueSuffix: "/4"
    }

    SignalSpy { id: steppedSliderMovedSpy; target: steppedSlider; signalName: "moved" }

    MeoAppGridItem {
        id: appGridItem
        x: 440
        y: 340
        title: "Settings"
        iconName: "settings"
    }

    SignalSpy { id: appGridTriggeredSpy; target: appGridItem; signalName: "triggered" }

    MeoQuickSettingsEditor {
        id: pixelEditor
        x: 20
        y: 470
        width: 500 * MeoTheme.globalScale
        visible: false
        tiles: [
            { "id": "wifi", "title": "Wi-Fi", "iconName": "wifi", "span": 2 },
            { "id": "focus", "title": "Modes", "iconName": "do_not_disturb_on", "span": 1 }
        ]
        availableTiles: [
            { "id": "bluetooth", "title": "Bluetooth", "iconName": "bluetooth", "span": 2 }
        ]
    }

    MeoMonthCalendar {
        id: calendar
        x: 430
        y: 20
        width: implicitWidth
        height: implicitHeight
        selectedDate: new Date(2026, 0, 31)
        displayDate: new Date(2026, 0, 1)
    }

    SignalSpy { id: calendarSelectedSpy; target: calendar; signalName: "dateSelected" }

    TestCase {
        name: "MeoImportantUx"
        when: windowShown

        function init() {
            tile.wide = true
            tile.visualStyle = "pixel"
            tile.editMode = false
            tile.detailsEnabled = true
            tileTriggeredSpy.clear()
            tileDetailsSpy.clear()

            if (dropdown.opened)
                dropdown.toggleMenu()
            dropdown.model = ["Speakers", "Headphones", "HDMI"]
            dropdown.text = "Headphones"
            dropdownSelectedSpy.clear()

            sliderIconSpy.clear()

            steppedSlider.value = 2
            steppedSliderMovedSpy.clear()
            appGridTriggeredSpy.clear()

            calendar.selectedDate = new Date(2026, 0, 31)
            calendar.displayDate = new Date(2026, 0, 1)
            calendar.focusedDate = new Date(2026, 0, 31)
            calendarSelectedSpy.clear()

            MeoTheme.reduceMotion = false
            wait(0)
        }

        function cleanup() {
            if (dropdown.opened)
                dropdown.toggleMenu()
            MeoTheme.reduceMotion = false
            wait(0)
        }

        function test_calendarRovingFocusAndCrossMonthSelection() {
            calendar.focusFocusedDay(Qt.TabFocusReason)
            tryVerify(function() {
                return calendar.focusedDayItem && calendar.focusedDayItem.activeFocus
            })
            verify(calendar.focusedDayItem.activeFocusOnTab)

            keyClick(Qt.Key_Right)
            tryCompare(calendar, "focusedIndex", calendar.indexForDate(new Date(2026, 1, 1)))
            compare(calendar.focusedDate.getFullYear(), 2026)
            compare(calendar.focusedDate.getMonth(), 1)
            compare(calendar.focusedDate.getDate(), 1)
            compare(calendar.displayDate.getMonth(), 1)
            tryVerify(function() {
                return calendar.focusedDayItem && calendar.focusedDayItem.activeFocus
            })

            keyClick(Qt.Key_Return)
            compare(calendarSelectedSpy.count, 1)
            compare(calendar.selectedDate.getMonth(), 1)
            compare(calendar.selectedDate.getDate(), 1)

            keyClick(Qt.Key_Down)
            keyClick(Qt.Key_Space)
            compare(calendarSelectedSpy.count, 2)
            compare(calendar.selectedDate.getDate(), 8)
        }

        function test_dropdownKeyboardContractAndFocusReturn() {
            compare(dropdown.currentIndex, 1)
            dropdown.forceActiveFocus(Qt.TabFocusReason)

            keyClick(Qt.Key_Down)
            compare(dropdown.currentIndex, 2)
            compare(dropdown.text, "HDMI")
            compare(dropdownSelectedSpy.count, 1)

            keyClick(Qt.Key_Return)
            tryCompare(dropdown, "opened", true)
            keyClick(Qt.Key_Up)
            compare(dropdown.highlightedIndex, 1)
            keyClick(Qt.Key_Return)
            tryCompare(dropdown, "opened", false)
            compare(dropdown.currentIndex, 1)
            compare(dropdown.text, "Headphones")
            compare(dropdownSelectedSpy.count, 2)
            tryCompare(dropdown, "activeFocus", true)

            keyClick(Qt.Key_Space)
            tryCompare(dropdown, "opened", true)
            keyClick(Qt.Key_Escape)
            tryCompare(dropdown, "opened", false)
            tryCompare(dropdown, "activeFocus", true)

            keyClick(Qt.Key_Up)
            compare(dropdown.currentIndex, 0)
            compare(dropdown.text, "Speakers")
        }

        function test_listMotionUsesReducedMotionGateway() {
            verify(MeoTheme.motionDurationEffectDefault > 0)
            MeoTheme.reduceMotion = true
            compare(MeoTheme.motionDurationEffectDefault, 0)
        }

        function test_quickSliderSemanticButtons() {
            compare(quickSlider.accessibleName, "Output volume")
            compare(quickSlider.iconAccessibleName, "Mute output")
            verify(quickSlider.iconActionEnabled)

            const iconButton = findChild(quickSlider, "quickControlIconButton")
            const valueSlider = findChild(quickSlider, "quickControlValueSlider")
            verify(iconButton !== null)
            verify(valueSlider !== null)
            compare(iconButton.width, 52 * MeoTheme.globalScale)
            compare(iconButton.height, 56 * MeoTheme.globalScale)
            verify(iconButton.activeFocusOnTab)
            verify(valueSlider.activeFocusOnTab)

            iconButton.forceActiveFocus(Qt.TabFocusReason)
            keyClick(Qt.Key_Space)
            compare(sliderIconSpy.count, 1)
        }

        function test_pixelReferencePrimitivesKeepTheirContracts() {
            compare(tile.visualHeight, 80 * MeoTheme.globalScale)
            compare(tile.pixelStyle, true)
            // The Android 16 editor works on four logical columns: a wide
            // tile spans two, while a compact tile spans one.
            compare(pixelEditor.effectiveColumns, 4)
            compare(pixelEditor.tileSpan(pixelEditor.tiles[0]), 2)
            compare(pixelEditor.tileSpan(pixelEditor.tiles[1]), 1)
            compare(pixelEditor.tileIcon(pixelEditor.availableTiles[0]), "bluetooth")

            steppedSlider.adjust(1)
            compare(steppedSlider.value, 3)
            compare(steppedSliderMovedSpy.count, 1)
            steppedSlider.adjust(9)
            compare(steppedSlider.value, 4)
            compare(steppedSliderMovedSpy.count, 2)

            compare(appGridItem.tileWidth, 80 * MeoTheme.globalScale)
            compare(appGridItem.tileHeight, 88 * MeoTheme.globalScale)
            appGridItem.activate()
            compare(appGridTriggeredSpy.count, 1)
        }

        function test_quickTileDetailButtonClickAndKeyboard() {
            let detailsButton = findChild(tile, "quickSettingsDetailsButton")
            verify(detailsButton !== null)
            compare(detailsButton.width, 44 * MeoTheme.globalScale)
            compare(detailsButton.height, 44 * MeoTheme.globalScale)

            mouseClick(detailsButton, detailsButton.width / 2, detailsButton.height / 2, Qt.LeftButton)
            compare(tileDetailsSpy.count, 1)
            compare(tileTriggeredSpy.count, 0)

            detailsButton.forceActiveFocus(Qt.TabFocusReason)
            keyClick(Qt.Key_Return)
            compare(tileDetailsSpy.count, 2)

            const touch = touchEvent(detailsButton)
            touch.press(0, detailsButton).commit()
            touch.release(0, detailsButton).commit()
            compare(tileDetailsSpy.count, 3)

            tile.forceActiveFocus(Qt.TabFocusReason)
            keyClick(Qt.Key_Space)
            compare(tileTriggeredSpy.count, 1)
            compare(tileDetailsSpy.count, 3)

            tile.wide = false
            wait(0)
            detailsButton = findChild(tile, "quickSettingsDetailsButton")
            verify(detailsButton !== null)
            compare(detailsButton.width, 44 * MeoTheme.globalScale)
            compare(detailsButton.height, 44 * MeoTheme.globalScale)
        }
    }
}
