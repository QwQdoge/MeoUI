// List transition lifecycle adapted from DankMaterialShell's
// ListViewTransitions.qml (MIT, Copyright 2025 Avenge Media LLC).
// Reimplemented with MeoTheme tokens; no Quickshell or DMS helper imports.
pragma Singleton

import QtQuick
import MeoUI

QtObject {
    id: root

    readonly property var theme: MeoTheme
    readonly property bool enabled: !theme.reduceMotion && theme.motionDurationListInsert > 0
    readonly property real insertOffset: 8 * theme.globalScale
    readonly property int staggerDelay: theme.motionListStaggerDelay
    readonly property int staggerCap: theme.motionListStaggerCap

    readonly property var add: enabled ? addTransition : null
    readonly property var remove: enabled ? removeTransition : null
    readonly property var displaced: enabled ? displacedTransition : null
    readonly property var move: enabled ? moveTransition : null

    readonly property Transition addTransition: Transition {
        id: addTransition
        SequentialAnimation {
            PropertyAction { property: "opacity"; value: 0 }
            PropertyAction { property: "y"; value: ViewTransition.item.y - root.insertOffset }
            PauseAnimation {
                duration: Math.max(0, Math.min(addTransition.ViewTransition.index
                    - (addTransition.ViewTransition.targetIndexes[0] || 0), root.staggerCap)) * root.staggerDelay
            }
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"; to: 1; duration: root.theme.motionDurationListInsert
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandardDecelerate
                }
                NumberAnimation {
                    property: "y"; duration: root.theme.motionDurationListInsert
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandardDecelerate
                }
            }
        }
    }

    readonly property Transition removeTransition: Transition {
        NumberAnimation {
            property: "opacity"; to: 0; duration: root.theme.motionDurationListRemove
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandardAccelerate
        }
    }

    readonly property Transition displacedTransition: Transition {
        ParallelAnimation {
            NumberAnimation {
                properties: "x,y"; duration: root.theme.motionDurationListDisplaced
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
            }
            NumberAnimation {
                property: "opacity"; to: 1; duration: root.theme.motionDurationListDisplaced
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }

    readonly property Transition moveTransition: displacedTransition
}
