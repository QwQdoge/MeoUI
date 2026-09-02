import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    Widgets.MeoAccountSwitcher {
        id: switcher
        model: [
            { "name": "One", "email": "one@example.test" },
            { "name": "Two", "email": "two@example.test" }
        ]
    }

    TestCase {
        name: "MeoAccountSwitcher"
        when: windowShown

        function test_externalIndexIsNormalized() {
            switcher.currentIndex = 9
            compare(switcher.currentIndex, 1)
            compare(switcher.currentAccount.name, "Two")
            switcher.currentIndex = -2
            compare(switcher.currentIndex, 0)
        }

        function test_selectAccountRespectsEnabledState() {
            var selected = -1
            switcher.accountSelected.connect(function(index) { selected = index })
            switcher.selectAccount(1)
            compare(selected, 1)
            switcher.enabled = false
            switcher.selectAccount(0)
            compare(selected, 1)
            switcher.enabled = true
        }

        function test_initialsAreBoundedForMultiwordNames() {
            compare(switcher.initialsFor({ "name": "Design Review" }), "DR")
            compare(switcher.initialsFor({ "name": "Meo" }), "Me")
            compare(switcher.initialsFor({ "name": "Preview", "initials": "PV" }), "PV")
        }
    }
}
