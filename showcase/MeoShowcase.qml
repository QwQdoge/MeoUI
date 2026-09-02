import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

ApplicationWindow {
    id: window
    width: 1280 * MeoTheme.globalScale
    height: 800 * MeoTheme.globalScale
    minimumWidth: 360 * MeoTheme.globalScale
    minimumHeight: 480 * MeoTheme.globalScale
    visible: true
    title: "MeoUI MD3 Expressive Showcase"
    color: MeoTheme.background
    property string componentFilter: commandLineValue("--component=")

    function commandLineValue(prefix) {
        for (let index = 0; index < Qt.application.arguments.length; ++index) {
            const argument = Qt.application.arguments[index]
            if (argument.indexOf(prefix) === 0)
                return argument.substring(prefix.length)
        }
        return ""
    }

    readonly property int requestedPage: {
        const value = commandLineValue("--page=")
        return value === "" ? 0 : Math.max(0, Math.min(categories.length - 1, Number(value)))
    }

    // Resolve a validation filter before the first page is constructed.  This
    // prevents a transient Foundations frame from contaminating a component
    // screenshot while still leaving normal interactive navigation untouched.
    readonly property int initialPageIndex: {
        if (componentFilter === "")
            return requestedPage
        for (let pageIndex = 0; pageIndex < categories.length; ++pageIndex) {
            const categoryIds = categories[pageIndex].categoryIds || []
            for (let categoryIndex = 0; categoryIndex < categoryIds.length; ++categoryIndex) {
                const entries = catalog.categoryById(categoryIds[categoryIndex]).components
                for (let entryIndex = 0; entryIndex < entries.length; ++entryIndex) {
                    if (entries[entryIndex].name === componentFilter)
                        return pageIndex
                }
            }
        }
        return requestedPage
    }
    ShowcaseCatalog {
        id: catalog
    }
    Component.onCompleted: {
        for (let index = 0; index < Qt.application.arguments.length; ++index) {
            const argument = Qt.application.arguments[index]
            if (argument.indexOf("--width=") === 0)
                width = Math.max(minimumWidth, Number(argument.substring(8)))
            else if (argument.indexOf("--height=") === 0)
                height = Math.max(minimumHeight, Number(argument.substring(9)))
            else if (argument === "--dark")
                MeoTheme.isDarkMode = true
            else if (argument === "--light")
                MeoTheme.isDarkMode = false
        }
    }

    readonly property var categories: catalog.navigationGroups

    MeoAppLayout {
        id: appLayout
        anchors.fill: parent
        currentIndex: window.initialPageIndex
        navigationModel: window.categories
        compactNavigationLimit: 5
        safeAreaTop: 0
        safeAreaBottom: 0

        pages: [
            Component {
                ShowcaseCategoryPage {
                    categoryId: "foundations"
                    categoryIds: catalog.navigationGroupById("foundations").categoryIds
                    navigationTitle: catalog.navigationGroupById("foundations").label
                    navigationSubtitle: catalog.navigationGroupById("foundations").subtitle
                    componentFilter: window.componentFilter
                }
            },
            Component {
                ShowcaseCategoryPage {
                    categoryId: "actions"
                    categoryIds: catalog.navigationGroupById("controls").categoryIds
                    navigationTitle: catalog.navigationGroupById("controls").label
                    navigationSubtitle: catalog.navigationGroupById("controls").subtitle
                    componentFilter: window.componentFilter
                }
            },
            Component {
                ShowcaseCategoryPage {
                    categoryId: "navigation"
                    categoryIds: catalog.navigationGroupById("composites").categoryIds
                    navigationTitle: catalog.navigationGroupById("composites").label
                    navigationSubtitle: catalog.navigationGroupById("composites").subtitle
                    componentFilter: window.componentFilter
                }
            },
            Component {
                ShowcaseCategoryPage {
                    categoryId: "search"
                    categoryIds: catalog.navigationGroupById("features").categoryIds
                    navigationTitle: catalog.navigationGroupById("features").label
                    navigationSubtitle: catalog.navigationGroupById("features").subtitle
                    componentFilter: window.componentFilter
                }
            }
        ]
    }
}
