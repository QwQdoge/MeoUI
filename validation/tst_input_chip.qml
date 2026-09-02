import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoInputChip { id: inputChip; label: "Avery"; leadingIcon: "person" }

    TestCase {
        name: "MeoInputChip"
        when: windowShown

        function test_inputDefaultsRemainClosable() {
            compare(inputChip.type, "input")
            verify(inputChip.closable)
            compare(inputChip.visualStyle, "outlined")
            compare(inputChip.chipHeight, 32 * inputChip.themeGlobalScale)
            verify(findChild(inputChip, "meoChipCloseButton") !== null)
            compare(inputChip.Accessible.name, "Avery")
        }

        function test_inputLeadingIconUsesInputTokenRoles() {
            compare(inputChip.leadingIconColor, inputChip.themeOnSurfaceVariant)
            inputChip.selected = true
            compare(inputChip.leadingIconColor, inputChip.themePrimary)
            inputChip.selected = false
        }

        function test_initialsAvatarSuppressesLeadingIcon() {
            inputChip.avatarInitials = "AV"
            verify(inputChip.hasAvatar)
            inputChip.avatarInitials = ""
        }
    }
}
