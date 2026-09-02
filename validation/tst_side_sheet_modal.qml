import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoSideSheetModal {
        id: sideSheet
        title: "Details"
        dismissible: false
    }

    TestCase {
        name: "MeoSideSheetModal"
        when: windowShown

        function test_modalUsesSharedThemeAndExplicitDismissPolicy() {
            compare(sideSheet.themeSurfaceContainerLow, MeoTheme.surfaceContainerLow)
            compare(sideSheet.themeOnSurface, MeoTheme.contentOnSurface)
            verify(!sideSheet.dismissible)
            compare(sideSheet.presentation, sideSheet.SideSheet)
        }
    }
}
