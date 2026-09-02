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

        function test_standardAndExpressiveConfigurationContract() {
            compare(standardSlider.effectiveTrackStyle, "standard")
            compare(standardSlider.thumbWidth, MeoTheme.sliderThumbWidthExpressive)
            compare(standardSlider.thumbHeight, MeoTheme.sliderThumbHeightXS)
            compare(standardSlider.valueLabelEnabled, false)
            standardSlider.expressive = true
            compare(standardSlider.effectiveTrackStyle, "split")
            compare(standardSlider.thumbWidth, MeoTheme.sliderThumbWidthExpressive)
            compare(standardSlider.trackHeight, MeoTheme.sliderTrackHeightM)
            compare(standardSlider.thumbHeight, MeoTheme.sliderThumbHeightM)
            standardSlider.size = "xl"
            compare(standardSlider.trackHeight, MeoTheme.sliderTrackHeightXL)
            compare(standardSlider.thumbHeight, MeoTheme.sliderThumbHeightXL)
            compare(centeredSlider.centered, true)
            compare(centeredSlider.effectiveTrackStyle, "standard")
            compare(centeredSlider.centerPosition, centeredSlider.trackLength / 2)
            compare(centeredSlider.activeTrackStart, centeredSlider.centerPosition)
            verify(centeredSlider.activeTrackEnd > centeredSlider.activeTrackStart)
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
    }
}
