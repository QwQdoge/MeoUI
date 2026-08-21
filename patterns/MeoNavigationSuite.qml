import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    property var model: []
    property int currentIndex: 0
    property bool expandedRail: false
    property Component header: null
    property Component footer: null
    property string labelType: "always"
    property real availableWidth: parent ? parent.width : width

    signal clicked(int index)

    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property bool isCompact: windowMetrics.isCompactWidth
    readonly property bool isMedium: windowMetrics.isMediumWidth
    readonly property bool isExpanded: windowMetrics.isExpandedWidth
    readonly property bool isLarge: windowMetrics.isLargeWidth || windowMetrics.isExtraLargeWidth
    readonly property string windowSizeClass: windowMetrics.widthSizeClass
    readonly property real expandedDrawerWidth: 280 * themeGlobalScale

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.availableWidth
        availableHeight: control.height
    }

    implicitWidth: isCompact ? (parent ? parent.width : 360 * themeGlobalScale) : (isMedium && !expandedRail ? 80 * themeGlobalScale : expandedDrawerWidth)
    implicitHeight: isCompact ? 80 * themeGlobalScale : 600 * themeGlobalScale
    width: implicitWidth

    Behavior on width {
        NumberAnimation {
            duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium1 !== 'undefined') ? MeoTheme.motionDurationMedium1 : 250
            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
        }
    }

    MeoNavigationBar {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: control.isCompact
        model: control.model
        currentIndex: control.currentIndex
        labelType: control.labelType
        onClicked: (index) => {
            control.currentIndex = index
            control.clicked(index)
        }
    }

    MeoNavigationRail {
        anchors.fill: parent
        visible: !control.isCompact
        model: control.model
        currentIndex: control.currentIndex
        isExpanded: control.width > 160 * control.themeGlobalScale
        header: control.header
        footer: control.footer
        labelType: control.labelType
        onClicked: (index) => {
            control.currentIndex = index
            control.clicked(index)
        }
    }
}
