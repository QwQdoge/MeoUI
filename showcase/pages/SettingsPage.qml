import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

// This is intentionally an interaction lab, not a settings application or a
// global token editor. Every public component remains documented in its own
// canonical category; this page only compares related motion and surfaces.
MeoPageLayout {
    id: labPage
    title: qsTr("Interaction lab")
    subtitle: qsTr("Compare selection, quick controls, progress, and continuous input in one place.")

    ShowcaseSection {
        title: qsTr("Selection and press states")
        subtitle: qsTr("Selections update the surface and feedback without shifting nearby controls.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoButtonGroup {
                Layout.fillWidth: true
                model: [qsTr("Day"), qsTr("Week"), qsTr("Month")]
                type: "outlined"
            }

            MeoSegmentedButtons {
                Layout.fillWidth: true
                model: [
                    { "label": qsTr("List"), "icon": "view_list" },
                    { "label": qsTr("Grid"), "icon": "grid_view" },
                    { "label": qsTr("Cards"), "icon": "dashboard" }
                ]
            }
        }
    }

    ShowcaseSection {
        title: qsTr("Quick controls")
        subtitle: qsTr("Active controls use clear contrast while inactive controls stay calm and easy to scan.")
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space12

            MeoQuickSettingsTile {
                title: qsTr("Internet")
                supportingText: qsTr("Meo Wi-Fi")
                iconName: "wifi"
                active: true
                wide: true
                visualStyle: "pixel"
            }
            MeoQuickSettingsTile {
                title: qsTr("Bluetooth")
                iconName: "bluetooth"
                visualStyle: "pixel"
            }
            MeoQuickSettingsTile {
                title: qsTr("Flashlight")
                iconName: "flashlight_on"
                visualStyle: "pixel"
            }
        }

        MeoQuickControlSlider {
            width: parent.width
            iconName: "light_mode"
            label: qsTr("Brightness")
            accessibleName: qsTr("Brightness")
            value: 68
        }
    }

    ShowcaseSection {
        title: qsTr("Progress and loading")
        subtitle: qsTr("Known progress stays clear; loading animation pauses when reduced motion is on.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            MeoProgressBar {
                Layout.fillWidth: true
                value: 0.62
                isThick: true
                linearStyle: "pill"
                leadingIcon: "pause"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space24

                MeoProgressBar {
                    Layout.preferredWidth: 152 * MeoTheme.globalScale
                    Layout.preferredHeight: width
                    type: "circular"
                    value: 0.76
                    isThick: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: MeoTheme.space12

                    MeoLoadingIndicator {
                        size: "m"
                        withContainer: true
                    }
                    MeoProgressBar {
                        Layout.fillWidth: true
                        indeterminate: true
                    }
                }
            }
        }
    }

    ShowcaseSection {
        title: qsTr("Continuous input")
        subtitle: qsTr("The split slider keeps the current value, remaining range, and handle easy to distinguish.")
        width: parent.width

        MeoSlider {
            width: parent.width
            from: 0
            to: 100
            value: 58
            size: "m"
            trackStyle: "split"
            leadingIcon: "volume_up"
        }
    }
}
