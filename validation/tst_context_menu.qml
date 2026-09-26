import QtQuick
import QtTest
import MeoUI 1.0
import "../components" as Components

Item {
    id: root
    width: 640
    height: 480

    Item {
        id: host
        x: 48
        y: 40
        width: parent.width - x
        height: parent.height - y

        Rectangle {
            id: target
            x: 72
            y: 56
            width: 160
            height: 96
        }

        Components.MeoContextMenu {
            id: contextMenu
            parent: host
            model: [{ "label": "Add widget", "icon": "widgets" }]
        }
    }

    TestCase {
        name: "MeoContextMenu"
        when: windowShown

        function init() {
            contextMenu.close()
            contextMenu.currentIndex = -1
        }

        function test_contextSurfaceUsesSharedMenuContract() {
            compare(contextMenu.surfaceStyle, "context")
            verify(contextMenu.isContextMenu)
            compare(contextMenu.surfaceCornerRadius, MeoTheme.shapeLargeIncreased)
            compare(contextMenu.surfaceColor, MeoTheme.surfaceContainer)
            compare(contextMenu.itemSpacing, MeoTheme.space4)
            compare(contextMenu.menuPadding, MeoTheme.space4)
            compare(contextMenu.itemHeight, 52 * MeoTheme.globalScale)
            compare(contextMenu.supportingItemHeight, 68 * MeoTheme.globalScale)
            compare(contextMenu.separatorHeight, 4 * MeoTheme.globalScale)
            compare(contextMenu.preferredMenuWidth, 256 * MeoTheme.globalScale)
            compare(contextMenu.rowContainerColor({ "label": "Open" }),
                    MeoTheme.surfaceContainerHigh)
            compare(contextMenu.itemCornerRadius, MeoTheme.shapeLarge)
            verify(contextMenu.itemIsSelectable(contextMenu.model[0]))
        }

        function test_openAtPointMapsTargetCoordinatesToMenuParent() {
            verify(contextMenu.openAtPoint(target, 24, 20))
            tryCompare(contextMenu, "opened", true, contextMenu.enterDuration + 250)
            // Qt moves open Popups into the window overlay. Compare in the
            // popup's current parent coordinate system rather than the
            // declarative host that owned it before opening.
            const expected = target.mapToItem(contextMenu.parent, 24, 20)
            verify(Math.abs(contextMenu.x - expected.x) <= 1)
            verify(Math.abs(contextMenu.y - expected.y) <= 1)
            contextMenu.close()
        }

        function test_openAtPointRejectsMissingAnchor() {
            verify(!contextMenu.openAtPoint(null, 0, 0))
        }
    }
}
