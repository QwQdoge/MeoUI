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
    property real horizontalPadding: padding
    property real topPadding: padding
    property real bottomPadding: padding
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
    contentHeight: rootColumn.implicitHeight + topPadding + bottomPadding
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    MeoWindowMetrics {
        id: localWindowMetrics
        availableWidth: control.width
        availableHeight: control.height
    }

    // Keep the conversion independently testable. Pixel deltas come from a
    // precision touchpad and must stay untouched; angle deltas are mouse-wheel
    // notches and follow the Qt/KDE wheel-line preference.
    function wheelDeltaFor(pixelX, pixelY, angleX, angleY) {
        const pixelDelta = pixelY !== 0 ? pixelY : pixelX
        const angleDelta = angleY !== 0 ? angleY : angleX
        return pixelDelta !== 0
                ? pixelDelta
                : (angleDelta / 120.0) * wheelHandler.systemWheelStep
    }

    function scrollForWheelDelta(delta) {
        if (delta === 0)
            return contentY
        const maximumContentY = Math.max(0, contentHeight - height)
        contentY = Math.max(0, Math.min(maximumContentY, contentY - delta))
        return contentY
    }

    WheelHandler {
        id: wheelHandler
        target: control
        // Preserve the operating system's scroll contract. Touchpads provide
        // high-resolution pixel deltas; mouse wheels provide notches whose
        // size follows Qt/KDE's configured wheelScrollLines value.
        property real systemWheelStep: Math.max(1, Application.styleHints.wheelScrollLines) * 20
        onWheel: (event) => {
            const delta = control.wheelDeltaFor(event.pixelDelta.x, event.pixelDelta.y,
                                                event.angleDelta.x, event.angleDelta.y)
            if (delta === 0) {
                event.accepted = false
                return
            }
            control.scrollForWheelDelta(delta)
            event.accepted = true
        }
    }

    Column {
        id: rootColumn
        width: control.width
        y: control.topPadding
        spacing: control.sectionSpacing

        Loader {
            width: parent.width
            sourceComponent: control.topBar
            visible: control.topBar !== null
        }

        Column {
            id: contentShell
            width: Math.min(control.width - control.horizontalPadding * 2, control.maxContentWidth)
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
