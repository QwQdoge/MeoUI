import QtQuick
import QtQuick.Controls
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 720
    height: 360

    Components.MeoSlider {
        id: standardSlider
        width: 360
        value: 50
        insetIcon: "volume_up"
    }

    Components.MeoSlider {
        id: centeredSlider
        x: 380
        width: 320
        from: -100
        to: 100
        centerValue: 0
        value: 25
        variant: "centered"
    }

    Components.MeoSlider {
        id: verticalSlider
        y: 80
        width: 64
        height: 240
        value: 70
        orientation: Qt.Vertical
        stops: true
        stepSize: 10
    }

    Components.MeoRangeSlider {
        id: rangeSlider
        x: 100
        y: 100
        width: 360
        firstValue: 20
        secondValue: 80
    }

    TestCase {
        name: "MeoSlider"
        when: windowShown

        function init() {
            standardSlider.enabled = true
            standardSlider.expressive = false
            standardSlider.size = "xs"
            standardSlider.value = 50
            standardSlider.valueLabelEnabled = false
        }

        function test_standardAndExpressiveConfigurationContract() {
            compare(standardSlider.effectiveTrackStyle, "standard")
            compare(standardSlider.thumbWidth, MeoTheme.sliderThumbWidthExpressive)
            compare(standardSlider.thumbHeight, MeoTheme.sliderThumbHeightXS)
            compare(standardSlider.valueLabelEnabled, false)
            standardSlider.expressive = true
            compare(standardSlider.effectiveTrackStyle, "split")
            compare(standardSlider.thumbWidth, MeoTheme.sliderThumbWidthExpressive)
            compare(standardSlider.trackHeight, MeoTheme.sliderTrackHeightXS)
            compare(standardSlider.thumbHeight, MeoTheme.sliderThumbHeightXS)
            compare(standardSlider.pressedThumbWidth, MeoTheme.sliderThumbPressedWidthExpressive)
            verify(standardSlider.endStopEnabled)
            standardSlider.size = "xl"
            compare(standardSlider.trackHeight, MeoTheme.sliderTrackHeightXL)
            compare(standardSlider.thumbHeight, MeoTheme.sliderThumbHeightXL)
            compare(centeredSlider.centered, true)
            compare(centeredSlider.effectiveTrackStyle, "standard")
            compare(centeredSlider.centerPosition, centeredSlider.trackLength / 2)
            compare(centeredSlider.activeTrackStart, centeredSlider.centerPosition)
            verify(centeredSlider.activeTrackEnd > centeredSlider.activeTrackStart)
        }

        function test_fiveSizeGeometryMatrix() {
            const sizes = ["xs", "s", "m", "l", "xl"]
            const tracks = [16, 24, 40, 56, 96]
            const handles = [44, 44, 52, 68, 108]
            const corners = [8, 8, 12, 16, 28]
            const icons = [0, 0, 24, 24, 32]
            standardSlider.expressive = true

            for (let i = 0; i < sizes.length; ++i) {
                standardSlider.size = sizes[i]
                compare(standardSlider.trackHeight, tracks[i] * MeoTheme.globalScale)
                compare(standardSlider.thumbHeight, handles[i] * MeoTheme.globalScale)
                compare(standardSlider.trackCornerRadius, corners[i] * MeoTheme.globalScale)
                compare(standardSlider.insetIconSize, icons[i] * MeoTheme.globalScale)
                compare(standardSlider.leadingIconEnabled, i >= 2)
            }
        }

        function test_splitTrackUsesOuterAndInsideCorners() {
            standardSlider.expressive = true
            standardSlider.size = "m"
            const active = findChild(standardSlider, "meoSliderSplitActiveTrack")
            const inactive = findChild(standardSlider, "meoSliderSplitInactiveTrack")
            const leading = findChild(standardSlider, "meoSliderLeadingEndStop")
            const trailing = findChild(standardSlider, "meoSliderTrailingEndStop")
            verify(active !== null)
            verify(inactive !== null)
            verify(leading !== null)
            verify(trailing !== null)
            tryCompare(active, "topLeftRadius", MeoTheme.sliderTrackCornerRadiusM,
                       MeoTheme.motionDurationSelection + 100)
            compare(active.topRightRadius, MeoTheme.sliderTrackInsideCornerRadius)
            compare(inactive.topLeftRadius, MeoTheme.sliderTrackInsideCornerRadius)
            compare(inactive.topRightRadius, MeoTheme.sliderTrackCornerRadiusM)
            compare(leading.visible, false)
            compare(trailing.visible, true)
            compare(trailing.x + trailing.width / 2,
                    inactive.parent.width - MeoTheme.sliderTrackCornerRadiusM)
        }

        function test_valueIndicatorUsesFortyDpContainer() {
            standardSlider.valueLabelEnabled = true
            const indicator = findChild(standardSlider, "meoSliderValueIndicator")
            verify(indicator !== null)
            compare(indicator.height, MeoTheme.sliderValueIndicatorSize)
        }

        function test_expressiveStopsUseSharedGeometry() {
            standardSlider.expressive = true
            const leading = findChild(standardSlider, "meoSliderLeadingEndStop")
            const trailing = findChild(standardSlider, "meoSliderTrailingEndStop")
            verify(leading !== null)
            verify(trailing !== null)
            verify(leading.visible)
            verify(trailing.visible)
            compare(leading.width, MeoTheme.sliderStopSizeExpressive)
            compare(trailing.width, MeoTheme.sliderStopSizeExpressive)
            standardSlider.expressive = false
        }

        function test_stopsAndVerticalContracts() {
            compare(verticalSlider.horizontal, false)
            compare(verticalSlider.orientation, Qt.Vertical)
            compare(verticalSlider.normalizedValue(74), 70)
            verticalSlider.setValue(76)
            compare(verticalSlider.value, 80)
            verify(verticalSlider.implicitHeight >= 44 * verticalSlider.themeGlobalScale)
        }

        function test_nativeSliderOwnsTheAccessibleSemantic() {
            standardSlider.accessibleName = "Room volume"
            standardSlider.accessibleDescription = "50 percent"
            const nativeSlider = findChild(standardSlider, "meoSliderNative")
            verify(nativeSlider !== null)
            verify(nativeSlider.activeFocusOnTab)
            compare(standardSlider.Accessible.ignored, true)
            compare(standardSlider.accessibleName, "Room volume")
            compare(standardSlider.accessibleDescription, "50 percent")
        }

        function test_disabledRolesAreResolvedPerElement() {
            standardSlider.enabled = false
            compare(standardSlider.resolvedActiveTrackColor,
                    standardSlider.compositeColor(MeoTheme.contentOnSurface,
                                                  MeoTheme.disabledContentOpacity,
                                                  MeoTheme.surface))
            compare(standardSlider.resolvedInactiveTrackColor,
                    standardSlider.compositeColor(MeoTheme.contentOnSurface,
                                                  MeoTheme.disabledContainerOpacity,
                                                  MeoTheme.surface))
            compare(standardSlider.resolvedThumbColor,
                    standardSlider.compositeColor(MeoTheme.contentOnSurface,
                                                  MeoTheme.disabledContentOpacity,
                                                  MeoTheme.surface))
            standardSlider.enabled = true
        }

        function test_rangeUsesTheSharedExpressiveColors() {
            compare(rangeSlider.activeTrackColor, standardSlider.activeTrackColor)
            compare(rangeSlider.inactiveTrackColor, standardSlider.inactiveTrackColor)
            compare(rangeSlider.thumbColor, standardSlider.thumbColor)
        }

        function test_wavyMotionRespectsReducedMotion() {
            const savedReduceMotion = MeoTheme.reduceMotion
            MeoTheme.reduceMotion = false
            compare(standardSlider.motionWaveDuration, MeoTheme.motionDurationWaveCycle)
            MeoTheme.reduceMotion = true
            compare(standardSlider.motionWaveDuration, 0)
            compare(standardSlider.waveAnimationActive, false)
            MeoTheme.reduceMotion = savedReduceMotion
        }
    }
}
