import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 480
    height: 160

    Components.MeoQuickControlSlider {
        id: quickControl
        width: 360
        iconName: "volume_up"
        label: "Output volume"
        accessibleName: "Output volume"
        iconAccessibleName: "Mute output"
        value: 48
        detailsAvailable: true
    }

    SignalSpy { id: trackingStartedSpy; target: quickControl; signalName: "trackingStarted" }
    SignalSpy { id: trackingEndedSpy; target: quickControl; signalName: "trackingEnded" }

    TestCase {
        name: "MeoQuickControlSlider"
        when: windowShown

        function init() {
            quickControl.enabled = true
            quickControl.value = 48
            quickControl.expanded = false
            trackingStartedSpy.clear()
            trackingEndedSpy.clear()
        }

        function test_containerAndValueContract() {
            const activeTrack = findChild(quickControl, "meoQuickControlActiveTrack")
            const divider = findChild(quickControl, "meoQuickControlDivider")
            const slider = findChild(quickControl, "quickControlValueSlider")
            verify(activeTrack !== null)
            verify(divider !== null)
            verify(slider !== null)
            compare(Math.round(quickControl.implicitHeight), Math.round(56 * MeoTheme.globalScale))
            compare(Math.round(quickControl.valueFraction * 100), 48)
            verify(activeTrack.width > 0)
            verify(slider.enabled)
        }

        function test_clampsExternalValueAndDisabledState() {
            quickControl.value = 120
            compare(quickControl.clampedValue, quickControl.to)
            compare(Math.round(quickControl.valueFraction * 100), 100)
            quickControl.value = -20
            compare(quickControl.clampedValue, quickControl.from)

            quickControl.enabled = false
            wait(MeoTheme.motionDurationState + 20)
            compare(quickControl.opacity, MeoTheme.disabledContentOpacity)
            const slider = findChild(quickControl, "quickControlValueSlider")
            verify(!slider.enabled)
        }

        function test_detailsStateAndAccessibility() {
            quickControl.expanded = true
            verify(quickControl.detailsAvailable)
            const slider = findChild(quickControl, "quickControlValueSlider")
            verify(slider.Accessible.description.indexOf("48") !== -1)
        }

        function test_realSliderOwnsAccessibilityAndTrackingBoundary() {
            const slider = findChild(quickControl, "quickControlValueSlider")
            verify(slider !== null)
            verify(quickControl.Accessible.ignored)
            mousePress(slider, slider.width / 2, slider.height / 2, Qt.LeftButton)
            verify(quickControl.tracking)
            compare(trackingStartedSpy.count, 1)
            mouseRelease(slider, slider.width / 2, slider.height / 2, Qt.LeftButton)
            verify(!quickControl.tracking)
            compare(trackingEndedSpy.count, 1)
        }
    }
}
