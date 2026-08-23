import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Flickable {
    id: control

    property string title: ""
    property string subtitle: ""
    property Component topBar: null
    property list<Component> actions
    // A shell can pass root metrics here so a page and its navigation agree on
    // the active breakpoint even when the content host is narrower.
    property var metricsOverride: null
    property real compactWidth: 680 * themeGlobalScale
    property real mediumWidth: 920 * themeGlobalScale
    property real expandedWidth: 1180 * themeGlobalScale
    property real padding: activeMetrics.pageMargin
    property real sectionSpacing: activeMetrics.sectionSpacing
    default property alias content: bodyColumn.data

    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property var activeMetrics: metricsOverride || localWindowMetrics
    readonly property bool isCompact: activeMetrics.isCompactWidth
    readonly property bool isMedium: activeMetrics.isMediumWidth
    readonly property bool isExpanded: activeMetrics.isExpandedWidth || activeMetrics.isLargeWidth || activeMetrics.isExtraLargeWidth
    readonly property bool isLarge: activeMetrics.isLargeWidth
    readonly property bool isExtraLarge: activeMetrics.isExtraLargeWidth
    readonly property string windowSizeClass: activeMetrics.widthSizeClass
    readonly property int preferredColumns: activeMetrics.preferredColumns
    // Use this for grids: a large root can still have a narrower content host
    // after a permanent navigation drawer is reserved.
    readonly property int contentPreferredColumns: localWindowMetrics.preferredColumns
    readonly property real maxContentWidth: Math.min(activeMetrics.maximumContentWidth, isCompact ? compactWidth : (isMedium ? mediumWidth : expandedWidth))
    readonly property var fontPageTitle: (typeof MeoTheme !== "undefined" && typeof MeoTheme.titleBig !== "undefined") ? MeoTheme.titleBig : { "size": 28, "weight": Font.DemiBold, "lineHeight": 36, "letterSpacing": 0 }
    readonly property var fontPageSubtitle: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyBig !== "undefined") ? MeoTheme.bodyBig : { "size": 16, "weight": Font.Normal, "lineHeight": 24, "letterSpacing": 0.5 }

    contentWidth: width
    contentHeight: rootColumn.implicitHeight + padding * 2
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    MeoWindowMetrics {
        id: localWindowMetrics
        availableWidth: control.width
        availableHeight: control.height
    }

    WheelHandler {
        id: wheelHandler
        target: control
        property real stepSize: 140 * control.themeGlobalScale * (typeof MeoTheme !== 'undefined' && typeof MeoTheme.scrollSpeedScale !== 'undefined' ? MeoTheme.scrollSpeedScale : 1.0)
        onWheel: (event) => {
            let dy = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
            let scrollY = control.contentY - (dy / 120.0) * stepSize
            control.contentY = Math.max(0, Math.min(Math.max(0, control.contentHeight - control.height), scrollY))
        }
    }

    Column {
        id: rootColumn
        width: control.width
        y: control.padding
        spacing: control.sectionSpacing

        Loader {
            width: parent.width
            sourceComponent: control.topBar
            visible: control.topBar !== null
        }

        Column {
            id: contentShell
            width: Math.min(control.width - control.padding * 2, control.maxContentWidth)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: control.sectionSpacing

            GridLayout {
                width: parent.width
                columns: control.isCompact ? 1 : 2
                columnSpacing: 16 * control.themeGlobalScale
                rowSpacing: 12 * control.themeGlobalScale
                visible: control.title !== "" || control.subtitle !== "" || control.actions.length > 0

                Column {
                    Layout.fillWidth: true
                    spacing: 4 * control.themeGlobalScale

                    MeoText {
                        width: parent.width
                        text: control.title
                        visible: text !== ""
                        typeRole: "title"
                        typeSize: "big"
                        // A 40dp display title is intentionally spacious on
                        // desktop, but it makes ordinary multi-word system
                        // settings titles wrap or clip on a compact window.
                        // Keep the same semantic token and scale its optical
                        // size for the compact class instead of asking every
                        // application to fork its page title.
                        fontScaleOverride: control.isCompact ? 0.78 : 1.0
                        emphasized: true
                        color: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
                        wrapMode: Text.WordWrap
                    }

                    MeoText {
                        width: parent.width
                        text: control.subtitle
                        visible: text !== ""
                        typeRole: "body"
                        typeSize: "big"
                        color: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
                        wrapMode: Text.WordWrap
                    }
                }

                Flow {
                    id: actionsRow
                    visible: control.actions.length > 0
                    spacing: 4 * control.themeGlobalScale
                    Layout.alignment: control.isCompact ? Qt.AlignLeft : Qt.AlignRight | Qt.AlignVCenter
                    Layout.fillWidth: control.isCompact

                    Repeater {
                        model: control.actions
                        delegate: Loader { sourceComponent: modelData }
                    }
                }
            }

            Column {
                id: bodyColumn
                width: parent.width
                spacing: control.sectionSpacing
            }
        }
    }
}
