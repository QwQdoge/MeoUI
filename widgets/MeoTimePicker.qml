import QtQuick
import QtQuick.Controls
import MeoUI

// Material 3 time picker. It owns the large selection surface; MeoTimeInput
// remains the compact form-field counterpart.
MeoCard {
    id: control

    type: "filled"
    padding: 24 * MeoTheme.globalScale
    implicitWidth: 320 * MeoTheme.globalScale
    implicitHeight: (inputMode ? 320 : 528) * MeoTheme.globalScale

    property int hours: 10
    property int minutes: 30
    property bool isPM: false
    property bool use24Hour: false
    property bool inputMode: false
    property string activeUnit: "hour" // "hour" | "minute"
    property string headline: "Select time"

    signal accepted(int hours, int minutes, bool isPM)
    signal rejected()

    readonly property real themeScale: MeoTheme.globalScale
    readonly property int maxHour: use24Hour ? 23 : 12
    readonly property color timeFieldColor: MeoTheme.primaryContainer
    readonly property color timeFieldTextColor: MeoTheme.contentOnPrimaryContainer
    readonly property color clockColor: MeoTheme.surfaceContainerHighest
    readonly property color clockLabelColor: MeoTheme.contentOnSurface
    readonly property color selectedClockLabelColor: MeoTheme.contentOnPrimary
    readonly property color selectorColor: MeoTheme.primary
    readonly property color selectorTrackColor: MeoTheme.primary
    readonly property color inactiveSelectorColor: MeoTheme.surfaceContainerHigh
    readonly property color inactiveSelectorTextColor: MeoTheme.contentOnSurface
    readonly property color periodContainerColor: MeoTheme.surfaceContainerHigh
    readonly property color periodTextColor: MeoTheme.contentOnSurface
    readonly property color outlineColor: MeoTheme.outline
    readonly property int motionFast: MeoTheme.motionDurationState
    readonly property int motionSelection: MeoTheme.motionDurationSelection
    readonly property real dialSize: 256 * scale
    readonly property real selectorHandleSize: 48 * scale
    readonly property real selectorAngle: activeUnit === "minute" ? (minutes / 5) * 30 : (hours % 12) * 30
    readonly property real selectorRadius: {
        if (activeUnit === "minute")
            return 96 * scale
        if (use24Hour && (hours === 0 || hours >= 13))
            return 96 * scale
        return use24Hour ? 64 * scale : 96 * scale
    }

    onHoursChanged: normalizeHours()
    onMinutesChanged: {
        const normalized = Math.max(0, Math.min(59, Math.round(minutes)))
        if (minutes !== normalized)
            minutes = normalized
    }
    onUse24HourChanged: normalizeHours()

    function normalizeHours() {
        const lowerBound = use24Hour ? 0 : 1
        const normalized = Math.max(lowerBound, Math.min(maxHour, Math.round(hours)))
        if (hours !== normalized)
            hours = normalized
    }

    function displayedHour() { return hours.toString().padStart(2, "0") }
    function displayedMinute() { return minutes.toString().padStart(2, "0") }

    function clockLabel(index) {
        if (!use24Hour)
            return (index === 0 ? 12 : index).toString()
        if (index < 12)
            return (index === 0 ? 12 : index).toString()
        return (index === 12 ? 0 : index).toString().padStart(2, "0")
    }

    function clockValue(index) {
        if (!use24Hour)
            return index === 0 ? 12 : index
        if (index < 12)
            return index === 0 ? 12 : index
        return index === 12 ? 0 : index
    }

    function isSelectedClockValue(index) {
        if (activeUnit === "minute")
            return !use24Hour && index === Math.round(minutes / 5) % 12
        return clockValue(index) === hours
    }

    function selectFromDial(mouseX, mouseY) {
        const dx = mouseX - dial.width / 2
        const dy = mouseY - dial.height / 2
        let angle = Math.atan2(dy, dx) * 180 / Math.PI + 90
        if (angle < 0)
            angle += 360
        const index = Math.round(angle / 30) % 12
        if (activeUnit === "minute") {
            minutes = index * 5
            return
        }
        if (!use24Hour) {
            hours = index === 0 ? 12 : index
        } else {
            const outerRing = Math.sqrt(dx * dx + dy * dy) >= 80 * scale
            hours = outerRing ? (index === 0 ? 0 : index + 12) : (index === 0 ? 12 : index)
        }
        activeUnit = "minute"
    }

    Column {
        anchors.fill: parent
        spacing: 16 * control.themeScale

        Row {
            width: parent.width
            height: 40 * control.themeScale
            spacing: 8 * control.themeScale

            Text {
                width: parent.width - modeButton.width
                anchors.verticalCenter: parent.verticalCenter
                text: control.headline
                color: MeoTheme.contentOnSurface
                font.family: MeoTheme.typefacePlain
                font.pixelSize: MeoTheme.titleLarge.size * control.themeScale
                font.weight: MeoTheme.titleLarge.weight
                elide: Text.ElideRight
            }

            MeoIconButton {
                id: modeButton
                anchors.verticalCenter: parent.verticalCenter
                icon.name: control.inputMode ? "schedule" : "keyboard"
                Accessible.name: control.inputMode ? "Switch to dial" : "Switch to input"
                enabled: control.interactive
                onClicked: control.inputMode = !control.inputMode
            }
        }

        Row {
            id: selectorRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8 * control.themeScale
            height: control.inputMode ? 72 * control.themeScale : 80 * control.themeScale

            TimeSelector {
                valueText: control.displayedHour()
                selected: control.activeUnit === "hour"
                input: control.inputMode
                isHour: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ":"
                color: MeoTheme.contentOnSurface
                font.family: MeoTheme.typefacePlain
                font.pixelSize: 40 * control.themeScale
            }

            TimeSelector {
                valueText: control.displayedMinute()
                selected: control.activeUnit === "minute"
                input: control.inputMode
                isHour: false
            }

            PeriodSelector {
                visible: !control.use24Hour
                height: parent.height
            }
        }

        Item {
            visible: !control.inputMode
            width: parent.width
            height: visible ? control.dialSize : 0

            Rectangle {
                id: dial
                width: control.dialSize
                height: width
                radius: width / 2
                color: control.clockColor
                anchors.centerIn: parent

                Rectangle {
                    width: 2 * control.themeScale
                    height: control.selectorRadius
                    color: control.selectorTrackColor
                    anchors.bottom: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    transformOrigin: Item.Bottom
                    rotation: control.selectorAngle
                }

                Rectangle {
                    width: control.selectorHandleSize
                    height: width
                    radius: width / 2
                    color: control.selectorColor
                    x: parent.width / 2 + Math.sin(control.selectorAngle * Math.PI / 180) * control.selectorRadius - width / 2
                    y: parent.height / 2 - Math.cos(control.selectorAngle * Math.PI / 180) * control.selectorRadius - height / 2

                    Behavior on x { NumberAnimation { duration: control.motionSelection } }
                    Behavior on y { NumberAnimation { duration: control.motionSelection } }
                }

                Rectangle {
                    width: 8 * control.themeScale
                    height: width
                    radius: width / 2
                    color: control.selectorColor
                    anchors.centerIn: parent
                }

                Repeater {
                    model: control.activeUnit === "minute" ? 12 : (control.use24Hour ? 24 : 12)

                    delegate: Item {
                        readonly property bool innerRing: control.use24Hour && control.activeUnit === "hour" && index < 12
                        readonly property real labelRadius: innerRing ? 64 * control.themeScale : 96 * control.themeScale
                        readonly property real angle: (index % 12) * 30
                        width: 48 * control.themeScale
                        height: width
                        x: dial.width / 2 + Math.sin(angle * Math.PI / 180) * labelRadius - width / 2
                        y: dial.height / 2 - Math.cos(angle * Math.PI / 180) * labelRadius - height / 2

                        Text {
                            anchors.centerIn: parent
                            text: control.activeUnit === "minute" ? (index * 5).toString().padStart(2, "0") : control.clockLabel(index)
                            color: control.activeUnit === "minute"
                                   ? (index === Math.round(control.minutes / 5) % 12 ? control.selectedClockLabelColor : control.clockLabelColor)
                                   : (control.isSelectedClockValue(index) ? control.selectedClockLabelColor : control.clockLabelColor)
                            font.family: MeoTheme.typefacePlain
                            font.pixelSize: MeoTheme.bodyLarge.size * control.themeScale
                            font.weight: MeoTheme.bodyLarge.weight
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: control.interactive
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: control.selectFromDial(mouseX, mouseY)
                    onPositionChanged: if (pressed) control.selectFromDial(mouseX, mouseY)
                }
            }
        }

        Item { width: 1; height: control.inputMode ? 8 * control.themeScale : 0 }

        Row {
            width: parent.width
            spacing: 8 * control.themeScale
            layoutDirection: Qt.RightToLeft

            MeoButton {
                text: "OK"
                type: "text"
                enabled: control.interactive
                onClicked: control.accepted(control.hours, control.minutes, control.isPM)
            }
            MeoButton {
                text: "Cancel"
                type: "text"
                enabled: control.interactive
                onClicked: control.rejected()
            }
        }
    }

    component TimeSelector: Rectangle {
        required property string valueText
        required property bool selected
        required property bool input
        required property bool isHour

        width: (control.use24Hour && isHour ? 114 : 96) * control.themeScale
        height: selectorRow.height
        radius: 8 * control.themeScale
        color: selected ? control.timeFieldColor : control.inactiveSelectorColor
        border.width: input && !selected ? MeoTheme.strokeWidthThin : 0
        border.color: control.outlineColor
        Accessible.role: Accessible.Button
        Accessible.name: isHour ? "Hour" : "Minute"
        Accessible.focusable: control.interactive

        TextInput {
            id: editor
            anchors.fill: parent
            visible: input
            enabled: control.interactive
            text: valueText
            color: selected ? control.timeFieldTextColor : control.inactiveSelectorTextColor
            font.family: MeoTheme.typefacePlain
            font.pixelSize: 40 * control.themeScale
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse: true
            validator: IntValidator { bottom: isHour ? (control.use24Hour ? 0 : 1) : 0; top: isHour ? control.maxHour : 59 }
            onActiveFocusChanged: if (!activeFocus) commit()
            Keys.onReturnPressed: commit()
            Keys.onEnterPressed: commit()

            function commit() {
                const number = Number(text)
                if (isHour)
                    control.hours = isNaN(number) ? control.hours : number
                else
                    control.minutes = isNaN(number) ? control.minutes : number
                text = isHour ? control.displayedHour() : control.displayedMinute()
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !input
            text: valueText
            color: selected ? control.timeFieldTextColor : control.inactiveSelectorTextColor
            font.family: MeoTheme.typefacePlain
            font.pixelSize: 40 * control.themeScale
        }

        MouseArea {
            anchors.fill: parent
            enabled: control.interactive && !input
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: control.activeUnit = isHour ? "hour" : "minute"
        }

        Behavior on color { ColorAnimation { duration: control.motionFast } }
    }

    component PeriodSelector: Item {
        width: 52 * control.themeScale

        Column {
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: ["AM", "PM"]
                delegate: Rectangle {
                    required property string modelData
                    width: parent.width
                    height: parent.height / 2
                    radius: 8 * control.themeScale
                    readonly property bool selected: (modelData === "PM") === control.isPM
                    color: selected ? MeoTheme.tertiaryContainer : control.periodContainerColor
                    border.width: MeoTheme.strokeWidthThin
                    border.color: control.outlineColor

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: parent.selected ? MeoTheme.contentOnTertiaryContainer : control.periodTextColor
                        font.family: MeoTheme.typefacePlain
                        font.pixelSize: MeoTheme.labelLarge.size * control.themeScale
                        font.weight: MeoTheme.labelLarge.weight
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: control.interactive
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: control.isPM = modelData === "PM"
                    }
                    Behavior on color { ColorAnimation { duration: control.motionFast } }
                }
            }
        }
    }
}
