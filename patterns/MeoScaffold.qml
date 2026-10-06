import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control
    anchors.fill: parent

    // 🌟 核心对外接口 (Slots)
    property Component topBar: null
    property Component bottomBar: null
    property Component navigationBar: null
    property Component navigationRail: null
    property var sidebarGroups: []
    property string sidebarTitle: qsTr("Navigation")
    property string selectedRoute: ""
    property var searchResults: null
    property string searchText: ""
    property Component sidebarFooter: null
    property Component sideSheet: null
    property bool sideSheetOpen: false
    property Component fab: null
    property Component content: null
    property Component snackbar: null

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property bool isCompact: windowMetrics.isCompactWidth
    readonly property bool isMedium: windowMetrics.isMediumWidth
    readonly property bool isExpanded: windowMetrics.isExpandedWidth || windowMetrics.isLargeWidth || windowMetrics.isExtraLargeWidth

    signal routeActivated(string route, var row)

    function openSidebar() { sidebarModal.openForNavigation() }

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.width
        availableHeight: control.height
    }

    // Layout Logic
    Row {
        anchors.fill: parent

        // The icon rail is a compact navigation mode. Full sidebars use
        // MeoSidebar at wide sizes and MeoSidebarModal when opened on demand.
        Loader {
            id: railLoader
            height: parent.height
            sourceComponent: control.navigationRail
            visible: (control.isCompact || control.isMedium) && control.navigationRail !== null
            onLoaded: {
                if (item && "isExpanded" in item)
                    item.isExpanded = false
                if (item && "labelType" in item)
                    item.labelType = "none"
            }
        }

        MeoSidebar {
            id: sidebar
            width: control.isExpanded ? MeoTheme.settingsSidebarWidth : 0
            height: parent.height
            visible: width > 0
            groups: control.sidebarGroups
            title: control.sidebarTitle
            selectedRoute: control.selectedRoute
            searchResults: control.searchResults
            searchText: control.searchText
            footer: control.sidebarFooter
            onSearchTextChanged: control.searchText = searchText
            onRouteActivated: (route, row) => control.routeActivated(route, row)
        }

        // 3. Main Body Column
        Column {
            width: parent.width - (railLoader.visible ? railLoader.width : 0) - (sidebar.visible ? sidebar.width : 0)
            height: parent.height

            // Top Bar Slot
            Loader {
                id: topBarLoader
                width: parent.width
                sourceComponent: control.topBar
                visible: control.topBar !== null
            }

            // Content Area
            Item {
                width: parent.width
                height: parent.height - (topBarLoader.visible ? topBarLoader.height : 0) - (bottomBarLoader.visible ? bottomBarLoader.height : 0) - (navBarLoader.visible ? navBarLoader.height : 0)

                Row {
                    anchors.fill: parent

                    Loader {
                        id: contentLoader
                        width: parent.width - (sideSheetLoader.visible ? sideSheetLoader.width : 0)
                        height: parent.height
                        sourceComponent: control.content
                    }

                    Loader {
                        id: sideSheetLoader
                        height: parent.height
                        sourceComponent: control.sideSheet
                        visible: control.sideSheetOpen && control.sideSheet !== null
                    }
                }

                // FAB Slot (MD3: Floating above content, usually bottom-right)
                Loader {
                    id: fabLoader
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 16 * control.themeGlobalScale
                    sourceComponent: control.fab
                    visible: control.fab !== null
                }
            }

            // Bottom Bar Slot (MD3: Bottom App Bar)
            Loader {
                id: bottomBarLoader
                width: parent.width
                sourceComponent: control.bottomBar
                visible: control.isCompact && control.bottomBar !== null
            }

            // Navigation Bar Slot (MD3: Mobile bottom nav)
            Loader {
                id: navBarLoader
                width: parent.width
                sourceComponent: control.navigationBar
                visible: control.isCompact && control.navigationBar !== null
            }
        }
    }

    MeoSidebarModal {
        id: sidebarModal
        groups: control.sidebarGroups
        title: control.sidebarTitle
        selectedRoute: control.selectedRoute
        searchResults: control.searchResults
        searchText: control.searchText
        footer: control.sidebarFooter
        onSearchTextChanged: control.searchText = searchText
        onRouteActivated: (route, row) => control.routeActivated(route, row)
    }

    // 4. Snackbar Layer (MD3: Floating above everything, usually bottom-center)
    Loader {
        id: snackbarLoader
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (navBarLoader.visible ? navBarLoader.height : (bottomBarLoader.visible ? bottomBarLoader.height : 0)) + 16 * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: control.snackbar
        visible: control.snackbar !== null
    }

    // The caller can invoke openSidebar() from its compact navigation action.
}
