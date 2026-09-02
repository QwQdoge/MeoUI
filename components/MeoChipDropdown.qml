import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心对外属性
    property string type: "filled" // "filled" (默认) | "outlined"
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string label: "" // 悬浮标签文本
    property string helperText: "" // 底部辅助文本
    property bool isError: false // 错误状态开关
    property string errorText: "" // 错误提示文本（开启 isError 时优先显示）
    property string placeholder: "" // 占位文本
    property var model: [] // 菜单所有可选项列表, 例如 ["A", "B", "C"]
    property var selectedIndices: [] // 当前选中项的索引数组, 例如 [0, 2]
    property bool showCounter: false // 是否显示选中计数
    property bool error: isError

    onErrorChanged: isError = error
    onIsErrorChanged: {
        if (error !== isError)
            error = isError
    }

    // This composite deliberately reuses the shared theme, motion, chip, and
    // menu primitives. It must not carry a local fallback palette or motion
    // system, because its selected seeds need to follow dynamic color updates.
    readonly property int motionFast: MeoTheme.motionDurationState
    readonly property int motionMedium: MeoTheme.motionDurationSelection
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeSurfaceContainerHighest: MeoTheme.surfaceContainerHighest
    readonly property color themeError: MeoTheme.error
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontBodyLarge: MeoTheme.bodyLarge
    readonly property var fontBodyMedium: MeoTheme.bodyMedium
    readonly property var fontBodySmall: MeoTheme.bodySmall
    readonly property var fontLabelSmall: MeoTheme.labelSmall

    // 🌟 尺寸定义
    readonly property real containerHeight: {
        if (size === "xs") return MeoTheme.buttonHeightXS;
        if (size === "s") return MeoTheme.buttonHeightS;
        if (size === "m") return MeoTheme.buttonHeightM;
        if (size === "l") return MeoTheme.buttonHeightL;
        if (size === "xl") return MeoTheme.buttonHeightXL;
        return MeoTheme.buttonHeightM;
    }
    readonly property real helperSpace: (helperText !== "" || (isError && errorText !== "") || showCounter) ? 20 * themeGlobalScale : 0

    padding: 0
    implicitWidth: 280 * themeGlobalScale
    implicitHeight: Math.max(control.containerHeight, contentFlow.implicitHeight + (control.type === "filled" ? (control.label !== "" ? 28 : 16) : 16) * themeGlobalScale) + (size === "xs" ? 0 : helperSpace)

    opacity: control.enabled ? 1.0 : MeoTheme.disabledContentOpacity
    Behavior on opacity { NumberAnimation { duration: control.motionFast } }

    readonly property var currentFont: {
        if (size === "xs") return fontBodySmall;
        if (size === "s") return fontBodyMedium;
        return fontBodyLarge;
    }

    // 🌟 内边距自适应优化
    readonly property real sidePadding: {
        if (size === "xs") return 8 * themeGlobalScale;
        if (size === "s") return 12 * themeGlobalScale;
        return 16 * themeGlobalScale;
    }

    readonly property color transparentBg: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0)

    readonly property color containerColor: {
        if (!control.enabled) return type === "filled" ? Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, MeoTheme.disabledContainerOpacity) : transparentBg;
        return type === "filled" ? themeSurfaceContainerHighest : transparentBg;
    }

    readonly property color indicatorColor: {
        if (!control.enabled) return Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, MeoTheme.disabledContainerOpacity);
        if (isError) return themeError;
        if (control.activeFocus) return themePrimary;
        if (bgMouseArea.containsMouse) return themeOnSurface;
        return type === "filled" ? themeOnSurfaceVariant : themeOutline;
    }

    // 🌟 Background MouseArea positioned at the top of the content hierarchy visually
    // to avoid blocking clicks on child chip actions.
    MouseArea {
        id: bgMouseArea
        anchors.fill: parent
        anchors.bottomMargin: (control.size === "xs" ? 0 : control.helperSpace)
        enabled: control.enabled
        hoverEnabled: true
        onClicked: {
            control.forceActiveFocus()
            menu.open()
        }
    }

    background: Item {
        Rectangle {
            id: containerRect
            width: parent.width
            height: control.height - (control.size === "xs" ? 0 : control.helperSpace)
            radius: control.type === "filled"
                    ? 12 * control.themeGlobalScale
                    : (control.activeFocus ? 16 : 12) * control.themeGlobalScale
            topLeftRadius: control.activeFocus ? 16 * control.themeGlobalScale : 12 * control.themeGlobalScale
            topRightRadius: control.activeFocus ? 16 * control.themeGlobalScale : 12 * control.themeGlobalScale
            color: {
                let base = control.containerColor;
                if (control.enabled && bgMouseArea.containsMouse && control.type === "filled") {
                    return Qt.tint(base, Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08));
                }
                return base;
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 4 * control.themeGlobalScale
                color: containerRect.color
                visible: control.type === "filled"
            }

            Behavior on color { ColorAnimation { duration: control.motionFast; easing.bezierCurve: MeoTheme.motionEasingStandard } }

            border.color: control.type === "outlined" ? control.indicatorColor : "transparent"
            border.width: control.type === "outlined" ? (control.activeFocus ? 2 : 1) : 0

            Behavior on border.color { ColorAnimation { duration: control.motionFast } }
            Behavior on radius { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
            Behavior on topLeftRadius { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
            Behavior on topRightRadius { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }

            Rectangle {
                id: activeIndicator
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: control.activeFocus ? 2 * control.themeGlobalScale : 1 * control.themeGlobalScale
                color: control.indicatorColor
                visible: control.type === "filled"

                Behavior on height { NumberAnimation { duration: control.motionFast; easing.bezierCurve: MeoTheme.motionEasingStandard } }
                Behavior on color { ColorAnimation { duration: control.motionFast } }
            }
        }
    }

    // 🌟 Responsive Wrapping Flow of Removable Chips
    Flow {
        id: contentFlow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: control.sidePadding
        anchors.rightMargin: control.sidePadding + 32 * control.themeGlobalScale // space for trailing icon
        anchors.topMargin: (control.type === "filled" && control.label !== "" && overlayLayer.isCollapsed)
                           ? (control.size === "xl" ? 28 : 20) * control.themeGlobalScale
                           : (control.size === "xs" ? 4 : 8) * control.themeGlobalScale
        anchors.bottomMargin: (control.size === "xs" ? 4 : 8) * control.themeGlobalScale
        spacing: 6 * control.themeGlobalScale

        Repeater {
            model: control.selectedIndices
            delegate: MeoChip {
                required property var modelData
                label: control.model[modelData] || ""
                type: "input"
                closable: true
                size: {
                    if (control.size === "xs" || control.size === "s") return "xs";
                    if (control.size === "xl") return "l";
                    return "s";
                }
                selected: true
                onClosed: {
                    let arr = []
                    for (let i = 0; i < control.selectedIndices.length; i++) {
                        if (control.selectedIndices[i] !== modelData) {
                            arr.push(control.selectedIndices[i])
                        }
                    }
                    control.selectedIndices = arr
                }
            }
        }
    }

    // Trailing Dropdown Icon
    MeoIcon {
        anchors.right: parent.right
        anchors.rightMargin: control.sidePadding
        anchors.top: parent.top
        anchors.topMargin: (control.containerHeight - height) / 2
        icon: menu.opened ? "arrow_drop_up" : "arrow_drop_down"
        size: control.size === "xs" ? 18 : 24
        color: control.isError ? control.themeError : control.themeOnSurfaceVariant
    }

    // Placeholder
    MeoText {
        anchors.left: parent.left
        anchors.leftMargin: control.sidePadding
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: control.containerHeight / 2
        text: control.placeholder
        visible: (!control.selectedIndices || control.selectedIndices.length === 0) && overlayLayer.isCollapsed && control.placeholder !== ""
        typeRole: "body"
        typeSize: control.size === "xs" ? "small" : "medium"
        color: control.themeOnSurfaceVariant
        opacity: 0.6
    }

    // Sliding / Floating Label Layer
    Item {
        id: overlayLayer
        width: parent.width
        height: control.containerHeight
        visible: control.label !== "" && control.size !== "xs"
        enabled: false

        readonly property bool isCollapsed: control.activeFocus || (control.selectedIndices && control.selectedIndices.length > 0) || menu.opened

        Item {
            id: labelContainer
            x: control.sidePadding
            y: overlayLayer.isCollapsed
               ? (control.type === "filled" ? 6 * control.themeGlobalScale : -10 * control.themeGlobalScale)
               : (control.containerHeight - labelText.implicitHeight) / 2
            width: labelText.implicitWidth
            height: labelText.implicitHeight
            scale: {
                let targetSize = overlayLayer.isCollapsed ? MeoTheme.labelSmallEmphasized.size : control.currentFont.size;
                return targetSize / control.currentFont.size;
            }
            transformOrigin: Item.Left

            readonly property var labelFont: overlayLayer.isCollapsed ? MeoTheme.labelSmallEmphasized : control.currentFont

            Behavior on y { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: MeoTheme.motionEasingStandard } }
            Behavior on scale { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: MeoTheme.motionEasingStandard } }

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -4 * control.themeGlobalScale
                anchors.rightMargin: -4 * control.themeGlobalScale
                color: control.themeSurface
                visible: control.type === "outlined" && overlayLayer.isCollapsed
            }

            Text {
                id: labelText
                text: control.label
                anchors.fill: parent
                font.pixelSize: control.currentFont.size * control.themeGlobalScale
                font.weight: labelContainer.labelFont.weight
                font.family: MeoTheme.typefacePlain
                color: {
                    if (!control.enabled) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity);
                    if (control.isError) return control.themeError;
                    if (control.activeFocus) return control.themePrimary;
                    return control.themeOnSurfaceVariant;
                }

                Behavior on color { ColorAnimation { duration: control.motionFast } }
            }
        }
    }

    // Supporting Text Area
    Item {
        id: helperItem
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.right: parent.right
        anchors.rightMargin: 16 * control.themeGlobalScale
        height: 16 * control.themeGlobalScale
        visible: (helperLabel.text !== "" || counterLabel.visible) && control.size !== "xs"

        Text {
            id: helperLabel
            anchors.left: parent.left
            anchors.right: counterLabel.left
            anchors.rightMargin: 16 * control.themeGlobalScale
            text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
            font.pixelSize: control.fontBodySmall.size * control.themeGlobalScale
            font.family: MeoTheme.typefacePlain
            color: {
                if (!control.enabled) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity);
                return control.isError ? control.themeError : control.themeOnSurfaceVariant;
            }
            elide: Text.ElideRight
            Behavior on color { ColorAnimation { duration: control.motionFast } }
        }

        Text {
            id: counterLabel
            anchors.right: parent.right
            visible: control.showCounter
            text: control.selectedIndices ? (control.selectedIndices.length + " selected") : "0 selected"
            font.pixelSize: control.fontBodySmall.size * control.themeGlobalScale
            font.family: MeoTheme.typefacePlain
            color: control.themeOnSurfaceVariant
        }
    }

    // Dropdown Selection Menu
    MeoMenu {
        id: menu
        width: control.width
        y: containerRect.height
        model: {
            let m = []
            for (let i = 0; i < control.model.length; i++) {
                let isSel = control.selectedIndices && control.selectedIndices.indexOf(i) !== -1;
                m.push({
                    label: control.model[i],
                    icon: isSel ? "check" : "",
                    isVibrant: isSel,
                    action: (function(idx) {
                        return function() {
                            let arr = []
                            let sel = control.selectedIndices || []
                            let idxInSel = sel.indexOf(idx);
                            if (idxInSel !== -1) {
                                // Remove option
                                for (let j = 0; j < sel.length; j++) {
                                    if (sel[j] !== idx) arr.push(sel[j])
                                }
                            } else {
                                // Add option
                                arr = sel.concat([idx])
                            }
                            control.selectedIndices = arr
                        }
                    })(i)
                })
            }
            return m
        }
    }
}
