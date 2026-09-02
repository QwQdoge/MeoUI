import QtQuick
import MeoUI

Item {
    id: control
    default property alias content: contentLayer.data
    property string type: "elevated"
    property bool interactive: true
    property bool bouncy: true
    property color color: MeoTheme.surfaceContainerLowest
    property real radius: MeoTheme.shapeExtraLarge
    property int elevation: 2
    property real entranceDistance: 40 * MeoTheme.globalScale
    property bool animateOnCompleted: false
    property int entranceDirection: 1
    property real motionOffset: 0
    property real entranceStartedAt: 0
    property real entranceOpacityStart: 1
    property real entranceScaleStart: 1
    property real entranceOffsetStart: 0

    readonly property var entranceSpatialSpec: MeoMotion.defaultSpatial
    readonly property var entranceEffectsSpec: MeoMotion.defaultEffects

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
        entranceStartedAt = Date.now()
        advanceEntrance()
        entranceDriver.start()
    }

    function advanceEntrance() {
        const elapsed = Math.max(0, Date.now() - entranceStartedAt)
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

    transform: Translate { x: control.motionOffset }
    Rectangle {
        x: 0; y: control.elevation * 4
        width: parent.width; height: parent.height
        radius: control.radius
        color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b, control.elevation > 0 ? 0.055 : 0)
        opacity: control.elevation > 0 ? 1 : 0
        Behavior on color {
            ColorAnimation {
                duration: MeoTheme.motionDurationEffectSlow
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }
    Rectangle {
        x: 0; y: control.elevation * 2
        width: parent.width; height: parent.height
        radius: control.radius
        color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b, control.elevation > 0 ? 0.065 : 0)
        opacity: control.elevation > 0 ? 1 : 0
        Behavior on color {
            ColorAnimation {
                duration: MeoTheme.motionDurationEffectSlow
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: control.radius
        color: control.color
        border.width: 1
        border.color: Qt.rgba(MeoTheme.outline.r, MeoTheme.outline.g, MeoTheme.outline.b, 0.16)
        Behavior on radius { NumberAnimation { duration: MeoTheme.motionDurationMedium1; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
        Behavior on color {
            ColorAnimation {
                duration: MeoTheme.motionDurationEffectSlow
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: MeoTheme.motionDurationEffectSlow
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }
    Item { id: contentLayer; anchors.fill: parent }

    Component.onCompleted: if (animateOnCompleted) reveal(entranceDirection)
    Timer {
        id: entranceDriver
        interval: 16
        repeat: true
        onTriggered: control.advanceEntrance()
    }
}
