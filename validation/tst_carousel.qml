import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 720
    height: 320

    Components.MeoCarousel {
        id: carousel
        width: 600
        height: 260
        model: ["One", "Two", "Three"]
        delegate: Component { Rectangle { color: "transparent" } }
    }

    TestCase {
        name: "MeoCarousel"
        when: windowShown

        function test_goToClampsAndUpdatesTheVisiblePage() {
            carousel.goTo(2)
            compare(carousel.currentIndex, 2)
            carousel.goTo(99)
            compare(carousel.currentIndex, 2)
            carousel.goTo(-1)
            compare(carousel.currentIndex, 0)
        }

        function test_pageIndicatorIsDerivedFromModelCount() {
            verify(carousel.showPageIndicator)
            verify(carousel.implicitHeight > carousel.itemHeight)
        }
    }
}
