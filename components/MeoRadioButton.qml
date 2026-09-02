import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control
    activeFocusOnTab: true

    // 🌟 核心属性
    property bool checked: false
    property string label: ""
    property string text: label
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string thickness: "medium" // "thin" | "medium" | "thick"
    property bool isError: false
    property string errorText: ""
    property string helperText: ""

    signal toggled(bool checked)

    onTextChanged: {
        if (label !== text)
            label = text
    }
    onLabelChanged: {
        if (text !== label)
            text = label
    }

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeError: MeoTheme.error
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionStateDuration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationShort2
    readonly property int motionSelectDuration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationFast
    // AndroidX RadioButtonTokens keeps selected enabled marks Primary. An
    // unselected enabled ring is OnSurfaceVariant at rest, then OnSurface for
    // hover, focus, or press. Keep that semantic distinction rather than
    // using one outline role for every enabled state.
    // Source: androidx-main RadioButton.kt 0f823cf70129ce97e94871fad6d1bb750cd6e5b5
    // and RadioButtonTokens.kt abd46df399f6e310e113f66cd51ab9250735215f
    // (Apache-2.0); expressed through existing MeoTheme color roles.
    readonly property bool hasInteractiveState: enabled
                                                && (activeFocus || mouseArea.containsMouse || mouseArea.pressed)
    readonly property color selectedIndicatorColor: !enabled
                                                  ? Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, MeoTheme.disabledContentOpacity)
                                                  : (isError ? themeError : themePrimary)
    // M3 Radio Button specs: a 20dp icon is hosted in a 48dp target with a
    // 40dp state layer. The public size variants keep their visual sizes, but
    // the default M3 target and interaction layer remain fixed.
    readonly property real minimumTargetSize: 48 * themeGlobalScale
    readonly property real stateLayerSize: 40 * themeGlobalScale

    Accessible.role: Accessible.RadioButton
    Accessible.name: label
    Accessible.description: isError && errorText !== "" ? errorText : helperText
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.focusable: enabled && activeFocusOnTab
    Accessible.onPressAction: select()

    // 📐 尺寸与比例自适应 (Sizes and Proportions)
    readonly property real radioOuterSize: {
        if (size === "xs") return 16 * themeGlobalScale
        if (size === "s") return 18 * themeGlobalScale
        if (size === "m") return 20 * themeGlobalScale
        if (size === "l") return 26 * themeGlobalScale
        if (size === "xl") return 34 * themeGlobalScale
        return 20 * themeGlobalScale
    }

    readonly property real radioBorderWidth: {
        const borderVal = (thickness === "thin" ? MeoTheme.strokeWidthThin :
                           (thickness === "thick" ? MeoTheme.strokeWidthThick : MeoTheme.strokeWidthMedium))
        if (size === "xs") return Math.max(1, borderVal * 0.75)
        if (size === "xl") return borderVal * 1.5
        return borderVal
    }

    readonly property real radioInnerSize: {
        if (size === "xs") return 8 * themeGlobalScale
        if (size === "s") return 9 * themeGlobalScale
        if (size === "m") return 10 * themeGlobalScale
        if (size === "l") return 14 * themeGlobalScale
        if (size === "xl") return 18 * themeGlobalScale
        return 10 * themeGlobalScale
    }

    readonly property var fontLabel: {
        if (size === "xs") return MeoTheme.labelSmallUi
        if (size === "s") return MeoTheme.labelMediumUi
        if (size === "m") return MeoTheme.labelBig
        if (size === "l") return MeoTheme.bodyMediumUi
        if (size === "xl") return MeoTheme.bodyBig
        return MeoTheme.labelBig
    }

    implicitWidth: Math.max(radioOuter.width + (label !== "" ? spacing + labelText.implicitWidth : 0), minimumTargetSize)
    implicitHeight: minimumTargetSize + ((errorText !== "" && isError) || helperText !== "" ? 20 * themeGlobalScale : 0)

    padding: 0
    spacing: 12 * themeGlobalScale

    function select() {
        if (!enabled || checked)
            return
        checked = true
        toggled(true)
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            select()
            event.accepted = true
        }
    }

    // 点击交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: control.enabled
        onClicked: control.select()
    }

    contentItem: Column {
        spacing: 4 * control.themeGlobalScale

        Row {
            objectName: "meoRadioButtonRow"
            height: control.minimumTargetSize
            spacing: control.spacing
            layoutDirection: control.LayoutMirroring.enabled ? Qt.RightToLeft : Qt.LeftToRight

            // 🎨 单选框外圈 (Radio outer ring)
            Rectangle {
                id: radioOuter
                objectName: "meoRadioButtonOuter"
                width: control.radioOuterSize
                height: control.radioOuterSize
                anchors.verticalCenter: parent.verticalCenter
                radius: width / 2
                color: "transparent"
                border.color: {
                    if (!control.enabled) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
                    if (control.checked) return control.isError ? control.themeError : control.themePrimary
                    if (control.isError)
                        return control.themeError
                    return control.hasInteractiveState
                           ? control.themeOnSurface
                           : control.themeOnSurfaceVariant
                }
                border.width: control.radioBorderWidth

                // 🌟 核心选中原点 (Active inner point)
                Rectangle {
                    objectName: "meoRadioButtonDot"
                    anchors.centerIn: parent
                    width: control.checked ? control.radioInnerSize : 0
                    height: width
                    radius: width / 2
                    color: control.selectedIndicatorColor

                    Behavior on width {
                        NumberAnimation {
                            duration: control.motionSelectDuration
                            easing.bezierCurve: MeoTheme.motionEasingStandard
                        }
                    }
                }

                // 🌟 状态层反馈 (Hover/Pressed/Focused states)
                Item {
                    anchors.centerIn: parent
                    width: control.stateLayerSize
                    height: control.stateLayerSize
                    z: -1

                    MeoStateLayer {
                        radius: width / 2
                        shape: "circle"
                        pressed: mouseArea.pressed
                        hovered: mouseArea.containsMouse
                        focused: control.activeFocus
                        pressX: mouseArea.mouseX - parent.x
                        pressY: mouseArea.mouseY - parent.y
                        color: control.checked ? (control.isError ? control.themeError : control.themePrimary) : control.themeOnSurface
                    }
                }

                Behavior on border.color { ColorAnimation { duration: control.motionStateDuration; easing.bezierCurve: MeoTheme.motionEasingStandard } }
            }

            // 🔤 标签文本
            Text {
                id: labelText
                text: control.label
                font.family: MeoTheme.typefacePlain
                font.pixelSize: control.fontLabel.size * control.themeGlobalScale
                font.weight: control.fontLabel.weight
                color: {
                    if (!control.enabled) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
                    return control.themeOnSurface
                }
                anchors.verticalCenter: parent.verticalCenter
                visible: text !== ""
            }
        }

        // Helper / Error Text Block (MD3 Specification)
        Text {
            id: feedbackText
            visible: (control.isError && control.errorText !== "") || control.helperText !== ""
            text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
            font.family: MeoTheme.typefacePlain
            font.pixelSize: (control.fontLabel.size - 2) * control.themeGlobalScale
            color: control.isError ? control.themeError : control.themeOnSurfaceVariant
            leftPadding: control.radioOuterSize + control.spacing
        }
    }
}
