import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 240
    height: 160

    Components.MeoLoadingIndicator {
        id: indicator
        size: "m"
        running: false
    }

    TestCase {
        name: "MeoLoadingIndicator"
        when: windowShown

        function init() {
            indicator.variant = "default"
            indicator.withContainer = false
            indicator.indeterminate = true
            indicator.running = false
            indicator.value = 0
        }

        function test_officialContainmentColorsAndMeasurements() {
            compare(indicator.variant, "default")
            compare(indicator.implicitWidth, 48 * indicator.themeGlobalScale)
            compare(indicator.activeIndicatorColor, indicator.color)
            compare(indicator.Accessible.role, Accessible.ProgressBar)
            const activeArea = findChild(indicator, "meoLoadingActiveArea")
            verify(activeArea !== null)
            compare(Math.round(activeArea.width), Math.round(indicator.implicitWidth * 38 / 48))

            indicator.variant = "contained"
            verify(indicator.activeIndicatorColor !== indicator.color)
            verify(indicator.containerColor.a > 0)

            compare(indicator.shapeSequence.length, 8)
            compare(indicator.shapeSequence[0], "SoftBurst")
            compare(indicator.shapeSequence[6], "Oval")
            compare(indicator.shapeSequence[7], "SoftBurst")
        }

        function test_legacySizeInputPreservesTheOneOfficialContainerSize() {
            const sizes = ["xs", "s", "m", "l", "xl"]
            for (let index = 0; index < sizes.length; ++index) {
                indicator.size = sizes[index]
                compare(indicator.implicitWidth, 48 * indicator.themeGlobalScale)
                compare(indicator.implicitHeight, 48 * indicator.themeGlobalScale)
            }
        }

        function test_determinateAndPausedUseStablePose() {
            indicator.indeterminate = false
            indicator.value = 0.62
            verify(indicator.Accessible.name.indexOf("62") !== -1)
            const morpher = findChild(indicator, "meoLoadingMorpher")
            verify(morpher !== null)
            compare(morpher.fromShape, "Circle")
            compare(morpher.toShape, "SoftBurst")
            compare(Math.round(morpher.morphProgress * 100), 62)
            compare(Math.round(morpher.rotationAngle), -94)

            indicator.indeterminate = true
            indicator.running = false
            compare(morpher.morphSequenceIndex, 0)
            compare(morpher.morphStepProgress, 0)
            compare(morpher.rawMorphProgress, 0)
            compare(morpher.localStepRotation, indicator.indeterminateInitialRotation)
        }
    }
}
