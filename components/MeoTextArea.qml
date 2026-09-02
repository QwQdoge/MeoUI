import QtQuick
import QtQuick.Controls
import MeoUI

TextArea {
    id: control

    property string type: "filled" // "filled" | "outlined"
    property string label: ""
    property string helperText: ""
    property bool isError: false
    property string errorText: ""
    property string placeholder: ""
    property int maxLength: -1
    property bool showCounter: false

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeSurfaceContainerHighest: MeoTheme.surfaceContainerHighest
    readonly property color themeError: MeoTheme.error
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int motionFast: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState
    readonly property var fontBody: MeoTheme.bodyLarge
    readonly property var fontLabel: MeoTheme.labelSmall
    readonly property var fontSupporting: MeoTheme.bodySmall

    readonly property bool mirrored: LayoutMirroring.enabled
    readonly property bool labelRaised: label !== "" && (activeFocus || text !== "")
    readonly property bool hasSupportingLine: helperText !== "" || (isError && errorText !== "") || showCounter
    readonly property real supportingHeight: hasSupportingLine ? 24 * themeGlobalScale : 0
    readonly property real containerRadius: 20 * themeGlobalScale

    implicitWidth: 320 * themeGlobalScale
    implicitHeight: Math.max(120 * themeGlobalScale, contentHeight + topPadding + bottomPadding)
    padding: 0
    leftPadding: 16 * themeGlobalScale
    rightPadding: 16 * themeGlobalScale
    topPadding: labelRaised ? 32 * themeGlobalScale : 16 * themeGlobalScale
    bottomPadding: 16 * themeGlobalScale + supportingHeight

    // Error is carried by the field indicator, label, and supporting line;
    // entered multiline content remains readable on-surface.
    color: enabled ? themeOnSurface
                   : Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, MeoTheme.disabledContentOpacity)
    selectionColor: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0.28)
    selectedTextColor: themeOnSurface
    font.family: MeoTheme.typefacePlain
    font.pixelSize: fontBody.size * themeGlobalScale
    font.weight: fontBody.weight
    selectByMouse: true
    wrapMode: TextArea.Wrap

    placeholderText: labelRaised ? placeholder : (label !== "" ? label : placeholder)
    placeholderTextColor: enabled ? themeOnSurfaceVariant
                                  : Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, MeoTheme.disabledContentOpacity)
    hoverEnabled: true
    Accessible.name: label !== "" ? label : placeholder

    onTextChanged: {
        if (maxLength > 0 && text.length > maxLength) {
            var keepCursor = Math.min(cursorPosition, maxLength)
            text = text.substring(0, maxLength)
            cursorPosition = keepCursor
        }
    }

    background: Item {
        Rectangle {
            id: areaContainer
            objectName: "meoTextAreaContainer"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: supportingRow.top
            anchors.bottomMargin: control.hasSupportingLine ? 4 * control.themeGlobalScale : 0
            radius: control.containerRadius
            color: {
                if (control.type === "outlined") return "transparent"
                if (!control.enabled) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContainerOpacity)
                var base = control.themeSurfaceContainerHighest
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
            objectName: "meoTextAreaActiveIndicator"
            visible: control.type === "filled"
            anchors.left: areaContainer.left
            anchors.right: areaContainer.right
            anchors.bottom: areaContainer.bottom
            height: control.activeFocus ? 2 * control.themeGlobalScale : 1 * control.themeGlobalScale
            color: {
                if (!control.enabled)
                    return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContainerOpacity)
                if (control.isError) return control.themeError
                if (control.activeFocus) return control.themePrimary
                return control.themeOnSurfaceVariant
            }
            Behavior on color { ColorAnimation { duration: control.motionFast } }
            Behavior on height { NumberAnimation { duration: control.motionFast } }
        }

        Text {
            objectName: "meoTextAreaLabel"
            visible: control.labelRaised
            text: control.label
            anchors.top: areaContainer.top
            anchors.topMargin: 9 * control.themeGlobalScale
            x: control.mirrored
               ? areaContainer.width - width - 16 * control.themeGlobalScale
               : 16 * control.themeGlobalScale
            font.family: control.font.family
            font.pixelSize: control.fontLabel.size * control.themeGlobalScale
            font.weight: control.fontLabel.weight
            color: control.isError ? control.themeError : (control.activeFocus ? control.themePrimary : control.themeOnSurfaceVariant)
            Behavior on color { ColorAnimation { duration: control.motionFast } }
        }

        Row {
            id: supportingRow
            objectName: "meoTextAreaSupportingRow"
            anchors.left: parent.left
            anchors.leftMargin: 16 * control.themeGlobalScale
            anchors.right: parent.right
            anchors.rightMargin: 16 * control.themeGlobalScale
            anchors.bottom: parent.bottom
            height: control.supportingHeight
            visible: control.hasSupportingLine
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

            Text {
                width: Math.max(0, parent.width - counterLabel.width - 12 * control.themeGlobalScale)
                text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
                visible: text !== ""
                font.family: control.font.family
                font.pixelSize: control.fontSupporting.size * control.themeGlobalScale
                font.weight: control.fontSupporting.weight
                color: control.isError ? control.themeError : control.themeOnSurfaceVariant
                elide: Text.ElideRight
            }

            Text {
                id: counterLabel
                visible: control.showCounter
                text: control.maxLength > 0 ? (control.text.length + " / " + control.maxLength) : control.text.length
                font.family: control.font.family
                font.pixelSize: control.fontSupporting.size * control.themeGlobalScale
                color: control.themeOnSurfaceVariant
            }
        }
    }
}
