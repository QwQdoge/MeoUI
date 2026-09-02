import QtQuick
import QtTest
import "../" as Source
import "../components" as Components

Item {
    width: 520
    height: 280

    Components.MeoStepper {
        id: horizontalStepper
        width: 420
        model: ["Account", { "label": "Profile" }, { "title": "Review" }]
        currentIndex: 1
    }

    Components.MeoStepper {
        id: verticalStepper
        x: 430
        height: 220
        orientation: "vertical"
        model: ["Draft", "Check", "Publish"]
        currentIndex: 3
        interactive: true
    }

    SignalSpy {
        id: activationSpy
        target: verticalStepper
        signalName: "stepActivated"
    }

    TestCase {
        name: "MeoStepper"
        when: windowShown

        function init() {
            horizontalStepper.currentIndex = 1
            verticalStepper.currentIndex = 3
            verticalStepper.enabled = true
            activationSpy.clear()
        }

        function test_labelsAndCompletion() {
            compare(horizontalStepper.stepCount, 3)
            compare(horizontalStepper.stepLabel(0), "Account")
            compare(horizontalStepper.stepLabel(1), "Profile")
            compare(horizontalStepper.stepLabel(2), "Review")
            verify(horizontalStepper.stepIsComplete(0))
            verify(!horizontalStepper.stepIsComplete(1))

            verify(verticalStepper.stepIsComplete(0))
            verify(verticalStepper.stepIsComplete(2))
            compare(verticalStepper.activeStep, -1)
        }

        function test_activationIsOptIn() {
            horizontalStepper.activateStep(2)
            compare(horizontalStepper.currentIndex, 1)

            verticalStepper.activateStep(1)
            compare(verticalStepper.currentIndex, 1)
            compare(activationSpy.count, 1)
        }

        function test_orientationAndDisabledState() {
            verify(!horizontalStepper.vertical)
            verify(verticalStepper.vertical)
            verify(verticalStepper.implicitHeight >= 192 * verticalStepper.themeGlobalScale)

            verticalStepper.enabled = false
            wait(Source.MeoTheme.motionDurationState + 20)
            compare(verticalStepper.opacity, Source.MeoTheme.disabledContentOpacity)
        }
    }
}
