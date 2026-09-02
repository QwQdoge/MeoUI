import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property Component content: null
    property Component leftAction: null
    property Component rightAction: null
    // Legacy ratio override. Leave at -1 to use AndroidX's 56dp default
    // positional threshold; retain ratio support for existing callers.
    property real swipeThreshold: -1
    property real positionalThreshold: 56 * themeGlobalScale
    property bool gesturesEnabled: true
    property bool dismissed: false

    // Logical alternatives supplement the existing physical left/right API.
    property Component startToEndAction: null
    property Component endToStartAction: null

    signal leftActionTriggered()
    signal rightActionTriggered()
    signal dismissedInDirection(string direction)

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: contentLoader.implicitHeight

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool reducedMotion: MeoTheme.reduceMotion
    readonly property bool isRightToLeft: Qt.application.layoutDirection === Qt.RightToLeft
    readonly property Component effectiveLeftAction: isRightToLeft
                                                  ? (endToStartAction || rightAction)
                                                  : (startToEndAction || leftAction)
    readonly property Component effectiveRightAction: isRightToLeft
                                                   ? (startToEndAction || leftAction)
                                                   : (endToStartAction || rightAction)
    readonly property bool canSwipeRight: effectiveLeftAction !== null
    readonly property bool canSwipeLeft: effectiveRightAction !== null
    readonly property bool canSwipeStartToEnd: isRightToLeft ? canSwipeLeft : canSwipeRight
    readonly property bool canSwipeEndToStart: isRightToLeft ? canSwipeRight : canSwipeLeft
    readonly property real thresholdDistance: swipeThreshold >= 0
                                                  ? width * swipeThreshold
                                                  : positionalThreshold

    function restore() {
        dismissed = false
        contentItem.x = 0
    }

    // 🎨 Background Actions Layer
    Item {
        id: backgroundActions
        anchors.fill: parent
        visible: contentItem.x !== 0

        // Left Action Background (e.g. Archive)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.horizontalCenter
            height: parent.height
            color: MeoTheme.primary
            visible: contentItem.x > 0

            Loader {
                anchors.left: parent.left
                anchors.leftMargin: 24 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: control.effectiveLeftAction
            }
        }

        // Right Action Background (e.g. Delete)
        Rectangle {
            anchors.left: parent.horizontalCenter
            anchors.right: parent.right
            height: parent.height
            color: MeoTheme.error
            visible: contentItem.x < 0

            Loader {
                anchors.right: parent.right
                anchors.rightMargin: 24 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: control.effectiveRightAction
            }
        }
    }

    // 📦 Foreground Content Layer
    Item {
        id: contentItem
        width: parent.width
        height: parent.height
        clip: true
        opacity: control.enabled ? 1 : 0.38

        Behavior on opacity {
            enabled: !control.reducedMotion
            NumberAnimation { duration: MeoTheme.motionDurationEffectDefault; easing.bezierCurve: MeoTheme.motionEasingStandard }
        }

        Rectangle {
            anchors.fill: parent
            color: MeoTheme.surface
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
            sourceComponent: control.content
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: contentItem
            drag.axis: Drag.XAxis
            drag.minimumX: control.canSwipeLeft ? -control.width : 0
            drag.maximumX: control.canSwipeRight ? control.width : 0
            enabled: control.enabled && control.gesturesEnabled && !control.dismissed

            onReleased: {
                if (control.canSwipeRight && contentItem.x > control.thresholdDistance) {
                    // Trigger Left Action & Dismiss
                    dismissToRight.start()
                } else if (control.canSwipeLeft && contentItem.x < -control.thresholdDistance) {
                    // Trigger Right Action & Dismiss
                    dismissToLeft.start()
                } else {
                    // Snap back
                    snapBack.start()
                }
            }
        }

        NumberAnimation {
            id: snapBack
            target: contentItem
            property: "x"
            to: 0
            duration: control.reducedMotion ? 0 : MeoTheme.motionDurationSelection
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }

        NumberAnimation {
            id: dismissToRight
            target: contentItem
            property: "x"
            to: control.width
            duration: control.reducedMotion ? 0 : MeoTheme.motionDurationSelection
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            onFinished: {
                control.leftActionTriggered()
                control.dismissedInDirection(control.isRightToLeft ? "endToStart" : "startToEnd")
                control.dismissed = true
            }
        }

        NumberAnimation {
            id: dismissToLeft
            target: contentItem
            property: "x"
            to: -control.width
            duration: control.reducedMotion ? 0 : MeoTheme.motionDurationSelection
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            onFinished: {
                control.rightActionTriggered()
                control.dismissedInDirection(control.isRightToLeft ? "startToEnd" : "endToStart")
                control.dismissed = true
            }
        }
    }

    // Optional: Auto-hide height when dismissed
    Behavior on implicitHeight {
        enabled: !control.reducedMotion
        NumberAnimation { duration: MeoTheme.motionDurationPage; easing.bezierCurve: MeoTheme.motionEasingStandard }
    }

    states: [
        State {
            name: "dismissed"
            when: control.dismissed
            PropertyChanges { target: control; implicitHeight: 0; opacity: 0; visible: false }
        }
    ]
}
