import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: selectionPage
    categoryId: "selection"

    // 🌟 Sizing scale variants (XS to XL) for Checkboxes, Radio Buttons, and Switches
    ShowcaseSection {
        title: qsTr("Selection control sizes")
        subtitle: qsTr("Compare compact through extra-large controls without changing their labels or behavior.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Checkboxes Size Scale
            MeoText {
                text: qsTr("MeoCheckbox sizes")
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }
            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16
                MeoCheckbox { label: qsTr("XS checkbox"); size: "xs"; checked: true }
                MeoCheckbox { label: qsTr("S checkbox"); size: "s"; checked: true }
                MeoCheckbox { label: qsTr("M checkbox"); size: "m"; checked: true }
                MeoCheckbox { label: qsTr("L checkbox"); size: "l"; checked: true }
                MeoCheckbox { label: qsTr("XL checkbox"); size: "xl"; checked: true }
            }

            // Radio Buttons Size Scale
            MeoText {
                text: qsTr("MeoRadioButton sizes")
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }
            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16
                MeoRadioButton { label: qsTr("XS radio button"); size: "xs"; checked: true }
                MeoRadioButton { label: qsTr("S radio button"); size: "s"; checked: true }
                MeoRadioButton { label: qsTr("M radio button"); size: "m"; checked: true }
                MeoRadioButton { label: qsTr("L radio button"); size: "l"; checked: true }
                MeoRadioButton { label: qsTr("XL radio button"); size: "xl"; checked: true }
            }

            // Switches Size Scale
            MeoText {
                text: qsTr("MeoSwitch sizes")
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }
            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16
                MeoSwitch { label: qsTr("XS switch"); size: "xs"; checked: true }
                MeoSwitch { label: qsTr("S switch"); size: "s"; checked: true }
                MeoSwitch { label: qsTr("M switch"); size: "m"; checked: true }
                MeoSwitch { label: qsTr("L switch"); size: "l"; checked: true }
                MeoSwitch { label: qsTr("XL switch"); size: "xl"; checked: true }
            }
        }
    }

    // 🌟 Thickness Variants (Thin, Medium, Thick)
    ShowcaseSection {
        title: qsTr("Outline thickness")
        subtitle: qsTr("Compare thin, medium, and thick outlines on the same selection controls.")
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Thin Panel
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthThin

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space8

                    MeoText {
                        text: qsTr("Thin") + " (strokeWidthThin: 1dp)"
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoCheckbox { label: qsTr("Thin outline"); thickness: "thin"; checked: false }
                    MeoRadioButton { label: qsTr("Thin outline"); thickness: "thin"; checked: false }
                    MeoSwitch { label: qsTr("Thin track"); thickness: "thin"; checked: false }
                }
            }

            // Medium Panel
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthMedium

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space8

                    MeoText {
                        text: qsTr("Medium") + " (strokeWidthMedium: 2dp)"
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoCheckbox { label: qsTr("Medium outline"); thickness: "medium"; checked: false }
                    MeoRadioButton { label: qsTr("Medium outline"); thickness: "medium"; checked: false }
                    MeoSwitch { label: qsTr("Medium track"); thickness: "medium"; checked: false }
                }
            }

            // Thick Panel
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthThick

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space8

                    MeoText {
                        text: qsTr("Thick") + " (strokeWidthThick: 3dp)"
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoCheckbox { label: qsTr("Thick outline"); thickness: "thick"; checked: false }
                    MeoRadioButton { label: qsTr("Thick outline"); thickness: "thick"; checked: false }
                    MeoSwitch { label: qsTr("Thick track"); thickness: "thick"; checked: false }
                }
            }
        }
    }

    // 🌟 Interaction States (Normal, Checked, Indeterminate, Error, Disabled, Focused)
    ShowcaseSection {
        title: qsTr("States and feedback")
        subtitle: qsTr("Review the normal, selected, unavailable, and error states people may encounter.")
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 3
            columnSpacing: MeoTheme.space24
            rowSpacing: MeoTheme.space24

            // Checkbox States Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText { text: qsTr("MeoCheckbox states"); typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoCheckbox { label: qsTr("Normal (not selected)"); checked: false }
                MeoCheckbox { label: qsTr("Normal (selected)"); checked: true }
                MeoCheckbox { label: qsTr("Partly selected"); indeterminate: true }
                MeoCheckbox { label: qsTr("Needs attention"); isError: true; errorText: qsTr("Choose a valid option.") }
                MeoCheckbox { label: qsTr("Helpful context"); helperText: qsTr("Use this when it applies.") }
                MeoCheckbox { label: qsTr("Unavailable"); enabled: false; checked: true }
            }

            // Radio Button States Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText { text: qsTr("MeoRadioButton states"); typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoRadioButton { label: qsTr("Normal (not selected)"); checked: false }
                MeoRadioButton { label: qsTr("Normal (selected)"); checked: true }
                MeoRadioButton { label: qsTr("Needs attention"); isError: true; errorText: qsTr("Select one option to continue.") }
                MeoRadioButton { label: qsTr("Helpful context"); helperText: qsTr("Choose the option that works best for you.") }
                MeoRadioButton { label: qsTr("Unavailable (not selected)"); enabled: false; checked: false }
                MeoRadioButton { label: qsTr("Unavailable (selected)"); enabled: false; checked: true }
            }

            // Switch States Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText { text: qsTr("MeoSwitch states"); typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoSwitch { label: qsTr("Normal (off)"); checked: false }
                MeoSwitch { label: qsTr("Normal (on)"); checked: true }
                MeoSwitch { label: qsTr("Without thumb icon"); checked: true; showIcon: false }
                MeoSwitch { label: qsTr("Needs attention"); isError: true; errorText: qsTr("Turn this off before continuing.") }
                MeoSwitch { label: qsTr("Helpful context"); helperText: qsTr("This setting controls system power.") }
                MeoSwitch { label: qsTr("Unavailable"); enabled: false; checked: true }
            }
        }
    }
}
