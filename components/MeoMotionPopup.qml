import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    // Lifecycle and placement behavior adapted from the small, reusable parts
    // of DankMaterialShell's DankPopout/TransientSurfaceTracker (MIT,
    // Copyright 2025 Avenge Media LLC). Reimplemented for Qt Quick Controls:
    // no Quickshell window, DMS theme, SettingsData, or service code is used.

    enum Presentation {
        Dialog,
        Menu,
        BottomSheet,
        SideSheet,
        FullScreen
    }

    property int presentation: MeoMotionPopup.Dialog
    property real surfaceRadius: isMenu ? MeoTheme.shapeLargeIncreased
                                        : isFullScreen ? MeoTheme.shapeNone
                                                       : MeoTheme.shapeExtraLarge
    property color surfaceColor: isMenu ? MeoTheme.surfaceContainer
                                        : isFullScreen ? MeoTheme.surface
                                                       : MeoTheme.surfaceContainerHigh
    property real scrimOpacity: 0.32
    property string motionProfile: "pixel"
    property real entranceOffset: MeoMotion.popupOffset(motionProfile) * MeoTheme.globalScale
    property real entranceScale: 0.98
    property real viewportMargin: 24 * MeoTheme.globalScale
    property Item initialFocusItem: null
    property Item focusReturnItem: null
    // `contentActive` is the common gate for nested Loaders, discovery work,
    // timers, and indeterminate indicators. Popup content itself stays owned
    // by Qt; a host opts in by binding its expensive children to this flag.
    property bool keepContentWarm: false
    property bool prewarmBeforeOpen: true
    // A child dialog, password prompt, or submenu registers itself here while
    // open. The parent then ignores outside presses until that transient closes.
    property var transientSurface: null
    // Manual preserves the existing API. Opt into auto/below/above/right/left
    // only for anchored transient surfaces that want viewport-aware placement.
    property string placement: "manual"
    property Item placementAnchor: null
    property real placementGap: 8 * MeoTheme.globalScale
    property bool _openRequested: false
    property bool _retainingExitContent: false

    readonly property bool isMenu: presentation === MeoMotionPopup.Menu
    readonly property bool isBottomSheet: presentation === MeoMotionPopup.BottomSheet
    readonly property bool isSideSheet: presentation === MeoMotionPopup.SideSheet
    readonly property bool isFullScreen: presentation === MeoMotionPopup.FullScreen
    readonly property int enterDuration: isMenu ? MeoTheme.motionDurationMenuEnter
                                                 : isBottomSheet || isSideSheet ? MeoTheme.motionDurationSheetEnter
                                                                               : MeoTheme.motionDurationDialogEnter
    readonly property int exitDuration: isMenu ? MeoTheme.motionDurationMenuExit
                                                : isBottomSheet || isSideSheet ? MeoTheme.motionDurationSheetExit
                                                                              : MeoTheme.motionDurationDialogExit
    readonly property bool contentActive: keepContentWarm || opened || _openRequested
                                         || _retainingExitContent
    readonly property bool hasOpenTransientSurface: transientSurface
                                                    && (transientSurface.opened
                                                        || transientSurface.visible)
    readonly property int defaultClosePolicy: isFullScreen ? Popup.CloseOnEscape
                                                           : Popup.CloseOnEscape | Popup.CloseOnPressOutside
    readonly property real measuredImplicitWidth: Math.max(implicitWidth, contentItem ? contentItem.implicitWidth : 0)
    readonly property real measuredImplicitHeight: Math.max(implicitHeight, contentItem ? contentItem.implicitHeight : 0)

    function openFrom(item) {
        focusReturnItem = item || null
        placementAnchor = item || placementAnchor
        requestOpen()
    }

    function requestOpen() {
        if (opened || _openRequested)
            return
        _openRequested = true
        if (!prewarmBeforeOpen) {
            open()
            return
        }
        // Queue one polish turn so a Loader activated by contentActive can
        // report its intrinsic size before the enter transition starts.
        Qt.callLater(function() {
            if (!_openRequested || opened)
                return
            // Reading both values forces QML to evaluate content geometry
            // after active Loaders have received contentActive.
            const measuredWidth = measuredImplicitWidth
            const measuredHeight = measuredImplicitHeight
            void measuredWidth
            void measuredHeight
            positionForAnchor()
            clampToViewport()
            open()
        })
    }

    function registerTransientSurface(surface) {
        transientSurface = surface || null
    }

    function unregisterTransientSurface(surface) {
        if (!surface || transientSurface === surface)
            transientSurface = null
    }

    function positionForAnchor() {
        const anchor = placementAnchor
        if (placement === "manual" || !anchor || !parent || isFullScreen
                || isBottomSheet || isSideSheet)
            return false

        const globalPoint = anchor.mapToGlobal(0, 0)
        const point = parent.mapFromGlobal(globalPoint.x, globalPoint.y)
        const popupWidth = Math.max(width, measuredImplicitWidth)
        const popupHeight = Math.max(height, measuredImplicitHeight)
        const below = parent.height - (point.y + anchor.height) - viewportMargin
        const above = point.y - viewportMargin
        const right = parent.width - (point.x + anchor.width) - viewportMargin
        const left = point.x - viewportMargin
        let direction = placement
        if (direction === "auto") {
            // Prefer the vertical edge with enough room. If neither fits,
            // choose the largest remaining side before viewport clamping.
            if (below >= popupHeight || below >= above)
                direction = "below"
            else if (above >= popupHeight)
                direction = "above"
            else
                direction = right >= left ? "right" : "left"
        }

        if (direction === "above") {
            x = point.x
            y = point.y - popupHeight - placementGap
        } else if (direction === "right") {
            x = point.x + anchor.width + placementGap
            y = point.y
        } else if (direction === "left") {
            x = point.x - popupWidth - placementGap
            y = point.y
        } else {
            x = point.x
            y = point.y + anchor.height + placementGap
        }
        return true
    }

    function clampToViewport() {
        if (!parent || isFullScreen || isBottomSheet || isSideSheet)
            return
        const maximumX = Math.max(viewportMargin, parent.width - width - viewportMargin)
        const maximumY = Math.max(viewportMargin, parent.height - height - viewportMargin)
        x = Math.max(viewportMargin, Math.min(x, maximumX))
        y = Math.max(viewportMargin, Math.min(y, maximumY))
    }

    modal: !isMenu
    focus: true
    closePolicy: hasOpenTransientSurface ? Popup.CloseOnEscape : defaultClosePolicy
    transformOrigin: isSideSheet ? Item.Right
                                 : isBottomSheet ? Item.Bottom
                                                 : isMenu ? Item.TopRight : Item.Center

    onAboutToShow: {
        if (prewarmBeforeOpen) {
            const measuredWidth = measuredImplicitWidth
            const measuredHeight = measuredImplicitHeight
            void measuredWidth
            void measuredHeight
        }
        positionForAnchor()
        clampToViewport()
    }
    onOpened: {
        _openRequested = false
        Qt.callLater(function() {
            if (initialFocusItem && initialFocusItem.visible && initialFocusItem.enabled)
                initialFocusItem.forceActiveFocus(Qt.PopupFocusReason)
            else if (contentItem)
                contentItem.forceActiveFocus(Qt.PopupFocusReason)
        })
    }
    onAboutToHide: _retainingExitContent = true
    onClosed: {
        _retainingExitContent = false
        if (focusReturnItem && focusReturnItem.visible && focusReturnItem.enabled)
            focusReturnItem.forceActiveFocus(Qt.PopupFocusReason)
    }

    Overlay.modal: Rectangle {
        color: Qt.rgba(MeoTheme.scrim.r, MeoTheme.scrim.g, MeoTheme.scrim.b, control.scrimOpacity)
        Behavior on opacity {
            NumberAnimation {
                duration: control.presentation === MeoMotionPopup.SideSheet
                          || control.presentation === MeoMotionPopup.BottomSheet
                          ? MeoTheme.motionDurationSheetExit : MeoTheme.motionDurationDialogExit
                easing.type: Easing.BezierSpline
                easing.bezierCurve: MeoTheme.motionEasingLinear
            }
        }
    }

    background: Item {
        clip: false

        Rectangle {
            visible: !control.isFullScreen
            x: control.isSideSheet ? -4 * MeoTheme.globalScale : 0
            y: control.isMenu ? 3 * MeoTheme.globalScale : 6 * MeoTheme.globalScale
            width: parent.width
            height: parent.height
            radius: control.surfaceRadius
            color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b,
                           control.isMenu ? 0.10 : 0.08)
        }

        Rectangle {
            visible: !control.isFullScreen
            x: control.isSideSheet ? -2 * MeoTheme.globalScale : 0
            y: control.isMenu ? 1 * MeoTheme.globalScale : 2 * MeoTheme.globalScale
            width: parent.width
            height: parent.height
            radius: control.surfaceRadius
            color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b,
                           control.isMenu ? 0.08 : 0.06)
        }

        Rectangle {
            anchors.fill: parent
            radius: control.surfaceRadius
            color: control.surfaceColor
            border.width: control.isFullScreen ? 0 : 1
            border.color: Qt.rgba(MeoTheme.outline.r, MeoTheme.outline.g, MeoTheme.outline.b, 0.22)

            Behavior on radius {
                NumberAnimation {
                    duration: MeoTheme.motionDurationSelection
                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasized
                }
            }
        }
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: MeoTheme.motionDurationPopupEffectsEnter
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandardDecelerate
            }
            NumberAnimation {
                property: "scale"
                from: MeoTheme.reduceMotion ? 1 : control.isMenu ? control.entranceScale : control.presentation === MeoMotionPopup.Dialog ? control.entranceScale : 1
                to: 1
                duration: MeoTheme.motionDurationPopupEffectsEnter
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
            NumberAnimation {
                property: "x"
                from: control.isSideSheet && control.parent && !MeoTheme.reduceMotion ? control.parent.width : control.x
                to: control.isSideSheet && control.parent ? control.parent.width - control.width : control.x
                duration: control.enterDuration
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
            NumberAnimation {
                property: "y"
                from: control.isBottomSheet && control.parent && !MeoTheme.reduceMotion ? control.parent.height
                      : (!MeoTheme.reduceMotion && !control.isSideSheet ? control.y - control.entranceOffset : control.y)
                to: control.isBottomSheet && control.parent ? control.parent.height - control.height : control.y
                duration: control.enterDuration
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: MeoTheme.motionDurationPopupEffectsExit
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: MeoTheme.reduceMotion ? 1 : control.isMenu ? 0.98 : control.presentation === MeoMotionPopup.Dialog ? 0.96 : 1
                duration: MeoTheme.motionDurationPopupEffectsExit
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate
            }
            NumberAnimation {
                property: "x"
                from: control.x
                to: control.isSideSheet && control.parent && !MeoTheme.reduceMotion ? control.parent.width : control.x
                duration: control.exitDuration
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate
            }
            NumberAnimation {
                property: "y"
                from: control.y
                to: control.isBottomSheet && control.parent && !MeoTheme.reduceMotion ? control.parent.height : control.y
                duration: control.exitDuration
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate
            }
        }
    }
}
