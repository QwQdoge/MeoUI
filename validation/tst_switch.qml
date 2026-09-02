import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 420
    height: 180

    Components.MeoSwitch {
        id: toggle
        label: "Enabled"
        icon: "check"
        uncheckedIcon: "close"
    }

    TestCase {
        name: "MeoSwitch"
        when: windowShown

        function init() {
            toggle.enabled = true
            toggle.checked = false
            toggle.isError = false
            toggle.size = "m"
            toggle.uncheckedIcon = ""
            toggle.LayoutMirroring.enabled = false
            toggle.LayoutMirroring.childrenInherit = true
        }

        function test_toggleMovesOnlyForSelectionNotPress() {
            const track = findChild(toggle, "meoSwitchTrack")
            const thumb = findChild(toggle, "meoSwitchThumb")
            verify(track !== null)
            verify(thumb !== null)
            wait(300) // let a preceding size test's intentional thumb transition settle
            const offWidth = thumb.width
            compare(toggle.minimumTargetSize, 48 * toggle.themeGlobalScale)
            compare(toggle.stateLayerSize, 40 * toggle.themeGlobalScale)
            compare(toggle.implicitHeight, toggle.minimumTargetSize)
            compare(track.border.width, 2 * toggle.themeGlobalScale)
            toggle.toggle()
            tryVerify(function() { return thumb.x + thumb.width / 2 > track.width / 2 }, 500)
            tryVerify(function() { return thumb.width > offWidth }, 500)
            const onWidth = thumb.width
            verify(onWidth > offWidth)
            compare(track.scale, 1)
            compare(thumb.scale, 1)

            // M3 specifies a 28dp pressed default handle, independent of its
            // unselected (16dp) or selected (24dp) rest size.
            mousePress(toggle, track.x + track.width / 2, track.y + track.height / 2)
            tryCompare(thumb, "width", 28 * toggle.themeGlobalScale, 500)
            // SwitchTokens changes the handle (not the selected track) to
            // PrimaryContainer while the switch is pressed, hovered, or
            // focused.  Keep this deterministic press assertion alongside
            // the independently specified 28dp press size.
            tryCompare(thumb, "color", toggle.themePrimaryContainer, 500)
            mouseRelease(toggle, track.x + track.width / 2, track.y + track.height / 2)
        }

        function test_unselectedInteractiveHandleUsesOnSurfaceVariant() {
            const track = findChild(toggle, "meoSwitchTrack")
            const thumb = findChild(toggle, "meoSwitchThumb")
            toggle.checked = false
            mousePress(toggle, track.x + track.width / 2, track.y + track.height / 2)
            tryCompare(thumb, "color", toggle.themeOnSurfaceVariant, 500)
            mouseRelease(toggle, track.x + track.width / 2, track.y + track.height / 2)
        }

        function test_sizesAndDisabledSemanticRoles() {
            const track = findChild(toggle, "meoSwitchTrack")
            const thumb = findChild(toggle, "meoSwitchThumb")
            const icon = findChild(toggle, "meoSwitchThumbIcon")
            const sizes = ["xs", "s", "m", "l", "xl"]
            for (let index = 0; index < sizes.length; ++index) {
                toggle.size = sizes[index]
                compare(track.radius, track.height / 2)
            }

            toggle.checked = true
            toggle.enabled = false
            tryVerify(function() { return Math.abs(track.color.a - 0.12) < 0.001 }, 500)
            tryCompare(thumb, "color", toggle.themeSurface, 500)
            tryVerify(function() { return Math.abs(icon.color.a - 0.38) < 0.001 }, 500)

            toggle.checked = false
            tryVerify(function() {
                return Math.abs(track.color.r - toggle.themeSurfaceContainerHighest.r) < 0.001
                    && Math.abs(track.color.g - toggle.themeSurfaceContainerHighest.g) < 0.001
                    && Math.abs(track.color.b - toggle.themeSurfaceContainerHighest.b) < 0.001
                    && Math.abs(track.color.a - 0.12) < 0.001
            }, 500)
            tryVerify(function() { return Math.abs(thumb.color.a - 0.38) < 0.001 }, 500)
        }

        function test_errorAndRtlContracts() {
            const track = findChild(toggle, "meoSwitchTrack")
            const row = findChild(toggle, "meoSwitchRow")
            toggle.enabled = true
            toggle.checked = true
            toggle.isError = true
            tryCompare(track, "color", toggle.themeError, 500)
            toggle.LayoutMirroring.enabled = true
            compare(row.layoutDirection, Qt.RightToLeft)
        }
    }
}
