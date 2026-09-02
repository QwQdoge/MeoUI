import QtQuick
import QtQuick.Controls
import MeoUI

// A compact, semantic hex-color input. It intentionally selects only a seed:
// product code must still hand that seed to its platform Material/HCT generator
// rather than deriving a local UI palette from the field value.
Control {
    id: control

    property color color: "#6750a4"
    property string label: ""
    property string helperText: ""
    // Expose the actual editable field rather than a one-way snapshot binding,
    // so callers can prefill or correct text before calling commit().
    property alias text: colorField.text
    readonly property bool valid: validHex(colorField.text)
    readonly property string normalizedText: normalizedHex(colorField.text)

    signal colorCommitted(color color)

    implicitWidth: 360 * MeoTheme.globalScale
    implicitHeight: Math.max(colorField.implicitHeight, 48 * MeoTheme.globalScale)
    padding: 0

    function validHex(value) {
        return /^#[0-9a-fA-F]{6}$/.test(String(value).trim())
    }

    function normalizedHex(value) {
        const candidate = String(value).trim()
        return validHex(candidate) ? candidate.toLowerCase() : ""
    }

    // Returns false and leaves the user's invalid text visible so the error is
    // actionable. Callers can use it before accepting a settings task sheet.
    function commit() {
        const hex = normalizedHex(colorField.text)
        if (hex === "") {
            colorField.forceActiveFocus()
            return false
        }
        colorField.text = hex
        color = hex
        colorCommitted(color)
        return true
    }

    onColorChanged: {
        if (!colorField.activeFocus)
            colorField.text = color.toString().toLowerCase()
    }

    contentItem: Row {
        width: control.availableWidth
        spacing: 12 * MeoTheme.globalScale

        MeoTextField {
            id: colorField
            width: Math.max(0, parent.width - swatch.width - parent.spacing)
            label: control.label
            placeholder: "#6750a4"
            helperText: control.valid ? control.helperText : qsTr("Use a six-digit color such as #4285f4")
            isError: !control.valid && text.trim() !== ""
            errorText: qsTr("Enter a valid #RRGGBB color")
            leadingIcon: "palette"
            showClearButton: true
            maximumLength: 7
            inputMethodHints: Qt.ImhNoPredictiveText
            Accessible.name: control.label || qsTr("Color seed")
            Accessible.description: control.helperText
            text: control.color.toString().toLowerCase()
            onEditingFinished: control.commit()
        }

        Rectangle {
            id: swatch
            width: 48 * MeoTheme.globalScale
            height: width
            anchors.verticalCenter: parent.verticalCenter
            radius: MeoTheme.shapeMedium
            color: control.valid ? control.normalizedText : MeoTheme.surfaceContainerHighest
            border.width: Math.max(1, MeoTheme.globalScale)
            border.color: MeoTheme.outlineVariant

            MeoIcon {
                anchors.centerIn: parent
                icon: control.valid ? "check" : "priority_high"
                size: 20
                color: control.valid ? MeoTheme.contentOnPrimary : MeoTheme.contentOnSurfaceVariant
            }

            Accessible.role: Accessible.Indicator
            Accessible.name: control.valid
                             ? qsTr("Selected color %1").arg(control.normalizedText)
                             : qsTr("Invalid color")
        }
    }
}
