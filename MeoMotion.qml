pragma Singleton

import QtQuick
import MeoUI

// Material motion tokens and analytic spring sampling.
//
// Source reference (Apache-2.0): AndroidX Compose Material3 MotionScheme.kt,
// StandardMotionTokens.kt and ExpressiveMotionTokens.kt at androidx-main
// bf48f4c018c001f2b10baab00a2710ab283fed0f. The equations below are an
// independent QML implementation of the damped-harmonic solution documented
// by AndroidX SpringSimulation.kt; no upstream source is copied.
QtObject {
    id: motion

    readonly property string androidxRevision: "bf48f4c018c001f2b10baab00a2710ab283fed0f"
    readonly property string androidxMotionSource: "androidx.compose.material3.MotionScheme"
    readonly property bool isExpressive: MeoTheme.isExpressive

    function springSpec(dampingRatio, stiffness) {
        return ({ "dampingRatio": dampingRatio, "stiffness": stiffness, "mass": 1.0 })
    }

    readonly property var standardDefaultSpatial: springSpec(0.9, 700)
    readonly property var standardFastSpatial: springSpec(0.9, 1400)
    readonly property var standardSlowSpatial: springSpec(0.9, 300)
    readonly property var standardDefaultEffects: springSpec(1.0, 1600)
    readonly property var standardFastEffects: springSpec(1.0, 3800)
    readonly property var standardSlowEffects: springSpec(1.0, 800)

    readonly property var expressiveDefaultSpatial: springSpec(0.8, 380)
    readonly property var expressiveFastSpatial: springSpec(0.6, 800)
    readonly property var expressiveSlowSpatial: springSpec(0.8, 200)
    readonly property var expressiveDefaultEffects: springSpec(1.0, 1600)
    readonly property var expressiveFastEffects: springSpec(1.0, 3800)
    readonly property var expressiveSlowEffects: springSpec(1.0, 800)

    readonly property var defaultSpatial: isExpressive ? expressiveDefaultSpatial : standardDefaultSpatial
    readonly property var fastSpatial: isExpressive ? expressiveFastSpatial : standardFastSpatial
    readonly property var slowSpatial: isExpressive ? expressiveSlowSpatial : standardSlowSpatial
    readonly property var defaultEffects: isExpressive ? expressiveDefaultEffects : standardDefaultEffects
    readonly property var fastEffects: isExpressive ? expressiveFastEffects : standardFastEffects
    readonly property var slowEffects: isExpressive ? expressiveSlowEffects : standardSlowEffects

    // Returns value and velocity after elapsedMilliseconds for a unit-mass spec.
    function stateAt(spec, value, velocity, target, elapsedMilliseconds) {
        const elapsedSeconds = Math.max(0, elapsedMilliseconds) / 1000.0
        const ratio = Math.max(0, Number(spec.dampingRatio))
        const frequency = Math.sqrt(Math.max(0.000001, Number(spec.stiffness)))
        const initialDisplacement = value - target
        const decay = -ratio * frequency
        let displacement
        let currentVelocity

        if (ratio > 1.0) {
            const root = frequency * Math.sqrt(ratio * ratio - 1.0)
            const positiveGamma = decay + root
            const negativeGamma = decay - root
            const coefficientB = (negativeGamma * initialDisplacement - velocity)
                    / (negativeGamma - positiveGamma)
            const coefficientA = initialDisplacement - coefficientB
            const negativeTerm = Math.exp(negativeGamma * elapsedSeconds)
            const positiveTerm = Math.exp(positiveGamma * elapsedSeconds)
            displacement = coefficientA * negativeTerm + coefficientB * positiveTerm
            currentVelocity = coefficientA * negativeGamma * negativeTerm
                    + coefficientB * positiveGamma * positiveTerm
        } else if (Math.abs(ratio - 1.0) < 0.000001) {
            const coefficientA = initialDisplacement
            const coefficientB = velocity + frequency * initialDisplacement
            const decayTerm = Math.exp(-frequency * elapsedSeconds)
            displacement = (coefficientA + coefficientB * elapsedSeconds) * decayTerm
            currentVelocity = (coefficientB
                    - frequency * (coefficientA + coefficientB * elapsedSeconds)) * decayTerm
        } else {
            const dampedFrequency = frequency * Math.sqrt(1.0 - ratio * ratio)
            const cosineCoefficient = initialDisplacement
            const sineCoefficient = (velocity - decay * initialDisplacement) / dampedFrequency
            const decayTerm = Math.exp(decay * elapsedSeconds)
            const sine = Math.sin(dampedFrequency * elapsedSeconds)
            const cosine = Math.cos(dampedFrequency * elapsedSeconds)
            displacement = decayTerm * (cosineCoefficient * cosine + sineCoefficient * sine)
            currentVelocity = displacement * decay
                    + decayTerm * (-dampedFrequency * cosineCoefficient * sine
                                   + dampedFrequency * sineCoefficient * cosine)
        }

        return ({ "value": displacement + target, "velocity": currentVelocity })
    }

    function isAtRest(state, target, valueThreshold, velocityThreshold) {
        return Math.abs(state.value - target) <= valueThreshold
                && Math.abs(state.velocity) <= velocityThreshold
    }
}
