import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 480
    height: 180

    Components.MeoFAB {
        id: fab
        text: "Compose"
        icon.name: "edit"
    }

    TestCase {
        name: "MeoFAB"
        when: windowShown

        function init() {
            fab.enabled = true
            fab.type = "regular"
            fab.collapsed = false
            fab.down = false
        }

        function test_materialSizesAndPressKeepBoundsStable() {
            const background = findChild(fab, "meoFabBackground")
            const content = findChild(fab, "meoFabContent")
            verify(background !== null)
            verify(content !== null)

            const types = ["small", "regular", "medium", "large", "extended"]
            for (let index = 0; index < types.length; ++index) {
                fab.type = types[index]
                fab.collapsed = false
                const radius = background.radius
                const width = fab.implicitWidth
                fab.down = true
                compare(background.radius, radius)
                compare(background.scale, 1)
                compare(content.scale, 1)
                compare(fab.implicitWidth, width)
                fab.down = false
            }
        }

        function test_extendedCollapseIsTheOnlyWidthChange() {
            fab.type = "extended"
            fab.collapsed = false
            wait(400) // allow the intentional extended/collapsed width transition
            const expandedWidth = fab.implicitWidth
            fab.collapsed = true
            tryCompare(fab, "implicitWidth", fab.baseSize, 500)
            verify(expandedWidth > fab.implicitWidth)
        }

        function test_disabledUsesSemanticContainerOpacity() {
            const background = findChild(fab, "meoFabBackground")
            fab.enabled = false
            compare(background.color.a, 0.12)
        }

        function test_expressiveMediumAndColorStylesUseSemanticRoles() {
            fab.type = "medium"
            compare(fab.baseSize, 80 * fab.themeGlobalScale)
            compare(fab.restRadius, 20 * fab.themeGlobalScale)

            fab.colorStyle = "secondary"
            compare(fab.resolvedContainerColor, MeoTheme.secondary)
            compare(fab.resolvedContentColor, MeoTheme.contentOnSecondary)

            fab.colorStyle = "tertiaryContainer"
            compare(fab.resolvedContainerColor, MeoTheme.tertiaryContainer)
            compare(fab.resolvedContentColor, MeoTheme.contentOnTertiaryContainer)
        }

        function test_sourceElevationRoles() {
            fab.enabled = true
            compare(fab.resolvedElevation, MeoTheme.elevationLevel3)
            fab.enabled = false
            compare(fab.resolvedElevation, 0)
        }
    }
}
