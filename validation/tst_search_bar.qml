import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    width: 640
    height: 160

    Widgets.MeoSearchBar {
        id: searchBar
        width: 480
        placeholder: "Search components"
    }

    TestCase {
        name: "MeoSearchBar"
        when: windowShown

        function init() {
            searchBar.active = false
            searchBar.visualStyle = "standard"
            searchBar.text = ""
            searchBar.LayoutMirroring.enabled = false
        }

        function test_focusChangesFeedbackWithoutChangingGeometry() {
            const initialWidth = searchBar.width
            const initialHeight = searchBar.height
            const initialRadius = searchBar.radius
            searchBar.active = true
            compare(searchBar.width, initialWidth)
            compare(searchBar.height, initialHeight)
            compare(searchBar.radius, initialRadius)
        }

        function test_realVisualStylesKeepStablePillContracts() {
            const styles = ["standard", "pixel", "settings", "launcher"]
            for (let index = 0; index < styles.length; ++index) {
                searchBar.visualStyle = styles[index]
                searchBar.active = false
                const radius = searchBar.radius
                searchBar.active = true
                compare(searchBar.radius, radius)
                verify(searchBar.implicitHeight > 0)
            }
        }

        function test_searchHonorsLayoutMirroring() {
            searchBar.LayoutMirroring.enabled = true
            wait(0)
            verify(searchBar.mirrored)
        }
    }
}
