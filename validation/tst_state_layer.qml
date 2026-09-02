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
        }

        function cleanup() {
            stateLayer.enabled = true
            stateLayer.hovered = false
            stateLayer.focused = false
            stateLayer.pressed = false
            stateLayer.dragged = false
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

            compare(stateLayer.rippleExpandDuration, 280)
            compare(stateLayer.rippleFadeDuration, 160)
        }
    }
}
