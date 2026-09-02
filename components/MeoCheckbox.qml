import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control
    activeFocusOnTab: true

    // 🌟 核心属性
    property bool checked: false
    property bool indeterminate: false // 🌟 New: Indeterminate state support
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
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themeOnError: MeoTheme.contentOnError
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeError: MeoTheme.error
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionStateDuration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationShort2
    readonly property int motionCheckDuration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium1
    // CheckboxTokens distinguishes the resting unselected outline
    // (OnSurfaceVariant) from hover/focus/pressed (OnSurface). Selected
    // containers remain Primary in all enabled interaction states.
    // Source: androidx-main Checkbox.kt fc0c51a91b9b4ab680d987a08b939e7907cd4e6f
    // and CheckboxTokens.kt 2e134988e3b23bb08dd846f449cc5c2e82c6ccba
    // (Apache-2.0); mapped only through existing semantic MeoTheme roles.
    readonly property bool hasInteractiveState: enabled
                                                && (activeFocus || mouseArea.containsMouse || mouseArea.pressed)
    // AndroidX CheckboxTokens: selected error marks use OnError; disabled
    // selected marks use Surface rather than a translucent content role.
    readonly property color checkmarkColor: !enabled ? themeSurface
                                             : isError ? themeOnError
                                             : themeOnPrimary
    // M3 Checkbox specs: a visual 18dp control sits in a 48dp target with a
    // 40dp state layer. Keep custom indicator-size variants while preserving
    // the standard target at the default scale.
    readonly property real minimumTargetSize: 48 * themeGlobalScale
    readonly property real stateLayerSize: 40 * themeGlobalScale

    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.description: isError && errorText !== "" ? errorText : helperText
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.checkStateMixed: indeterminate
    Accessible.focusable: enabled && activeFocusOnTab
    Accessible.onPressAction: toggleSelection()

    // 📐 尺寸与比例自适应 (Sizes and Proportions)
    readonly property real checkboxSize: {
        if (size === "xs") return 14 * themeGlobalScale
        if (size === "s") return 16 * themeGlobalScale
        if (size === "m") return 18 * themeGlobalScale
        if (size === "l") return 24 * themeGlobalScale
        if (size === "xl") return 32 * themeGlobalScale
        return 18 * themeGlobalScale
    }

    readonly property real checkboxBorderWidth: {
        const borderVal = (thickness === "thin" ? MeoTheme.strokeWidthThin :
                           (thickness === "thick" ? MeoTheme.strokeWidthThick : MeoTheme.strokeWidthMedium))
        if (size === "xs") return Math.max(1, borderVal * 0.75)
        if (size === "xl") return borderVal * 1.5
        return borderVal
    }

    readonly property var fontLabel: {
        if (size === "xs") return MeoTheme.labelSmallUi
        if (size === "s") return MeoTheme.labelMediumUi
        if (size === "m") return MeoTheme.labelBig
        if (size === "l") return MeoTheme.bodyMediumUi
        if (size === "xl") return MeoTheme.bodyBig
        return MeoTheme.labelBig
    }

    implicitWidth: Math.max(checkboxRect.width + (label !== "" ? spacing + labelText.implicitWidth : 0), minimumTargetSize)
    implicitHeight: minimumTargetSize + ((errorText !== "" && isError) || helperText !== "" ? 20 * themeGlobalScale : 0)

    padding: 0
    spacing: 12 * themeGlobalScale

    function toggleSelection() {
        if (!enabled)
            return
        if (indeterminate) {
            indeterminate = false
            checked = true
        } else {
            checked = !checked
        }
        toggled(checked)
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            toggleSelection()
            event.accepted = true
        }
    }

    // 点击交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: control.enabled
        onClicked: control.toggleSelection()
    }

    contentItem: Column {
        spacing: 4 * control.themeGlobalScale

        Row {
            objectName: "meoCheckboxRow"
            height: control.minimumTargetSize
            spacing: control.spacing
            layoutDirection: control.LayoutMirroring.enabled ? Qt.RightToLeft : Qt.LeftToRight

            // 🎨 复选框容器 (Checkbox container)
            Rectangle {
                id: checkboxRect
                objectName: "meoCheckboxIndicator"
                width: control.checkboxSize
                height: control.checkboxSize
                anchors.verticalCenter: parent.verticalCenter
                radius: 2 * control.themeGlobalScale

                color: {
                    if (!control.enabled)
                        return (control.checked || control.indeterminate)
                                ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
                                : "transparent"
                    if (control.checked || control.indeterminate) return control.isError ? control.themeError : control.themePrimary
                    return "transparent"
                }

                border.color: {
                    if (!control.enabled) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
                    if (control.checked || control.indeterminate) return control.isError ? control.themeError : control.themePrimary
                    if (control.isError)
                        return control.themeError
                    return control.hasInteractiveState
                           ? control.themeOnSurface
                           : control.themeOnSurfaceVariant
                }
                // CheckboxTokens selected states have no separate outline.
                // The unselected/error outline remains the 2dp token (or the
                // existing explicit thickness compatibility setting).
                border.width: (control.checked || control.indeterminate) ? 0 : control.checkboxBorderWidth

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

                // 🌟 对勾/不确定态图标 (Animated Canvas Path)
                Canvas {
                    id: checkmarkCanvas
                    objectName: "meoCheckboxMark"
                    anchors.fill: parent
                    anchors.margins: Math.max(1, 2 * control.themeGlobalScale)
                    property real animationProgress: (control.checked || control.indeterminate) ? 1.0 : 0.0
                    // AndroidX morphs an indeterminate dash into the check by
                    // gravitating its centre and right endpoint. Off-to-on is
                    // still controlled by the drawing fraction above.
                    property real indeterminateMorph: control.indeterminate ? 1.0 : 0.0

                    onAnimationProgressChanged: requestPaint()
                    onIndeterminateMorphChanged: requestPaint()

                    Connections {
                        target: control
                        function onIndeterminateChanged() { checkmarkCanvas.requestPaint() }
                    }

                    Behavior on animationProgress {
                        NumberAnimation { duration: control.motionCheckDuration; easing.bezierCurve: MeoTheme.motionEasingStandard }
                    }
                    Behavior on indeterminateMorph {
                        NumberAnimation { duration: control.motionCheckDuration; easing.bezierCurve: MeoTheme.motionEasingStandard }
                    }

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = control.checkmarkColor;
                        // CheckboxDefaults.StrokeWidth is 2dp. Custom
                        // thicknesses remain a MeoUI compatibility extension.
                        ctx.lineWidth = Math.max(1, control.checkboxBorderWidth);
                        ctx.lineCap = "square";
                        ctx.lineJoin = "miter";

                        var w = width;
                        var h = height;

                        if (control.indeterminate) {
                            // Horizontal line for indeterminate
                            ctx.beginPath();
                            ctx.moveTo(w * 0.25, h * 0.5);
                            ctx.lineTo(w * (0.25 + 0.5 * animationProgress), h * 0.5);
                            ctx.stroke();
                        } else {
                            // Checkmark points
                            var indeterminateProgress = checkmarkCanvas.indeterminateMorph;
                            var p1 = { x: w * 0.25, y: h * 0.5 };
                            var p2 = { x: w * (0.4 + 0.1 * indeterminateProgress),
                                       y: h * (0.65 - 0.15 * indeterminateProgress) };
                            var p3 = { x: w * 0.75,
                                       y: h * (0.3 + 0.2 * indeterminateProgress) };

                            ctx.beginPath();
                            if (animationProgress > 0) {
                                ctx.moveTo(p1.x, p1.y);
                                if (animationProgress <= 0.4) {
                                    var t = animationProgress / 0.4;
                                    ctx.lineTo(p1.x + (p2.x - p1.x) * t, p1.y + (p2.y - p1.y) * t);
                                } else {
                                    ctx.lineTo(p2.x, p2.y);
                                    var t = (animationProgress - 0.4) / 0.6;
                                    ctx.lineTo(p2.x + (p3.x - p2.x) * t, p2.y + (p3.y - p2.y) * t);
                                }
                            }
                            ctx.stroke();
                        }
                    }
                }

                Behavior on color { ColorAnimation { duration: control.motionStateDuration; easing.bezierCurve: MeoTheme.motionEasingStandard } }
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
            leftPadding: control.checkboxSize + control.spacing
        }
    }
}
