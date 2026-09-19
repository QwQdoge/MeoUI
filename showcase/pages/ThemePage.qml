import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: themePage
    categoryId: "foundations"

    // 🌟 1. Dynamic Theme Tokens Tuner (Sliders & Switches)
    ShowcaseSection {
        title: qsTr("Theme and corner radius")
        subtitle: qsTr("Adjust corner radius, type, interface scale, motion, and color mode to preview the theme in real time.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Dark Mode & Expressive Toggles
            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                MeoSwitch {
                    label: qsTr("Dark mode")
                    checked: MeoTheme.isDarkMode
                    onToggled: (val) => { MeoTheme.isDarkMode = val }
                }

                MeoSwitch {
                    label: qsTr("Expressive motion")
                    checked: MeoTheme.isExpressive
                    onToggled: (val) => { MeoTheme.isExpressive = val }
                }

                MeoSwitch {
                    label: qsTr("Reduced motion")
                    checked: MeoTheme.reduceMotion
                    onToggled: (val) => { MeoTheme.reduceMotion = val }
                }
            }

            // Sliders Row 1: Corner Radius Scale & Global Scale
            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                // Corner Radius Scale
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    RowLayout {
                        MeoText { text: qsTr("Corner radius scale:"); typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.cornerScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    MeoSlider {
                        Layout.fillWidth: true
                        accessibleName: qsTr("Corner radius scale")
                        accessibleDescription: qsTr("Adjust the roundness of component corners.")
                        from: 0.2
                        to: 2.5
                        value: MeoTheme.cornerScale
                        onValueChanged: { MeoTheme.cornerScale = value }
                    }
                }

                // Global Scale
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    RowLayout {
                        MeoText { text: qsTr("Interface scale:"); typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.globalScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    MeoSlider {
                        Layout.fillWidth: true
                        accessibleName: qsTr("Interface scale")
                        accessibleDescription: qsTr("Adjust the size of the interface preview.")
                        from: 0.8
                        to: 1.5
                        value: MeoTheme.globalScale
                        onValueChanged: { MeoTheme.globalScale = value }
                    }
                }
            }

            // Sliders Row 2: Font Scale & Motion Scale
            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                // Font Scale
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    RowLayout {
                        MeoText { text: qsTr("Text size:"); typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.fontScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    MeoSlider {
                        Layout.fillWidth: true
                        accessibleName: qsTr("Text size")
                        accessibleDescription: qsTr("Adjust the size of text in the preview.")
                        from: 0.8
                        to: 1.4
                        value: MeoTheme.fontScale
                        onValueChanged: { MeoTheme.fontScale = value }
                    }
                }

                // Motion Duration Scale
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    RowLayout {
                        MeoText { text: qsTr("Motion speed:"); typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.motionScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    MeoSlider {
                        Layout.fillWidth: true
                        accessibleName: qsTr("Motion speed")
                        accessibleDescription: qsTr("Adjust how quickly motion plays in the preview.")
                        from: 0.5
                        to: 2.0
                        value: MeoTheme.motionScale
                        onValueChanged: { MeoTheme.motionScale = value }
                    }
                }
            }

            // Reset Button
            MeoButton {
                text: qsTr("Reset theme settings")
                type: "tonal"
                icon.name: "refresh"
                onClicked: {
                    MeoTheme.cornerScale = 1.0
                    MeoTheme.globalScale = 1.0
                    MeoTheme.fontScale = 1.0
                    MeoTheme.motionScale = 1.0
                    MeoTheme.isDarkMode = false
                    MeoTheme.reduceMotion = false
                }
            }
        }
    }

    // 🌟 2. Live Components Reaction Test Ground (真实组件动态生效预览)
    ShowcaseSection {
        title: qsTr("Live component preview")
        subtitle: qsTr("Components update their corners, spacing, size, and color as you adjust the theme above.")
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            MeoButton {
                text: qsTr("Filled button")
                type: "filled"
                size: "m"
            }

            MeoButton {
                text: qsTr("Tonal button")
                type: "tonal"
                size: "m"
            }

            MeoButton {
                text: qsTr("Outlined button")
                type: "outlined"
                size: "m"
            }

            MeoChip {
                label: qsTr("Filter chip")
                icon: "filter_list"
                selected: true
            }

            MeoTextField {
                placeholder: qsTr("Try typing here…")
                width: 220 * MeoTheme.globalScale
            }

            MeoCard {
                width: 240 * MeoTheme.globalScale
                height: 90 * MeoTheme.globalScale
                type: "elevated"
                interactive: true
                bouncy: true
                Accessible.name: qsTr("Dynamic shape card")

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: qsTr("Dynamic shape card"); typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: qsTr("Radius: %1 px").arg(Math.round(MeoTheme.cardRadius)); typeRole: "body"; typeSize: "small" }
                }
            }
        }
    }

    // 🌟 3. Semantic Corner Tokens Readout (语义圆角 Token 实时读数)
    ShowcaseSection {
        title: qsTr("Corner radius tokens")
        subtitle: qsTr("See the current pixel radius calculated from the interface and corner-radius scales.")
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space12

            readonly property var tokens: [
                { name: "ExtraSmall", val: MeoTheme.shapeExtraSmall },
                { name: "Small", val: MeoTheme.shapeSmall },
                { name: "Medium", val: MeoTheme.shapeMedium },
                { name: "Large", val: MeoTheme.shapeLarge },
                { name: "LargeIncreased", val: MeoTheme.shapeLargeIncreased },
                { name: "ExtraLarge", val: MeoTheme.shapeExtraLarge },
                { name: "ExtraLargeIncreased", val: MeoTheme.shapeExtraLargeIncreased },
                { name: "ExtraExtraLarge", val: MeoTheme.shapeExtraExtraLarge }
            ]

            Repeater {
                model: parent.tokens
                delegate: Rectangle {
                    width: 130 * MeoTheme.globalScale
                    height: 60 * MeoTheme.globalScale
                    radius: modelData.val
                    color: MeoTheme.surfaceContainerLow
                    border.color: MeoTheme.outlineVariant
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        MeoText { text: modelData.name; typeRole: "label"; typeSize: "small"; emphasized: true; horizontalAlignment: Text.AlignHCenter }
                        MeoText { text: Math.round(modelData.val) + " px"; typeRole: "body"; typeSize: "small"; color: MeoTheme.primary; horizontalAlignment: Text.AlignHCenter }
                    }
                }
            }
        }
    }

    // 4. Cross-toolkit semantic geometry contract
    ShowcaseSection {
        title: qsTr("Control geometry")
        subtitle: qsTr("The same semantic geometry keeps MeoUI, Plasma, native Qt controls, and KWin decoration consistent.")
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space8
                MeoText { text: qsTr("Button · %1 px").arg(Math.round(MeoTheme.controlHeight)); typeRole: "label"; typeSize: "medium"; emphasized: true }
                MeoButton { text: qsTr("Primary action"); type: "filled"; size: "s" }
            }

            Column {
                spacing: MeoTheme.space8
                MeoText { text: qsTr("Icon targets · 32–56 px"); typeRole: "label"; typeSize: "medium"; emphasized: true }
                Row {
                    spacing: MeoTheme.space8
                    Repeater {
                        model: ["xs", "s", "m", "l", "xl"]
                        delegate: MeoIconButton {
                            required property string modelData
                            size: modelData
                            type: modelData === "m" ? "tonal" : "outlined"
                            icon.name: "favorite"
                            Accessible.name: qsTr("Favorite icon button, %1 size").arg(modelData)
                        }
                    }
                }
            }

            Column {
                spacing: MeoTheme.space8
                MeoText { text: qsTr("Surface roles"); typeRole: "label"; typeSize: "medium"; emphasized: true }
                Row {
                    spacing: MeoTheme.space8
                    Repeater {
                        model: [
                            { label: qsTr("Control"), radius: MeoTheme.controlRadius },
                            { label: qsTr("Window"), radius: MeoTheme.windowRadius },
                            { label: qsTr("Card"), radius: MeoTheme.cardRadius },
                            { label: qsTr("Dialog"), radius: MeoTheme.dialogRadius }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            width: 88 * MeoTheme.globalScale
                            height: 56 * MeoTheme.globalScale
                            radius: modelData.radius
                            color: MeoTheme.surfaceContainerHigh
                            border.color: MeoTheme.outlineVariant
                            border.width: MeoTheme.strokeWidthThin
                            MeoText {
                                anchors.centerIn: parent
                                text: modelData.label + "\n" + Math.round(modelData.radius) + " px"
                                typeRole: "label"
                                typeSize: "small"
                                horizontalAlignment: Text.AlignHCenter
                                color: MeoTheme.contentOnSurface
                            }
                        }
                    }
                }
            }
        }
    }
}
