import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 720
    height: 480

    MeoButton {
        id: compactButton
        size: "s"
        text: "Action"
        type: "filled"
    }

    Row {
        y: 72
        spacing: MeoTheme.space8
        MeoIconButton { id: iconXs; size: "xs"; icon.name: "add" }
        MeoIconButton { id: iconS; size: "s"; icon.name: "add" }
        MeoIconButton { id: iconM; size: "m"; icon.name: "add" }
        MeoIconButton { id: iconL; size: "l"; icon.name: "add" }
        MeoIconButton { id: iconXl; size: "xl"; icon.name: "add" }
    }

    MeoCard {
        id: card
        y: 160
        width: 240
        height: 120
    }

    TestCase {
        name: "MeoControlGeometry"
        when: windowShown

        function test_semanticRoleValues() {
            compare(MeoTheme.controlHeight, 40 * MeoTheme.globalScale)
            compare(MeoTheme.controlRadius, 12 * MeoTheme.globalScale * MeoTheme.cornerScale)
            compare(MeoTheme.controlPressedRadius, 8 * MeoTheme.globalScale * MeoTheme.cornerScale)
            compare(MeoTheme.windowRadius, 16 * MeoTheme.globalScale * MeoTheme.cornerScale)
            compare(MeoTheme.cardRadius, 20 * MeoTheme.globalScale * MeoTheme.cornerScale)
            compare(MeoTheme.dialogRadius, 28 * MeoTheme.globalScale * MeoTheme.cornerScale)
            compare(MeoTheme.focusRingWidth, 2 * MeoTheme.globalScale)
        }

        function test_buttonSizeAndRadiusFunctions() {
            compare(compactButton.implicitHeight, MeoTheme.controlHeight)
            compare(compactButton.restingRadius, compactButton.buttonHeight / 2)
            compare(MeoTheme.buttonRadiusForHeight(compactButton.buttonHeight, true),
                    MeoTheme.controlRadius)
        }

        function test_iconButtonTargetScale() {
            compare(iconXs.implicitWidth, MeoTheme.iconButtonSizeXS)
            compare(iconS.implicitWidth, MeoTheme.iconButtonSizeS)
            compare(iconM.implicitWidth, MeoTheme.iconButtonSizeM)
            compare(iconL.implicitWidth, MeoTheme.iconButtonSizeL)
            compare(iconXl.implicitWidth, MeoTheme.iconButtonSizeXL)
        }

        function test_surfaceRole() {
            compare(card.radius, MeoTheme.cardRadius)
        }
    }
}
