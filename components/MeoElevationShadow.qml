import QtQuick
import QtQuick.Effects
import MeoUI

// The single elevation-shadow primitive behind every elevated MeoUI surface,
// and for host surfaces (panels, docks, popups) that need the same shadow.
// Place it as a sibling *behind* the visible surface; it mirrors the
// surface's geometry and casts the key shadow for `elevation` from
// MeoTheme's shared M3 level table.
//
// The shadow is a silhouette filled with the shadow color, offset and
// blurred. It never draws a copy of the surface itself, so translucent
// surfaces stay translucent and there is no extra full-size fill, and
// ripple/hover/content animation on the surface above never re-runs the
// blur (only geometry, color and elevation do).
Item {
    id: control

    // The visible surface whose geometry/transform this shadow follows.
    property Item target: null
    // Elevation in scaled pixels (MeoTheme.elevationLevelN or between).
    property real elevation: 0
    // Silhouette. "rect"/"round"/"squircle"/"circle" use per-corner radii;
    // any expressive MeoShape type uses that shape's path.
    property string shape: "rect"
    property real radius: 0
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius
    // Kept for API symmetry with the surface; the shadow is always drawn in
    // MeoTheme.shadow.
    property color color: MeoTheme.surface
    // +1 casts downward (default). -1 casts upward, e.g. bottom sheets.
    property int direction: 1

    readonly property bool _native: shape === "rect" || shape === "round"
                                    || shape === "squircle" || shape === "circle"
    readonly property real _circleRadius: Math.min(width, height) / 2
    readonly property real _offset: MeoTheme.elevationShadowOffset(elevation) * direction

    x: target ? target.x : 0
    y: (target ? target.y : 0) + _offset
    width: target ? target.width : 0
    height: target ? target.height : 0
    scale: target ? target.scale : 1
    rotation: target ? target.rotation : 0
    transformOrigin: target ? target.transformOrigin : Item.Center
    opacity: MeoTheme.elevationShadowOpacity * (target ? target.opacity : 1)
    visible: elevation > 0 && width > 0 && height > 0
             && (!target || target.visible)

    layer.enabled: visible
    layer.effect: MultiEffect {
        blurEnabled: true
        blurMax: 32
        blur: MeoTheme.elevationShadowBlur(control.elevation)
        autoPaddingEnabled: true
    }

    Rectangle {
        anchors.fill: parent
        visible: control._native
        color: MeoTheme.shadow
        topLeftRadius: control.shape === "circle" ? control._circleRadius : control.topLeftRadius
        topRightRadius: control.shape === "circle" ? control._circleRadius : control.topRightRadius
        bottomLeftRadius: control.shape === "circle" ? control._circleRadius : control.bottomLeftRadius
        bottomRightRadius: control.shape === "circle" ? control._circleRadius : control.bottomRightRadius
        antialiasing: true
    }

    Loader {
        anchors.fill: parent
        active: !control._native
        sourceComponent: MeoShape {
            type: control.shape
            radius: control.radius
            color: MeoTheme.shadow
        }
    }
}
