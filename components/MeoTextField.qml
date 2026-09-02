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

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeSurfaceContainerHighest: MeoTheme.surfaceContainerHighest
    readonly property color themeError: MeoTheme.error
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionFast: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState
    readonly property bool mirrored: LayoutMirroring.enabled

    readonly property var fontBody: {
        if (size === "xs") return MeoTheme.bodySmall
        if (size === "s") return MeoTheme.bodyMedium
        return MeoTheme.bodyLarge
    }
    readonly property var fontLabel: MeoTheme.labelSmall

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
    // M3 fields use 16dp side padding without icons and 12dp with one.
    // Explicit compact/expressive sizes retain their existing side insets.
    readonly property real sidePadding: {
        if (size === "xs") return 12 * themeGlobalScale
        if (size === "s") return 14 * themeGlobalScale
        return (leadingIcon !== "" || hasTrailingAction) ? 12 * themeGlobalScale : 16 * themeGlobalScale
    }
    readonly property real iconSizePx: (size === "xs" ? 18 : size === "s" ? 20 : 24) * themeGlobalScale
    readonly property bool hasSupportingLine: (isError && errorText !== "") || helperText !== "" || showCounter
    readonly property real supportingHeight: hasSupportingLine ? 24 * themeGlobalScale : 0
    readonly property bool labelRaised: label !== "" && (activeFocus || text !== "")
    readonly property bool hasLeading: leadingIcon !== "" || prefixText !== ""
    readonly property bool hasTrailingAction: trailingIcon !== "" || isPassword || (showClearButton && text !== "")
    readonly property real leadingContentWidth: (leadingIcon !== "" ? iconSizePx + 16 * themeGlobalScale : 0)
                                                + (prefixText !== "" ? prefixLabel.implicitWidth + 6 * themeGlobalScale : 0)
    readonly property real trailingContentWidth: (suffixText !== "" ? suffixLabel.implicitWidth + 6 * themeGlobalScale : 0)
                                                 + (hasTrailingAction ? 34 * themeGlobalScale : 0)

    implicitWidth: 280 * themeGlobalScale
    implicitHeight: containerHeight + supportingHeight
    padding: 0
    maximumLength: maxLength > 0 ? maxLength : 32767
    echoMode: isPassword && !passwordVisible ? TextInput.Password : TextInput.Normal
    selectByMouse: true

    font.family: MeoTheme.typefacePlain
    font.pixelSize: fontBody.size * themeGlobalScale
    font.weight: fontBody.weight
    // Error is communicated by indicator, label, and supporting text; entered
    // content stays on-surface so it remains readable and selectable.
    color: enabled ? themeOnSurface
                   : Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.38)
    selectionColor: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0.28)
    selectedTextColor: themeOnSurface

    placeholderText: labelRaised ? placeholder : (label !== "" ? label : placeholder)
    placeholderTextColor: enabled ? themeOnSurfaceVariant : Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.38)

    leftPadding: sidePadding + (mirrored ? trailingContentWidth : leadingContentWidth)
    rightPadding: sidePadding + (mirrored ? leadingContentWidth : trailingContentWidth)
    topPadding: labelRaised ? 18 * themeGlobalScale : 0
    bottomPadding: supportingHeight + (labelRaised ? 2 * themeGlobalScale : 0)
    verticalAlignment: TextInput.AlignVCenter

    background: Item {
        Rectangle {
            id: fieldContainer
            objectName: "meoTextFieldContainer"
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

        Rectangle {
            id: activeIndicator
            objectName: "meoTextFieldActiveIndicator"
            visible: control.type === "filled"
            anchors.left: fieldContainer.left
            anchors.right: fieldContainer.right
            anchors.bottom: fieldContainer.bottom
            height: control.activeFocus ? 2 * control.themeGlobalScale : 1 * control.themeGlobalScale
            color: {
                if (!control.enabled)
                    return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.12)
                if (control.isError) return control.themeError
                if (control.activeFocus) return control.themePrimary
                return control.themeOnSurfaceVariant
            }
            Behavior on color { ColorAnimation { duration: control.motionFast } }
            Behavior on height { NumberAnimation { duration: control.motionFast } }
        }

        Text {
            visible: control.labelRaised
            text: control.label
            anchors.top: fieldContainer.top
            anchors.topMargin: 7 * control.themeGlobalScale
            x: control.mirrored
               ? fieldContainer.width - width - control.sidePadding - (control.leadingIcon !== "" ? control.iconSizePx + 10 * control.themeGlobalScale : 0)
               : control.sidePadding + (control.leadingIcon !== "" ? control.iconSizePx + 10 * control.themeGlobalScale : 0)
            font.family: control.font.family
            font.pixelSize: control.fontLabel.size * control.themeGlobalScale
            font.weight: control.fontLabel.weight
            color: control.isError ? control.themeError : (control.activeFocus ? control.themePrimary : control.themeOnSurfaceVariant)
            Behavior on color { ColorAnimation { duration: control.motionFast } }
        }

        Row {
            width: implicitWidth
            x: control.mirrored ? fieldContainer.width - width - control.sidePadding : control.sidePadding
            anchors.verticalCenter: fieldContainer.verticalCenter
            anchors.verticalCenterOffset: control.labelRaised ? 6 * control.themeGlobalScale : 0
            spacing: 8 * control.themeGlobalScale
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight
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
            width: implicitWidth
            x: control.mirrored ? control.sidePadding : fieldContainer.width - width - control.sidePadding
            anchors.verticalCenter: fieldContainer.verticalCenter
            anchors.verticalCenterOffset: control.labelRaised ? 6 * control.themeGlobalScale : 0
            spacing: 6 * control.themeGlobalScale
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

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
                Accessible.name: control.passwordVisible ? qsTr("Hide password") : qsTr("Show password")
                onClicked: control.passwordVisible = !control.passwordVisible
            }

            MeoIconButton {
                visible: !control.isPassword && control.showClearButton && control.text !== ""
                icon.name: "close"
                size: "s"
                type: "standard"
                width: 32 * control.themeGlobalScale
                height: width
                Accessible.name: qsTr("Clear text")
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
                Accessible.name: control.trailingIcon
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
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

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
