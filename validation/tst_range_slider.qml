import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 520
    height: 160

    Components.MeoRangeSlider {
        id: range
        width: 360
        firstValue: 24
        secondValue: 78
    }

    TestCase {
        name: "MeoRangeSlider"
        when: windowShown

        function init() {
            range.firstValue = 24
            range.secondValue = 78
            range.discrete = false
            range.expressive = false
            range.wavy = false
            range.enabled = true
        }

        function test_standardRangeUsesM3DefaultHandles() {
            const track = findChild(range, "meoRangeSliderStandardTrack")
            const active = findChild(range, "meoRangeSliderActiveTrack")
            const thumb = findChild(range, "meoRangeSliderThumb")
            verify(track !== null)
            verify(active !== null)
            verify(thumb !== null)
            verify(track.visible)
            compare(range.trackStyle, "standard")
            compare(range.thumbWidth, MeoTheme.sliderThumbWidthExpressive)
            compare(range.thumbHeight, MeoTheme.sliderThumbHeightXS)
            compare(range.valueLabelEnabled, false)
            verify(active.width > 0)
            verify(range.Accessible.name.indexOf("24") !== -1)
        }

        function test_expressiveSplitIsExplicit() {
            range.expressive = true
            const active = findChild(range, "meoRangeSliderSplitActiveTrack")
            verify(active !== null)
            verify(active.visible)
            compare(range.trackStyle, "split")
            compare(range.thumbWidth, MeoTheme.sliderThumbWidthExpressive)
            compare(range.trackHeight, MeoTheme.sliderTrackHeightM)
            compare(range.thumbHeight, MeoTheme.sliderThumbHeightM)
        }

        function test_discreteAndDisabledConfiguration() {
            range.discrete = true
            range.stepSize = 10
            range.firstValue = 20
            range.secondValue = 80
            compare(range.firstValue, 20)
            compare(range.secondValue, 80)

            range.enabled = false
            compare(range.resolvedActiveTrackColor,
                    range.compositeColor(MeoTheme.contentOnSurface, MeoTheme.disabledContentOpacity, MeoTheme.surface))
            compare(range.resolvedInactiveTrackColor,
                    range.compositeColor(MeoTheme.contentOnSurface, MeoTheme.disabledContainerOpacity, MeoTheme.surface))
            compare(range.resolvedThumbColor,
                    range.compositeColor(MeoTheme.contentOnSurface, MeoTheme.disabledContentOpacity, MeoTheme.surface))
            compare(range.Accessible.ignored, true)
        }
    }
}
