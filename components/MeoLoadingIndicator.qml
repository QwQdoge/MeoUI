import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 M3 Expressive Loading Indicator Specification
    // Variant: "uncontained" (default) | "contained"
    property string variant: "uncontained"
    property bool vibrant: false
    property real value: 0.0 // 0.0 ~ 1.0 for determinate mode
    property bool indeterminate: true
    property bool running: true
    property bool withContainer: variant === "contained"
    property string size: "m" // "xs" (24dp) | "s" (32dp) | "m" (48dp) | "l" (64dp) | "xl" (72dp)
    property color color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    property color containerColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property real themeMotionScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionScale !== 'undefined') ? MeoTheme.motionScale : 1.0
    readonly property bool reduceMotion: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.reduceMotion !== 'undefined') ? MeoTheme.reduceMotion : false

    // Official M3E Timing Constants
    readonly property int morphInterval: Math.round(650 * themeMotionScale)
    readonly property int globalRotationDuration: reduceMotion ? 0 : Math.round(4666 * themeMotionScale)

    // Official 7-Shape Sequence
    readonly property var shapeSequence: ["SoftBurst", "Cookie9Sided", "Pentagon", "Pill", "Sunny", "Cookie4Sided", "Oval", "SoftBurst"]

    implicitWidth: {
        if (size === "xs") return 24 * themeGlobalScale;
        if (size === "s") return 32 * themeGlobalScale;
        if (size === "l") return 64 * themeGlobalScale;
        if (size === "xl") return 72 * themeGlobalScale;
        return 48 * themeGlobalScale; // M3E standard 48dp
    }
    implicitHeight: implicitWidth

    contentItem: Item {
        id: container
        anchors.fill: parent

        // Outer 48dp Container (for Contained Loader)
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            visible: control.withContainer || control.variant === "contained"
            color: control.containerColor
        }

        // Active Morphing Shape Item (38dp nominal inside 48dp container = ~79.2%)
        Item {
            id: activeArea
            width: (control.withContainer || control.variant === "contained") ? parent.width * 0.7917 : parent.width
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
                anchors.fill: parent
                color: (control.withContainer || control.variant === "contained")
                       ? ((typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D")
                       : control.color
                fromShape: control.shapeSequence[morphSequenceIndex]
                toShape: control.shapeSequence[(morphSequenceIndex + 1) % (control.shapeSequence.length - 1)]
                morphProgress: morphStepProgress
                rawSpringProgress: morphStepProgress
                rotationAngle: localStepRotation

                property int morphSequenceIndex: 0
                property real morphStepProgress: 0.0
                property real localStepRotation: 0.0

                // Sequential Indeterminate Morphing (650ms per step + 90° local rotation)
                SequentialAnimation {
                    running: control.running && control.indeterminate && control.visible
                    loops: Animation.Infinite

                    ParallelAnimation {
                        NumberAnimation {
                            target: morpher
                            property: "morphStepProgress"
                            from: 0.0
                            to: 1.0
                            duration: control.morphInterval
                            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSpringBouncy !== 'undefined') ? MeoTheme.motionEasingSpringBouncy : [0.34, 1.35, 0.64, 1.0]
                        }
                        NumberAnimation {
                            target: morpher
                            property: "localStepRotation"
                            from: morpher.morphSequenceIndex * 90
                            to: (morpher.morphSequenceIndex + 1) * 90
                            duration: control.morphInterval
                            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.05, 0.7, 0.1, 1]
                        }
                    }

                    ScriptAction {
                        script: {
                            morpher.morphSequenceIndex = (morpher.morphSequenceIndex + 1) % (control.shapeSequence.length - 1);
                            morpher.morphStepProgress = 0.0;
                        }
                    }
                }

                // Determinate Mode: Circle (18° initial) -> SoftBurst with -180° x progress rotation
                Binding {
                    target: morpher
                    property: "fromShape"
                    value: "Circle"
                    when: !control.indeterminate
                }
                Binding {
                    target: morpher
                    property: "toShape"
                    value: "SoftBurst"
                    when: !control.indeterminate
                }
                Binding {
                    target: morpher
                    property: "morphStepProgress"
                    value: Math.max(0.0, Math.min(1.0, control.value))
                    when: !control.indeterminate
                }
                Binding {
                    target: morpher
                    property: "localStepRotation"
                    value: 18.0 - 180.0 * Math.max(0.0, Math.min(1.0, control.value))
                    when: !control.indeterminate
                }
            }
        }
    }
}
