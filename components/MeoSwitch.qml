import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control
    activeFocusOnTab: true

    property bool checked: false
    property bool isExpressive: MeoTheme.isExpressive
    property string label: ""
    property string text: label
    property bool showIcon: false
    property string icon: "check"
    property string uncheckedIcon: ""
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string thickness: "medium" // compatibility: "thin" | "medium" | "thick"
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
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeOnError: MeoTheme.contentOnError
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeSurfaceContainerHighest: MeoTheme.surfaceContainerHighest
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeError: MeoTheme.error
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionFast: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState
    readonly property int motionSelection: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection
    // AndroidX SwitchTokens.kt uses PrimaryContainer for a selected
    // hover/focus/pressed handle and OnSurfaceVariant for an unselected one.
    // The checked/unchecked resting colors are deliberately different.
    // Source: androidx-main Switch.kt 2e5e0a17a68bd5503a4a88f6d875e641ed9e7c46
    // and SwitchTokens.kt 1fd474ec436e63b0ec54c455f32445d2d4ef5123
    // (Apache-2.0); independently expressed with existing MeoTheme roles.
    readonly property bool hasInteractiveState: enabled
                                                && (activeFocus || hitArea.containsMouse || hitArea.pressed)
    // M3 Switch specs define a 40dp state layer and 48dp target around the
    // 52x32dp default track. Pressed handles grow to the track height minus
    // 4dp (28dp at the default size).
    readonly property real minimumTargetSize: 48 * themeGlobalScale
    readonly property real stateLayerSize: 40 * themeGlobalScale

    readonly property real trackWidth: {
        if (size === "xs") return 32 * themeGlobalScale
        if (size === "s") return 40 * themeGlobalScale
        if (size === "l") return 64 * themeGlobalScale
        if (size === "xl") return 80 * themeGlobalScale
        return 52 * themeGlobalScale
    }
    readonly property real trackHeight: {
        if (size === "xs") return 20 * themeGlobalScale
        if (size === "s") return 24 * themeGlobalScale
        if (size === "l") return 40 * themeGlobalScale
        if (size === "xl") return 48 * themeGlobalScale
        return 32 * themeGlobalScale
    }
    readonly property real thumbSizeUnchecked: {
        if (size === "xs") return 10 * themeGlobalScale
        if (size === "s") return 12 * themeGlobalScale
        if (size === "l") return 20 * themeGlobalScale
        if (size === "xl") return 24 * themeGlobalScale
        return 16 * themeGlobalScale
    }
    readonly property real thumbSizeChecked: {
        if (size === "xs") return 14 * themeGlobalScale
        if (size === "s") return 18 * themeGlobalScale
        if (size === "l") return 30 * themeGlobalScale
        if (size === "xl") return 36 * themeGlobalScale
        return 24 * themeGlobalScale
    }
    readonly property real thumbRestSize: checked || uncheckedIcon !== "" ? thumbSizeChecked : thumbSizeUnchecked
    readonly property real pressedThumbSize: Math.max(thumbRestSize, trackHeight - 4 * themeGlobalScale)
    readonly property real thumbTargetSize: hitArea.pressed ? pressedThumbSize : thumbRestSize
    readonly property real thumbCenterX: checked
                                          ? (mirrored ? trackHeight / 2 : trackWidth - trackHeight / 2)
                                          : (mirrored ? trackWidth - trackHeight / 2 : trackHeight / 2)
    // The baseline M3 outline is 2dp. The alternate widths are retained as
    // explicit MeoUI compatibility configurations rather than changing the
    // default Material contract.
    readonly property real trackBorderWidth: checked ? 0
                                                    : (thickness === "thin" ? 1
                                                                             : (thickness === "thick" ? 3 : 2)) * themeGlobalScale

    readonly property var fontLabel: {
        if (size === "xs") return MeoTheme.labelSmallUi
        if (size === "s") return MeoTheme.labelMediumUi
        if (size === "l") return MeoTheme.bodyMediumUi
        if (size === "xl") return MeoTheme.bodyBig
        return MeoTheme.labelBig
    }

    implicitWidth: Math.max(trackWidth + (label !== "" ? spacing + labelText.implicitWidth : 0), 52 * themeGlobalScale)
    implicitHeight: minimumTargetSize + (((isError && errorText !== "") || helperText !== "") ? 20 * themeGlobalScale : 0)
    spacing: 12 * themeGlobalScale
    padding: 0

    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.description: isError && errorText !== "" ? errorText : helperText
    Accessible.checked: checked
    Accessible.checkable: true
    Accessible.focusable: enabled && activeFocusOnTab
    Accessible.onPressAction: toggle()

    Keys.onSpacePressed: toggle()
    Keys.onReturnPressed: toggle()
    Keys.onEnterPressed: toggle()

    function toggle() {
        if (!enabled)
            return
        checked = !checked
        toggled(checked)
    }

    contentItem: Column {
        spacing: 4 * control.themeGlobalScale

        Row {
            objectName: "meoSwitchRow"
            height: control.minimumTargetSize
            spacing: control.spacing
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

            Item {
                width: control.trackWidth
                height: control.minimumTargetSize

                Rectangle {
                    id: switchTrack
                    objectName: "meoSwitchTrack"
                    anchors.centerIn: parent
                    width: control.trackWidth
                    height: control.trackHeight
                    radius: height / 2
                    color: {
                        if (!control.enabled) {
                            if (control.checked)
                                return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContainerOpacity)
                            return Qt.rgba(control.themeSurfaceContainerHighest.r, control.themeSurfaceContainerHighest.g, control.themeSurfaceContainerHighest.b, MeoTheme.disabledContainerOpacity)
                        }
                        if (control.checked)
                            return control.isError ? control.themeError : control.themePrimary
                        return control.themeSurfaceContainerHighest
                    }
                    border.width: control.trackBorderWidth
                    border.color: {
                        if (!control.enabled)
                            return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContainerOpacity)
                        return control.isError ? control.themeError : control.themeOutline
                    }

                    Behavior on color { ColorAnimation { duration: control.motionFast } }
                    Behavior on border.color { ColorAnimation { duration: control.motionFast } }

                    Rectangle {
                        id: thumb
                        objectName: "meoSwitchThumb"
                        width: control.thumbTargetSize
                        height: width
                        x: control.thumbCenterX - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        radius: width / 2
                        color: {
                            if (!control.enabled && control.checked)
                                return control.themeSurface
                            if (!control.enabled)
                                return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
                        if (control.checked)
                            return control.isError ? control.themeOnError
                                                   : (control.hasInteractiveState
                                                      ? control.themePrimaryContainer
                                                      : control.themeOnPrimary)
                        return control.isError ? control.themeError
                                               : (control.hasInteractiveState
                                                  ? control.themeOnSurfaceVariant
                                                  : control.themeOutline)
                        }

                        MeoIcon {
                            objectName: "meoSwitchThumbIcon"
                            anchors.centerIn: parent
                            icon: control.checked ? (control.showIcon ? control.icon : "") : control.uncheckedIcon
                            visible: icon !== ""
                            size: Math.max(10, control.thumbSizeChecked / control.themeGlobalScale * 0.62)
                            color: !control.enabled
                                   ? (control.checked
                                      ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
                                      : Qt.rgba(control.themeSurfaceContainerHighest.r, control.themeSurfaceContainerHighest.g, control.themeSurfaceContainerHighest.b, MeoTheme.disabledContentOpacity))
                                   : control.checked ? (control.isError ? control.themeError : control.themeOnPrimaryContainer)
                                                     : control.themeSurfaceContainerHighest
                            fill: control.checked
                            opacity: visible ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: control.motionFast } }
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: control.motionSelection
                                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                            }
                        }
                        Behavior on x {
                            NumberAnimation {
                                duration: control.motionSelection
                                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                            }
                        }
                        Behavior on color { ColorAnimation { duration: control.motionFast } }
                    }
                }

                MeoStateLayer {
                    width: control.stateLayerSize
                    height: width
                    x: switchTrack.x + control.thumbCenterX - width / 2
                    y: (parent.height - height) / 2
                    radius: width / 2
                    shape: "circle"
                    pressed: hitArea.pressed
                    hovered: hitArea.containsMouse
                    focused: control.activeFocus
                    pressX: hitArea.mouseX - x
                    pressY: hitArea.mouseY - y
                    color: control.checked ? (control.isError ? control.themeError : control.themePrimary) : control.themeOnSurface

                    Behavior on x {
                        NumberAnimation {
                            duration: control.motionSelection
                            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                        }
                    }
                }

                MouseArea {
                    id: hitArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: control.enabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        control.forceActiveFocus(Qt.MouseFocusReason)
                        control.toggle()
                    }
                }
            }

            Text {
                id: labelText
                text: control.label
                visible: text !== ""
                anchors.verticalCenter: parent.verticalCenter
                font.family: MeoTheme.typefacePlain
                font.pixelSize: control.fontLabel.size * control.themeGlobalScale
                font.weight: control.fontLabel.weight
                color: {
                    if (!control.enabled)
                        return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
                    return control.themeOnSurface
                }
            }
        }

        Text {
            visible: (control.isError && control.errorText !== "") || control.helperText !== ""
            text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
            leftPadding: control.trackWidth + control.spacing
            font.family: MeoTheme.typefacePlain
            font.pixelSize: Math.max(10, control.fontLabel.size - 2) * control.themeGlobalScale
            color: control.isError ? control.themeError : control.themeOnSurfaceVariant
        }
    }
}
