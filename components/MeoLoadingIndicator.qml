import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // Material 3 Expressive exposes exactly two configurations: default and
    // contained.  The default's active shape uses primary; the contained
    // configuration uses primaryContainer with onPrimaryContainer.
    property string variant: "default" // "default" | "contained"
    // Kept for source compatibility. Loading colors remain the single M3
    // token set instead of becoming a separate expressive color variant.
    property bool vibrant: false
    property real value: 0.0 // 0.0 ~ 1.0 for determinate mode
    property bool indeterminate: true
    property bool running: true
    // Compatibility bridge for existing Meo controls. New callers should use
    // variant: "contained" so containment remains explicit in the API.
    property bool withContainer: false
    // Kept as a source-compatible input only. The M3 Expressive Loading
    // Indicator has one fixed 48dp container; scaling it creates a different
    // control rather than an official size variant.
    property string size: "m"
    property color color: MeoTheme.primary
    property color containerColor: MeoTheme.primaryContainer

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real themeMotionScale: MeoTheme.motionScale
    readonly property bool reduceMotion: MeoTheme.reduceMotion
    readonly property bool isContained: variant === "contained" || withContainer
    readonly property color activeIndicatorColor: isContained ? MeoTheme.contentOnPrimaryContainer : color

    // AndroidX keeps one 650ms cadence between individual morphs while the
    // shape itself settles with a low-damping spring.  The cadence and the
    // rotation duration are public implementation constants, not local UI
    // guesses.  Source: androidx-main cb385ff0850af6dd89bdea7f9df340fe4950a6eb,
    // LoadingIndicator.kt (Apache-2.0), independently expressed through
    // MeoMotion's analytic spring sampler.
    readonly property int morphInterval: Math.max(1, Math.round(650 * themeMotionScale))
    readonly property int globalRotationDuration: Math.max(1, Math.round(4666 * themeMotionScale))
    readonly property var morphSpring: MeoMotion.springSpec(0.6, 200)

    // Official 7-Shape Sequence
    readonly property var shapeSequence: ["SoftBurst", "Cookie9Sided", "Pentagon", "Pill", "Sunny", "Cookie4Sided", "Oval", "SoftBurst"]
    // AndroidX Material3 LoadingIndicator begins the indeterminate morph at
    // QuarterRotation (90°), then advances one quarter-turn per shape pair.
    readonly property real indeterminateInitialRotation: 90.0
    readonly property real clampedProgress: Math.max(0.0, Math.min(1.0, value))

    implicitWidth: 48 * themeGlobalScale
    implicitHeight: implicitWidth
    Accessible.name: indeterminate ? qsTr("Loading")
                                : qsTr("Loading progress %1 percent").arg(Math.round(Math.max(0, Math.min(1, value)) * 100))
    Accessible.role: Accessible.ProgressBar

    function resetIndeterminatePose() {
        globalRotationAnimation.currentAngle = 0
        morpher.resetIndeterminateMorph()
    }

    onReduceMotionChanged: {
        if (reduceMotion)
            resetIndeterminatePose()
    }
    onRunningChanged: resetIndeterminatePose()
    onIndeterminateChanged: resetIndeterminatePose()

    contentItem: Item {
        id: container
        anchors.fill: parent

        // Outer 48dp Container (for Contained Loader)
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            visible: control.isContained
            color: control.containerColor
        }

        // M3E specifies a 38dp active shape inside the 48dp indicator bounds.
        // Keep that ratio at every supported desktop scale/size.
        Item {
            id: activeArea
            objectName: "meoLoadingActiveArea"
            width: Math.min(parent.width, parent.height) * (38 / 48)
            height: width
            anchors.centerIn: parent

            // Continuous Global Rotation (360° / 4666ms)
            rotation: globalRotationAnimation.currentAngle

            Item {
                id: globalRotationAnimation
                property real currentAngle: 0.0

                NumberAnimation on currentAngle {
                    running: control.running && control.indeterminate && !control.reduceMotion && control.visible
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: control.globalRotationDuration
                }
            }

            // M3E Morph Engine Component
            MeoShapeMorph {
                id: morpher
                objectName: "meoLoadingMorpher"
                anchors.fill: parent
                color: control.activeIndicatorColor
                fromShape: control.indeterminate
                           ? control.shapeSequence[morphSequenceIndex]
                           : "Circle"
                toShape: control.indeterminate
                         ? control.shapeSequence[(morphSequenceIndex + 1) % (control.shapeSequence.length - 1)]
                         : "SoftBurst"
                morphProgress: control.indeterminate ? morphStepProgress : control.clampedProgress
                rawSpringProgress: control.indeterminate ? rawMorphProgress : control.clampedProgress
                rotationAngle: control.indeterminate
                               ? localStepRotation
                               : 18.0 - 180.0 * control.clampedProgress

                property int morphSequenceIndex: 0
                property real morphStepProgress: 0.0
                property real rawMorphProgress: 0.0
                property real localStepRotation: 0.0
                property double morphStartedAt: 0

                function resetIndeterminateMorph() {
                    morphSequenceIndex = 0
                    morphStepProgress = 0.0
                    rawMorphProgress = 0.0
                    localStepRotation = control.indeterminateInitialRotation
                    morphStartedAt = Date.now()
                }

                // The AndroidX path morph clamps its spring value to avoid
                // folding, but retains the raw spring for rotation/scale.
                // Sample the shared unit-mass motion implementation instead
                // of flattening this expressive spring into a Bezier curve.
                Timer {
                    id: morphTimer
                    interval: 16
                    repeat: true
                    running: control.running && control.indeterminate
                             && control.visible && !control.reduceMotion
                    onRunningChanged: {
                        if (running)
                            morpher.resetIndeterminateMorph()
                    }
                    onTriggered: {
                        const elapsed = Date.now() - morpher.morphStartedAt
                        const springState = MeoMotion.stateAt(
                                    control.morphSpring, 0.0, 0.0, 1.0, elapsed)
                        morpher.rawMorphProgress = springState.value
                        morpher.morphStepProgress = Math.max(0.0, Math.min(1.0, springState.value))
                        morpher.localStepRotation = control.indeterminateInitialRotation
                                + morpher.morphSequenceIndex * 90
                                + springState.value * 90

                        if (elapsed >= control.morphInterval) {
                            morpher.morphSequenceIndex = (morpher.morphSequenceIndex + 1)
                                    % (control.shapeSequence.length - 1)
                            morpher.morphStepProgress = 0.0
                            morpher.rawMorphProgress = 0.0
                            morpher.localStepRotation = control.indeterminateInitialRotation
                                    + morpher.morphSequenceIndex * 90
                            morpher.morphStartedAt = Date.now()
                        }
                    }
                }

                Component.onCompleted: resetIndeterminateMorph()
            }
        }
    }
}
