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

        function cleanup() {
            defaultSurface.entranceAxis = "x"
            defaultSurface.motionOffset = 0
        }

        function test_verticalEntranceAxisProjectsOffsetToY() {
            defaultSurface.entranceAxis = "y"
            defaultSurface.motionOffset = 12
            compare(defaultSurface.transform[0].x, 0)
            compare(defaultSurface.transform[0].y, 12)
        }

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