import QtQuick
import QtTest
import "../components" as Components

Item {
    width: 480
    height: 220

    Components.MeoTextArea {
        id: area
        width: 320
        height: 140
        label: "Description"
        placeholder: "Enter text"
        helperText: "Supporting text"
    }

    TestCase {
        name: "MeoTextArea"
        when: windowShown

        function init() {
            area.enabled = true
            area.type = "filled"
            area.isError = false
            area.text = ""
            area.maxLength = -1
            area.LayoutMirroring.enabled = false
            area.LayoutMirroring.childrenInherit = true
        }

        function test_labelAndVariantGeometryFollowTextFieldContract() {
            const container = findChild(area, "meoTextAreaContainer")
            verify(container !== null)
            compare(area.labelRaised, false)
            const radius = container.radius
            const width = area.width

            area.type = "outlined"
            compare(container.radius, radius)
            compare(area.width, width)
            area.text = "A description"
            compare(area.labelRaised, true)
        }

        function test_counterAndDisabledUseTheSemanticContract() {
            const container = findChild(area, "meoTextAreaContainer")
            const indicator = findChild(area, "meoTextAreaActiveIndicator")
            verify(indicator !== null)
            area.maxLength = 4
            area.text = "123456"
            compare(area.text, "1234")

            area.isError = true
            compare(area.color, area.themeOnSurface)
            compare(indicator.color, area.themeError)
            area.isError = false

            area.enabled = false
            tryVerify(function() { return Math.abs(container.color.a - 0.12) < 0.001 }, 500)
        }

        function test_supportingLineMirrorsForRtl() {
            const supporting = findChild(area, "meoTextAreaSupportingRow")
            verify(supporting !== null)
            area.LayoutMirroring.enabled = true
            compare(supporting.layoutDirection, Qt.RightToLeft)
        }
    }
}
