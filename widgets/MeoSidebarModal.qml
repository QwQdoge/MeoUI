import QtQuick
import QtQuick.Controls
import MeoUI

// Leading-edge modal presentation of the same search-first route sidebar used
// by persistent application layouts.
MeoMotionPopup {
    id: control
    presentation: MeoMotionPopup.SideSheet
    parent: Overlay.overlay

    property var groups: []
    property string selectedRoute: ""
    property string searchText: ""
    property var searchResults: null
    property Component footer: null
    property string title: qsTr("Navigation")
    property string searchPlaceholder: qsTr("Search navigation")
    property bool showTitle: true
    property real sidebarWidth: MeoTheme.settingsSidebarWidth

    signal routeActivated(string route, var row)

    x: 0
    y: 0
    width: parent ? Math.min(parent.width, sidebarWidth) : sidebarWidth
    height: parent ? parent.height : 600 * MeoTheme.globalScale
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    surfaceRadius: MeoTheme.shapeLarge
    surfaceColor: MeoTheme.surfaceContainerLow

    enter: Transition {
        NumberAnimation {
            property: "x"
            from: MeoTheme.reduceMotion ? 0 : -control.width
            to: 0
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSheetEnter
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEnter
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "x"
            from: 0
            to: MeoTheme.reduceMotion ? 0 : -control.width
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSheetExit
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingExit
        }
    }

    function openForNavigation() {
        open()
        Qt.callLater(function() {
            if (sidebarLoader.item)
                sidebarLoader.item.focusSearch()
        })
    }

    contentItem: Item {
        Accessible.role: Accessible.Dialog
        Accessible.name: control.title

        Loader {
            id: sidebarLoader
            anchors.fill: parent
            sourceComponent: Component {
                MeoSidebar {
                    anchors.fill: parent
                    title: control.title
                    searchPlaceholder: control.searchPlaceholder
                    showTitle: control.showTitle
                    groups: control.groups
                    selectedRoute: control.selectedRoute
                    searchText: control.searchText
                    searchResults: control.searchResults
                    footer: control.footer
                    onSearchTextChanged: control.searchText = searchText
                    onRouteActivated: (route, row) => {
                        control.routeActivated(route, row)
                        control.close()
                    }
                }
            }
        }
    }
}
