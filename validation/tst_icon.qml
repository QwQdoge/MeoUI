import QtQuick
import QtTest
import MeoUI
import "../components" as Components

Item {
    width: 160
    height: 96

    Components.MeoIcon {
        id: icon
        icon: "favorite"
        size: 32
        color: MeoTheme.primary
    }

    TestCase {
        name: "MeoIcon"
        when: windowShown

        function init() {
            icon.fill = false
            icon.weight = 400
            icon.grade = 0
            icon.opticalSize = 24
        }

        function test_dynamicThemeScaleAndDefaultAxes() {
            compare(icon.themeGlobalScale, MeoTheme.globalScale)
            compare(icon.font.pixelSize, 32 * MeoTheme.globalScale)
            compare(icon.fillLevel, 0)
            compare(icon.weight, 400)
            compare(icon.grade, 0)
            compare(icon.opticalSize, 24)
        }

        function test_filledAndExpressiveAxisContract() {
            icon.fill = true
            icon.weight = 700
            icon.grade = 200
            icon.opticalSize = 48

            compare(icon.fillLevel, 100)
            compare(icon.weight, 700)
            compare(icon.grade, 200)
            compare(icon.opticalSize, 48)
        }
    }
}
