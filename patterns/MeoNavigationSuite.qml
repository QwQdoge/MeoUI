import QtQuick
import MeoUI

Item {
    id: control

    property var model: []
    property int currentIndex: 0
    // Retained for source compatibility. Size classes now choose the actual
    // navigation primitive instead of treating every desktop width as a rail.
    property bool expandedRail: false
    property Component header: null
    property Component footer: null
    property string labelType: "always"
    property real availableWidth: parent ? parent.width : width
    property int compactNavigationLimit: 5
    // Most applications use the compact bottom bar. Information-dense shells
    // such as Settings use a searchable index and a temporary category drawer
    // instead, so their category hierarchy is not hidden behind five tabs.
    property string compactPresentation: "bottomBar" // bottomBar | drawer
    property bool windowResizeActive: false

    signal clicked(int index)

    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property bool isCompact: windowMetrics.isCompactWidth
    readonly property bool isMedium: windowMetrics.isMediumWidth
    readonly property bool isExpanded: windowMetrics.isExpandedWidth
    readonly property bool isLarge: windowMetrics.isLargeWidth
    readonly property bool isExtraLarge: windowMetrics.isExtraLargeWidth
    readonly property string windowSizeClass: windowMetrics.widthSizeClass
    // Expanded is a stable docked pane, while Large and Extra Large share the
    // permanent drawer width unless an application deliberately composes more
    // drawer content through its header/footer slots.
    readonly property real expandedRailWidth: 240 * themeGlobalScale
    readonly property real drawerWidth: 280 * themeGlobalScale
    readonly property int compactDirectCount: Math.min(model.length,
                                                       Math.max(1, compactNavigationLimit - (model.length > compactNavigationLimit ? 1 : 0)))
    readonly property bool hasCompactOverflow: model.length > compactDirectCount
    readonly property var compactNavigationModel: {
        const destinations = model.slice(0, compactDirectCount)
        if (hasCompactOverflow) {
            destinations.push({
                "id": "meo-navigation-more",
                "label": qsTr("More"),
                "icon": "menu"
            })
        }
        return destinations
    }
    readonly property int compactCurrentIndex: currentIndex >= 0 && currentIndex < compactDirectCount ? currentIndex : -1
    readonly property bool usesCompactBottomBar: isCompact && compactPresentation === "bottomBar"
    readonly property real compactNavigationHeight: usesCompactBottomBar ? bottomNavigation.implicitHeight : 0
    readonly property bool motionEnabled: !MeoTheme.reduceMotion && !windowResizeActive

    implicitWidth: isCompact ? (parent ? parent.width : 360 * themeGlobalScale)
                             : isMedium ? 80 * themeGlobalScale
                                        : isExpanded ? expandedRailWidth
                                                     : drawerWidth
    implicitHeight: isCompact ? bottomNavigation.implicitHeight : 600 * themeGlobalScale
    width: implicitWidth
    clip: true

    function select(index) {
        if (index < 0 || index >= model.length)
            return
        clicked(index)
    }

    function openOverflow() {
        if (isCompact && (compactPresentation === "drawer" || hasCompactOverflow))
            overflowDrawer.open()
    }

    function markResizeActive() {
        windowResizeActive = true
        resizeSettled.restart()
    }

    onAvailableWidthChanged: markResizeActive()
    onHeightChanged: markResizeActive()

    Timer {
        id: resizeSettled
        interval: 90
        repeat: false
        onTriggered: control.windowResizeActive = false
    }

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.availableWidth
        availableHeight: control.height
    }

    Behavior on width {
        NumberAnimation {
            duration: control.motionEnabled ? MeoTheme.motionDurationSpatialDefault : 0
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
    }

    MeoNavigationBar {
        id: bottomNavigation
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: control.usesCompactBottomBar
        model: control.compactNavigationModel
        currentIndex: control.compactCurrentIndex
        labelType: control.labelType
        onClicked: (index) => {
            if (control.hasCompactOverflow && index === control.compactDirectCount)
                control.openOverflow()
            else
                control.select(index)
        }
    }

    MeoNavigationRail {
        id: navigationRail
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: control.isMedium ? 80 * control.themeGlobalScale
                                : control.isExpanded ? control.expandedRailWidth : 0
        visible: width > 0
        opacity: control.isMedium || control.isExpanded ? 1 : 0
        model: control.model
        currentIndex: control.currentIndex
        isExpanded: control.isExpanded
        resizeInstantly: control.windowResizeActive
        header: control.header
        footer: control.footer
        labelType: control.labelType
        onClicked: (index) => control.select(index)

        Behavior on width {
            NumberAnimation {
                duration: control.motionEnabled ? MeoTheme.motionDurationSpatialDefault : 0
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: control.motionEnabled ? MeoTheme.motionDurationEffectDefault : 0
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }

    MeoNavigationDrawer {
        id: navigationDrawer
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: control.isLarge || control.isExtraLarge ? control.drawerWidth : 0
        visible: width > 0
        opacity: control.isLarge || control.isExtraLarge ? 1 : 0
        model: control.model
        currentIndex: control.currentIndex
        header: control.header
        footer: control.footer
        onClicked: (index) => control.select(index)

        Behavior on width {
            NumberAnimation {
                duration: control.motionEnabled ? MeoTheme.motionDurationSpatialDefault : 0
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: control.motionEnabled ? MeoTheme.motionDurationEffectDefault : 0
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }

    MeoNavigationDrawerModal {
        id: overflowDrawer
        model: control.model
        currentIndex: control.currentIndex
        header: control.header
        onClicked: (index) => {
            control.select(index)
            overflowDrawer.close()
        }
    }
}
