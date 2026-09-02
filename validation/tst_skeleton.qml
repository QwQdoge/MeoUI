import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 420
    height: 180

    Components.MeoSkeleton {
        id: avatarSkeleton
        type: "avatar"
    }

    Components.MeoSkeleton {
        id: cardSkeleton
        x: 64
        type: "card"
        active: false
    }

    TestCase {
        name: "MeoSkeleton"
        when: windowShown

        function test_typeDefaultsHaveMeasuredGeometry() {
            compare(Math.round(avatarSkeleton.width), Math.round(40 * avatarSkeleton.themeGlobalScale))
            compare(Math.round(avatarSkeleton.height), Math.round(40 * avatarSkeleton.themeGlobalScale))
            compare(Math.round(cardSkeleton.width), Math.round(240 * cardSkeleton.themeGlobalScale))
            compare(Math.round(cardSkeleton.height), Math.round(144 * cardSkeleton.themeGlobalScale))
        }

        function test_activeControlsAnimationAndSurfaceIsExposed() {
            verify(avatarSkeleton.animationActive === (avatarSkeleton.active && avatarSkeleton.animate
                                                       && avatarSkeleton.visible
                                                       && avatarSkeleton.width > 0
                                                       && avatarSkeleton.height > 0
                                                       && !MeoTheme.reduceMotion))
            verify(!cardSkeleton.animationActive)
            verify(findChild(avatarSkeleton, "meoSkeletonSurface") !== null)
            compare(cardSkeleton.Accessible.name, "Loading placeholder")
        }

        function test_visualRolesResolveFromTheme() {
            compare(avatarSkeleton.themeSurfaceVariant, MeoTheme.surfaceVariant)
            compare(avatarSkeleton.themeOnSurface, MeoTheme.contentOnSurface)
        }
    }
}
