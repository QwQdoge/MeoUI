import QtQuick
import QtTest
import MeoUI 1.0

Item {
    id: root
    width: 640
    height: 480

    MeoWidget {
        id: widget
        widgetId: "weather"
        preferredSize: MeoWidget.SizeMedium
        supportedSizes: [MeoWidget.SizeSmall, MeoWidget.SizeMedium]
        privacy: MeoWidget.Location
        refreshPolicy: MeoWidget.Periodic
        supportedSurfaces: [MeoWidget.Desktop, MeoWidget.LockScreen]
        accessibleName: "Weather"

        Rectangle {
            objectName: "widgetContent"
            anchors.fill: parent
        }
    }

    TestCase {
        name: "MeoWidget"
        when: windowShown

        function test_publicContractMapsSizesAndHostCapabilities() {
            compare(widget.preferredColumns, 2)
            compare(widget.preferredRows, 2)
            compare(widget.columnsForSize(MeoWidget.SizeExtraLarge), 4)
            compare(widget.rowsForSize(MeoWidget.SizeExtraLarge), 4)
            compare(widget.columnsForSize(MeoWidget.SizeWide), 2)
            compare(widget.rowsForSize(MeoWidget.SizeWide), 1)
            verify(widget.supportsSurface(MeoWidget.Desktop))
            verify(widget.supportsSurface(MeoWidget.LockScreen))
            verify(!widget.supportsSurface(MeoWidget.Overview))
            verify(widget.implicitWidth > 0)
            verify(widget.implicitHeight > 0)
        }

        function test_framingUsesDynamicMeoTokens() {
            compare(widget.frameMode, MeoWidget.MeoFramed)
            verify(widget.drawsFrame)
            compare(widget.dynamicCornerRadius, MeoTheme.cardRadius)
            compare(widget.widgetPadding, MeoTheme.space16)
            compare(widget.background.visible, true)

            widget.frameMode = MeoWidget.Adaptive
            widget.wantsOwnBackground = true
            compare(widget.drawsFrame, false)
            compare(widget.effectivePadding, 0)
        }
    }
}
