import QtQuick
import MeoUI
import "." as Components

// A pointer-positioned MD3 context menu.  It deliberately extends MeoMenu so
// keyboard traversal, RTL, selection, submenu, and accessibility behavior
// cannot drift between a button menu and a right-click menu.
Components.MeoMenu {
    id: control

    objectName: "meoContextMenu"
    surfaceStyle: "context"
    placement: "manual"
    preferredMenuWidth: 256 * MeoTheme.globalScale
    // Screenshot-inspired Pixel launcher treatment: a quiet outer surface
    // containing individually rounded action cards with small breathing room.
    menuPadding: MeoTheme.space4
    menuHorizontalInset: MeoTheme.space4
    itemSpacing: MeoTheme.space4
    itemHeight: 52 * MeoTheme.globalScale
    supportingItemHeight: 68 * MeoTheme.globalScale
    property Item pointAnchor: null
    property real pointLocalX: 0
    property real pointLocalY: 0

    function positionAtPoint() {
        if (!pointAnchor || !parent)
            return false
        // Popup may move from its declarative parent to the window Overlay as
        // it opens. Map through global coordinates on every placement pass so
        // the requested pointer point remains stable across that reparenting.
        const globalPoint = pointAnchor.mapToGlobal(pointLocalX, pointLocalY)
        const point = parent.mapFromGlobal(globalPoint.x, globalPoint.y)
        x = point.x
        y = point.y
        clampToViewport()
        return true
    }

    // `anchor` owns the local pointer coordinate. `MeoMenu.openAt()` only
    // anchors at an offset used by button menus; a context target needs its
    // actual press point so the menu opens beside the intended object.
    function openAtPoint(anchor, localX, localY) {
        if (!anchor || !parent)
            return false

        pointAnchor = anchor
        pointLocalX = localX
        pointLocalY = localY
        positionAtPoint()
        // Context menus have a point, not a control edge, as their anchor.
        // `MeoMotionPopup.openFrom()` would intentionally recompute a menu
        // placement from the full target rectangle; keep the pointer point
        // through prewarming and the about-to-show clamp instead.
        focusReturnItem = anchor
        placementAnchor = null
        requestOpen()
        return true
    }

    Timer {
        interval: 0
        repeat: false
        running: control.opened && control.pointAnchor
        onTriggered: control.positionAtPoint()
    }
}
