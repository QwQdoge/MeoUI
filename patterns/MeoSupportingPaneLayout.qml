import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property Component mainPane: null
    property Component supportingPane: null
    property bool showSupportingPane: false
    property string adaptiveMode: "adaptive" // "adaptive" | "stacked" (compact) | "side-by-side" (expanded)

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionMedium: MeoTheme.motionDurationMedium
    readonly property var motionEasing: MeoTheme.motionEasingStandard

    // Canonical Layout dimensions (M3)
    readonly property real expandedPaneWidth: 360 * themeGlobalScale
    readonly property real spacing: 24 * themeGlobalScale
    readonly property real compactThreshold: 600 * themeGlobalScale

    readonly property bool isCompact: control.adaptiveMode === "stacked" || (control.adaptiveMode === "adaptive" && control.width < compactThreshold)

    implicitWidth: 800 * themeGlobalScale
    implicitHeight: 600 * themeGlobalScale
    clip: true

    Item {
        id: container
        anchors.fill: parent

        // Main Pane
        Item {
            id: mainArea
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            // Adjust width based on state
            width: {
                if (control.isCompact) {
                    return control.width
                }
                return control.showSupportingPane ? (control.width - control.expandedPaneWidth - control.spacing) : control.width
            }

            Behavior on width {
                NumberAnimation {
                    duration: control.motionMedium
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
                }
            }

            Loader {
                anchors.fill: parent
                sourceComponent: control.mainPane
                asynchronous: true
                // In compact mode, if showing supporting pane, hide main pane or dim it (using standard navigation transitions)
                // We'll handle visual opacity based on compact mode
                opacity: control.isCompact && control.showSupportingPane ? 0.0 : 1.0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: control.motionMedium
                        easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
            }
        }

        // Supporting Pane
        Item {
            id: supportingArea
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            // On compact screens, it takes the whole width. On expanded, it takes expandedPaneWidth.
            width: control.isCompact ? control.width : control.expandedPaneWidth

            // Position: slide from right
            x: control.showSupportingPane ? (control.isCompact ? 0 : control.width - width) : control.width

            Behavior on x {
                NumberAnimation {
                    duration: control.motionMedium
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: control.motionMedium
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
                }
            }

            Rectangle {
                anchors.fill: parent
                color: MeoTheme.surface

                Loader {
                    anchors.fill: parent
                    sourceComponent: control.supportingPane
                    asynchronous: true
                }
            }
        }
    }
}
