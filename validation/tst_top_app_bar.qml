import QtQuick
import QtTest
import "../widgets" as Widgets

Item {
    id: root
    width: 480
    height: 220

    Widgets.MeoTopAppBar {
        id: topAppBar
        width: root.width
        title: "Library"
    }

    TestCase {
        name: "MeoTopAppBar"
        when: windowShown

        function init() {
            topAppBar.type = "small"
            topAppBar.flexible = false
            topAppBar.scrollProgress = 0
            topAppBar.isContextual = false
        }

        function test_m3ModeHeightsAndImplicitContract() {
            tryVerify(function() {
                return Math.round(topAppBar.height) === Math.round(64 * topAppBar.themeGlobalScale)
            }, 500)
            compare(Math.round(topAppBar.implicitHeight), Math.round(topAppBar.height))

            topAppBar.type = "center"
            compare(Math.round(topAppBar.height), Math.round(64 * topAppBar.themeGlobalScale))

            topAppBar.type = "medium"
            tryVerify(function() {
                return Math.round(topAppBar.height) === Math.round(112 * topAppBar.themeGlobalScale)
            }, 500)

            topAppBar.type = "large"
            tryVerify(function() {
                return Math.round(topAppBar.height) === Math.round(152 * topAppBar.themeGlobalScale)
            }, 500)
        }

        function test_flexibleLargeInterpolatesWithoutChangingItsImplicitContract() {
            topAppBar.type = "large"
            topAppBar.flexible = true
            topAppBar.scrollProgress = 0
            tryVerify(function() {
                return Math.round(topAppBar.height) === Math.round(64 * topAppBar.themeGlobalScale)
            }, 500)

            topAppBar.scrollProgress = 1
            tryVerify(function() {
                return Math.round(topAppBar.height) === Math.round(152 * topAppBar.themeGlobalScale)
            }, 500)
            compare(Math.round(topAppBar.implicitHeight), Math.round(topAppBar.height))
        }

        function test_contextualModeUsesSelectionInsteadOfTitle() {
            topAppBar.isContextual = true
            topAppBar.selectionCount = 3
            compare(topAppBar.selectionCount, 3)
            tryCompare(topAppBar, "color", topAppBar.themePrimaryContainer, 500)
        }
    }
}
