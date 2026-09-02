import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

// Docked Material 3 date picker.  The calendar mechanics, keyboard model, and
// day states live in MeoMonthCalendar so this surface does not fork them.
MeoCard {
    id: control

    type: "filled"
    padding: 24 * MeoTheme.globalScale
    implicitWidth: 376 * MeoTheme.globalScale
    implicitHeight: 540 * MeoTheme.globalScale

    property date selectedDate: new Date()
    property date displayDate: new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
    property bool interactive: true
    property string headline: "Select date"

    signal dateSelected(date selected)
    signal accepted(date selected)
    signal rejected()

    readonly property real themeScale: MeoTheme.globalScale
    readonly property int motionFast: MeoTheme.motionDurationState
    readonly property color headerTextColor: MeoTheme.contentOnSurface
    readonly property color supportingTextColor: MeoTheme.contentOnSurfaceVariant

    onSelectedDateChanged: {
        if (!selectedDate || isNaN(selectedDate.getTime()))
            return
        if (dateInput && !dateInput.activeFocus)
            dateInput.value = selectedDate
    }

    function normalizedMonth(value) {
        return new Date(value.getFullYear(), value.getMonth(), 1)
    }

    function moveMonth(offset) {
        if (!interactive)
            return
        displayDate = new Date(displayDate.getFullYear(), displayDate.getMonth() + offset, 1)
    }

    function chooseMonth(month) {
        if (!interactive)
            return
        displayDate = new Date(displayDate.getFullYear(), month, 1)
    }

    function chooseYear(year) {
        if (!interactive)
            return
        displayDate = new Date(year, displayDate.getMonth(), 1)
    }

    function monthEntries() {
        const months = []
        for (let month = 0; month < 12; ++month) {
            const label = Qt.formatDate(new Date(displayDate.getFullYear(), month, 1), "MMMM")
            months.push({
                label: label,
                selected: month === displayDate.getMonth(),
                action: (function(value) { return function() { control.chooseMonth(value) } })(month)
            })
        }
        return months
    }

    function yearEntries() {
        const years = []
        const start = displayDate.getFullYear() - 6
        for (let offset = 0; offset < 13; ++offset) {
            const year = start + offset
            years.push({
                label: year.toString(),
                selected: year === displayDate.getFullYear(),
                action: (function(value) { return function() { control.chooseYear(value) } })(year)
            })
        }
        return years
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 16 * control.themeScale

        MeoText {
            Layout.fillWidth: true
            text: control.headline
            typeRole: "title"
            typeSize: "large"
            emphasized: true
            color: control.headerTextColor
        }

        MeoDateInput {
            id: dateInput
            Layout.fillWidth: true
            label: qsTr("Date")
            format: "yyyy-MM-dd"
            enabled: control.interactive
            value: control.selectedDate
            onDateAccepted: function(date) {
                control.selectedDate = date
                control.displayDate = control.normalizedMonth(date)
                control.dateSelected(date)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48 * control.themeScale
            spacing: 4 * control.themeScale

            MeoButton {
                id: monthButton
                text: Qt.formatDate(control.displayDate, "MMMM")
                type: "text"
                size: "s"
                icon.name: "arrow_drop_down"
                enabled: control.interactive
                Accessible.name: qsTr("Select month")
                onClicked: monthMenu.openAt(monthButton, 0, monthButton.height)
            }

            MeoButton {
                id: yearButton
                text: control.displayDate.getFullYear().toString()
                type: "text"
                size: "s"
                icon.name: "arrow_drop_down"
                enabled: control.interactive
                Accessible.name: qsTr("Select year")
                onClicked: yearMenu.openAt(yearButton, 0, yearButton.height)
            }

            Item { Layout.fillWidth: true }

            MeoIconButton {
                type: "standard"
                size: "s"
                icon.name: "chevron_left"
                enabled: control.interactive
                Accessible.name: qsTr("Previous month")
                onClicked: control.moveMonth(-1)
            }
            MeoIconButton {
                type: "standard"
                size: "s"
                icon.name: "chevron_right"
                enabled: control.interactive
                Accessible.name: qsTr("Next month")
                onClicked: control.moveMonth(1)
            }
        }

        MeoMonthCalendar {
            id: calendar
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            selectedDate: control.selectedDate
            displayDate: control.displayDate
            interactive: control.interactive
            showHeader: false
            onDateSelected: function(date) {
                control.selectedDate = date
                control.displayDate = control.normalizedMonth(date)
                control.dateSelected(date)
            }
            onDisplayDateChanged: {
                const changed = displayDate.getFullYear() !== control.displayDate.getFullYear()
                                || displayDate.getMonth() !== control.displayDate.getMonth()
                if (changed)
                    control.displayDate = control.normalizedMonth(displayDate)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            layoutDirection: Qt.RightToLeft
            spacing: 8 * control.themeScale

            MeoButton {
                text: qsTr("OK")
                type: "text"
                enabled: control.interactive
                onClicked: control.accepted(control.selectedDate)
            }
            MeoButton {
                text: qsTr("Cancel")
                type: "text"
                enabled: control.interactive
                onClicked: control.rejected()
            }
        }
    }

    MeoMenu {
        id: monthMenu
        model: control.monthEntries()
        preferredMenuWidth: 180 * control.themeScale
    }

    MeoMenu {
        id: yearMenu
        model: control.yearEntries()
        preferredMenuWidth: 144 * control.themeScale
    }
}
