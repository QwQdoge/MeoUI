import QtQuick
import QtTest
import "../components" as Components

Item {
    id: root
    width: 520
    height: 96

    Components.MeoBreadcrumbs {
        id: breadcrumbs
        model: [
            { "label": "Home", "icon": "home" },
            { "label": "Restricted", "enabled": false },
            { "label": "Current" }
        ]
    }

    SignalSpy {
        id: clickSpy
        target: breadcrumbs
        signalName: "clicked"
    }

    TestCase {
        name: "MeoBreadcrumbs"
        when: windowShown

        function init() {
            breadcrumbs.currentIndex = -1
            clickSpy.clear()
        }

        function test_lastItemIsCurrentByDefault() {
            compare(breadcrumbs.resolvedCurrentIndex(), 2)
            const current = findChild(breadcrumbs, "meoBreadcrumb_2")
            verify(current !== null)
            verify(!current.Accessible.focusable)
            mouseClick(current, current.width / 2, current.height / 2)
            compare(clickSpy.count, 0)
        }

        function test_explicitCurrentAndDisabledLinkAreNonInteractive() {
            breadcrumbs.currentIndex = 0
            compare(breadcrumbs.resolvedCurrentIndex(), 0)
            const restricted = findChild(breadcrumbs, "meoBreadcrumb_1")
            verify(restricted !== null)
            verify(!restricted.Accessible.focusable)
            mouseClick(restricted, restricted.width / 2, restricted.height / 2)
            compare(clickSpy.count, 0)
        }

        function test_intermediateLinkActivates() {
            const home = findChild(breadcrumbs, "meoBreadcrumb_0")
            verify(home !== null)
            mouseClick(home, home.width / 2, home.height / 2)
            compare(clickSpy.count, 1)
        }
    }
}
