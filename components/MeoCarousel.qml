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

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool reducedMotion: MeoTheme.reduceMotion
    readonly property int currentIndex: listView.currentIndex

    implicitWidth: parent ? parent.width : 400 * themeGlobalScale
    implicitHeight: itemHeight + (showPageIndicator ? 36 * themeGlobalScale : 0)
    activeFocusOnTab: true
    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("Carousel")

    property bool showPageIndicator: true
    property bool autoScroll: false
    property int interval: 5000

    function goTo(index) {
        if (listView.count <= 0)
            return
        listView.currentIndex = Math.max(0, Math.min(listView.count - 1, index))
        listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
    }

    Timer {
        interval: control.interval
        running: control.autoScroll && control.visible && control.enabled && listView.count > 1
        repeat: true
        onTriggered: {
            if (listView.count > 0) {
                control.goTo((listView.currentIndex + 1) % listView.count)
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

            Behavior on scale {
                enabled: !control.reducedMotion
                NumberAnimation {
                    duration: MeoTheme.motionDurationSelection
                    easing.bezierCurve: MeoTheme.motionEasingSoul
                }
            }
            Behavior on opacity {
                enabled: !control.reducedMotion
                NumberAnimation { duration: MeoTheme.motionDurationState }
            }

            Loader {
                id: delegateLoader
                anchors.fill: parent
                sourceComponent: control.delegate
                property var modelData: model.modelData
                property int modelIndex: index
            }
        }
        snapMode: (control.type === "uncontained" || control.type === "full-screen") ? ListView.NoSnap : ListView.SnapToItem
        highlightMoveDuration: control.reducedMotion ? 0 : (MeoTheme.isExpressive
                                                             ? MeoTheme.motionDurationLong2
                                                             : MeoTheme.motionDurationSelection)
        preferredHighlightBegin: (control.type === "hero" || control.type === "uncontained") ? 16 * control.themeGlobalScale : 0
        preferredHighlightEnd: (control.type === "hero" || control.type === "uncontained") ? width - 16 * control.themeGlobalScale : width
        highlightRangeMode: (control.type === "hero" || control.type === "uncontained") ? ListView.ApplyRange : ListView.NoHighlightRange

        onMovementEnded: {
            const index = indexAt(contentX + width / 2, height / 2)
            if (index >= 0)
                currentIndex = index
        }
    }

    Keys.onLeftPressed: control.goTo(listView.currentIndex - 1)
    Keys.onRightPressed: control.goTo(listView.currentIndex + 1)

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
