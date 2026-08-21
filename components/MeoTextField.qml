import QtQuick
import QtQuick.Controls
import MeoUI

TextField {
    id: control

    property string type: "filled" // "filled" | "outlined"
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string label: ""
    property string helperText: ""
    property bool isError: false
    property string errorText: ""
    property bool showClearButton: false
    property string placeholder: ""
    property string supportingText: ""
    property bool error: isError
    property bool isPassword: false
    property bool passwordVisible: false
    property string leadingIcon: ""
    property string trailingIcon: ""
    property string prefixText: ""
    property string suffixText: ""
    property int maxLength: -1
    property bool showCounter: false

    signal trailingIconClicked()

    onSupportingTextChanged: {
        if (helperText !== supportingText)
            helperText = supportingText
    }
    onHelperTextChanged: {
        if (supportingText !== helperText)
            supportingText = helperText
    }
    onErrorChanged: {
        if (isError !== error)
            isError = error
    }
    onIsErrorChanged: {
        if (error !== isError)
            error = isError
    }

    readonly property bool isDarkMode: (typeof MeoTheme !== "undefined" && typeof MeoTheme.isDarkMode !== "undefined") ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutline: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outline !== "undefined") ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerHighest !== "undefined") ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeError: (typeof MeoTheme !== "undefined" && typeof MeoTheme.error !== "undefined") ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 100
    readonly property int motionMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSelection !== "undefined") ? MeoTheme.motionDurationSelection : 220

    readonly property var fontBody: {
        if (typeof MeoTheme === "undefined") return ({ "size": 16, "weight": Font.Normal })
        if (size === "xs" && typeof MeoTheme.bodySmall !== "undefined") return MeoTheme.bodySmall
        if (size === "s" && typeof MeoTheme.bodyMedium !== "undefined") return MeoTheme.bodyMedium
        return typeof MeoTheme.bodyLarge !== "undefined" ? MeoTheme.bodyLarge : ({ "size": 16, "weight": Font.Normal })
    }
    readonly property var fontLabel: (typeof MeoTheme !== "undefined" && typeof MeoTheme.labelSmall !== "undefined") ? MeoTheme.labelSmall : ({ "size": 11, "weight": Font.Medium })

    readonly property real containerHeight: {
        if (size === "xs") return 40 * themeGlobalScale
        if (size === "s") return 48 * themeGlobalScale
        if (size === "l") return 64 * themeGlobalScale
        if (size === "xl") return 72 * themeGlobalScale
        return 56 * themeGlobalScale
    }
    readonly property real containerRadius: {
        if (size === "xs") return 16 * themeGlobalScale
        if (size === "s") return 18 * themeGlobalScale
        if (size === "xl") return 24 * themeGlobalScale
        return 20 * themeGlobalScale
    }
    readonly property real sidePadding: (size === "xs" ? 12 : size === "s" ? 14 : 16) * themeGlobalScale
    readonly property real iconSizePx: (size === "xs" ? 18 : size === "s" ? 20 : 24) * themeGlobalScale
    readonly property bool hasSupportingLine: (isError && errorText !== "") || helperText !== "" || showCounter
    readonly property real supportingHeight: hasSupportingLine ? 24 * themeGlobalScale : 0
    readonly property bool labelRaised: label !== "" && (activeFocus || text !== "" || placeholder !== "")
    readonly property bool hasLeading: leadingIcon !== "" || prefixText !== ""
    readonly property bool hasTrailing: trailingIcon !== "" || suffixText !== "" || isPassword || (showClearButton && text !== "")

    implicitWidth: 280 * themeGlobalScale
    implicitHeight: containerHeight + supportingHeight
    padding: 0
    maximumLength: maxLength > 0 ? maxLength : 32767
    echoMode: isPassword && !passwordVisible ? TextInput.Password : TextInput.Normal
    selectByMouse: true

    font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
    font.pixelSize: fontBody.size * themeGlobalScale
    font.weight: fontBody.weight
    color: enabled ? (isError ? themeError : themeOnSurface)
                   : Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.38)
    selectionColor: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0.28)
    selectedTextColor: themeOnSurface

    placeholderText: labelRaised ? placeholder : (label !== "" ? label : placeholder)
    placeholderTextColor: enabled ? themeOnSurfaceVariant : Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.38)

    leftPadding: sidePadding
                 + (leadingIcon !== "" ? iconSizePx + 10 * themeGlobalScale : 0)
                 + (prefixText !== "" ? prefixLabel.implicitWidth + 6 * themeGlobalScale : 0)
    rightPadding: sidePadding
                  + (suffixText !== "" ? suffixLabel.implicitWidth + 6 * themeGlobalScale : 0)
                  + (hasTrailing ? 34 * themeGlobalScale : 0)
    topPadding: labelRaised ? 18 * themeGlobalScale : 0
    bottomPadding: supportingHeight + (labelRaised ? 2 * themeGlobalScale : 0)
    verticalAlignment: TextInput.AlignVCenter

    background: Item {
        Rectangle {
            id: fieldContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: control.containerHeight
            radius: control.containerRadius
            color: {
                if (control.type === "outlined")
                    return "transparent"
                var base = control.themeSurfaceContainerHighest
                if (!control.enabled)
                    return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.04)
                if (control.hovered)
                    return Qt.tint(base, Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.06))
                return base
            }
            border.width: {
                if (control.activeFocus) return 2 * control.themeGlobalScale
                if (control.type === "outlined") return 1 * control.themeGlobalScale
                return 0
            }
            border.color: {
                if (control.isError) return control.themeError
                if (control.activeFocus) return control.themePrimary
                if (control.type === "outlined") return control.hovered ? control.themeOnSurface : control.themeOutline
                return "transparent"
            }

            Behavior on color { ColorAnimation { duration: control.motionFast } }
            Behavior on border.color { ColorAnimation { duration: control.motionFast } }
            Behavior on border.width { NumberAnimation { duration: control.motionFast } }
        }

        Text {
            visible: control.labelRaised
            text: control.label
            anchors.left: fieldContainer.left
            anchors.leftMargin: control.sidePadding + (control.leadingIcon !== "" ? control.iconSizePx + 10 * control.themeGlobalScale : 0)
            anchors.top: fieldContainer.top
            anchors.topMargin: 7 * control.themeGlobalScale
            font.family: control.font.family
            font.pixelSize: control.fontLabel.size * control.themeGlobalScale
            font.weight: control.fontLabel.weight
            color: control.isError ? control.themeError : (control.activeFocus ? control.themePrimary : control.themeOnSurfaceVariant)
            Behavior on color { ColorAnimation { duration: control.motionFast } }
        }

        Row {
            anchors.left: fieldContainer.left
            anchors.leftMargin: control.sidePadding
            anchors.verticalCenter: fieldContainer.verticalCenter
            anchors.verticalCenterOffset: control.labelRaised ? 6 * control.themeGlobalScale : 0
            spacing: 8 * control.themeGlobalScale
            visible: control.hasLeading

            MeoIcon {
                icon: control.leadingIcon
                visible: icon !== ""
                size: control.iconSizePx / control.themeGlobalScale
                color: control.activeFocus ? control.themePrimary : control.themeOnSurfaceVariant
            }

            Text {
                id: prefixLabel
                text: control.prefixText
                visible: text !== ""
                font.family: control.font.family
                font.pixelSize: control.font.pixelSize
                color: control.themeOnSurfaceVariant
            }
        }

        Row {
            anchors.right: fieldContainer.right
            anchors.rightMargin: control.sidePadding
            anchors.verticalCenter: fieldContainer.verticalCenter
            anchors.verticalCenterOffset: control.labelRaised ? 6 * control.themeGlobalScale : 0
            spacing: 6 * control.themeGlobalScale

            Text {
                id: suffixLabel
                text: control.suffixText
                visible: text !== ""
                font.family: control.font.family
                font.pixelSize: control.font.pixelSize
                color: control.themeOnSurfaceVariant
            }

            MeoIconButton {
                visible: control.isPassword
                icon.name: control.passwordVisible ? "visibility_off" : "visibility"
                size: "s"
                type: "standard"
                width: 32 * control.themeGlobalScale
                height: width
                onClicked: control.passwordVisible = !control.passwordVisible
            }

            MeoIconButton {
                visible: !control.isPassword && control.showClearButton && control.text !== ""
                icon.name: "close"
                size: "s"
                type: "standard"
                width: 32 * control.themeGlobalScale
                height: width
                onClicked: {
                    control.clear()
                    control.forceActiveFocus()
                }
            }

            MeoIconButton {
                visible: !control.isPassword && !(control.showClearButton && control.text !== "") && control.trailingIcon !== ""
                icon.name: control.trailingIcon
                size: "s"
                type: "standard"
                width: 32 * control.themeGlobalScale
                height: width
                onClicked: control.trailingIconClicked()
            }
        }

        Row {
            anchors.left: fieldContainer.left
            anchors.leftMargin: control.sidePadding
            anchors.right: fieldContainer.right
            anchors.rightMargin: control.sidePadding
            anchors.top: fieldContainer.bottom
            anchors.topMargin: 4 * control.themeGlobalScale
            height: control.supportingHeight
            visible: control.hasSupportingLine

            Text {
                width: Math.max(0, parent.width - counterText.width - 8 * control.themeGlobalScale)
                text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
                visible: text !== ""
                font.family: control.font.family
                font.pixelSize: control.fontLabel.size * control.themeGlobalScale
                color: control.isError ? control.themeError : control.themeOnSurfaceVariant
                elide: Text.ElideRight
            }

            Text {
                id: counterText
                text: control.showCounter ? control.text.length + (control.maxLength > 0 ? " / " + control.maxLength : "") : ""
                visible: control.showCounter
                font.family: control.font.family
                font.pixelSize: control.fontLabel.size * control.themeGlobalScale
                color: control.themeOnSurfaceVariant
            }
        }
    }
}
