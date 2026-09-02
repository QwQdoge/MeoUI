import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property var model: []
    property int currentIndex: 0
    // Stable destination identity is additive for legacy callers and matches
    // the M3 Expressive rail replacement's selection contract.
    property string currentId: ""
    property bool isModal: false
    property string title: ""
    property Component header: null
    property Component footer: null
    property string visualStyle: "standard" // standard | settings

    signal clicked(int index)
    signal activated(var item, int index)

    // This is retained as a permanent-drawer compatibility surface. New M3
    // Expressive work should use MeoNavigationRail { isExpanded: true }.
    readonly property bool isDarkMode: MeoTheme.isDarkMode
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property real themeGlobalScale: MeoTheme.globalScale

    readonly property var fontTitleSmall: MeoTheme.titleSmall

    implicitWidth: visualStyle === "settings" ? MeoTheme.settingsSidebarWidth
                                               : 360 * themeGlobalScale
    width: implicitWidth
    height: parent ? parent.height : 600 * themeGlobalScale
    // AndroidX NavigationDrawerTokens use Surface for persistent/dismissible
    // drawers and SurfaceContainerLow only for modal sheets. `isModal` is a
    // compatibility API, so preserve it while making the default permanent
    // drawer match the source token.
    // Source: androidx-main NavigationDrawer.kt 8f8c02618f5d29d9ae6fb71c949ebe0a7290cd0a
    // and NavigationDrawerTokens.kt acff122169a9156381ab51e9a579eec8beff3b69
    // (Apache-2.0); mapped only through existing semantic MeoTheme roles.
    color: isModal ? themeSurfaceContainerLow : themeSurface

    function destinationAt(index) {
        if (!model || index < 0)
            return null
        const count = typeof model.count === "number" ? model.count
                                                   : (typeof model.length === "number" ? model.length : 0)
        if (index >= count)
            return null
        return typeof model.get === "function" ? model.get(index) : model[index]
    }

    function syncCurrentId() {
        const item = destinationAt(currentIndex)
        if (!item || item.type === "header" || item.id === undefined || item.id === null)
            return
        currentId = String(item.id)
    }

    onCurrentIndexChanged: syncCurrentId()
    onModelChanged: syncCurrentId()
    onCurrentIdChanged: {
        if (currentId === "")
            return
        const count = typeof model.count === "number" ? model.count
                                                   : (typeof model.length === "number" ? model.length : 0)
        for (let index = 0; index < count; ++index) {
            const item = destinationAt(index)
            if (item && item.type !== "header" && item.id !== undefined
                    && String(item.id) === currentId) {
                if (currentIndex !== index)
                    currentIndex = index
                return
            }
        }
    }

    // Drawer Content Layout
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.topMargin: 16 * control.themeGlobalScale
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.bottomMargin: 16 * control.themeGlobalScale
        spacing: 0

        Loader {
            Layout.fillWidth: true
            sourceComponent: control.header
            visible: control.header !== null
        }

        Text {
            text: control.title
            visible: text !== ""
            Layout.fillWidth: true
            leftPadding: 28 * control.themeGlobalScale
            rightPadding: 28 * control.themeGlobalScale
            topPadding: 12 * control.themeGlobalScale
            bottomPadding: 12 * control.themeGlobalScale
            font.pixelSize: fontTitleSmall.size * control.themeGlobalScale
            font.weight: fontTitleSmall.weight
            color: MeoTheme.contentOnSurfaceVariant
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: parent.width
                spacing: 0

                Repeater {
                    model: control.model
                    delegate: Loader {
                        width: parent.width
                        sourceComponent: modelData.type === "header" ? headerItemComp : itemComp

                        Component {
                            id: headerItemComp
                            MeoListHeader {
                                text: modelData.label
                                topPadding: 16 * control.themeGlobalScale
                                bottomPadding: 8 * control.themeGlobalScale
                            }
                        }

                        Component {
                            id: itemComp
                            MeoNavigationDrawerItem {
                                width: parent.width - (control.visualStyle === "settings"
                                                      ? MeoTheme.settingsSidebarHorizontalMargin * 2
                                                      : 24 * control.themeGlobalScale)
                                anchors.horizontalCenter: parent.horizontalCenter
                                label: modelData.label
                                icon: modelData.icon
                                badgeText: modelData.badgeText || ""
                                selected: control.currentIndex === index
                                visualStyle: control.visualStyle
                                onClicked: {
                                    control.currentIndex = index
                                    control.clicked(index)
                                    control.activated(control.destinationAt(index), index)
                                }
                            }
                        }
                    }
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            sourceComponent: control.footer
            visible: control.footer !== null
            Layout.bottomMargin: 16 * control.themeGlobalScale
        }
    }
}
