import QtQuick
import MeoUI

Item {
    id: control

    property var model: []
    property int currentIndex: 0
    // Keep selection stable if destinations are reordered across adaptive
    // presentations. This is the same identity contract as bar and rail.
    property string currentId: ""
    // Retained for source compatibility. Size classes now choose the actual
    // navigation primitive instead of treating every desktop width as a rail.
    property bool expandedRail: false
    property Component header: null
    property Component footer: null
    property string labelType: "always"
    property real availableWidth: parent ? parent.width : width
    property int compactNavigationLimit: 5
    // Most applications use the compact bottom bar. Information-dense shells
    // can open a temporary expanded rail for categories rather than falling
    // back to the M3 Expressive-deprecated navigation drawer. "drawer" stays
    // accepted as the established API spelling for this compact presentation.
    property string compactPresentation: "bottomBar" // bottomBar | drawer (modal rail)
    property bool windowResizeActive: false
    property bool preferPersistentDrawer: false
    property string navigationVisualStyle: "standard"

    signal clicked(int index)
    signal activated(var item, int index)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool isCompact: windowMetrics.isCompactWidth
    readonly property bool isMedium: windowMetrics.isMediumWidth
    readonly property bool isExpanded: windowMetrics.isExpandedWidth
    readonly property bool isLarge: windowMetrics.isLargeWidth
    readonly property bool isExtraLarge: windowMetrics.isExtraLargeWidth
    readonly property string windowSizeClass: windowMetrics.widthSizeClass
    // M3 Expressive keeps one rail family across non-compact breakpoints.
    // The expanded rail replaces the default permanent navigation drawer.
    readonly property real expandedRailWidth: 280 * themeGlobalScale
    readonly property real drawerWidth: navigationVisualStyle === "settings"
                                        ? MeoTheme.settingsSidebarWidth
                                        : 280 * themeGlobalScale
    readonly property bool usesPersistentDrawer: preferPersistentDrawer
                                                 && (isExpanded || isLarge || isExtraLarge)
    readonly property bool usesExpandedRail: !usesPersistentDrawer
                                             && (isExpanded || isLarge || isExtraLarge)
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
                             : isMedium ? 96 * themeGlobalScale
                                        : usesExpandedRail ? expandedRailWidth
                                                           : drawerWidth
    implicitHeight: isCompact ? bottomNavigation.implicitHeight : 600 * themeGlobalScale
    width: implicitWidth
    clip: true

    function destinationAt(index) {
        if (!model || index < 0 || index >= model.length)
            return null
        return model[index]
    }

    function syncCurrentId() {
        const item = destinationAt(currentIndex)
        if (!item || item.type === "header" || item.id === undefined || item.id === null)
            return
        currentId = String(item.id)
    }

    function select(index) {
        const item = destinationAt(index)
        if (!item || item.type === "header" || item.enabled === false)
            return
        currentIndex = index
        if (item.id !== undefined && item.id !== null)
            currentId = String(item.id)
        clicked(index)
        activated(item, index)
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
    onCurrentIndexChanged: syncCurrentId()
    onModelChanged: syncCurrentId()
    onCurrentIdChanged: {
        if (currentId === "")
            return
        for (let index = 0; index < model.length; ++index) {
            const item = destinationAt(index)
            if (item && item.type !== "header" && item.id !== undefined
                    && String(item.id) === currentId) {
                if (currentIndex !== index)
                    currentIndex = index
                return
            }
        }
    }

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
        currentId: control.currentId
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
        width: control.isMedium ? 96 * control.themeGlobalScale
                                : control.usesExpandedRail ? control.expandedRailWidth : 0
        visible: width > 0
        opacity: control.isMedium || control.usesExpandedRail ? 1 : 0
        model: control.model
        currentIndex: control.currentIndex
        currentId: control.currentId
        isExpanded: control.usesExpandedRail
        expandedWidth: control.expandedRailWidth
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
        width: control.usesPersistentDrawer ? control.drawerWidth : 0
        visible: width > 0
        opacity: control.usesPersistentDrawer ? 1 : 0
        model: control.model
        currentIndex: control.currentIndex
        currentId: control.currentId
        header: control.header
        footer: control.footer
        visualStyle: control.navigationVisualStyle
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

    MeoNavigationRailModal {
        id: overflowDrawer
        objectName: "meoNavigationSuiteOverflowRail"
        model: control.model
        currentIndex: control.currentIndex
        currentId: control.currentId
        header: control.header
        footer: control.footer
        closeOnDestination: true
        onClicked: (index) => {
            control.select(index)
        }
    }
}
