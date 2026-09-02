import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 320
    height: 80

    Components.MeoChip {
        id: closableChip
        label: "Avery"
        closable: true
    }

    Components.MeoChip {
        id: filterChip
        x: 140
        type: "filter"
        label: "Design"
    }

    SignalSpy {
        id: deletedSpy
        target: closableChip
        signalName: "deleted"
    }

    TestCase {
        name: "MeoChip"
        when: windowShown

        function test_closeTargetAndFilterSelectionAreAvailable() {
            verify(findChild(closableChip, "meoChipCloseButton") !== null)
            const closeTarget = findChild(closableChip, "meoChipCloseTarget")
            verify(closeTarget !== null)
            compare(closeTarget.width, 48 * closableChip.themeGlobalScale)
            compare(closeTarget.height, 48 * closableChip.themeGlobalScale)
            filterChip.activate()
            verify(filterChip.selected)
            filterChip.activate()
            verify(!filterChip.selected)
        }

        function test_disabledChipDoesNotActivate() {
            filterChip.enabled = false
            filterChip.activate()
            verify(!filterChip.selected)
            filterChip.enabled = true
        }

        function test_defaultGeometryAndInitialsAvatarAreAvailable() {
            compare(closableChip.chipHeight, 32 * closableChip.themeGlobalScale)
            compare(closableChip.chipRadius, 8 * closableChip.themeGlobalScale)
            closableChip.avatarSource = ""
            closableChip.avatarInitials = "AV"
            verify(closableChip.hasAvatar)
            closableChip.avatarInitials = ""
        }
    }
}
