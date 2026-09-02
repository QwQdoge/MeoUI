import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 640
    height: 180

    MeoSettingsAccountCard {
        id: card
        width: 420
        title: "Meo User"
        subtitle: "Local session"
        initials: "MU"
    }

    TestCase {
        name: "MeoSettingsAccountCard"
        when: windowShown

        function test_geometryAndAccessibleMetadata() {
            compare(card.implicitHeight, 92 * MeoTheme.globalScale)
            compare(card.Accessible.name, "Meo User")
            compare(card.Accessible.description, "Local session")
        }

        function test_readOnlyCardDoesNotActivate() {
            var activations = 0
            card.clicked.connect(function() { activations += 1 })
            card.interactive = false
            card.activate()
            compare(activations, 0)
            card.interactive = true
            card.activate()
            compare(activations, 1)
        }
    }
}
