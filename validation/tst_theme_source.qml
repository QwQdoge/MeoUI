import QtQuick
import QtTest
import MeoUI

Item {
    width: 240
    height: 160

    TestCase {
        name: "MeoThemeSource"
        when: windowShown

        property bool savedDark: false
        property var savedLight: ({})
        property var savedDarkScheme: ({})
        property var savedSingle: ({})
        property bool savedDynamic: false
        property string savedSource: ""
        property bool savedExpressive: false

        function initTestCase() {
            savedDark = MeoTheme.isDarkMode
            savedLight = JSON.parse(JSON.stringify(MeoTheme.dynamicLightColorScheme || ({})))
            savedDarkScheme = JSON.parse(JSON.stringify(MeoTheme.dynamicDarkColorScheme || ({})))
            savedSingle = JSON.parse(JSON.stringify(MeoTheme.dynamicColorScheme || ({})))
            savedDynamic = MeoTheme.dynamicColorsAvailable
            savedSource = MeoTheme.dynamicColorSourceId
            savedExpressive = MeoTheme.isExpressive
        }

        function relativeLuminance(colorValue) {
            const color = Qt.color(colorValue)
            function linear(channel) {
                return channel <= 0.04045
                        ? channel / 12.92
                        : Math.pow((channel + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear(color.r)
                 + 0.7152 * linear(color.g)
                 + 0.0722 * linear(color.b)
        }

        function contrastRatio(first, second) {
            const firstLum = relativeLuminance(first)
            const secondLum = relativeLuminance(second)
            return (Math.max(firstLum, secondLum) + 0.05)
                    / (Math.min(firstLum, secondLum) + 0.05)
        }

        function cleanupTestCase() {
            MeoTheme.isDarkMode = savedDark
            MeoTheme.isExpressive = savedExpressive
            if (MeoTheme.hasCompleteColorScheme(savedLight)
                    && MeoTheme.hasCompleteColorScheme(savedDarkScheme)) {
                MeoTheme.applyDynamicColorSchemes(savedLight, savedDarkScheme, savedSource)
            } else if (savedDynamic) {
                MeoTheme.applyDynamicColorScheme(savedSingle, savedSource, savedDark)
            } else {
                MeoTheme.clearDynamicColorScheme()
            }
        }

        function test_fallbackSchemesHaveTheCompleteRoleTable() {
            verify(MeoTheme.hasCompleteColorScheme(MeoTheme.fallbackLightColorScheme))
            verify(MeoTheme.hasCompleteColorScheme(MeoTheme.fallbackDarkColorScheme))
            compare(String(MeoTheme.fallbackLightColorScheme.surface).toLowerCase(), "#fdf7ff")
            compare(String(MeoTheme.fallbackDarkColorScheme.surface).toLowerCase(), "#141218")
            verify(contrastRatio(MeoTheme.fallbackLightColorScheme.surface,
                                 MeoTheme.fallbackLightColorScheme.onSurface) >= 4.5)
            verify(contrastRatio(MeoTheme.fallbackDarkColorScheme.surface,
                                 MeoTheme.fallbackDarkColorScheme.onSurface) >= 4.5)
        }

        function test_dynamicPairChangesWithAppearance() {
            const light = JSON.parse(JSON.stringify(MeoTheme.fallbackLightColorScheme))
            const dark = JSON.parse(JSON.stringify(MeoTheme.fallbackDarkColorScheme))
            light.primary = "#0058A8"
            dark.primary = "#B4C5FF"

            verify(MeoTheme.applyDynamicColorSchemes(light, dark, "source-theme-test"))
            MeoTheme.isDarkMode = false
            compare(String(MeoTheme.primary).toLowerCase(), "#0058a8")

            MeoTheme.isDarkMode = true
            compare(String(MeoTheme.primary).toLowerCase(), "#b4c5ff")
            compare(String(MeoTheme.surface).toLowerCase(), "#141218")
        }

        function test_singleSchemeDoesNotLeakIntoTheOtherAppearance() {
            const light = JSON.parse(JSON.stringify(MeoTheme.fallbackLightColorScheme))
            light.primary = "#0061A4"

            MeoTheme.isDarkMode = false
            verify(MeoTheme.applyDynamicColorScheme(light, "source-single-test", false))
            compare(String(MeoTheme.primary).toLowerCase(), "#0061a4")

            MeoTheme.isDarkMode = true
            compare(String(MeoTheme.primary).toLowerCase(),
                    String(MeoTheme.fallbackDarkColorScheme.primary).toLowerCase())
        }

        function test_motionSchemeMatchesAndroidXMaterial3Tokens() {
            MeoTheme.isExpressive = false
            compare(MeoMotion.defaultSpatial.dampingRatio, 0.9)
            compare(MeoMotion.defaultSpatial.stiffness, 700)
            compare(MeoMotion.fastSpatial.stiffness, 1400)
            compare(MeoMotion.slowSpatial.stiffness, 300)
            compare(MeoMotion.defaultEffects.dampingRatio, 1.0)
            compare(MeoMotion.defaultEffects.stiffness, 1600)
            compare(MeoMotion.fastEffects.stiffness, 3800)
            compare(MeoMotion.slowEffects.stiffness, 800)

            MeoTheme.isExpressive = true
            compare(MeoMotion.defaultSpatial.dampingRatio, 0.8)
            compare(MeoMotion.defaultSpatial.stiffness, 380)
            compare(MeoMotion.fastSpatial.dampingRatio, 0.6)
            compare(MeoMotion.fastSpatial.stiffness, 800)
            compare(MeoMotion.slowSpatial.dampingRatio, 0.8)
            compare(MeoMotion.slowSpatial.stiffness, 200)
            compare(MeoMotion.defaultEffects.stiffness, 1600)
        }

        function test_motionSamplerHasCorrectEndpointsAndSettles() {
            const spec = MeoMotion.standardDefaultSpatial
            const initial = MeoMotion.stateAt(spec, 0, 0, 1, 0)
            compare(initial.value, 0)
            compare(initial.velocity, 0)

            const settled = MeoMotion.stateAt(spec, 0, 0, 1, 1000)
            verify(MeoMotion.isAtRest(settled, 1, 0.005, 0.01))
        }

        function test_motionTokensRespectReducedMotion() {
            const savedReduceMotion = MeoTheme.reduceMotion
            MeoTheme.reduceMotion = false
            compare(MeoTheme.motionDurationIndeterminateCycle, 1000)
            MeoTheme.reduceMotion = true
            compare(MeoTheme.motionDurationState, 0)
            compare(MeoTheme.motionDurationIndeterminateCycle, 0)
            MeoTheme.reduceMotion = savedReduceMotion
        }

        function test_profileMotionUsesOfficialSchemesAndBounds() {
            compare(MeoMotion.spatialSpec("calm", "fast").stiffness, 1400)
            compare(MeoMotion.spatialSpec("pixel", "default").stiffness, 380)
            compare(MeoMotion.spatialSpec("playful", "slow").stiffness, 200)
            compare(MeoMotion.effectsSpec("fast").dampingRatio, 1.0)
            compare(MeoMotion.maximumDuration("calm", "slow"), 550)
            compare(MeoMotion.maximumDuration("pixel", "default"), 550)
            compare(MeoMotion.maximumDuration("playful", "fast"), 500)
            compare(MeoMotion.pressScale("calm"), 0.98)
            compare(MeoMotion.pressScale("pixel"), 0.96)
            compare(MeoMotion.pressScale("playful"), 0.94)
        }

        function test_scaledElapsedRespectsMotionScaleAndReducedMotion() {
            const savedReduceMotion = MeoTheme.reduceMotion
            MeoTheme.reduceMotion = false
            compare(MeoMotion.scaledElapsed(100, 0.5), 50)
            compare(MeoMotion.scaledElapsed(100, 0), Number.MAX_SAFE_INTEGER)
            MeoTheme.reduceMotion = true
            compare(MeoMotion.scaledElapsed(100, 1), Number.MAX_SAFE_INTEGER)
            MeoTheme.reduceMotion = savedReduceMotion
        }
    }
}
