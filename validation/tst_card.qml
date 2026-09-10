import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 800
    height: 240

    Row {
        spacing: 16
        MeoCard { id: elevated; width: 120; height: 96; type: "elevated" }
        MeoCard { id: filled; width: 120; height: 96; type: "filled"; interactive: true }
        MeoCard { id: outlined; width: 120; height: 96; type: "outlined" }
        MeoCard { id: selectedCard; width: 120; height: 96; type: "filled"; selected: true }
    }

    TestCase {
        name: "MeoCard"
        when: windowShown

        function test_usesM3SurfaceRoles() {
            compare(elevated.containerColor, MeoTheme.surfaceContainerLow)
            compare(filled.containerColor, MeoTheme.surfaceContainerHighest)
            compare(outlined.containerColor, MeoTheme.surface)
            compare(selectedCard.containerColor, MeoTheme.primaryContainer)
        }

        function test_geometryAndElevationContracts() {
            compare(elevated.radius, MeoTheme.cardRadius)
            verify(elevated.elevation > 0)
            compare(filled.elevation, 0)
            compare(outlined.elevation, 0)
            compare(filled.padding, 16 * MeoTheme.globalScale)
            compare(filled.bouncy, false)
        }

        function test_disabledTokenComposites() {
            filled.enabled = false
            compare(filled.containerColor,
                    filled.compositeColor(MeoTheme.surfaceVariant,
                                          MeoTheme.disabledContentOpacity,
                                          MeoTheme.surfaceContainerHighest))
            outlined.enabled = false
            compare(outlined.containerColor, MeoTheme.surface)
            const outlinedShape = findChild(outlined, "meoCardShape")
            verify(outlinedShape !== null)
            compare(outlinedShape.strokeColor,
                    outlined.compositeColor(MeoTheme.outline,
                                            MeoTheme.disabledContainerOpacity,
                                            MeoTheme.surfaceContainerLow))
        }

        function test_interactiveCardUsesClickPointRippleAndHold() {
            filled.enabled = true
            const stateLayer = findChild(filled, "meoCardStateLayer")
            verify(stateLayer !== null)
            const x = 28
            const y = 34
            const expected = stateLayer.mapFromItem(filled, x, y)
            verify(stateLayer.visible)
            verify(stateLayer.enabled)
            verify(!stateLayer.theme.reduceMotion)
            mouseMove(filled, x, y)
            mousePress(filled, x, y, Qt.LeftButton)
            wait(0)
            verify(stateLayer.rippleActive)
            compare(Math.round(stateLayer.rippleOriginX), Math.round(expected.x))
            compare(Math.round(stateLayer.rippleOriginY), Math.round(expected.y))
            wait(stateLayer.rippleExpandDuration + 30)
            verify(stateLayer.rippleActive)
            compare(stateLayer.rippleOpacity, stateLayer.pressedOpacity)
            mouseRelease(filled, x, y, Qt.LeftButton)
            tryCompare(stateLayer, "rippleActive", false,
                       stateLayer.rippleFadeDuration + 250)
        }
    }
}
