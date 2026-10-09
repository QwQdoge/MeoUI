import QtQuick
import QtQuick.Controls
import MeoUI

// Platform-neutral Meo Widget contract.
//
// A Meo widget may be presented by a Plasma applet adapter, a lock-screen
// adapter, or a future overview host, but its visual and privacy contracts
// belong to MeoUI. Hosts must honour `supportedSurfaces` and never infer that
// a desktop widget is safe to load in a lock screen.
Control {
    id: control

    enum Size {
        SizeSmall,       // 1 x 1
        SizeWide,        // 2 x 1
        SizeMedium,      // 2 x 2
        SizeLarge,       // 4 x 2
        SizeExtraLarge   // 4 x 4
    }
    enum Privacy {
        None,
        Local,
        Media,
        Location
    }
    enum RefreshPolicy {
        Manual,
        Periodic,
        EventDriven
    }
    enum HostSurface {
        Desktop,
        LockScreen,
        Overview
    }
    enum FrameMode {
        Native,
        MeoFramed,
        Adaptive
    }

    // Registry identifiers are stable public API. A host maps them to a
    // concrete package/adapter; the Meo widget never loads packages itself.
    property string widgetId: ""
    property int preferredSize: MeoWidget.SizeMedium
    property var supportedSizes: [MeoWidget.SizeSmall, MeoWidget.SizeWide,
                                  MeoWidget.SizeMedium, MeoWidget.SizeLarge,
                                  MeoWidget.SizeExtraLarge]
    property int privacy: MeoWidget.None
    property int refreshPolicy: MeoWidget.EventDriven
    property var supportedSurfaces: [MeoWidget.Desktop]

    // `Adaptive` permits a host to avoid drawing a second surface around
    // content that declares its own background. This is also the policy used
    // by compatibility hosts for native Plasma content; it never rewrites the
    // applet's internal QML or theme bindings.
    property int frameMode: MeoWidget.MeoFramed
    property bool wantsOwnBackground: false
    property real gridCellSize: 96 * MeoTheme.globalScale
    property real gridGap: MeoTheme.space8
    property real widgetPadding: MeoTheme.space16
    property color frameColor: MeoTheme.surfaceContainerLow
    property real frameRadius: MeoTheme.cardRadius
    property bool showFrameOutline: false
    property string accessibleName: ""
    property string accessibleDescription: ""

    readonly property bool drawsFrame: frameMode === MeoWidget.MeoFramed
                                        || (frameMode === MeoWidget.Adaptive
                                            && !wantsOwnBackground)
    readonly property int preferredColumns: columnsForSize(preferredSize)
    readonly property int preferredRows: rowsForSize(preferredSize)
    readonly property int currentColumns: spanForExtent(width)
    readonly property int currentRows: spanForExtent(height)
    readonly property bool compactLayout: currentColumns <= 1 || currentRows <= 1
    readonly property bool wideLayout: currentColumns > currentRows
    readonly property bool expandedLayout: currentColumns >= 4 || currentRows >= 4
    readonly property real dynamicCornerRadius: frameRadius
    readonly property real effectivePadding: drawsFrame ? widgetPadding : 0

    default property alias content: contentHost.data

    implicitWidth: preferredColumns * gridCellSize
                   + Math.max(0, preferredColumns - 1) * gridGap
    implicitHeight: preferredRows * gridCellSize
                    + Math.max(0, preferredRows - 1) * gridGap
    leftPadding: effectivePadding
    rightPadding: effectivePadding
    topPadding: effectivePadding
    bottomPadding: effectivePadding

    Accessible.role: Accessible.Pane
    Accessible.name: accessibleName || widgetId
    Accessible.description: accessibleDescription

    function columnsForSize(size) {
        if (size === MeoWidget.SizeWide || size === MeoWidget.SizeMedium)
            return 2
        if (size === MeoWidget.SizeLarge || size === MeoWidget.SizeExtraLarge)
            return 4
        return 1
    }

    function rowsForSize(size) {
        if (size === MeoWidget.SizeWide)
            return 1
        if (size === MeoWidget.SizeExtraLarge)
            return 4
        if (size === MeoWidget.SizeMedium || size === MeoWidget.SizeLarge)
            return 2
        return 1
    }

    // Googlebook/Android home widgets reflow as users drag resize handles.
    // Expose the effective grid span so content can react to real host
    // geometry rather than only the preferred size declared in metadata.
    function spanForExtent(extent) {
        const unit = Math.max(1, gridCellSize + gridGap)
        return Math.max(1, Math.min(4, Math.round((Math.max(1, extent) + gridGap) / unit)))
    }

    function supportsSurface(surface) {
        return supportedSurfaces.indexOf(surface) !== -1
    }

    contentItem: Item {
        id: contentHost
        clip: true
    }

    background: Item {
        visible: control.drawsFrame

        MeoShape {
            anchors.fill: parent
            type: "rect"
            radius: control.dynamicCornerRadius
            color: control.frameColor
            // Pixel/Googlebook-style home widgets primarily separate from the
            // wallpaper through a tonal surface, not a permanent keyline.
            strokeWidth: control.showFrameOutline ? MeoTheme.strokeWidthThin : 0
            strokeColor: MeoTheme.outlineVariant

            Behavior on color {
                enabled: !MeoTheme.reduceMotion
                ColorAnimation {
                    duration: MeoTheme.motionDurationState
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: MeoTheme.motionEasingStandard
                }
            }
            Behavior on radius {
                enabled: !MeoTheme.reduceMotion
                NumberAnimation {
                    duration: MeoTheme.motionDurationShapeSettle
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: MeoTheme.motionEasingStandard
                }
            }
        }
    }
}
