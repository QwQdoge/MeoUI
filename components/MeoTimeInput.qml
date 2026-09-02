import QtQuick
import QtQuick.Controls
import MeoUI

MeoTextField {
    id: control

    // 🌟 核心属性
    property string format: "HH:mm"
    property string value: ""
    property bool allowEmpty: false
    readonly property bool hasValue: text.trim() !== ""

    signal timeAccepted(string time)
    signal cleared()

    label: "Time"
    placeholder: format
    leadingIcon: "schedule"

    inputMask: "99:99"

    validator: RegularExpressionValidator {
        regularExpression: /^([01]\d|2[0-3]):([0-5]\d)$/
    }

    Component.onCompleted: syncTextFromValue()

    onValueChanged: syncTextFromValue()

    onTextChanged: {
        if (allowEmpty && text.trim() === "") {
            isError = false
            errorText = ""
            return
        }

        if (text.length !== format.length) {
            isError = false
            errorText = ""
            return
        }

        isError = parseTime(text) === ""
        errorText = isError ? "Invalid time" : ""
    }

    onAccepted: commit()
    onEditingFinished: commit()

    function commit() {
        if (allowEmpty && text.trim() === "") {
            isError = false
            errorText = ""
            if (value !== "")
                value = ""
            cleared()
            return
        }

        const parsed = parseTime(text)
        if (parsed === "") {
            isError = true
            errorText = "Invalid time"
            // Keep invalid input visible so users can correct it in place;
            // resetting to the old value hides the correction context.
            return
        }

        isError = false
        errorText = ""
        if (value !== parsed)
            value = parsed
        timeAccepted(parsed)
    }

    function parseTime(valueText) {
        const match = /^(?:[01]\d|2[0-3]):[0-5]\d$/.exec(valueText.trim())
        return match ? match[0] : ""
    }

    function syncTextFromValue() {
        const parsed = parseTime(value)
        const next = parsed === "" && allowEmpty ? "" : parsed
        if (text !== next)
            text = next
    }
}
