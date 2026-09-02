import QtQuick
import QtQuick.Controls
import MeoUI

MeoCard {
    id: control
    type: "filled"
    padding: 24 * MeoTheme.globalScale

    // 🌟 核心属性
    property date startDate: new Date(0) // Default to invalid/epoch
    property date endDate: new Date(0)
    property date displayDate: new Date()
    property bool interactive: true
    property string headline: "Select range"

    signal rangeSelected(date start, date end)
    signal accepted(date start, date end)
    signal rejected()

    readonly property bool hasStartDate: startDate.getTime() > 0
    readonly property bool hasEndDate: endDate.getTime() > 0

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale

    implicitWidth: 376 * themeGlobalScale
    implicitHeight: 640 * themeGlobalScale

    onStartDateChanged: {
        if (startInput)
            startInput.value = control.hasStartDate ? control.startDate : new Date(0)
    }
    onEndDateChanged: {
        if (endInput)
            endInput.value = control.hasEndDate ? control.endDate : new Date(0)
    }

    Column {
        anchors.fill: parent
        spacing: 16 * control.themeGlobalScale

        // Header: Selection Summary
        Column {
            width: parent.width
            height: 144 * control.themeGlobalScale
            spacing: 8 * control.themeGlobalScale
            padding: 12 * control.themeGlobalScale

            Text {
                text: control.headline
                font.pixelSize: 12 * control.themeGlobalScale
                font.weight: Font.Medium
                color: control.themeOnSurfaceVariant
            }

            Row {
                spacing: 12 * control.themeGlobalScale
                Text {
                    text: control.hasStartDate ? Qt.formatDate(control.startDate, "MMM d, yyyy") : "Start date"
                    font.pixelSize: 18 * control.themeGlobalScale
                    font.weight: Font.Medium
                    color: control.hasStartDate ? control.themeOnSurface : control.themeOnSurfaceVariant
                }
                Text {
                    text: "–"
                    font.pixelSize: 18 * control.themeGlobalScale
                    color: control.themeOnSurfaceVariant
                }
                Text {
                    text: control.hasEndDate ? Qt.formatDate(control.endDate, "MMM d, yyyy") : "End date"
                    font.pixelSize: 18 * control.themeGlobalScale
                    font.weight: Font.Medium
                    color: control.hasEndDate ? control.themeOnSurface : control.themeOnSurfaceVariant
                }
            }

            Row {
                width: parent.width
                spacing: 8 * control.themeGlobalScale

                MeoDateInput {
                    id: startInput
                    width: (parent.width - parent.spacing) / 2
                    height: 48 * control.themeGlobalScale
                    label: "Start"
                    format: "yyyy-MM-dd"
                    allowEmpty: true
                    enabled: control.interactive
                    value: control.hasStartDate ? control.startDate : new Date(0)
                    onDateAccepted: function(date) { setRangeDate(true, date) }
                    onCleared: control.startDate = new Date(0)
                }

                MeoDateInput {
                    id: endInput
                    width: (parent.width - parent.spacing) / 2
                    height: 48 * control.themeGlobalScale
                    label: "End"
                    format: "yyyy-MM-dd"
                    allowEmpty: true
                    enabled: control.interactive
                    value: control.hasEndDate ? control.endDate : new Date(0)
                    onDateAccepted: function(date) { setRangeDate(false, date) }
                    onCleared: control.endDate = new Date(0)
                }
            }
        }

        MeoDivider {}

        // Month Selection
        Item {
            width: parent.width
            height: 48 * control.themeGlobalScale

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4 * control.themeGlobalScale

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
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                MeoIconButton {
                    icon.name: "chevron_left"
                    enabled: control.interactive
                    onClicked: {
                        let d = new Date(control.displayDate)
                        d.setMonth(d.getMonth() - 1)
                        control.displayDate = d
                    }
                }
                MeoIconButton {
                    icon.name: "chevron_right"
                    enabled: control.interactive
                    onClicked: {
                        let d = new Date(control.displayDate)
                        d.setMonth(d.getMonth() + 1)
                        control.displayDate = d
                    }
                }
            }
        }

        // Weekday Labels
        Row {
            width: parent.width
            Repeater {
                model: ["S", "M", "T", "W", "T", "F", "S"]
                delegate: Text {
                    width: (parent.width) / 7
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 12 * control.themeGlobalScale
                    color: control.themeOnSurfaceVariant
                }
            }
        }

        // Days Grid
        Grid {
            id: daysGrid
            columns: 7
            width: parent.width

            Repeater {
                model: 42 // 6 weeks
                delegate: Item {
                    width: daysGrid.width / 7
                    height: width

                    readonly property var dateInfo: getDateForIndex(index)
                    readonly property bool isStart: isSameDate(dateInfo.date, control.startDate)
                    readonly property bool isEnd: isSameDate(dateInfo.date, control.endDate)
                    readonly property bool isInRange: isBetween(dateInfo.date, control.startDate, control.endDate)
                    readonly property bool isCurrentMonth: dateInfo.date.getMonth() === control.displayDate.getMonth()

                    // Range Bridge
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        height: 32 * control.themeGlobalScale
                        width: (isStart || isEnd) ? parent.width / 2 : parent.width
                        x: isStart ? parent.width / 2 : 0
                        color: (isInRange || isStart || isEnd) && control.hasStartDate && control.hasEndDate ? control.themePrimaryContainer : "transparent"
                        visible: control.hasStartDate && control.hasEndDate && (isInRange || isStart || isEnd)

                        // Rounding at row ends (Expressive MD3)
                        radius: (index % 7 === 0 || index % 7 === 6) ? 16 * control.themeGlobalScale : 0

                        // Use overlay rectangles to "square off" internal connections since QtQuick.Rectangle
                        // doesn't support per-corner radius.
                        Rectangle {
                            anchors.left: parent.left
                            width: 16 * control.themeGlobalScale
                            height: parent.height
                            color: parent.color
                            visible: parent.radius > 0 && index % 7 !== 0
                        }
                        Rectangle {
                            anchors.right: parent.right
                            width: 16 * control.themeGlobalScale
                            height: parent.height
                            color: parent.color
                            visible: parent.radius > 0 && index % 7 !== 6
                        }
                    }

                    // Selection Circle
                    Rectangle {
                        anchors.centerIn: parent
                        width: 32 * control.themeGlobalScale
                        height: 32 * control.themeGlobalScale
                        radius: 16 * control.themeGlobalScale
                        color: (isStart || isEnd) ? control.themePrimary : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: dateInfo.day
                            font.pixelSize: 12 * control.themeGlobalScale
                            font.weight: (isStart || isEnd || isInRange) ? Font.Medium : Font.Normal
                            color: (isStart || isEnd) ? control.themeOnPrimary : (isInRange ? control.themeOnPrimaryContainer : (isCurrentMonth ? control.themeOnSurface : control.themeOnSurfaceVariant))
                            opacity: isCurrentMonth ? 1.0 : 0.4
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: control.interactive
                        onClicked: {
                            handleDateClick(dateInfo.date)
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width
            layoutDirection: Qt.RightToLeft
            spacing: 8 * control.themeGlobalScale

            MeoButton {
                text: qsTr("OK")
                type: "text"
                enabled: control.interactive && control.hasStartDate && control.hasEndDate
                onClicked: control.accepted(control.startDate, control.endDate)
            }
            MeoButton {
                text: qsTr("Cancel")
                type: "text"
                enabled: control.interactive
                onClicked: control.rejected()
            }
        }
    }

    function getDateForIndex(index) {
        let firstDayOfMonth = new Date(control.displayDate.getFullYear(), control.displayDate.getMonth(), 1)
        let startOffset = firstDayOfMonth.getDay()
        let targetDate = new Date(firstDayOfMonth)
        targetDate.setDate(1 - startOffset + index)
        // Reset time to midnight for accurate comparison
        targetDate.setHours(0, 0, 0, 0)
        return {
            day: targetDate.getDate(),
            date: targetDate
        }
    }

    function isSameDate(d1, d2) {
        if (!d1 || !d2) return false
        return d1.getFullYear() === d2.getFullYear() &&
               d1.getMonth() === d2.getMonth() &&
               d1.getDate() === d2.getDate()
    }

    function isBetween(date, start, end) {
        if (!control.hasStartDate || !control.hasEndDate) return false
        return date.getTime() > start.getTime() && date.getTime() < end.getTime()
    }

    function handleDateClick(date) {
        if (!interactive)
            return
        if (!control.hasStartDate || (control.hasStartDate && control.hasEndDate)) {
            control.startDate = date
            control.endDate = new Date(0)
        } else {
            if (date.getTime() < control.startDate.getTime()) {
                control.endDate = control.startDate
                control.startDate = date
            } else if (date.getTime() === control.startDate.getTime()) {
                // Toggle off
                control.startDate = new Date(0)
            } else {
                control.endDate = date
            }
        }
        control.rangeSelected(control.startDate, control.endDate)
    }

    function setRangeDate(isStart, date) {
        if (!interactive)
            return
        if (isStart) {
            if (control.hasEndDate && control.endDate.getTime() < date.getTime()) {
                control.startDate = control.endDate
                control.endDate = date
            } else {
                control.startDate = date
            }
        } else {
            if (control.hasStartDate && date.getTime() < control.startDate.getTime()) {
                control.endDate = control.startDate
                control.startDate = date
            } else {
                control.endDate = date
            }
        }
        control.displayDate = isStart ? control.startDate : control.endDate
        control.rangeSelected(control.startDate, control.endDate)
    }

    function chooseMonth(month) {
        if (interactive)
            displayDate = new Date(displayDate.getFullYear(), month, 1)
    }

    function chooseYear(year) {
        if (interactive)
            displayDate = new Date(year, displayDate.getMonth(), 1)
    }

    function monthEntries() {
        const months = []
        for (let month = 0; month < 12; ++month) {
            months.push({
                label: Qt.formatDate(new Date(displayDate.getFullYear(), month, 1), "MMMM"),
                selected: month === displayDate.getMonth(),
                action: (function(value) { return function() { control.chooseMonth(value) } })(month)
            })
        }
        return months
    }

    function yearEntries() {
        const years = []
        const first = displayDate.getFullYear() - 6
        for (let offset = 0; offset < 13; ++offset) {
            const year = first + offset
            years.push({
                label: year.toString(),
                selected: year === displayDate.getFullYear(),
                action: (function(value) { return function() { control.chooseYear(value) } })(year)
            })
        }
        return years
    }

    MeoMenu {
        id: monthMenu
        model: control.monthEntries()
        preferredMenuWidth: 180 * control.themeGlobalScale
    }

    MeoMenu {
        id: yearMenu
        model: control.yearEntries()
        preferredMenuWidth: 144 * control.themeGlobalScale
    }
}
