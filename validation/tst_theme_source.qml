import QtQuick
import QtTest
import "../" as Source

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
            savedDark = Source.MeoTheme.isDarkMode
            savedLight = JSON.parse(JSON.stringify(Source.MeoTheme.dynamicLightColorScheme || ({})))
            savedDarkScheme = JSON.parse(JSON.stringify(Source.MeoTheme.dynamicDarkColorScheme || ({})))
            savedSingle = JSON.parse(JSON.stringify(Source.MeoTheme.dynamicColorScheme || ({})))
            savedDynamic = Source.MeoTheme.dynamicColorsAvailable
            savedSource = Source.MeoTheme.dynamicColorSourceId
            savedExpressive = Source.MeoTheme.isExpressive
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
            Source.MeoTheme.isDarkMode = savedDark
            Source.MeoTheme.isExpressive = savedExpressive
            if (Source.MeoTheme.hasCompleteColorScheme(savedLight)
                    && Source.MeoTheme.hasCompleteColorScheme(savedDarkScheme)) {
                Source.MeoTheme.applyDynamicColorSchemes(savedLight, savedDarkScheme, savedSource)
            } else if (savedDynamic) {
                Source.MeoTheme.applyDynamicColorScheme(savedSingle, savedSource, savedDark)
            } else {
                Source.MeoTheme.clearDynamicColorScheme()
            }
        }

        function test_fallbackSchemesHaveTheCompleteRoleTable() {
            verify(Source.MeoTheme.hasCompleteColorScheme(Source.MeoTheme.fallbackLightColorScheme))
            verify(Source.MeoTheme.hasCompleteColorScheme(Source.MeoTheme.fallbackDarkColorScheme))
            compare(String(Source.MeoTheme.fallbackLightColorScheme.surface).toLowerCase(), "#fdf7ff")
            compare(String(Source.MeoTheme.fallbackDarkColorScheme.surface).toLowerCase(), "#141218")
            verify(contrastRatio(Source.MeoTheme.fallbackLightColorScheme.surface,
                                 Source.MeoTheme.fallbackLightColorScheme.onSurface) >= 4.5)
            verify(contrastRatio(Source.MeoTheme.fallbackDarkColorScheme.surface,
                                 Source.MeoTheme.fallbackDarkColorScheme.onSurface) >= 4.5)
        }

        function test_dynamicPairChangesWithAppearance() {
            const light = JSON.parse(JSON.stringify(Source.MeoTheme.fallbackLightColorScheme))
            const dark = JSON.parse(JSON.stringify(Source.MeoTheme.fallbackDarkColorScheme))
            light.primary = "#0058A8"
            dark.primary = "#B4C5FF"

            verify(Source.MeoTheme.applyDynamicColorSchemes(light, dark, "source-theme-test"))
            Source.MeoTheme.isDarkMode = false
            compare(String(Source.MeoTheme.primary).toLowerCase(), "#0058a8")

            Source.MeoTheme.isDarkMode = true
            compare(String(Source.MeoTheme.primary).toLowerCase(), "#b4c5ff")
            compare(String(Source.MeoTheme.surface).toLowerCase(), "#141218")
        }

        function test_singleSchemeDoesNotLeakIntoTheOtherAppearance() {
            const light = JSON.parse(JSON.stringify(Source.MeoTheme.fallbackLightColorScheme))
            light.primary = "#0061A4"

            Source.MeoTheme.isDarkMode = false
            verify(Source.MeoTheme.applyDynamicColorScheme(light, "source-single-test", false))
            compare(String(Source.MeoTheme.primary).toLowerCase(), "#0061a4")

            Source.MeoTheme.isDarkMode = true
            compare(String(Source.MeoTheme.primary).toLowerCase(),
                    String(Source.MeoTheme.fallbackDarkColorScheme.primary).toLowerCase())
        }

        function test_motionSchemeMatchesAndroidXMaterial3Tokens() {
            Source.MeoTheme.isExpressive = false
            compare(Source.MeoMotion.defaultSpatial.dampingRatio, 0.9)
            compare(Source.MeoMotion.defaultSpatial.stiffness, 700)
            compare(Source.MeoMotion.fastSpatial.stiffness, 1400)
            compare(Source.MeoMotion.slowSpatial.stiffness, 300)
            compare(Source.MeoMotion.defaultEffects.dampingRatio, 1.0)
            compare(Source.MeoMotion.defaultEffects.stiffness, 1600)
            compare(Source.MeoMotion.fastEffects.stiffness, 3800)
            compare(Source.MeoMotion.slowEffects.stiffness, 800)

            Source.MeoTheme.isExpressive = true
            compare(Source.MeoMotion.defaultSpatial.dampingRatio, 0.8)
            compare(Source.MeoMotion.defaultSpatial.stiffness, 380)
            compare(Source.MeoMotion.fastSpatial.dampingRatio, 0.6)
            compare(Source.MeoMotion.fastSpatial.stiffness, 800)
            compare(Source.MeoMotion.slowSpatial.dampingRatio, 0.8)
            compare(Source.MeoMotion.slowSpatial.stiffness, 200)
            compare(Source.MeoMotion.defaultEffects.stiffness, 1600)
        }

        function test_motionSamplerHasCorrectEndpointsAndSettles() {
            const spec = Source.MeoMotion.standardDefaultSpatial
            const initial = Source.MeoMotion.stateAt(spec, 0, 0, 1, 0)
            compare(initial.value, 0)
            compare(initial.velocity, 0)

            const settled = Source.MeoMotion.stateAt(spec, 0, 0, 1, 1000)
            verify(Source.MeoMotion.isAtRest(settled, 1, 0.005, 0.01))
        }
    }
}
