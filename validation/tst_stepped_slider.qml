import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 400
    height: 160

    Components.MeoSteppedSlider {
        id: slider
        width: 360
        title: "Volume"
        supportingText: "Room speaker"
        from: 0
        to: 100
        value: 50
        stepSize: 10
        valueSuffix: "%"
        showValueLabel: true
    }

    SignalSpy {
        id: movedSpy
        target: slider
        signalName: "moved"
    }

    TestCase {
        name: "MeoSteppedSlider"
        when: windowShown

        function init() {
            slider.enabled = true
            slider.discrete = true
            slider.from = 0
            slider.to = 100
            slider.stepSize = 10
            slider.value = 50
            movedSpy.clear()
        }

        function test_snapsAndClamps() {
            compare(slider.normalizedValue(56), 60)
            compare(slider.normalizedValue(-3), 0)
            compare(slider.normalizedValue(104), 100)
            slider.setValue(56)
            compare(slider.value, 60)
            compare(movedSpy.count, 1)
        }

        function test_buttonsUseTheDeclaredIncrement() {
            slider.adjust(-1)
            compare(slider.value, 40)
            slider.adjust(1)
            compare(slider.value, 50)
            compare(movedSpy.count, 2)
        }

        function test_fractionalAndContinuousSteps() {
            slider.from = 0.5
            slider.to = 2
            slider.value = 1
            slider.stepSize = 0.25
            slider.adjust(1)
            compare(slider.value, 1.25)

            slider.discrete = false
            slider.stepSize = 0
            slider.adjust(1)
            compare(slider.value, 1.265)
        }

        function test_internalTrackAndAccessibleDescription() {
            const track = findChild(slider, "meoSteppedSliderTrack")
            verify(track !== null)
            compare(slider.Accessible.ignored, true)
            compare(track.accessibleName, "Volume")
            verify(track.accessibleDescription.indexOf("50") !== -1)
        }
    }
}
