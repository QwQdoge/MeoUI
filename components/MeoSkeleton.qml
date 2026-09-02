import QtQuick
import MeoUI

Item {
    id: control

    // `type` supplies useful measured defaults without preventing callers
    // from setting width, height, or radius for a custom placeholder.
    property string type: "text" // "text" | "avatar" | "card" | "pill" | "block"
    property bool active: true
    property bool animate: true
    readonly property real defaultRadius: type === "avatar" || type === "pill"
                                       ? Math.min(width, height) / 2
                                       : type === "card" ? 12 * themeGlobalScale
                                       : 4 * themeGlobalScale
    property real radius: defaultRadius

    // Skeleton is a MeoUI product primitive; its visual values still resolve
    // through the shared scheme and scaling contract.
    readonly property color themeSurfaceVariant: MeoTheme.surfaceVariant
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property real themeGlobalScale: MeoTheme.globalScale
    // Pause shimmer whenever there is no drawable surface.  It resumes from
    // its current position, so virtualized delegates do not flash on return.
    readonly property bool animationActive: active && animate && visible && width > 0 && height > 0 && !MeoTheme.reduceMotion

    implicitWidth: (type === "avatar" ? 40 : type === "card" ? 240 : type === "pill" ? 120 : type === "block" ? 160 : 100) * themeGlobalScale
    implicitHeight: (type === "avatar" ? 40 : type === "card" ? 144 : type === "pill" ? 32 : type === "block" ? 64 : 16) * themeGlobalScale
    width: implicitWidth
    height: implicitHeight

    Accessible.role: Accessible.StaticText
    Accessible.name: qsTr("Loading placeholder")

    Rectangle {
        id: base
        objectName: "meoSkeletonSurface"
        anchors.fill: parent
        radius: control.radius
        color: control.themeSurfaceVariant
        clip: true

        // Shimmer Effect
        Rectangle {
            id: shimmer
            width: parent.width * 2
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop {
                    position: 0.5;
                    color: Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08)
                }
                GradientStop { position: 1.0; color: "transparent" }
            }

            XAnimator {
                target: shimmer
                from: -control.width * 2
                to: control.width
                duration: MeoTheme.motionDurationFor(1500)
                running: control.animationActive
                loops: Animation.Infinite
            }
        }
    }
}
