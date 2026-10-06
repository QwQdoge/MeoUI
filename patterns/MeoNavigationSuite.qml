import QtQuick
import MeoUI

Item {
    id: control

    property var model: []
    property int currentIndex: 0
    // Keep selection stable if destinations are reordered across adaptive
    // presentations. This is the same identity contract as bar and rail.
    property string currentId: ""
    property string selectedRoute: ""
    property Component header: null
    property Component footer: null
    property string labelType: "always"
    property real availableWidth: parent ? parent.width : width
    property int compactNavigationLimit: 5
    // Compact apps use bottom navigation; information-dense apps open the
    // same MeoSidebar component in a modal surface.
    property string compactPresentation: "bottomBar" // bottomBar | sidebar
    property var groups: []
    property string sidebarTitle: qsTr("Navigation")
    property bool showSidebarTitle: true
    property var searchResults: null
    property string searchText: ""
    property bool windowResizeActive: false

    signal clicked(int index)
    signal activated(var item, int index)
    signal routeActivated(string route, var row)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool isCompact: windowMetrics.isCompactWidth
    readonly property bool isMedium: windowMetrics.isMediumWidth
    readonly property bool isExpanded: windowMetrics.isExpandedWidth
    readonly property bool isLarge: windowMetrics.isLargeWidth
    readonly property bool isExtraLarge: windowMetrics.isExtraLargeWidth
    readonly property string windowSizeClass: windowMetrics.widthSizeClass
    // The compact icon rail remains available at medium widths.
    readonly property real sidebarWidth: MeoTheme.settingsSidebarWidth
    readonly property bool usesExpandedSidebar: isExpanded || isLarge || isExtraLarge
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
    readonly property var effectiveSidebarGroups: {
        if (groups && groups.length)
            return groups
        const rows = []
        for (let index = 0; index < model.length; ++index) {
            const item = model[index]
            if (!item || item.type === "header")
                continue
            const route = String(item.route || item.id || "")
            if (!route)
                continue
            rows.push({
                "route": route,
                "title": item.label || item.title || "",
                "subtitle": item.subtitle || "",
                "leadingIcon": item.icon || "",
                "enabled": item.enabled !== false
            })
        }
        return [{ "title": "", "rows": rows }]
    }
    readonly property var effectiveSearchResults: {
        if (searchResults !== null)
            return searchResults
        const query = searchText.trim().toLocaleLowerCase()
        if (!query)
            return []
        const rows = []
        for (let index = 0; index < model.length; ++index) {
            const item = model[index]
            if (!item || item.type === "header")
                continue
            const route = String(item.route || item.id || "")
            if (!route)
                continue
            const title = String(item.label || item.title || "")
            const subtitle = String(item.subtitle || "")
            if (title.toLocaleLowerCase().includes(query) || subtitle.toLocaleLowerCase().includes(query))
                rows.push({ "route": route,
                            "title": title, "subtitle": subtitle, "leadingIcon": item.icon || "",
                            "enabled": item.enabled !== false })
        }
        return rows
    }
    readonly property int compactCurrentIndex: currentIndex >= 0 && currentIndex < compactDirectCount ? currentIndex : -1
    readonly property bool usesCompactBottomBar: isCompact && compactPresentation === "bottomBar"
    readonly property real compactNavigationHeight: usesCompactBottomBar ? bottomNavigation.implicitHeight : 0
    readonly property bool motionEnabled: !MeoTheme.reduceMotion && !windowResizeActive
    readonly property string effectiveSelectedRoute: selectedRoute || currentId

    implicitWidth: isCompact ? (parent ? parent.width : 360 * themeGlobalScale)
                             : isMedium ? 96 * themeGlobalScale
                                        : usesExpandedSidebar ? sidebarWidth : 96 * themeGlobalScale
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
        if (!item || item.type === "header")
            return
        const identity = item.route !== undefined ? item.route : item.id
        if (identity === undefined || identity === null)
            return
        currentId = String(identity)
    }

    function select(index) {
        const item = destinationAt(index)
        if (!item || item.type === "header" || item.enabled === false)
            return
        currentIndex = index
        const identity = item.route !== undefined ? item.route : item.id
        if (identity !== undefined && identity !== null)
            currentId = String(identity)
        clicked(index)
        activated(item, index)
    }

    function openOverflow() {
        if (isCompact && (compactPresentation === "sidebar" || hasCompactOverflow))
            overflowSidebar.openForNavigation()
    }

    function openSidebar() { overflowSidebar.openForNavigation() }

    function markResizeActive() {
        windowResizeActive = true
        resizeSettled.restart()
    }

    onAvailableWidthChanged: markResizeActive()
    onHeightChanged: markResizeActive()
    onCurrentIndexChanged: syncCurrentId()
    onSelectedRouteChanged: {
        if (!selectedRoute)
            return
        for (let index = 0; index < model.length; ++index) {
            const item = destinationAt(index)
            if (item && item.type !== "header" && String(item.route || item.id || "") === selectedRoute) {
                if (currentIndex !== index)
                    currentIndex = index
                return
            }
        }
    }
    onModelChanged: {
        const identity = selectedRoute || currentId
        for (let index = 0; index < model.length; ++index) {
            const item = destinationAt(index)
            if (item && item.type !== "header" && String(item.route || item.id || "") === identity) {
                currentIndex = index
                return
            }
        }
        if (!identity)
            syncCurrentId()
    }
    onCurrentIdChanged: {
        if (currentId === "")
            return
        for (let index = 0; index < model.length; ++index) {
            const item = destinationAt(index)
            if (item && item.type !== "header"
                    && String(item.route || item.id || "") === currentId) {
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
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
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
                                : 0
        visible: width > 0
        opacity: control.isMedium ? 1 : 0
        model: control.model
        currentIndex: control.currentIndex
        currentId: control.currentId
        resizeInstantly: control.windowResizeActive
        header: control.header
        footer: control.footer
        onClicked: (index) => control.select(index)

        Behavior on width {
            NumberAnimation {
                duration: control.motionEnabled ? MeoTheme.motionDurationSpatialDefault : 0
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: control.motionEnabled ? MeoTheme.motionDurationEffectDefault : 0
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }

    MeoSidebar {
        id: navigationSidebar
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: control.usesExpandedSidebar ? control.sidebarWidth : 0
        visible: width > 0
        opacity: control.usesExpandedSidebar ? 1 : 0
        groups: control.effectiveSidebarGroups
        title: control.sidebarTitle
        showTitle: control.showSidebarTitle
        searchResults: control.effectiveSearchResults
        searchText: control.searchText
        selectedRoute: control.effectiveSelectedRoute
        footer: control.footer
        onSearchTextChanged: control.searchText = searchText
        onRouteActivated: (route, row) => {
            control.searchText = ""
            control.routeActivated(route, row)
            for (let index = 0; index < control.model.length; ++index) {
                if (String(control.model[index].route || control.model[index].id || "") === String(route)) {
                    control.select(index)
                    return
                }
            }
            activated(row, -1)
        }

        Behavior on width {
            NumberAnimation {
                duration: control.motionEnabled ? MeoTheme.motionDurationSpatialDefault : 0
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: control.motionEnabled ? MeoTheme.motionDurationEffectDefault : 0
                easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }

    MeoSidebarModal {
        id: overflowSidebar
        objectName: "meoNavigationSuiteSidebar"
        groups: control.effectiveSidebarGroups
        title: control.sidebarTitle
        showTitle: control.showSidebarTitle
        searchResults: control.effectiveSearchResults
        searchText: control.searchText
        selectedRoute: control.effectiveSelectedRoute
        footer: control.footer
        onSearchTextChanged: control.searchText = searchText
        onRouteActivated: (route, row) => {
            control.routeActivated(route, row)
            for (let index = 0; index < control.model.length; ++index) {
                if (String(control.model[index].route || control.model[index].id || "") === String(route)) {
                    control.select(index)
                    return
                }
            }
            activated(row, -1)
        }
    }
}
