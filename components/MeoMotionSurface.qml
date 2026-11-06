import QtQuick
import MeoUI

Item {
    id: control
    default property alias content: contentLayer.data
    property string type: "elevated"
    property bool interactive: true
    property bool bouncy: true
    property string surfaceStyle: "theme" // theme | flat | tonal | translucent
    // A surface outline is a hierarchy cue, never the focus indicator. Keep
    // the historical default for compatibility; transient tonal hosts can opt
    // out and rely on their semantic surface/elevation instead.
    property bool showOutline: true
    property real surfaceOpacity: 1.0
    property string motionProfile: "pixel"
    property color color: MeoTheme.surfaceContainerLowest
    property real radius: MeoTheme.shapeExtraLarge
    property int elevation: 2
    property real entranceDistance: 40 * MeoTheme.globalScale
    // Reusable reveal direction for popouts, cards, panes, and transient
    // surfaces. Existing users keep the historical horizontal default.
    property string entranceAxis: "x" // x | y
    property bool animateOnCompleted: false
    property int entranceDirection: 1
    property real motionOffset: 0
    property real entranceStartedAt: 0
    property real _entranceLastTickAt: 0
    property real entranceOpacityStart: 1
    property real entranceScaleStart: 1
    property real entranceOffsetStart: 0

    readonly property var entranceSpatialSpec: MeoMotion.spatialSpec(motionProfile, "default")
    readonly property var entranceEffectsSpec: MeoMotion.effectsSpec("default")
    readonly property color resolvedColor: {
        const semantic = surfaceStyle === "flat" ? MeoTheme.surface
                       : surfaceStyle === "tonal" ? MeoTheme.surfaceContainer
                       : color
        const opacity = surfaceStyle === "translucent"
                        ? MeoTheme.surfaceAlpha(Math.max(0.7, Math.min(1, surfaceOpacity))) : 1
        return Qt.rgba(semantic.r, semantic.g, semantic.b, opacity)
    }

    function reveal(direction) {
        entranceDirection = direction === 0 ? 1 : direction
        entranceDriver.stop()
        opacity = 0
        scale = 0.985
        motionOffset = entranceDistance * entranceDirection
        if (MeoTheme.reduceMotion) {
            opacity = 1
            scale = 1
            motionOffset = 0
            return
        }
        entranceOpacityStart = opacity
        entranceScaleStart = scale
        entranceOffsetStart = motionOffset
        // Anchored on the first rendered frame in advanceEntrance().
        entranceStartedAt = 0
        advanceEntrance()
        entranceDriver.start()
    }

    function advanceEntrance() {
        const now = Date.now()
        if (entranceStartedAt <= 0) {
            entranceStartedAt = now - 16
            _entranceLastTickAt = now - 16
        }
        // Pause over stalls instead of skipping motion (see MeoSpringValue).
        const gap = now - _entranceLastTickAt
        if (gap > 64)
            entranceStartedAt += gap - 16
        _entranceLastTickAt = now
        const elapsed = Math.max(0, now - entranceStartedAt)
        const opacityState = MeoMotion.stateAt(entranceEffectsSpec,
                                               entranceOpacityStart, 0, 1, elapsed)
        const scaleState = MeoMotion.stateAt(entranceSpatialSpec,
                                             entranceScaleStart, 0, 1, elapsed)
        const offsetState = MeoMotion.stateAt(entranceSpatialSpec,
                                              entranceOffsetStart, 0, 0, elapsed)
        opacity = opacityState.value
        scale = scaleState.value
        motionOffset = offsetState.value

        if (MeoMotion.isAtRest(opacityState, 1, 0.005, 0.005)
                && MeoMotion.isAtRest(scaleState, 1, 0.002, 0.01)
                && MeoMotion.isAtRest(offsetState, 0, 0.25, 0.25)) {
            opacity = 1
            scale = 1
            motionOffset = 0
            entranceDriver.stop()
        }
    }

    transform: Translate {
        x: control.entranceAxis === "y" ? 0 : control.motionOffset
        y: control.entranceAxis === "y" ? control.motionOffset : 0
    }
    // M3 elevation level (0-5) through the shared shadow model, replacing
    // two hard-edged offset rectangles.
    MeoElevationShadow {
        target: surfaceContainer
        elevation: [MeoTheme.elevationLevel0, MeoTheme.elevationLevel1, MeoTheme.elevationLevel2,
                    MeoTheme.elevationLevel3, MeoTheme.elevationLevel4,
                    MeoTheme.elevationLevel5][Math.max(0, Math.min(5, control.elevation))]
        radius: surfaceContainer.radius
        Behavior on elevation {
            NumberAnimation { duration: MeoTheme.motionDurationEffectSlow; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard }
        }
    }
    Rectangle {
        id: surfaceContainer
        objectName: "meoMotionSurfaceContainer"
        anchors.fill: parent
        radius: control.radius
        color: control.resolvedColor
        border.width: control.showOutline ? MeoTheme.strokeWidthThin : 0
        border.color: control.showOutline
                      ? Qt.rgba(MeoTheme.outline.r, MeoTheme.outline.g,
                                MeoTheme.outline.b, 0.16)
                      : "transparent"
        Behavior on radius { NumberAnimation { duration: MeoTheme.motionDurationMedium1; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
        Behavior on color {
            ColorAnimation {
                duration: MeoTheme.motionDurationEffectSlow
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: MeoTheme.motionDurationEffectSlow
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }
    Item { id: contentLayer; anchors.fill: parent }

    Component.onCompleted: if (animateOnCompleted) reveal(entranceDirection)
    // Sampled once per rendered frame (vsync-aligned) like MeoSpringValue.
    FrameAnimation {
        id: entranceDriver
        onTriggered: control.advanceEntrance()
    }
}
