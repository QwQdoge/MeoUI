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
            compare(stateLayer.renderBackend,
                    stateLayer.softwareRendering ? "software-fallback"
                                                 : "single-pass-shader")
            compare(stateLayer.topLeftRadius, stateLayer.radius)
            compare(stateLayer.topRightRadius, stateLayer.radius)
            compare(stateLayer.bottomLeftRadius, stateLayer.radius)
            compare(stateLayer.bottomRightRadius, stateLayer.radius)

            compare(stateLayer.hoverDuration, MeoTheme.motionDurationStateHoverEnter)
            compare(stateLayer.focusDuration, MeoTheme.motionDurationStateFocusEnter)
            compare(stateLayer.dragEnterDuration, MeoTheme.motionDurationStateDragEnter)
            compare(stateLayer.dragExitDuration, MeoTheme.motionDurationStateDragExit)
            compare(stateLayer.rippleFadeInDuration, MeoTheme.motionDurationRippleFadeIn)
            compare(stateLayer.rippleExpandDuration, MeoTheme.motionDurationRippleExpand)
            compare(stateLayer.rippleFadeDuration, MeoTheme.motionDurationRippleFade)
            compare(stateLayer.rippleFadeInDuration, MeoTheme.motionDurationFor(75))
            compare(stateLayer.rippleExpandDuration, MeoTheme.motionDurationFor(225))
            compare(stateLayer.rippleFadeDuration, MeoTheme.motionDurationFor(150))
        }

        function test_internalPointerTrackingUsesActualPressPoint() {
            mousePress(stateLayer, 31, 19, Qt.LeftButton)
            tryCompare(stateLayer, "rippleActive", true, 100)
            verify(Math.abs(stateLayer.rippleOriginX - 31) < 1)
            verify(Math.abs(stateLayer.rippleOriginY - 19) < 1)
            mouseRelease(stateLayer, 31, 19, Qt.LeftButton)
            tryCompare(stateLayer, "rippleActive", false,
                       stateLayer.rippleExpandDuration
                       + stateLayer.rippleFadeDuration + 250)
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
            compare(stateLayer.rippleCenterX, 12)
            compare(stateLayer.rippleCenterY, 14)
            verify(Math.abs(stateLayer.rippleRadius
                            - Math.max(stateLayer.width, stateLayer.height) * 0.3) < 0.1)
            const expectedTarget = Math.sqrt(stateLayer.width * stateLayer.width
                                             + stateLayer.height * stateLayer.height) / 2
                                   + 10 * MeoTheme.globalScale
            verify(Math.abs(stateLayer.rippleTargetRadius - expectedTarget) < 0.1)
            wait(stateLayer.rippleExpandDuration + 30)
            verify(Math.abs(stateLayer.rippleCenterX - stateLayer.width / 2) < 0.5)
            verify(Math.abs(stateLayer.rippleCenterY - stateLayer.height / 2) < 0.5)
            stateLayer.releaseRipple()
            tryCompare(stateLayer, "rippleActive", false,
                       stateLayer.rippleFadeDuration + 250)

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

        function test_holdKeepsExpandedRippleUntilRelease() {
            stateLayer.pressX = 24
            stateLayer.pressY = 18
            stateLayer.pressed = true

            tryCompare(stateLayer, "rippleActive", true, 100)
            wait(MeoTheme.motionDurationRippleExpand + 50)
            verify(stateLayer.rippleActive)
            compare(stateLayer.rippleOpacity, stateLayer.pressedOpacity)
            verify(Math.abs(stateLayer.rippleRadius - stateLayer.rippleTargetRadius) <= 1)

            stateLayer.pressed = false
            verify(stateLayer.rippleActive)
            tryCompare(stateLayer, "rippleActive", false,
                       MeoTheme.motionDurationRippleFade + 250)
        }

        function test_reduceMotionRemovesActiveRippleImmediately() {
            const previousReduceMotion = stateLayer.theme.reduceMotion
            stateLayer.pressed = true
            tryCompare(stateLayer, "rippleActive", true, 100)
            stateLayer.theme.reduceMotion = true
            tryCompare(stateLayer, "rippleActive", false, 100)
            tryCompare(stateLayer, "rippleRadius", 0, 100)
            stateLayer.pressed = false
            stateLayer.theme.reduceMotion = previousReduceMotion
        }
    }
}
