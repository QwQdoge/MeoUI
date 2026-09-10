import QtQuick
import QtTest
import MeoUI
import "../components" as Components
import "../widgets" as Widgets

Item {
    width: 1000
    height: 720

    Components.MeoButton {
        id: button
        x: 20
        y: 20
        text: "Button"
    }

    Components.MeoIconButton {
        id: iconButton
        x: 180
        y: 20
        icon.name: "settings"
    }

    Components.MeoTabs {
        id: tabs
        x: 20
        y: 100
        width: 420
        model: ["Overview", "Activity", "Settings"]
    }

    Widgets.MeoNavigationBar {
        id: navigationBar
        x: 20
        y: 190
        width: 520
        model: [
            { "id": "home", "label": "Home", "icon": "home" },
            { "id": "apps", "label": "Apps", "icon": "apps" },
            { "id": "settings", "label": "Settings", "icon": "settings" }
        ]
    }

    Widgets.MeoNavigationRail {
        id: navigationRail
        x: 600
        y: 0
        height: parent.height
        model: [
            { "id": "home", "label": "Home", "icon": "home" },
            { "id": "controls", "label": "Controls", "icon": "tune" }
        ]
        resizeInstantly: true
    }

    Components.MeoPageIndicator {
        id: pageIndicator
        x: 20
        y: 310
        count: 4
        interactive: true
    }

    Components.MeoButtonGroup {
        id: buttonGroup
        x: 20
        y: 370
        model: ["Day", "Week", "Month"]
    }

    Components.MeoSegmentedButtons {
        id: segmentedButtons
        x: 20
        y: 440
        width: 420
        model: ["List", "Grid", "Compact"]
    }

    Components.MeoSplitButton {
        id: splitButton
        x: 20
        y: 510
        text: "Create"
        icon: "add"
    }

    Components.MeoQuickControlSlider {
        id: quickControlSlider
        x: 240
        y: 510
        width: 360
        label: "Volume"
        iconName: "volume_up"
        iconAccessibleName: "Mute"
        value: 50
    }

    TestCase {
        name: "MeoInteractionFeedback"
        when: windowShown

        function verifyClickPointRipple(target, stateLayer, x, y) {
            const expected = stateLayer.mapFromItem(target, x, y)
            mousePress(target, x, y, Qt.LeftButton)
            wait(0)
            verify(Math.abs(stateLayer.rippleOriginX - expected.x) <= 1)
            verify(Math.abs(stateLayer.rippleOriginY - expected.y) <= 1)
            verify(stateLayer.rippleActive)
            compare(stateLayer.rippleOriginMode, "pointer")
            mouseRelease(target, x, y, Qt.LeftButton)
            verify(stateLayer.rippleActive)
        }

        function test_buttonsUseExactClickPoint() {
            const buttonState = findChild(button, "meoButtonStateLayer")
            const iconState = findChild(iconButton, "meoIconButtonStateLayer")
            verify(buttonState !== null)
            verify(iconState !== null)
            verifyClickPointRipple(button, buttonState, 18, 14)
            verifyClickPointRipple(iconButton, iconState, 14, 16)
        }

        function test_tabsAndPageIndicatorUseSharedRipple() {
            const firstTab = findChild(tabs, "meoTab_0")
            const tabState = findChild(tabs, "meoTabStateLayer_0")
            const dot = findChild(pageIndicator, "meoPageIndicatorDot_1")
            const dotState = findChild(pageIndicator, "meoPageIndicatorStateLayer_1")
            verifyClickPointRipple(firstTab, tabState, 20, 18)
            verifyClickPointRipple(dot, dotState, dot.width / 2, dot.height / 2)
        }

        function test_sideAndBottomNavigationUseSharedRipple() {
            const barDestination = findChild(navigationBar, "meoNavigationBarDestination_0")
            const barState = findChild(navigationBar, "meoNavigationBarStateLayer_0")
            verifyClickPointRipple(barDestination, barState, barDestination.width / 2, 24)

            const railDestination = findChild(navigationRail, "meoNavigationRailDestination_0")
            const railState = findChild(navigationRail, "meoNavigationRailCollapsedStateLayer_0")
            verifyClickPointRipple(railDestination, railState,
                                   railDestination.width / 2, railDestination.height / 2)
        }

        function test_compositeButtonsUseExactClickPoint() {
            const groupButton = findChild(buttonGroup, "meoButtonGroupButton_0")
            const groupState = findChild(buttonGroup, "meoButtonGroupStateLayer_0")
            verifyClickPointRipple(groupButton, groupState, 21, 17)

            const segmentButton = findChild(segmentedButtons, "meoSegmentedButton_0")
            const segmentState = findChild(segmentedButtons, "meoSegmentedButtonStateLayer_0")
            verifyClickPointRipple(segmentButton, segmentState, 27, 16)

            const splitPrimary = findChild(splitButton, "meoSplitButtonPrimaryAction")
            const splitState = findChild(splitButton, "meoSplitButtonPrimaryStateLayer")
            verifyClickPointRipple(splitPrimary, splitState, 24, 18)

            const quickIcon = findChild(quickControlSlider, "quickControlIconButton")
            const quickIconState = findChild(quickControlSlider, "quickControlIconStateLayer")
            verifyClickPointRipple(quickIcon, quickIconState, 19, 22)
        }

        function test_feedbackUsesSharedTimingAndDarkeningTokens() {
            const stateLayer = findChild(button, "meoButtonStateLayer")
            compare(stateLayer.hoverOpacity, MeoTheme.stateOpacityHover)
            compare(stateLayer.pressedOpacity, MeoTheme.stateOpacityPressed)
            compare(stateLayer.pressDuration, MeoTheme.motionDurationPress)
            compare(stateLayer.rippleExpandDuration, MeoTheme.motionDurationRippleExpand)
            compare(stateLayer.rippleFadeDuration, MeoTheme.motionDurationRippleFade)
            compare(stateLayer.overlayColor, MeoTheme.scrim)
        }
    }
}
