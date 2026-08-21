import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control
    activeFocusOnTab: true

    property bool checked: false
    property bool isExpressive: (typeof MeoTheme !== "undefined" && typeof MeoTheme.isExpressive !== "undefined") ? MeoTheme.isExpressive : true
    property string label: ""
    property string text: label
    property bool showIcon: true
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

    readonly property bool isDarkMode: (typeof MeoTheme !== "undefined" && typeof MeoTheme.isDarkMode !== "undefined") ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnPrimary !== "undefined") ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerHighest !== "undefined") ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outline !== "undefined") ? MeoTheme.outline : "#79747E"
    readonly property color themeError: (typeof MeoTheme !== "undefined" && typeof MeoTheme.error !== "undefined") ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 100
    readonly property int motionSelection: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSelection !== "undefined") ? MeoTheme.motionDurationSelection : 220

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
    readonly property real thumbTargetSize: hitArea.pressed && isExpressive
                                            ? Math.min(trackHeight - 4 * themeGlobalScale, thumbRestSize + 4 * themeGlobalScale)
                                            : thumbRestSize
    readonly property real thumbCenterX: checked ? trackWidth - trackHeight / 2 : trackHeight / 2
    readonly property real trackBorderWidth: checked ? 0 : Math.max(1 * themeGlobalScale, (thickness === "thick" ? 2 : 1) * themeGlobalScale)

    readonly property var fontLabel: {
        if (typeof MeoTheme === "undefined") return ({ "size": 14, "weight": Font.Medium })
        if (size === "xs" && typeof MeoTheme.labelSmallUi !== "undefined") return MeoTheme.labelSmallUi
        if (size === "s" && typeof MeoTheme.labelMediumUi !== "undefined") return MeoTheme.labelMediumUi
        if (size === "l" && typeof MeoTheme.bodyMediumUi !== "undefined") return MeoTheme.bodyMediumUi
        if (size === "xl" && typeof MeoTheme.bodyBig !== "undefined") return MeoTheme.bodyBig
        return typeof MeoTheme.labelBig !== "undefined" ? MeoTheme.labelBig : MeoTheme.labelLarge
    }

    implicitWidth: Math.max(trackWidth + (label !== "" ? spacing + labelText.implicitWidth : 0), 52 * themeGlobalScale)
    implicitHeight: Math.max(trackHeight, 40 * themeGlobalScale) + (((isError && errorText !== "") || helperText !== "") ? 20 * themeGlobalScale : 0)
    spacing: 12 * themeGlobalScale
    padding: 4 * themeGlobalScale

    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.checked: checked
    Accessible.checkable: true
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
            spacing: control.spacing

            Item {
                width: control.trackWidth
                height: Math.max(control.trackHeight, 40 * control.themeGlobalScale)

                Rectangle {
                    id: switchTrack
                    anchors.centerIn: parent
                    width: control.trackWidth
                    height: control.trackHeight
                    radius: height / 2
                    color: {
                        if (!control.enabled)
                            return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08)
                        if (control.checked)
                            return control.isError ? control.themeError : control.themePrimary
                        return control.themeSurfaceContainerHighest
                    }
                    border.width: control.trackBorderWidth
                    border.color: {
                        if (!control.enabled)
                            return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.18)
                        return control.isError ? control.themeError : control.themeOutline
                    }

                    Behavior on color { ColorAnimation { duration: control.motionFast } }
                    Behavior on border.color { ColorAnimation { duration: control.motionFast } }

                    Rectangle {
                        id: thumb
                        width: control.thumbTargetSize
                        height: width
                        x: control.thumbCenterX - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        radius: width / 2
                        color: {
                            if (!control.enabled)
                                return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.38)
                            if (control.checked)
                                return control.themeOnPrimary
                            return control.isError ? control.themeError : control.themeOutline
                        }

                        MeoIcon {
                            anchors.centerIn: parent
                            icon: control.checked ? (control.showIcon ? control.icon : "") : control.uncheckedIcon
                            visible: icon !== ""
                            size: Math.max(10, control.thumbSizeChecked / control.themeGlobalScale * 0.62)
                            color: control.checked ? (control.isError ? control.themeError : control.themePrimary) : control.themeSurfaceContainerHighest
                            fill: control.checked
                            scale: visible ? 1.0 : 0.75
                            opacity: visible ? 1.0 : 0.0
                            Behavior on scale { NumberAnimation { duration: control.motionSelection } }
                            Behavior on opacity { NumberAnimation { duration: control.motionFast } }
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: control.motionSelection
                                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                            }
                        }
                        Behavior on x {
                            NumberAnimation {
                                duration: control.motionSelection
                                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                            }
                        }
                        Behavior on color { ColorAnimation { duration: control.motionFast } }
                    }
                }

                MeoStateLayer {
                    width: 40 * control.themeGlobalScale
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
                            easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
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
                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: control.fontLabel.size * control.themeGlobalScale
                font.weight: control.fontLabel.weight
                color: {
                    if (!control.enabled)
                        return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.38)
                    if (control.isError)
                        return control.themeError
                    return control.themeOnSurface
                }
            }
        }

        Text {
            visible: (control.isError && control.errorText !== "") || control.helperText !== ""
            text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
            leftPadding: control.trackWidth + control.spacing
            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
            font.pixelSize: Math.max(10, control.fontLabel.size - 2) * control.themeGlobalScale
            color: control.isError ? control.themeError : control.themeOnSurfaceVariant
        }
    }
}
