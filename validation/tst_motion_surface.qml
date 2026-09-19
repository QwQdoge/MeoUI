import QtQuick
import QtTest
import MeoUI 1.0

Item {
    MeoMotionSurface {
        id: defaultSurface
        width: 240
        height: 120
    }

    MeoMotionSurface {
        id: borderlessTonalSurface
        width: 240
        height: 120
        surfaceStyle: "tonal"
        showOutline: false
    }

    TestCase {
        name: "MeoMotionSurface"
        when: windowShown

        function test_outlinePolicyPreservesCompatibilityAndAllowsTonalOptOut() {
            compare(defaultSurface.showOutline, true)
            compare(borderlessTonalSurface.showOutline, false)

            const defaultContainer = findChild(defaultSurface,
                                               "meoMotionSurfaceContainer")
            const borderlessContainer = findChild(borderlessTonalSurface,
                                                  "meoMotionSurfaceContainer")
            verify(defaultContainer !== null)
            verify(borderlessContainer !== null)
            compare(defaultContainer.border.width, MeoTheme.strokeWidthThin)
            compare(borderlessContainer.border.width, 0)
            compare(borderlessContainer.border.color, "#00000000")
        }
    }
}
