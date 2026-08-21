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

    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutline: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outline !== "undefined") ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerHighest !== "undefined") ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeError: (typeof MeoTheme !== "undefined" && typeof MeoTheme.error !== "undefined") ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 100
    readonly property var fontBody: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyLarge !== "undefined") ? MeoTheme.bodyLarge : ({ "size": 16, "weight": Font.Normal })
    readonly property var fontLabel: (typeof MeoTheme !== "undefined" && typeof MeoTheme.labelSmall !== "undefined") ? MeoTheme.labelSmall : ({ "size": 11, "weight": Font.Medium })
    readonly property var fontSupporting: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodySmall !== "undefined") ? MeoTheme.bodySmall : ({ "size": 12, "weight": Font.Normal })

    readonly property bool labelRaised: label !== "" && (activeFocus || text !== "" || placeholder !== "")
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

    color: enabled ? (isError ? themeError : themeOnSurface)
                   : Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.38)
    selectionColor: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0.28)
    selectedTextColor: themeOnSurface
    font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
    font.pixelSize: fontBody.size * themeGlobalScale
    font.weight: fontBody.weight
    selectByMouse: true
    wrapMode: TextArea.Wrap

    placeholderText: labelRaised ? placeholder : (label !== "" ? label : placeholder)
    placeholderTextColor: enabled ? themeOnSurfaceVariant
                                  : Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.38)

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
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: supportingRow.top
            anchors.bottomMargin: control.hasSupportingLine ? 4 * control.themeGlobalScale : 0
            radius: control.containerRadius
            color: {
                if (control.type === "outlined") return "transparent"
                if (!control.enabled) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.04)
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

        Text {
            visible: control.labelRaised
            text: control.label
            anchors.left: areaContainer.left
            anchors.leftMargin: 16 * control.themeGlobalScale
            anchors.top: areaContainer.top
            anchors.topMargin: 9 * control.themeGlobalScale
            font.family: control.font.family
            font.pixelSize: control.fontLabel.size * control.themeGlobalScale
            font.weight: control.fontLabel.weight
            color: control.isError ? control.themeError : (control.activeFocus ? control.themePrimary : control.themeOnSurfaceVariant)
            Behavior on color { ColorAnimation { duration: control.motionFast } }
        }

        Row {
            id: supportingRow
            anchors.left: parent.left
            anchors.leftMargin: 16 * control.themeGlobalScale
            anchors.right: parent.right
            anchors.rightMargin: 16 * control.themeGlobalScale
            anchors.bottom: parent.bottom
            height: control.supportingHeight
            visible: control.hasSupportingLine

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
