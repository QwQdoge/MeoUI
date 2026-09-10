import QtQuick
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property string type: "small" // "small" | "center" | "medium" | "large"
    property bool flexible: false
    property real scrollProgress: 0.0 // 0.0 (collapsed) to 1.0 (expanded)
    property string title: ""
    property Component navigationIcon: null
    property list<Component> actions

    // 🌟 MD3 Contextual Mode (Selection state)
    property bool isContextual: false
    property int selectionCount: 0

    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionFast: MeoTheme.motionDurationState
    readonly property int motionMedium: MeoTheme.motionDurationShapeSettle
    readonly property bool hasNavigation: navigationIcon !== null

    readonly property var fontTitleLarge: MeoTheme.titleLarge
    readonly property var fontHeadlineMedium: MeoTheme.headlineMedium
    readonly property var fontHeadlineLarge: MeoTheme.headlineLarge

    width: parent ? parent.width : 360 * themeGlobalScale
    height: {
        let baseHeight = 64;
        if (type === "medium") baseHeight = 112;
        if (type === "large") baseHeight = 152;

        if (flexible && (type === "medium" || type === "large")) {
            return (64 + (baseHeight - 64) * scrollProgress) * themeGlobalScale;
        }
        return baseHeight * themeGlobalScale;
    }
    // Top app bars are regularly placed in ColumnLayout/Scaffold slots. Give
    // those parents the same M3 size contract as direct users of `height`.
    implicitWidth: 360 * themeGlobalScale
    implicitHeight: height
    Accessible.role: Accessible.Pane
    Accessible.name: isContextual ? qsTr("%1 selected").arg(selectionCount) : title

    // Background color transition for Contextual Mode
    color: isContextual ? themePrimaryContainer : themeSurface
    Behavior on color {
        enabled: !MeoTheme.reduceMotion
        ColorAnimation { duration: control.motionMedium; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasized }
    }

    Behavior on height {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: control.motionMedium; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasized }
    }

    Rectangle {
        id: stateLayer
        anchors.fill: parent
        color: control.isContextual ? control.themeOnPrimaryContainer : "transparent"
        opacity: 0.08
        visible: control.isContextual
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 4 * control.themeGlobalScale
        anchors.rightMargin: 4 * control.themeGlobalScale
        anchors.topMargin: 0
        anchors.bottomMargin: 0

        Loader {
            id: navIconLoader
            anchors.left: parent.left
            anchors.verticalCenter: control.type === "small" || control.type === "center" ? parent.verticalCenter : undefined
            anchors.top: control.type === "medium" || control.type === "large" ? parent.top : undefined
            sourceComponent: control.navigationIcon
            visible: control.hasNavigation
            width: visible ? 48 * control.themeGlobalScale : 0
            height: 48 * control.themeGlobalScale
        }

        Text {
            id: titleLabel
            text: control.isContextual
                  ? (control.selectionCount > 0 ? control.selectionCount.toString() : "")
                  : control.title

            readonly property real targetFontSize: {
                if (control.type === "large") return control.fontHeadlineLarge.size;
                if (control.type === "medium") return control.fontHeadlineMedium.size;
                return control.fontTitleLarge.size;
            }

            font.pixelSize: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) {
                    return (control.fontTitleLarge.size
                            + (targetFontSize - control.fontTitleLarge.size) * control.scrollProgress)
                           * control.themeGlobalScale;
                }
                return targetFontSize * control.themeGlobalScale;
            }

            font.weight: control.type === "large" ? control.fontHeadlineLarge.weight
                                                   : (control.type === "medium"
                                                      ? control.fontHeadlineMedium.weight
                                                      : control.fontTitleLarge.weight)
            font.letterSpacing: (control.fontTitleLarge.letterSpacing || 0) * control.themeGlobalScale
            lineHeight: control.fontTitleLarge.lineHeight
                        ? (control.fontTitleLarge.lineHeight / control.fontTitleLarge.size) : 28 / 22
            color: control.isContextual ? control.themeOnPrimaryContainer : control.themeOnSurface
            readonly property bool centeredTitle: control.type === "center" && !control.isContextual
            readonly property real logicalLeft: control.hasNavigation
                                                ? navIconLoader.x + navIconLoader.width + 16 * control.themeGlobalScale
                                                : 12 * control.themeGlobalScale
            readonly property real logicalRight: (control.type === "small" || control.type === "center")
                                                 ? actionRow.x - 12 * control.themeGlobalScale
                                                 : parent.width - 16 * control.themeGlobalScale
            width: centeredTitle
                   ? Math.max(0, parent.width - Math.max(navIconLoader.width, actionRow.width) * 2
                                      - 24 * control.themeGlobalScale)
                   : Math.max(0, logicalRight - logicalLeft)
            x: centeredTitle ? (parent.width - width) / 2 : logicalLeft
            elide: Text.ElideRight
            readonly property real resolvedBottomMargin: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) {
                    return (parent.height - control.fontTitleLarge.size * control.themeGlobalScale)
                           / 2 * (1.0 - control.scrollProgress);
                }
                return 0;
            }
            y: control.type === "small" || control.type === "center"
               ? (parent.height - height) / 2
               : parent.height - height - resolvedBottomMargin

            Behavior on font.pixelSize {
                enabled: !control.flexible && !MeoTheme.reduceMotion
                NumberAnimation { duration: control.motionMedium; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasized }
            }
            Behavior on color { ColorAnimation { duration: control.motionFast; easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandard } }
        }

        Row {
            id: actionRow
            anchors.right: parent.right
            anchors.verticalCenter: control.type === "small" || control.type === "center" ? parent.verticalCenter : undefined
            anchors.top: control.type === "medium" || control.type === "large" ? parent.top : undefined
            spacing: 4 * control.themeGlobalScale

            Repeater {
                model: control.actions
                delegate: Loader { sourceComponent: modelData }
            }
        }
    }
}
