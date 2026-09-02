import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 520
    height: 180

    Components.MeoProgressBar {
        id: progress
        width: 240
        value: 0.42
    }

    TestCase {
        name: "MeoProgressBar"
        when: windowShown

        function init() {
            progress.type = "linear"
            progress.value = 0.42
            progress.indeterminate = false
            progress.showTrack = true
            progress.isThick = false
            progress.linearStyle = "standard"
            progress.leadingIcon = ""
            progress.wavy = false
        }

        function test_standardLinearIsContinuousAndClamped() {
            const standard = findChild(progress, "meoProgressStandardLinear")
            const track = findChild(progress, "meoProgressStandardTrack")
            const segment = findChild(progress, "meoProgressDeterminateSegment")
            const endStop = findChild(progress, "meoProgressLinearEndStop")
            verify(standard !== null)
            verify(track !== null)
            verify(segment !== null)
            verify(endStop !== null)
            verify(standard.visible)
            verify(track.visible)
            verify(segment.visible)
            verify(endStop.visible)
            compare(Math.round(progress.implicitHeight), Math.round(4 * progress.themeGlobalScale))
            compare(Math.round(endStop.width), Math.round(4 * progress.themeGlobalScale))
            compare(Math.round(track.x - segment.width),
                    Math.round(Math.min(segment.width, 4 * progress.themeGlobalScale)))

            progress.value = -1
            compare(progress.clampedValue, 0)
            verify(!segment.visible)
            progress.value = 2
            compare(progress.clampedValue, 1)
            verify(progress.Accessible.name.indexOf("100") !== -1)
        }

        function test_rtlFillsFromTheInlineStart() {
            const segment = findChild(progress, "meoProgressDeterminateSegment")
            progress.LayoutMirroring.enabled = true
            progress.LayoutMirroring.childrenInherit = true
            progress.value = 0.25
            verify(progress.mirrored)
            verify(segment.x > 0)
            progress.LayoutMirroring.enabled = false
            progress.LayoutMirroring.childrenInherit = false
        }

        function test_indeterminateLinearUsesSourceTimedTwoSegments() {
            progress.indeterminate = true
            const firstSegment = findChild(progress, "meoProgressIndeterminateSegment")
            const secondSegment = findChild(progress, "meoProgressIndeterminateSegment2")
            const stop = findChild(progress, "meoProgressLinearEndStop")
            verify(firstSegment !== null)
            verify(secondSegment !== null)
            verify(firstSegment.visible)
            verify(secondSegment.visible)
            verify(!stop.visible)
            compare(Math.round(progress.indeterminateLinearElapsed),
                    Math.round(progress.indeterminateLinearPhase * 1750))
            wait(20)
            verify(progress.firstLineHead >= progress.firstLineTail)
            verify(progress.secondLineHead >= progress.secondLineTail)
        }

        function test_expressivePillIsExplicitAndKeepsBoundsStable() {
            progress.isThick = true
            compare(Math.round(progress.implicitHeight), Math.round(8 * progress.themeGlobalScale))

            progress.linearStyle = "pill"
            progress.leadingIcon = "pause"
            const pill = findChild(progress, "meoProgressPill")
            const marker = findChild(progress, "meoProgressPillMarker")
            verify(pill !== null)
            verify(marker !== null)
            verify(pill.visible)
            verify(marker.visible)
            compare(Math.round(progress.implicitHeight), Math.round(progress.pillMarkerHeight))
        }

        function test_circularDeterminateAndIndeterminate() {
            progress.type = "circular"
            const circular = findChild(progress, "meoProgressCircular")
            const canvas = findChild(progress, "meoProgressCircularCanvas")
            verify(circular !== null)
            verify(canvas !== null)
            verify(circular.visible)
            compare(Math.round(progress.implicitWidth), Math.round(40 * progress.themeGlobalScale))
            verify(progress.circularTrackGapSweepDegrees(progress.implicitWidth,
                                                         progress.strokeThickness) > 0)
            verify(progress.circularDeterminateTrackSweepDegrees(progress.implicitWidth,
                                                                  progress.strokeThickness) < 360)

            progress.isThick = true
            compare(Math.round(progress.implicitWidth), Math.round(44 * progress.themeGlobalScale))

            progress.indeterminate = true
            verify(circular.visible)
            verify(canvas.indeterminateArcLength > 0)
            verify(!circular.sourceDrawsTrack)
        }

        function test_wavyIsAnOptInExpressiveConfiguration() {
            progress.wavy = true
            const canvas = findChild(progress, "meoProgressWavyCanvas")
            verify(canvas !== null)
            verify(canvas.visible)
            compare(Math.round(progress.implicitHeight), Math.round(10 * progress.themeGlobalScale))
            compare(Math.round(progress.indeterminateLinearWavelength), Math.round(20 * progress.themeGlobalScale))
            compare(Math.round(progress.wavyTrackStart - progress.wavyActiveWidth),
                    Math.round(4 * progress.themeGlobalScale))

            progress.isThick = true
            compare(Math.round(progress.implicitHeight), Math.round(14 * progress.themeGlobalScale))

            progress.type = "circular"
            compare(Math.round(progress.implicitWidth), Math.round(52 * progress.themeGlobalScale))
            compare(Math.round(progress.implicitHeight), Math.round(52 * progress.themeGlobalScale))
            compare(progress.circularAmplitude, 1.6 * progress.themeGlobalScale)
        }

        function test_wavyTrackGapCollapsesAtZeroProgress() {
            progress.wavy = true
            progress.type = "linear"
            progress.value = 0
            compare(Math.round(progress.wavyActiveWidth), 0)
            compare(Math.round(progress.wavyTrackStart), 0)
        }
    }
}
