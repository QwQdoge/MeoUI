import QtQuick
import QtTest
import MeoUI 1.0

Item {
    id: root
    width: 640
    height: 480

    MeoWidget {
        id: widget
        width: implicitWidth
        height: implicitHeight
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
            compare(widget.currentColumns, 2)
            compare(widget.currentRows, 2)
            verify(!widget.compactLayout)
            verify(!widget.expandedLayout)
            verify(widget.supportsSurface(MeoWidget.Desktop))
            verify(widget.supportsSurface(MeoWidget.LockScreen))
            verify(!widget.supportsSurface(MeoWidget.Overview))
            verify(widget.implicitWidth > 0)
            verify(widget.implicitHeight > 0)
        }

        function test_liveSpanTracksResize() {
            widget.width = widget.gridCellSize
            widget.height = widget.gridCellSize
            compare(widget.currentColumns, 1)
            compare(widget.currentRows, 1)
            verify(widget.compactLayout)

            widget.width = 4 * widget.gridCellSize + 3 * widget.gridGap
            widget.height = 2 * widget.gridCellSize + widget.gridGap
            compare(widget.currentColumns, 4)
            compare(widget.currentRows, 2)
            verify(widget.wideLayout)
            verify(widget.expandedLayout)
        }

        function test_framingUsesDynamicMeoTokens() {
            compare(widget.frameMode, MeoWidget.MeoFramed)
            verify(widget.drawsFrame)
            compare(widget.dynamicCornerRadius, MeoTheme.cardRadius)
            compare(widget.frameColor, MeoTheme.surfaceContainerLow)
            compare(widget.showFrameOutline, false)
            compare(widget.widgetPadding, MeoTheme.space16)
            compare(widget.background.visible, true)

            widget.frameMode = MeoWidget.Adaptive
            widget.wantsOwnBackground = true
            compare(widget.drawsFrame, false)
            compare(widget.effectivePadding, 0)
        }

        function cleanup() {
            widget.width = widget.implicitWidth
            widget.height = widget.implicitHeight
            widget.frameMode = MeoWidget.MeoFramed
            widget.wantsOwnBackground = false
        }
    }
}
