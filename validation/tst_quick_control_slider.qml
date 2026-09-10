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
            const slider = findChild(quickControl, "quickControlValueSlider")
            verify(slider !== null)
            compare(findChild(quickControl, "meoQuickControlActiveTrack"), null)
            compare(findChild(quickControl, "meoQuickControlDivider"), null)
            compare(Math.round(quickControl.implicitHeight), Math.round(52 * MeoTheme.globalScale))
            compare(Math.round(quickControl.valueFraction * 100), 48)
            compare(slider.trackHeight, MeoTheme.sliderTrackHeightM)
            compare(slider.trackCornerRadius, MeoTheme.sliderTrackCornerRadiusM)
            compare(slider.insetIconSize, MeoTheme.sliderInsetIconSizeM)
            compare(slider.thumbWidth, MeoTheme.sliderThumbWidthExpressive)
            verify(slider.endStopEnabled)
            compare(findChild(slider, "meoSliderLeadingEndStop").visible, false)
            compare(findChild(slider, "meoSliderTrailingEndStop").visible, true)
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
            tryVerify(function() {
                return Math.abs(quickControl.opacity - MeoTheme.disabledContentOpacity) < 0.001
            }, 500)
            const slider = findChild(quickControl, "quickControlValueSlider")
            verify(!slider.enabled)
        }

        function test_detailsStateAndAccessibility() {
            quickControl.expanded = true
            verify(quickControl.detailsAvailable)
            const slider = findChild(quickControl, "quickControlValueSlider")
            verify(slider.accessibleDescription.indexOf("48") !== -1)
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
