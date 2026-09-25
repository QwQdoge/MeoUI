import QtQuick
import QtTest
import MeoUI 1.0

Item {
    id: root
    width: 240
    height: 120

    MeoInteractionSpring {
        id: interaction
    }

    TestCase {
        name: "MeoInteractionSpring"
        when: windowShown

        function init() {
            interaction.enabled = true
            interaction.hovered = false
            interaction.pressed = false
            interaction.active = false
            interaction.snapToCurrentState()
        }

        function test_targetsFollowInteractionPriority() {
            compare(interaction.targetScale, interaction.restingScale)
            compare(interaction.targetOffsetY, interaction.restingOffsetY)

            interaction.hovered = true
            compare(interaction.targetScale, interaction.hoverScale)
            compare(interaction.targetOffsetY, interaction.hoverOffsetY)

            interaction.active = true
            compare(interaction.targetScale, interaction.activeScale)
            compare(interaction.targetOffsetY, interaction.activeOffsetY)

            interaction.pressed = true
            compare(interaction.targetScale, interaction.pressedScale)
            compare(interaction.targetOffsetY, interaction.pressedOffsetY)

            interaction.enabled = false
            compare(interaction.targetScale, interaction.restingScale)
            compare(interaction.targetOffsetY, interaction.restingOffsetY)
        }

        function test_snapUsesCurrentTarget() {
            interaction.hovered = true
            interaction.snapToCurrentState()
            compare(interaction.scale, interaction.hoverScale)
            compare(interaction.offsetY, interaction.hoverOffsetY)

            interaction.pressed = true
            interaction.snapToCurrentState()
            compare(interaction.scale, interaction.pressedScale)
            compare(interaction.offsetY, interaction.pressedOffsetY)
        }
    }
}
