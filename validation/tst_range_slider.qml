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
            range.size = "xs"
            range.wavy = false
            range.enabled = true
        }

        function test_standardRangeUsesM3DefaultHandles() {
            const track = findChild(range, "meoRangeSliderStandardTrack")
            const active = findChild(range, "meoRangeSliderActiveTrack")
            const thumb = findChild(range, "meoRangeSliderThumb")
            const nativeRange = findChild(range, "meoRangeSliderNative")
            verify(track !== null)
            verify(active !== null)
            verify(thumb !== null)
            verify(nativeRange !== null)
            tryCompare(range, "trackStyle", "standard")
            tryCompare(track, "visible", true)
            verify(track.visible)
            compare(range.thumbWidth, MeoTheme.sliderThumbWidthExpressive)
            compare(range.thumbHeight, MeoTheme.sliderThumbHeightXS)
            compare(range.valueLabelEnabled, false)
            verify(active.width > 0)
            verify(nativeRange.Accessible.name.indexOf("24") !== -1)
        }

        function test_expressiveSplitIsExplicit() {
            range.expressive = true
            const active = findChild(range, "meoRangeSliderSplitActiveTrack")
            verify(active !== null)
            verify(active.visible)
            compare(range.trackStyle, "split")
            compare(range.thumbWidth, MeoTheme.sliderThumbWidthExpressive)
            compare(range.trackHeight, MeoTheme.sliderTrackHeightXS)
            compare(range.thumbHeight, MeoTheme.sliderThumbHeightXS)
            compare(range.pressedThumbWidth, MeoTheme.sliderThumbPressedWidthExpressive)
            compare(range.trackCornerRadius, MeoTheme.sliderTrackCornerRadiusXS)
            verify(range.endStopEnabled)
            range.discrete = true
            range.stepSize = 10
            wait(0)
            const interiorTick = findChild(range, "meoRangeSliderTick_5")
            verify(interiorTick !== null)
            compare(interiorTick.width, MeoTheme.sliderStopSizeExpressive)
            range.discrete = false
        }

        function test_splitTrackUsesSharedAsymmetricCorners() {
            range.expressive = true
            range.size = "l"
            const leading = findChild(range, "meoRangeSliderSplitLeadingTrack")
            const active = findChild(range, "meoRangeSliderSplitActiveTrack")
            const trailing = findChild(range, "meoRangeSliderSplitTrailingTrack")
            verify(leading !== null)
            verify(active !== null)
            verify(trailing !== null)
            compare(leading.topLeftRadius, MeoTheme.sliderTrackCornerRadiusL)
            compare(leading.topRightRadius, MeoTheme.sliderTrackInsideCornerRadius)
            compare(active.radius, MeoTheme.sliderTrackInsideCornerRadius)
            compare(trailing.topLeftRadius, MeoTheme.sliderTrackInsideCornerRadius)
            compare(trailing.topRightRadius, MeoTheme.sliderTrackCornerRadiusL)
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

        function test_eachThumbUsesSharedPointerFeedback() {
            const stateLayer = findChild(range, "meoRangeSliderThumbStateLayer")
            verify(stateLayer !== null)
            verify(stateLayer.rippleEnabled)
            compare(stateLayer.shape, "circle")
            compare(stateLayer.rippleExpandDuration, MeoTheme.motionDurationRippleExpand)
        }
    }
}
