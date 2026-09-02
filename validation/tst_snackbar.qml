import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    id: root
    width: 640
    height: 420

    Components.MeoSnackbar {
        id: snackbar
        parent: root
        message: "Message sent"
        duration: 1000
    }

    TestCase {
        id: testCase
        name: "MeoSnackbar"
        when: windowShown

        function init() {
            snackbar.close()
            snackbar.actionText = ""
        }

        function test_tokenRolesAndShape() {
            compare(snackbar.themeInverseSurface, MeoTheme.inverseSurface)
            compare(snackbar.themeInverseOnSurface, MeoTheme.contentOnInverseSurface)
            compare(snackbar.themeInversePrimary, MeoTheme.inversePrimary)
            compare(snackbar.background.radius, MeoTheme.shapeExtraSmall)
        }

        function test_onlyActionlessSnackbarStartsTimeout() {
            const timer = findChild(snackbar, "meoSnackbarAutoCloseTimer")
            verify(timer !== null)
            snackbar.actionText = ""
            snackbar.open()
            tryVerify(function() { return snackbar.opened }, 500)
            verify(timer.running)
            snackbar.close()

            snackbar.actionText = "Undo"
            snackbar.open()
            tryVerify(function() { return snackbar.opened }, 500)
            verify(!timer.running)
        }
    }
}
