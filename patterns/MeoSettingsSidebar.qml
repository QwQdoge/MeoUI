import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

// A reusable desktop Settings index: search stays visible, related routes are
// grouped as connected rows, and the selected route remains obvious while the
// detail page changes independently beside it.
Rectangle {
    id: control

    property string title: qsTr("Settings")
    property string searchPlaceholder: qsTr("Search settings")
    property alias searchText: searchField.text
    property var groups: []
    property var searchResults: []
    property string selectedRoute: ""
    property Component footer: null
    property bool showTitle: true

    signal routeActivated(string route, var row)

    readonly property bool searching: searchText.trim().length > 0
    readonly property real contentInset: MeoTheme.space16

    function selectedIndexFor(rows) {
        if (!rows)
            return -1
        for (let index = 0; index < rows.length; ++index) {
            if (String(rows[index].route || "") === selectedRoute)
                return index
        }
        return -1
    }

    function activateRow(row) {
        if (!row || row.enabled === false || !row.route)
            return
        routeActivated(String(row.route), row)
    }

    function ensureSelectedRouteVisible() {
        if (searching || !routeScroll.contentItem)
            return

        const flickable = routeScroll.contentItem
        for (let groupIndex = 0; groupIndex < groupsRepeater.count; ++groupIndex) {
            const group = groupsRepeater.itemAt(groupIndex)
            if (!group || group.selectedIndex < 0)
                continue

            const selectedLoader = group.itemAt(group.selectedIndex)
            if (!selectedLoader)
                return

            const position = selectedLoader.mapToItem(flickable, 0, 0)
            const inset = MeoTheme.space8
            const viewportTop = flickable.contentY
            const viewportBottom = viewportTop + flickable.height
            let target = viewportTop
            if (position.y < viewportTop + inset)
                target = position.y - inset
            else if (position.y + selectedLoader.height > viewportBottom - inset)
                target = position.y + selectedLoader.height - flickable.height + inset
            else
                return

            flickable.contentY = Math.max(0, Math.min(target,
                                                     Math.max(0, flickable.contentHeight - flickable.height)))
            return
        }
    }

    onSelectedRouteChanged: Qt.callLater(ensureSelectedRouteVisible)
    onGroupsChanged: Qt.callLater(ensureSelectedRouteVisible)
    onHeightChanged: Qt.callLater(ensureSelectedRouteVisible)

    implicitWidth: MeoTheme.settingsSidebarWidth
    implicitHeight: 720 * MeoTheme.globalScale
    color: MeoTheme.surfaceContainerLow

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: control.contentInset
        anchors.rightMargin: control.contentInset
        anchors.topMargin: MeoTheme.space16
        anchors.bottomMargin: MeoTheme.space12
        spacing: MeoTheme.space12

        MeoText {
            Layout.fillWidth: true
            visible: control.showTitle
            text: control.title
            typeRole: "title"
            typeSize: "large"
            emphasized: true
            color: MeoTheme.contentOnSurface
            leftPadding: MeoTheme.space8
            rightPadding: MeoTheme.space8
        }

        MeoSearchBar {
            id: searchField
            objectName: "meoSettingsSidebarSearch"
            Layout.fillWidth: true
            placeholder: control.searchPlaceholder
            trailingIcon: ""
            visualStyle: "settings"
            Accessible.name: control.searchPlaceholder
        }

        ScrollView {
            id: routeScroll
            objectName: "meoSettingsSidebarScroll"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: routeScroll.availableWidth
                spacing: MeoTheme.space16

                MeoSettingsGroup {
                    objectName: "meoSettingsSidebarSearchResults"
                    width: parent.width
                    visible: control.searching && control.searchResults.length > 0
                    title: qsTr("Results")
                    model: control.searchResults
                    selectedIndex: control.selectedIndexFor(model)
                    onRowActivated: (index, row) => control.activateRow(row)
                }

                MeoText {
                    width: parent.width
                    visible: control.searching && control.searchResults.length === 0
                    text: qsTr("No matching settings")
                    typeRole: "body"
                    typeSize: "medium"
                    color: MeoTheme.contentOnSurfaceVariant
                    horizontalAlignment: Text.AlignHCenter
                    topPadding: MeoTheme.space24
                    bottomPadding: MeoTheme.space24
                }

                Repeater {
                    id: groupsRepeater
                    model: control.searching ? [] : control.groups

                    delegate: MeoSettingsGroup {
                        required property int index
                        required property var modelData
                        objectName: "meoSettingsSidebarGroup_" + index
                        width: parent.width
                        title: modelData.title || ""
                        subtitle: modelData.subtitle || ""
                        model: modelData.rows || []
                        selectedIndex: control.selectedIndexFor(model)
                        onRowActivated: (rowIndex, row) => control.activateRow(row)
                        Component.onCompleted: Qt.callLater(control.ensureSelectedRouteVisible)
                    }
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            sourceComponent: control.footer
            visible: control.footer !== null
        }
    }
}
