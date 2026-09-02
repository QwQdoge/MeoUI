import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

// Android-style labelled slider with explicit decrease/increase affordances.
// It remains generic: hosts own the value and decide whether a change maps to
// brightness, a preview-only preference, or another verified setting.
Control {
    id: control

    property string title: ""
    property string supportingText: ""
    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 1
    property bool discrete: true
    property bool showValueLabel: false
    property string valueSuffix: ""
    property string valueText: ""
    property string decreaseAccessibleName: qsTr("Make %1 smaller").arg(title || qsTr("value"))
    property string increaseAccessibleName: qsTr("Make %1 larger").arg(title || qsTr("value"))
    signal moved(real value)

    readonly property real uiScale: MeoTheme.globalScale
    readonly property real lowerBound: Math.min(from, to)
    readonly property real upperBound: Math.max(from, to)

    implicitWidth: 320 * uiScale
    implicitHeight: sliderColumn.implicitHeight
    // The embedded MeoSlider is the only adjustable semantic node.  Keeping
    // this labelled composition ignored avoids duplicate slider announcements.
    Accessible.ignored: true

    function accessibleValueDescription() {
        const visibleValue = valueText !== "" ? valueText
                                               : Math.round(value) + valueSuffix
        return supportingText !== "" ? supportingText + ". " + visibleValue
                                     : visibleValue
    }

    function normalizedValue(rawValue) {
        let nextValue = Math.max(lowerBound, Math.min(upperBound, Number(rawValue)))
        if (discrete && stepSize > 0)
            nextValue = from + Math.round((nextValue - from) / stepSize) * stepSize
        return Math.max(lowerBound, Math.min(upperBound, nextValue))
    }

    function setValue(rawValue) {
        const nextValue = normalizedValue(rawValue)
        if (value === nextValue)
            return
        value = nextValue
        moved(nextValue)
    }

    function adjust(direction) {
        // A non-discrete slider still needs a predictable keyboard/button
        // increment. Prefer its declared step; otherwise use 1% of the range.
        const range = upperBound - lowerBound
        const increment = stepSize > 0 ? stepSize : (range > 0 ? range / 100 : 1)
        setValue(value + direction * increment)
    }

    contentItem: ColumnLayout {
        id: sliderColumn
        spacing: 2 * control.uiScale

        RowLayout {
            Layout.fillWidth: true
            spacing: MeoTheme.space8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MeoText {
                    Layout.fillWidth: true
                    text: control.title
                    visible: text !== ""
                    typeRole: "body"
                    typeSize: "medium"
                    emphasized: true
                    color: MeoTheme.contentOnSurface
                    opacity: control.enabled ? 1.0 : MeoTheme.disabledContentOpacity
                    elide: Text.ElideRight
                }

                MeoText {
                    Layout.fillWidth: true
                    text: control.supportingText
                    visible: text !== ""
                    typeRole: "body"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                    opacity: control.enabled ? 1.0 : MeoTheme.disabledContentOpacity
                    elide: Text.ElideRight
                }
            }

            MeoText {
                visible: control.showValueLabel
                text: control.valueText !== "" ? control.valueText
                                                : Math.round(control.value) + control.valueSuffix
                typeRole: "label"
                typeSize: "medium"
                color: MeoTheme.contentOnSurfaceVariant
                opacity: control.enabled ? 1.0 : MeoTheme.disabledContentOpacity
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: MeoTheme.space4

            MeoIconButton {
                type: "standard"
                size: "m"
                icon.name: "remove"
                enabled: control.enabled && control.value > control.lowerBound
                Accessible.name: control.decreaseAccessibleName
                onClicked: control.adjust(-1)
            }

            MeoSlider {
                id: slider
                objectName: "meoSteppedSliderTrack"
                Layout.fillWidth: true
                from: control.from
                to: control.to
                value: control.value
                discrete: control.discrete
                stepSize: control.stepSize
                snapMode: control.discrete
                tickMarksEnabled: control.discrete
                valueLabelEnabled: false
                enabled: control.enabled
                accessibleName: control.title !== "" ? control.title : qsTr("Slider")
                accessibleDescription: control.accessibleValueDescription()
                size: "s"
                trackStyle: "standard"
                onMoved: control.setValue(value)
            }

            MeoIconButton {
                type: "standard"
                size: "m"
                icon.name: "add"
                enabled: control.enabled && control.value < control.upperBound
                Accessible.name: control.increaseAccessibleName
                onClicked: control.adjust(1)
            }
        }
    }
}
