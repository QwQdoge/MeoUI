import QtQuick
import QtTest
import MeoUI 1.0
import "../components" as Components

Item {
    width: 320
    height: 120

    Components.MeoStateLayer {
        id: stateLayer
        width: 160
        height: 48
        radius: 12
        color: "#65558F"
    }

    TestCase {
        name: "MeoStateLayer"
        when: windowShown

        function init() {
            stateLayer.enabled = true
            stateLayer.hovered = false
            stateLayer.focused = false
            stateLayer.pressed = false
            stateLayer.dragged = false
            stateLayer.rippleOriginMode = "pointer"
        }

        function cleanup() {
            stateLayer.enabled = true
            stateLayer.hovered = false
            stateLayer.focused = false
            stateLayer.pressed = false
            stateLayer.dragged = false
            stateLayer.rippleOriginMode = "pointer"
        }

        function test_statePriorityAndDisabledContract() {
            compare(stateLayer.stateOpacity, 0)

            stateLayer.hovered = true
            compare(stateLayer.stateOpacity, stateLayer.hoverOpacity)

            stateLayer.focused = true
            compare(stateLayer.stateOpacity, stateLayer.hoverOpacity)

            stateLayer.pressed = true
            compare(stateLayer.stateOpacity, stateLayer.pressedOpacity)

            stateLayer.dragged = true
            compare(stateLayer.stateOpacity, stateLayer.draggedOpacity)

            stateLayer.enabled = false
            compare(stateLayer.enabled, false)
            tryCompare(stateLayer, "stateOpacity", 0)
        }

        function test_materialStateOpacityTokens() {
            // AndroidX Material 3 StateTokens (v0_210): state-layer values
            // are shared by the runtime token singleton, MeoTheme, and this
            // reusable QML primitive.
            compare(MeoTheme.stateOpacityHover, 0.08)
            compare(MeoTheme.stateOpacityFocus, 0.10)
            compare(MeoTheme.stateOpacityPressed, 0.10)
            compare(MeoTheme.stateOpacityDragged, 0.16)

            compare(stateLayer.hoverOpacity, MeoTheme.stateOpacityHover)
            compare(stateLayer.focusOpacity, MeoTheme.stateOpacityFocus)
            compare(stateLayer.pressedOpacity, MeoTheme.stateOpacityPressed)
            compare(stateLayer.draggedOpacity, MeoTheme.stateOpacityDragged)
        }

        function test_motionAndCornerContracts() {
            compare(stateLayer.topLeftRadius, stateLayer.radius)
            compare(stateLayer.topRightRadius, stateLayer.radius)
            compare(stateLayer.bottomLeftRadius, stateLayer.radius)
            compare(stateLayer.bottomRightRadius, stateLayer.radius)

            compare(stateLayer.rippleExpandDuration, MeoTheme.motionDurationRippleExpand)
            compare(stateLayer.rippleFadeDuration, MeoTheme.motionDurationRippleFade)
        }

        function test_keyboardRippleStartsFromTheCenterAndReleasesResources() {
            stateLayer.triggerFromKeyboard()
            compare(stateLayer.rippleOriginX, stateLayer.width / 2)
            compare(stateLayer.rippleOriginY, stateLayer.height / 2)
            tryCompare(stateLayer, "rippleActive", true, 100)
            stateLayer.pressed = true
            stateLayer.pressed = false
            tryCompare(stateLayer, "rippleActive", false,
                       MeoTheme.motionDurationRippleExpand
                       + MeoTheme.motionDurationRippleFade + 500)
        }

        function test_pointerPressUsesClickPointAndCenterRemainsAvailable() {
            stateLayer.trigger(12, 14)
            compare(stateLayer.rippleOriginX, 12)
            compare(stateLayer.rippleOriginY, 14)

            stateLayer.rippleOriginMode = "center"
            stateLayer.trigger(12, 14)
            compare(stateLayer.rippleOriginX, stateLayer.width / 2)
            compare(stateLayer.rippleOriginY, stateLayer.height / 2)
        }

        function test_quickReleaseKeepsClickFeedbackUntilExpansionCompletes() {
            stateLayer.pressed = true
            stateLayer.pressed = false
            tryCompare(stateLayer, "rippleActive", true, 50)
            wait(Math.max(1, MeoTheme.motionDurationPress))
            verify(stateLayer.rippleActive)
            tryCompare(stateLayer, "rippleActive", false,
                       MeoTheme.motionDurationRippleExpand
                       + MeoTheme.motionDurationRippleFade + 250)
        }
    }
}
