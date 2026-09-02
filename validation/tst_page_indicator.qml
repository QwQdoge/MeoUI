import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 220
    height: 180

    Components.MeoPageIndicator {
        id: horizontalIndicator
        count: 5
        currentIndex: 20
        interactive: true
    }

    Components.MeoPageIndicator {
        id: verticalIndicator
        x: 160
        count: 4
        currentIndex: -4
        orientation: "vertical"
    }

    SignalSpy {
        id: activationSpy
        target: horizontalIndicator
        signalName: "activated"
    }

    TestCase {
        name: "MeoPageIndicator"
        when: windowShown

        function test_emptyAndOutOfRangeIndexesAreSafe() {
            compare(horizontalIndicator.resolvedCurrentIndex, 4)
            compare(verticalIndicator.resolvedCurrentIndex, 0)
            horizontalIndicator.count = 0
            compare(horizontalIndicator.implicitWidth, 0)
            compare(horizontalIndicator.resolvedCurrentIndex, -1)
            horizontalIndicator.count = 5
        }

        function test_verticalGeometryAndInteractiveActivation() {
            verify(verticalIndicator.implicitHeight > verticalIndicator.implicitWidth)
            const dot = findChild(horizontalIndicator, "meoPageIndicatorDot_2")
            verify(dot !== null)
            mouseClick(dot, dot.width / 2, dot.height / 2)
            compare(horizontalIndicator.currentIndex, 2)
            compare(activationSpy.count, 1)
        }

        function test_activationClampsAndNoninteractiveIndicatorDoesNotMutate() {
            horizontalIndicator.activate(40)
            compare(horizontalIndicator.currentIndex, 4)
            compare(activationSpy.count, 2)

            verticalIndicator.activate(2)
            compare(verticalIndicator.currentIndex, -4)
        }
    }
}
