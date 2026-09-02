import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 240
    height: 100

    Components.MeoAvatar {
        id: initialsAvatar
        initials: "me"
        size: 40
    }

    Components.MeoAvatar {
        id: iconAvatar
        x: 80
        size: 56
        variant: "diamond"
    }

    TestCase {
        name: "MeoAvatar"
        when: windowShown

        function test_measuredSizeIsAppliedToTheRootItem() {
            compare(Math.round(initialsAvatar.width), Math.round(40 * initialsAvatar.themeGlobalScale))
            compare(Math.round(initialsAvatar.height), Math.round(40 * initialsAvatar.themeGlobalScale))
            compare(Math.round(iconAvatar.width), Math.round(56 * iconAvatar.themeGlobalScale))
        }

        function test_initialsAndIconFallbackAreExposed() {
            verify(findChild(initialsAvatar, "meoAvatarInitials") !== null)
            verify(findChild(iconAvatar, "meoAvatarFallbackIcon") !== null)
            verify(initialsAvatar.Accessible.name.indexOf("ME") >= 0)
            compare(initialsAvatar.color, MeoTheme.primaryContainer)
            compare(initialsAvatar.textColor, MeoTheme.contentOnPrimaryContainer)
        }
    }
}
