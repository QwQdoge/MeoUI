import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 400
    height: 120

    Components.MeoListHeader {
        id: standardHeader
        text: "Recent"
    }

    Components.MeoListHeader {
        id: paddedHeader
        y: 56
        width: 240
        text: "Pinned"
        type: "emphasized"
        topPadding: 8
        bottomPadding: 8
    }

    TestCase {
        name: "MeoListHeader"
        when: windowShown

        function test_rootUsesMeasuredImplicitSize() {
            compare(Math.round(standardHeader.width), Math.round(360 * standardHeader.themeGlobalScale))
            compare(Math.round(standardHeader.height), Math.round(40 * standardHeader.themeGlobalScale))
            compare(Math.round(paddedHeader.height), Math.round((40 + 8 + 8) * paddedHeader.themeGlobalScale))
        }

        function test_textAndAccessibleNameAreExposed() {
            verify(findChild(standardHeader, "meoListHeaderText") !== null)
            compare(paddedHeader.Accessible.name, "Pinned")
            compare(paddedHeader.type, "emphasized")
        }
    }
}
