import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    id: root
    width: 900
    height: 700

    Widgets.MeoSearchView {
        id: fullScreenView
        parent: root
        suggestions: [{ "label": "MeoTheme" }]
    }

    Widgets.MeoSearchView {
        id: dockedView
        parent: root
        layout: "docked"
        style: "divided"
        dockedWidth: 480
        dockedHeight: 360
        suggestions: [{ "label": "MeoSlider" }]
    }

    Widgets.MeoDockedSearchBar {
        id: embeddedSearch
        width: 480
        style: "contained"
        isExpanded: true
        suggestions: [{ "label": "MeoButton" }]
    }

    TestCase {
        name: "MeoSearchView"
        when: windowShown

        function test_expressiveDefaultsUseContainedFullscreen() {
            compare(fullScreenView.style, "contained")
            compare(fullScreenView.layout, "full-screen")
            verify(fullScreenView.containedStyle)
            verify(!fullScreenView.docked)
            verify(fullScreenView.modal)
        }

        function test_dockedDividedLayoutIsAvailableForCompatibility() {
            compare(dockedView.style, "divided")
            compare(dockedView.layout, "docked")
            verify(!dockedView.containedStyle)
            verify(dockedView.docked)
            verify(!dockedView.modal)
            verify(dockedView.width <= root.width)
            verify(dockedView.height <= root.height)
        }

        function test_embeddedDockedSurfaceSupportsResults() {
            compare(embeddedSearch.style, "contained")
            verify(embeddedSearch.isExpanded)
            verify(embeddedSearch.implicitHeight > 56)
            compare(embeddedSearch.suggestions.length, 1)
        }

        function test_embeddedDockedSurfaceCanCollapse() {
            embeddedSearch.isExpanded = true
            embeddedSearch.deactivateSearch()
            compare(embeddedSearch.isExpanded, false)
            compare(embeddedSearch.implicitHeight, 56)
        }

        function test_fullScreenAndDockedPopupsOpen() {
            fullScreenView.open()
            wait(0)
            verify(fullScreenView.visible)
            fullScreenView.close()

            dockedView.open()
            wait(0)
            verify(dockedView.visible)
            dockedView.close()
        }
    }
}
