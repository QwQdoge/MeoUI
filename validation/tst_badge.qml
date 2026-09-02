import QtQuick
import QtTest
import "../components" as Components

Item {
    id: root
    width: 200
    height: 100

    Components.MeoBadge {
        id: countBadge
        text: "120"
    }

    Components.MeoBadge {
        id: dotBadge
        x: 60
        isDot: true
    }

    Item {
        id: target
        x: 110
        width: 48
        height: 48
    }

    Components.MeoBadge {
        id: attachedBadge
        text: "3"
        target: target
    }

    TestCase {
        name: "MeoBadge"
        when: windowShown

        function test_countOverflowAndM3Sizes() {
            compare(countBadge.displayText, "99+")
            compare(Math.round(countBadge.height), Math.round(16 * countBadge.themeGlobalScale))
            verify(countBadge.width >= 16 * countBadge.themeGlobalScale)
        }

        function test_nonNumericBadgeTextIsNotTruncatedAsACount() {
            countBadge.text = "12 new"
            compare(countBadge.displayText, "12 new")
            countBadge.text = "120"
        }

        function test_dotAndAccessibleLabels() {
            compare(Math.round(dotBadge.width), Math.round(6 * dotBadge.themeGlobalScale))
            compare(Math.round(dotBadge.height), Math.round(6 * dotBadge.themeGlobalScale))
            verify(dotBadge.Accessible.name.length > 0)
            verify(countBadge.Accessible.name.indexOf("99+") >= 0)
        }

        function test_targetAttachmentUsesTargetCoordinateSpace() {
            compare(attachedBadge.parent, target)
            compare(Math.round(attachedBadge.x), Math.round(target.width - attachedBadge.width / 2))
            compare(Math.round(attachedBadge.y), Math.round(-attachedBadge.height / 2))
        }
    }
}
