import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoAccountHeader {
        id: accountHeader
        name: "Meo User"
        email: "hello@meoarch.dev"
    }

    TestCase {
        name: "MeoAccountHeader"
        when: windowShown

        function test_activationRespectsInteractiveAndEnabled() {
            var activations = 0
            accountHeader.clicked.connect(function() { ++activations })
            accountHeader.activate()
            compare(activations, 1)
            accountHeader.interactive = false
            accountHeader.activate()
            compare(activations, 1)
            accountHeader.interactive = true
            accountHeader.enabled = false
            accountHeader.activate()
            compare(activations, 1)
            accountHeader.enabled = true
        }

        function test_intrinsicWidthIsIndependentOfParent() {
            compare(accountHeader.implicitWidth, 360 * MeoTheme.globalScale)
        }
    }
}
