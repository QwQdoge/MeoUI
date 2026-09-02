import QtQuick
import QtTest
import MeoUI 1.0
import "../components" as Components

Item {
    id: root
    width: 640
    height: 480
    readonly property var defaultMenuModel: [
        { "label": "Copy", "icon": "content_copy" },
        { "type": "separator" },
        { "label": "More", "icon": "more_horiz", "selected": true, "subItems": [{ "label": "Inspect" }] },
        { "label": "Paste", "icon": "content_paste", "enabled": false }
    ]

    Item {
        id: menuHost
        x: 72
        y: 36
        width: parent.width - x
        height: parent.height - y

        Components.MeoMenu {
            id: menu
            parent: menuHost
            x: 20
            y: 20
            itemSpacing: 4
            model: root.defaultMenuModel
        }
    }

    SignalSpy {
        id: submenuSpy
        target: menu
        signalName: "submenuRequested"
    }

    ListModel {
        id: listMenuModel
        ListElement { label: "Archive"; icon: "archive" }
        ListElement { label: "Unavailable"; enabled: false }
    }

    ListModel {
        id: listSubmenuModel
        ListElement { label: "Document" }
        ListElement { label: "Image" }
    }

    TestCase {
        name: "MeoMenu"
        when: windowShown

        function init() {
            menu.closeSubmenu()
            menu.close()
            menu.model = root.defaultMenuModel
            menu.currentIndex = -1
            submenuSpy.clear()
        }

        function test_modelHelpersAndKeyboardTraversal() {
            compare(menu.itemLabel(menu.model[0]), "Copy")
            verify(menu.itemEnabled(menu.model[0]))
            verify(!menu.itemEnabled(menu.model[3]))
            verify(menu.itemHasSubmenu(menu.model[2]))

            verify(menu.focusMenuItem(-1, 1))
            compare(menu.currentIndex, 0)
            verify(menu.focusMenuItem(menu.currentIndex, 1))
            compare(menu.currentIndex, 2)
            verify(menu.focusMenuItem(menu.currentIndex, 1))
            compare(menu.currentIndex, 0)
            verify(menu.menuItemAt(0) !== null)
        }

        function test_selectedAndSubmenuRowContracts() {
            menu.open()
            wait(220)
            verify(menu.model[2].selected)
            verify(menu.activateItem(2, null))
            compare(submenuSpy.count, 1)
            verify(menu.visible)
            wait(220)
            verify(menu.submenuOpened)
            compare(menu.itemShortcut({ "shortcut": "Ctrl+P" }), "Ctrl+P")
            compare(menu.itemSupportingText({ "supportingText": "Available offline" }), "Available offline")
            verify(menu.itemIsSelected({ "checked": true }))
            verify(!menu.activateItem(1, null))
            verify(!menu.activateItem(3, null))
            menu.closeSubmenu()
            wait(220)
            menu.close()
            wait(220)
        }

        function test_listModelSupportsSizingActivationAndSubmenus() {
            menu.model = listMenuModel
            compare(menu.modelCount(menu.model), 2)
            compare(menu.itemLabel(menu.modelItem(menu.model, 0)), "Archive")
            verify(menu.menuContentHeight(menu.model) > menu.menuPadding * 2)
            verify(menu.activateItem(0, null))
            verify(!menu.activateItem(1, null))
            verify(menu.itemHasSubmenu({ "subItems": listSubmenuModel }))
            menu.model = [
                { "label": "More", "subItems": listSubmenuModel }
            ]
            menu.open()
            wait(220)
            verify(menu.activateItem(0, menu.menuItemAt(0)))
            wait(220)
            verify(menu.submenuOpened)
            compare(menu.submenu.currentIndex, 0)
            verify(menu.submenu.activateItem(0, menu.submenu.menuItemAt(0)))
            wait(220)
        }

        function test_submenuPlacementUsesItsParentCoordinateSpace() {
            menu.open()
            wait(220)
            const anchor = menu.menuItemAt(2)
            verify(anchor !== null)
            verify(menu.openSubmenu(2, menu.model[2], anchor))
            wait(220)
            const globalPoint = anchor.mapToGlobal(0, 0)
            const anchorInSubmenuParent = menu.submenu.parent.mapFromGlobal(globalPoint.x, globalPoint.y)
            const preferredX = anchorInSubmenuParent.x + anchor.width + 4 * menu.themeGlobalScale
            const maximumX = Math.max(menu.submenu.viewportMargin,
                                      menu.submenu.parent.width - menu.submenu.width - menu.submenu.viewportMargin)
            const preferredY = anchorInSubmenuParent.y
            const maximumY = Math.max(menu.submenu.viewportMargin,
                                      menu.submenu.parent.height - menu.submenu.height - menu.submenu.viewportMargin)
            compare(Math.round(menu.submenu.x), Math.round(Math.max(menu.submenu.viewportMargin,
                                                                     Math.min(preferredX, maximumX))))
            compare(Math.round(menu.submenu.y), Math.round(Math.max(menu.submenu.viewportMargin,
                                                                     Math.min(preferredY, maximumY))))
            menu.closeSubmenu()
            menu.close()
        }

        function test_vibrantColorRoles() {
            const selected = { "label": "Selected", "selected": true }
            const unselected = { "label": "Unselected" }

            compare(menu.themeSurfaceContainerLow, MeoTheme.surfaceContainerLow)
            compare(menu.rowContainerColor(selected), MeoTheme.tertiaryContainer)
            compare(menu.rowContentColor(selected), MeoTheme.contentOnTertiaryContainer)
            compare(menu.rowIconColor(unselected), MeoTheme.contentOnSurfaceVariant)
            compare(menu.rowSupportingContentColor(unselected), MeoTheme.contentOnSurfaceVariant)

            menu.vibrant = true
            compare(menu.rowContainerColor(selected), MeoTheme.tertiary)
            compare(menu.rowContentColor(selected), MeoTheme.contentOnTertiary)
            compare(menu.rowContentColor(unselected), MeoTheme.contentOnTertiaryContainer)
            compare(menu.rowSupportingContentColor(unselected), MeoTheme.contentOnTertiaryContainer)
            menu.vibrant = false
        }
    }
}
