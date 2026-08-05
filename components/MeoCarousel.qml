import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property var model: []
    property Component delegate: null
    property string type: "multi-browse" // "multi-browse" | "uncontained" | "hero" | "full-screen"
    property real itemWidth: type === "hero" ? Math.max(120 * themeGlobalScale, width - 48 * themeGlobalScale) : 200 * themeGlobalScale
    property real itemHeight: 260 * themeGlobalScale
    spacing: (type === "multi-browse" || type === "uncontained") ? 8 * themeGlobalScale : 16 * themeGlobalScale
    clip: true

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: parent ? parent.width : 400 * themeGlobalScale
    implicitHeight: itemHeight + (showPageIndicator ? 36 * themeGlobalScale : 0)

    property bool showPageIndicator: true
    property bool autoScroll: false
    property int interval: 5000

    Timer {
        interval: control.interval
        running: control.autoScroll && control.visible && control.enabled && listView.count > 1
        repeat: true
        onTriggered: {
            if (listView.count > 0) {
                listView.currentIndex = (listView.currentIndex + 1) % listView.count
                listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
            }
        }
    }

    ListView {
        id: listView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: pageIndicator.visible ? pageIndicator.top : parent.bottom
        orientation: ListView.Horizontal
        spacing: control.spacing
        model: control.model
        clip: true
        leftMargin: (control.type === "multi-browse" || control.type === "hero") ? 16 * control.themeGlobalScale : 0
        rightMargin: (control.type === "multi-browse" || control.type === "hero") ? 16 * control.themeGlobalScale : 0

        delegate: Item {
            width: {
                if (control.type === "multi-browse") {
                    let largeWidth = Math.max(100 * control.themeGlobalScale, (listView.width - 64 * control.themeGlobalScale) / 1.5);
                    if (index % 4 === 0) return largeWidth;
                    if (index % 4 === 1) return largeWidth * 0.6;
                    if (index % 4 === 2) return 56 * control.themeGlobalScale;
                    return largeWidth;
                }
                if (control.type === "uncontained") return (listView.width * 0.8);
                if (control.type === "full-screen") return listView.width;
                return control.itemWidth;
            }
            height: listView.height
            clip: true

            scale: control.type === "hero" ? (listView.currentIndex === index ? 1.0 : 0.92) : 1.0
            opacity: control.type === "hero" ? (listView.currentIndex === index ? 1.0 : 0.65) : 1.0

            Behavior on scale { NumberAnimation { duration: (typeof MeoTheme !== 'undefined') ? MeoTheme.motionDurationMedium1 : 250; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
            Behavior on opacity { NumberAnimation { duration: (typeof MeoTheme !== 'undefined') ? MeoTheme.motionDurationMedium1 : 250 } }

            Loader {
                id: delegateLoader
                anchors.fill: parent
                sourceComponent: control.delegate
                property var modelData: model.modelData
                property int modelIndex: index
            }
        }
        snapMode: (control.type === "uncontained" || control.type === "full-screen") ? ListView.NoSnap : ListView.SnapToItem
        highlightMoveDuration: (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive) ? 400 : 250
        preferredHighlightBegin: (control.type === "hero" || control.type === "uncontained") ? 16 * control.themeGlobalScale : 0
        preferredHighlightEnd: (control.type === "hero" || control.type === "uncontained") ? width - 16 * control.themeGlobalScale : width
        highlightRangeMode: (control.type === "hero" || control.type === "uncontained") ? ListView.ApplyRange : ListView.NoHighlightRange
    }

    MeoPageIndicator {
        id: pageIndicator
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 4 * control.themeGlobalScale
        count: listView.count
        currentIndex: listView.currentIndex
        visible: control.showPageIndicator && listView.count > 1
    }
}
