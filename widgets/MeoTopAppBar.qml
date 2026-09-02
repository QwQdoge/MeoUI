import QtQuick
import QtQuick.Controls
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
        ColorAnimation { duration: control.motionMedium; easing.bezierCurve: MeoTheme.motionEasingEmphasized }
    }

    Behavior on height {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: control.motionMedium; easing.bezierCurve: MeoTheme.motionEasingEmphasized }
    }

    Rectangle {
        id: stateLayer
        anchors.fill: parent
        color: isContextual ? themeOnPrimaryContainer : "transparent"
        opacity: 0.08
        visible: isContextual
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
            text: isContextual ? (selectionCount > 0 ? selectionCount.toString() : "") : control.title

            readonly property real targetFontSize: {
                if (control.type === "large") return fontHeadlineLarge.size;
                if (control.type === "medium") return fontHeadlineMedium.size;
                return fontTitleLarge.size;
            }

            font.pixelSize: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) {
                    return (fontTitleLarge.size + (targetFontSize - fontTitleLarge.size) * control.scrollProgress) * control.themeGlobalScale;
                }
                return targetFontSize * control.themeGlobalScale;
            }

            font.weight: (control.type === "large" ? fontHeadlineLarge.weight : (control.type === "medium" ? fontHeadlineMedium.weight : fontTitleLarge.weight))
            font.letterSpacing: (fontTitleLarge.letterSpacing || 0) * control.themeGlobalScale
            lineHeight: fontTitleLarge.lineHeight ? (fontTitleLarge.lineHeight / fontTitleLarge.size) : 28 / 22
            color: isContextual ? control.themeOnPrimaryContainer : control.themeOnSurface
            anchors.horizontalCenter: (control.type === "center" && !isContextual) ? parent.horizontalCenter : undefined
            anchors.left: (control.type === "center" && !isContextual) ? undefined : (control.hasNavigation ? navIconLoader.right : parent.left)
            anchors.leftMargin: (control.type === "center" && !isContextual) ? 0 : (control.hasNavigation ? 16 : 12) * control.themeGlobalScale
            anchors.right: (control.type === "center" && !isContextual) ? undefined
                          : ((control.type === "small" || control.type === "center") ? actionRow.left : parent.right)
            anchors.rightMargin: (control.type === "small" || control.type === "center") ? 12 * control.themeGlobalScale : 16 * control.themeGlobalScale
            width: (control.type === "center" && !isContextual)
                   ? Math.max(0, parent.width - Math.max(navIconLoader.width, actionRow.width) * 2 - 24 * control.themeGlobalScale)
                   : undefined
            elide: Text.ElideRight

            anchors.verticalCenter: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) return undefined;
                return control.type === "small" || control.type === "center" ? parent.verticalCenter : undefined
            }

            anchors.bottom: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) return parent.bottom;
                return control.type === "medium" || control.type === "large" ? parent.bottom : undefined
            }

            anchors.bottomMargin: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) {
                    return (parent.height - fontTitleLarge.size * control.themeGlobalScale) / 2 * (1.0 - control.scrollProgress);
                }
                return 0;
            }

            Behavior on font.pixelSize {
                enabled: !control.flexible && !MeoTheme.reduceMotion
                NumberAnimation { duration: control.motionMedium; easing.bezierCurve: MeoTheme.motionEasingEmphasized }
            }
            Behavior on color { ColorAnimation { duration: control.motionFast } }
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
