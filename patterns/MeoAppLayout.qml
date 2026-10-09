pragma ComponentBehavior: Bound
import QtQuick
import MeoUI

Item {
    id: control
    anchors.fill: parent

    // 🌟 Configuration
    property var navigationModel: []
    property list<Component> pages
    property int currentIndex: 0
    property int compactNavigationLimit: 5
    property bool windowResizeActive: false
    property string currentRoute: ""
    property var sidebarGroups: []
    property string sidebarTitle: qsTr("Navigation")
    property string searchPlaceholder: qsTr("Search navigation")
    property var searchResults: null
    property string searchText: ""

    // App-level actions belong to the shared top app bar rather than being
    // overlaid by individual applications. Expanded layouts keep the previous
    // behavior by default unless an app explicitly opts in.
    property list<Component> topAppBarActions
    property bool showTopAppBarOnExpanded: false

    // 🌟 Safe Area Insets (Edge-to-Edge support)
    property real safeAreaTop: 0
    property real safeAreaBottom: 0
    property real safeAreaLeft: 0
    property real safeAreaRight: 0

    // 🌟 Sidebar & Actions
    property Component sidebarFooter: null
    property Component fab: null

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property bool isCompact: windowMetrics.isCompactWidth
    readonly property bool isMedium: windowMetrics.isMediumWidth
    readonly property bool isExpanded: windowMetrics.isExpandedWidth
    readonly property bool isLarge: windowMetrics.isLargeWidth || windowMetrics.isExtraLargeWidth
    readonly property string windowSizeClass: windowMetrics.widthSizeClass
    readonly property bool usesExpandedSidebar: isExpanded || isLarge
    readonly property string selectedRoute: currentRoute || (navigationModel[currentIndex] && navigationModel[currentIndex].id !== undefined
                                                          ? String(navigationModel[currentIndex].id) : "")
    readonly property var effectiveSidebarGroups: {
        if (sidebarGroups && sidebarGroups.length)
            return sidebarGroups
        const rows = []
        for (let index = 0; index < navigationModel.length; ++index) {
            const item = navigationModel[index]
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
        for (let index = 0; index < navigationModel.length; ++index) {
            const item = navigationModel[index]
            const route = String(item.route || item.id || "")
            if (!route)
                continue
            const title = String(item.label || item.title || "")
            const subtitle = String(item.subtitle || "")
            if (title.toLocaleLowerCase().includes(query) || subtitle.toLocaleLowerCase().includes(query))
                rows.push({ "route": route,
                            "title": title, "subtitle": subtitle,
                            "leadingIcon": item.icon || "", "enabled": item.enabled !== false })
        }
        return rows
    }

    function indexForRoute(route) {
        if (!route)
            return -1
        for (let index = 0; index < navigationModel.length; ++index) {
            const item = navigationModel[index]
            if (String(item.route || item.id || "") === String(route))
                return index
        }
        return -1
    }

    function openSidebar() { modalSidebar.openForNavigation() }
    readonly property var compactNavigationModel: navigationModel.slice(0, Math.min(compactNavigationLimit, navigationModel.length))

    onWidthChanged: {
        windowResizeActive = true
        resizeSettled.restart()
    }
    onHeightChanged: {
        windowResizeActive = true
        resizeSettled.restart()
    }

    Timer {
        id: resizeSettled
        interval: 90
        repeat: false
        onTriggered: control.windowResizeActive = false
    }

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.width
        availableHeight: control.height
    }


    // Main Layout
    Row {
        anchors.fill: parent

        // Compact navigation stays focused; wider windows share MeoSidebar.
        MeoNavigationRail {
            id: navRail
            width: control.isMedium ? 96 * control.themeGlobalScale
                                    : 0
            height: parent.height
            model: control.navigationModel
            currentIndex: control.currentIndex
            visible: width > 0
            enabled: control.isMedium
            opacity: control.isMedium ? 1 : 0
            resizeInstantly: control.windowResizeActive
            onClicked: (index) => { control.currentIndex = index }

            Behavior on width { NumberAnimation { duration: control.windowResizeActive || MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate } }
            Behavior on opacity { NumberAnimation { duration: control.windowResizeActive || MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard } }

        }

        MeoSidebar {
            id: navSidebar
            width: control.usesExpandedSidebar ? MeoTheme.settingsSidebarWidth : 0
            height: parent.height
            groups: control.effectiveSidebarGroups
            title: control.sidebarTitle
            searchPlaceholder: control.searchPlaceholder
            selectedRoute: control.selectedRoute
            searchResults: control.effectiveSearchResults
            searchText: control.searchText
            footer: control.sidebarFooter
            visible: width > 0
            opacity: control.usesExpandedSidebar ? 1 : 0
            onSearchTextChanged: control.searchText = searchText
            onRouteActivated: (route, row) => {
                control.currentRoute = route
                const index = control.indexForRoute(route)
                if (index >= 0)
                    control.currentIndex = index
            }

            Behavior on width { NumberAnimation { duration: control.windowResizeActive || MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate } }
            Behavior on opacity { NumberAnimation { duration: control.windowResizeActive || MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard } }
        }

        // 3. Main Content Area
        Column {
            width: parent.width - (navRail.visible ? navRail.width : 0) - (navSidebar.visible ? navSidebar.width : 0)
            height: parent.height

            Behavior on width { NumberAnimation { duration: control.windowResizeActive || MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate } }

            // Shared Top App Bar. Applications can opt into keeping it on
            // expanded layouts and can provide app-specific actions.
            MeoTopAppBar {
                id: topAppBar
                width: parent.width
                title: control.navigationModel[control.currentIndex] ? control.navigationModel[control.currentIndex].label : qsTr("App")
                type: "small"
                visible: control.showTopAppBarOnExpanded || control.isCompact || control.isMedium
                actions: control.topAppBarActions

                // Add top padding for notch
                Item { height: control.safeAreaTop; width: parent.width }

                // Add a navigation icon for the hamburger menu
                navigationIcon: Component {
                    MeoIconButton {
                        icon.name: "menu"
                        visible: !control.usesExpandedSidebar
                        enabled: visible
                        onClicked: modalSidebar.openForNavigation()
                    }
                }
            }

            // Page Content (StackLayout for Keep-Alive)
            Item {
                width: parent.width
                height: parent.height - (topAppBar.visible ? topAppBar.height : 0) - (bottomNavBar.visible ? bottomNavBar.height + control.safeAreaBottom : 0)

                Loader {
                    id: pageLoader
                    property real slideDistance: 0
                    anchors.fill: parent
                    anchors.leftMargin: control.safeAreaLeft
                    anchors.rightMargin: control.safeAreaRight
                    sourceComponent: control.currentIndex >= 0 && control.currentIndex < control.pages.length
                                     ? control.pages[control.currentIndex] : null
                }

                // FAB Layer
                Loader {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 16 * control.themeGlobalScale
                    anchors.bottomMargin: 16 * control.themeGlobalScale + control.safeAreaBottom
                    anchors.rightMargin: 16 * control.themeGlobalScale + control.safeAreaRight
                    sourceComponent: control.fab
                    visible: control.fab !== null
                }
            }

            // Bottom Navigation Bar (Compact only)
            MeoNavigationBar {
                id: bottomNavBar
                width: parent.width
                model: control.compactNavigationModel
                currentIndex: control.currentIndex
                visible: control.isCompact
                onClicked: (index) => { control.currentIndex = index }
            }

            // Safe Area Bottom Spacer for BottomNav
            Item {
                width: parent.width
                height: control.safeAreaBottom
                visible: control.isCompact
            }
        }
    }

    MeoSidebarModal {
        id: modalSidebar
        groups: control.effectiveSidebarGroups
        title: control.sidebarTitle
        searchPlaceholder: control.searchPlaceholder
        searchResults: control.effectiveSearchResults
        searchText: control.searchText
        footer: control.sidebarFooter
        selectedRoute: control.selectedRoute
        onSearchTextChanged: control.searchText = searchText
        onRouteActivated: (route, row) => {
            control.currentRoute = route
            const index = control.indexForRoute(route)
            if (index >= 0)
                control.currentIndex = index
        }
    }

    property int lastIndex: 0

    onCurrentIndexChanged: {
        const current = navigationModel[currentIndex]
        if (current)
            currentRoute = String(current.route || current.id || "")
        let isForward = currentIndex >= lastIndex;
        lastIndex = currentIndex;
        pageLoader.slideDistance = isForward ? (40 * control.themeGlobalScale) : (-40 * control.themeGlobalScale);
        pageEntrance.restart();
    }

    Component.onCompleted: {
        if (!currentRoute && navigationModel[currentIndex])
            currentRoute = String(navigationModel[currentIndex].route || navigationModel[currentIndex].id || "")
    }

    onNavigationModelChanged: {
        const index = indexForRoute(currentRoute)
        if (index >= 0)
            currentIndex = index
    }

    onCurrentRouteChanged: {
        const nextIndex = indexForRoute(currentRoute)
        if (nextIndex >= 0 && nextIndex !== currentIndex)
            currentIndex = nextIndex
    }

    ParallelAnimation {
        id: pageEntrance
        NumberAnimation {
            target: pageLoader
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSpatialDefault
            easing.type: Easing.BezierSpline; easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
        }
        NumberAnimation {
            target: pageLoader
            property: "scale"
            from: (typeof MeoTheme !== 'undefined' && MeoTheme.reduceMotion) ? 1.0 : 0.96
            to: 1.0
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSpatialSlow
            easing.type: Easing.BezierSpline; easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSpringBouncy !== 'undefined') ? MeoTheme.motionEasingSpringBouncy : [0.34, 1.35, 0.64, 1.0]
        }
        NumberAnimation {
            target: pageLoader
            property: "x"
            from: (typeof MeoTheme !== 'undefined' && MeoTheme.reduceMotion) ? 0 : pageLoader.slideDistance
            to: 0
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSpatialSlow
            easing.type: Easing.BezierSpline; easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.05, 0.7, 0.1, 1]
        }
    }
}
