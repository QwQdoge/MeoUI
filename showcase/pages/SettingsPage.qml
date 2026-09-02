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
    title: "Interaction lab"
    subtitle: "Compare component states together: stable selection, strong quick-control contrast, progress, loading, and continuous input."

    ShowcaseSection {
        title: "Selection and click states"
        subtitle: "Selection changes the surface and state layer; it does not reflow neighbouring controls."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoButtonGroup {
                Layout.fillWidth: true
                model: ["Day", "Week", "Month"]
                type: "outlined"
            }

            MeoSegmentedButtons {
                Layout.fillWidth: true
                model: [
                    { "label": "List", "icon": "view_list" },
                    { "label": "Grid", "icon": "grid_view" },
                    { "label": "Cards", "icon": "dashboard" }
                ]
            }
        }
    }

    ShowcaseSection {
        title: "Quick controls"
        subtitle: "The active tile and active slider segment use primary/onPrimary; inactive surfaces stay neutral."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space12

            MeoQuickSettingsTile {
                title: "Internet"
                supportingText: "Meo Wi-Fi"
                iconName: "wifi"
                active: true
                wide: true
                visualStyle: "pixel"
            }
            MeoQuickSettingsTile {
                title: "Bluetooth"
                iconName: "bluetooth"
                visualStyle: "pixel"
            }
            MeoQuickSettingsTile {
                title: "Flashlight"
                iconName: "flashlight_on"
                visualStyle: "pixel"
            }
        }

        MeoQuickControlSlider {
            width: parent.width
            iconName: "light_mode"
            label: "Brightness"
            accessibleName: "Brightness"
            value: 68
        }
    }

    ShowcaseSection {
        title: "Progress and loading"
        subtitle: "Determinate states use a clear primary arc or segment. Indeterminate animation stops when reduced motion is enabled."
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
        title: "Continuous input"
        subtitle: "The split slider keeps a clear primary active rail, neutral inactive rail, and a thin draggable divider."
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
