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
    // Kept only for applications that explicitly preserve a legacy drawer.
    // New layouts use the expanded navigation rail at every wide breakpoint.
    property bool useLegacyDrawer: false

    // 🌟 Safe Area Insets (Edge-to-Edge support)
    property real safeAreaTop: 0
    property real safeAreaBottom: 0
    property real safeAreaLeft: 0
    property real safeAreaRight: 0

    // 🌟 Branding & Actions
    property Component accountHeader: null
    property Component fab: null

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property bool isCompact: windowMetrics.isCompactWidth
    readonly property bool isMedium: windowMetrics.isMediumWidth
    readonly property bool isExpanded: windowMetrics.isExpandedWidth
    readonly property bool isLarge: windowMetrics.isLargeWidth || windowMetrics.isExtraLargeWidth
    readonly property string windowSizeClass: windowMetrics.widthSizeClass
    readonly property real expandedRailWidth: 280 * themeGlobalScale
    readonly property bool usesExpandedRail: !useLegacyDrawer && (isExpanded || isLarge)
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

        // 1. Collapsed rail on medium; expanded rail on all wider layouts.
        MeoNavigationRail {
            id: navRail
            width: control.isMedium ? 96 * control.themeGlobalScale
                                    : control.usesExpandedRail ? control.expandedRailWidth : 0
            height: parent.height
            model: control.navigationModel
            currentIndex: control.currentIndex
            visible: width > 0
            enabled: control.isMedium || control.usesExpandedRail
            opacity: control.isMedium || control.usesExpandedRail ? 1 : 0
            isExpanded: control.usesExpandedRail
            expandedWidth: control.expandedRailWidth
            resizeInstantly: control.windowResizeActive
            header: control.accountHeader ? accountHeaderWrapper : null
            onClicked: (index) => { control.currentIndex = index }

            Behavior on width { NumberAnimation { duration: control.windowResizeActive || MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate } }
            Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }

            Component {
                id: accountHeaderWrapper
                Loader { sourceComponent: control.accountHeader }
            }
        }

        // 2. Legacy drawer compatibility; it is never selected by default.
        MeoNavigationDrawer {
            id: navDrawer
            width: control.useLegacyDrawer && control.isLarge ? 280 * control.themeGlobalScale : 0
            height: parent.height
            model: control.navigationModel
            currentIndex: control.currentIndex
            visible: width > 0
            enabled: control.useLegacyDrawer && control.isLarge
            opacity: control.useLegacyDrawer && control.isLarge ? 1 : 0
            header: control.accountHeader
            onClicked: (index) => { control.currentIndex = index }

            Behavior on width { NumberAnimation { duration: control.windowResizeActive || MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate } }
            Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }
        }

        // 3. Main Content Area
        Column {
            width: parent.width - (navRail.visible ? navRail.width : 0) - (navDrawer.visible ? navDrawer.width : 0)
            height: parent.height

            Behavior on width { NumberAnimation { duration: control.windowResizeActive || MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate } }

            // Top App Bar (Compact only, with Hamburger)
            MeoTopAppBar {
                id: topAppBar
                width: parent.width
                title: control.navigationModel[control.currentIndex] ? control.navigationModel[control.currentIndex].label : "App"
                type: "small"
                visible: control.isCompact

                // Add top padding for notch
                Item { height: control.safeAreaTop; width: parent.width }

                // Add a navigation icon for the hamburger menu
                navigationIcon: Component {
                    MeoIconButton {
                        icon.name: "menu"
                        onClicked: modalDrawer.open()
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

    // Modal Navigation Drawer (Compact only, triggered by hamburger)
    MeoNavigationDrawerModal {
        id: modalDrawer
        model: control.navigationModel
        currentIndex: control.currentIndex
        header: control.accountHeader
        onClicked: (index) => {
            control.currentIndex = index
            modalDrawer.close()
        }
    }

    property int lastIndex: 0

    onCurrentIndexChanged: {
        let isForward = currentIndex >= lastIndex;
        lastIndex = currentIndex;
        pageLoader.slideDistance = isForward ? (40 * control.themeGlobalScale) : (-40 * control.themeGlobalScale);
        pageEntrance.restart();
    }

    ParallelAnimation {
        id: pageEntrance
        NumberAnimation {
            target: pageLoader
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationSpatialDefault !== 'undefined') ? MeoTheme.motionDurationSpatialDefault : 240
            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
        }
        NumberAnimation {
            target: pageLoader
            property: "scale"
            from: (typeof MeoTheme !== 'undefined' && MeoTheme.reduceMotion) ? 1.0 : 0.96
            to: 1.0
            duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationSpatialSlow !== 'undefined') ? MeoTheme.motionDurationSpatialSlow : 320
            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSpringBouncy !== 'undefined') ? MeoTheme.motionEasingSpringBouncy : [0.34, 1.35, 0.64, 1.0]
        }
        NumberAnimation {
            target: pageLoader
            property: "x"
            from: (typeof MeoTheme !== 'undefined' && MeoTheme.reduceMotion) ? 0 : pageLoader.slideDistance
            to: 0
            duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationSpatialSlow !== 'undefined') ? MeoTheme.motionDurationSpatialSlow : 320
            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.05, 0.7, 0.1, 1]
        }
    }
}
