import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 520
    height: 240

    Components.MeoBanner {
        id: banner
        width: 460
        title: "Storage almost full"
        text: "Free space before creating a backup."
        icon: "error"
        tone: "error"
        confirmText: "Manage"
        cancelText: "Dismiss"
    }

    TestCase {
        name: "MeoBanner"
        when: windowShown

        function test_semanticToneAndActions() {
            compare(banner.containerColor, MeoTheme.errorContainer)
            compare(banner.contentColor, MeoTheme.contentOnErrorContainer)
            verify(findChild(banner, "meoBannerConfirm") !== null)
            verify(findChild(banner, "meoBannerCancel") !== null)
            verify(banner.implicitHeight >= 64 * MeoTheme.globalScale)
        }

        function test_toneChangesResolveThroughTheme() {
            banner.tone = "success"
            compare(banner.containerColor, MeoTheme.successContainer)
            compare(banner.contentColor, MeoTheme.contentOnSuccessContainer)
            banner.tone = "tonal"
            compare(banner.containerColor, MeoTheme.secondaryContainer)
            compare(banner.contentColor, MeoTheme.contentOnSecondaryContainer)
        }
    }
}
