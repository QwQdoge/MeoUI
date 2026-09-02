import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    width: 800
    height: 600

    Widgets.MeoSideSheet {
        id: sideSheet
        parent: parent
        title: "Details"
    }

    TestCase {
        name: "MeoSideSheet"
        when: windowShown

        function test_persistentSheetUsesSharedThemeAndClosedOffset() {
            compare(sideSheet.themeSurfaceContainerLow, MeoTheme.surfaceContainerLow)
            compare(sideSheet.themeOnSurface, MeoTheme.contentOnSurface)
            compare(sideSheet.x, sideSheet.parent.width)
            sideSheet.isOpen = true
            compare(sideSheet.x, sideSheet.parent.width - sideSheet.width)
            sideSheet.isOpen = false
        }
    }
}
