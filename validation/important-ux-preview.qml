import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI 1.0

ApplicationWindow {
    id: window
    width: 980
    height: 700
    visible: true
    color: MeoTheme.surface
    title: "MeoUI Important UX validation"

    property string outputPath: ""

    Component.onCompleted: {
        for (let index = 0; index < Qt.application.arguments.length; ++index) {
            const argument = Qt.application.arguments[index]
            if (argument.indexOf("--output=") === 0)
                outputPath = argument.substring(9)
        }
        MeoTheme.isExpressive = true
        Qt.callLater(function() { calendar.focusFocusedDay(Qt.TabFocusReason) })
        captureTimer.start()
    }

    Timer {
        id: captureTimer
        interval: 400
        onTriggered: content.grabToImage(function(result) {
            if (window.outputPath !== "" && !result.saveToFile(window.outputPath))
                console.error("Unable to save validation image", window.outputPath)
            Qt.quit()
        })
    }

    Item {
        id: content
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: MeoTheme.surface
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: MeoTheme.space32
            spacing: MeoTheme.space24

            MeoText {
                text: "Important shell controls"
                typeRole: "headline"
                typeSize: "medium"
                emphasized: true
                color: MeoTheme.onSurface
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space24

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: MeoTheme.space16

                    RowLayout {
                        spacing: MeoTheme.space12

                        MeoQuickSettingsTile {
                            Layout.preferredWidth: 220 * MeoTheme.globalScale
                            title: "Wi-Fi"
                            supportingText: "Connected to MeoArch"
                            iconName: "wifi"
                            active: true
                            wide: true
                            visualStyle: "pixel"
                            detailsEnabled: true
                        }

                        MeoQuickSettingsTile {
                            Layout.preferredWidth: 88 * MeoTheme.globalScale
                            title: "Bluetooth"
                            iconName: "bluetooth"
                            wide: false
                            visualStyle: "pixel"
                            detailsEnabled: true
                            showCompactLabel: true
                        }
                    }

                    MeoExposedDropdown {
                        id: dropdown
                        Layout.fillWidth: true
                        label: "Output device"
                        model: ["Built-in audio speakers", "USB-C studio headphones", "HDMI display audio"]
                        text: "USB-C studio headphones"
                    }

                    MeoQuickControlSlider {
                        Layout.fillWidth: true
                        iconName: "volume_up"
                        label: "Built-in audio"
                        accessibleName: "Output volume"
                        iconAccessibleName: "Mute output"
                        value: 64
                        detailsAvailable: true
                    }

                    MeoQuickControlSlider {
                        Layout.fillWidth: true
                        iconName: "light_mode"
                        label: "Internal display brightness"
                        accessibleName: "Display brightness"
                        iconAccessibleName: "Display options"
                        iconActionEnabled: false
                        value: 78
                    }

                    Item { Layout.fillHeight: true }
                }

                Rectangle {
                    Layout.preferredWidth: 1 * MeoTheme.globalScale
                    Layout.fillHeight: true
                    color: MeoTheme.outlineVariant
                }

                ColumnLayout {
                    Layout.preferredWidth: 360 * MeoTheme.globalScale
                    Layout.fillHeight: true
                    spacing: MeoTheme.space12

                    MeoText {
                        text: "Keyboard calendar"
                        typeRole: "title"
                        typeSize: "medium"
                        emphasized: true
                        color: MeoTheme.onSurface
                    }

                    MeoMonthCalendar {
                        id: calendar
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight
                        selectedDate: new Date(2026, 7, 21)
                        displayDate: new Date(2026, 7, 1)
                        focusedDate: new Date(2026, 7, 22)
                    }

                    MeoText {
                        Layout.fillWidth: true
                        text: "Tab enters one date. Arrow keys move the visible focus; Enter or Space selects."
                        typeRole: "body"
                        typeSize: "medium"
                        color: MeoTheme.onSurfaceVariant
                        wrapMode: Text.WordWrap
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
