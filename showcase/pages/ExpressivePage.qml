import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: expressivePage
    categoryId: "expressive"

    // 🌟 1. Expressive XS-XL Sizing Scale
    ShowcaseSection {
        title: qsTr("Expressive control sizes")
        subtitle: qsTr("Compare five button and chip sizes from extra-small to extra-large.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoText {
                text: qsTr("MeoButton sizes")
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoButton { text: qsTr("XS button"); size: "xs"; type: "filled" }
                MeoButton { text: qsTr("S button"); size: "s"; type: "filled" }
                MeoButton { text: qsTr("M button"); size: "m"; type: "filled" }
                MeoButton { text: qsTr("L button"); size: "l"; type: "filled" }
                MeoButton { text: qsTr("XL button"); size: "xl"; type: "filled" }
            }

            MeoText {
                text: qsTr("MeoChip sizes")
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoChip { label: qsTr("XS chip"); size: "xs"; icon: "tag" }
                MeoChip { label: qsTr("S chip"); size: "s"; icon: "tag" }
                MeoChip { label: qsTr("M chip"); size: "m"; icon: "tag" }
                MeoChip { label: qsTr("L chip"); size: "l"; icon: "tag" }
                MeoChip { label: qsTr("XL chip"); size: "xl"; icon: "tag" }
            }
        }
    }

    // 🌟 2. Official 35 MaterialShapes Gallery
    ShowcaseSection {
        title: qsTr("Material Shapes gallery")
        subtitle: qsTr("Browse all 35 Material 3 expressive shapes rendered from their vector geometry.")
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space12

            readonly property var shapes35: [
                "Arch", "Arrow", "Boom", "Bun", "Burst", "Circle", "ClamShell", "Clover4Leaf",
                "Clover8Leaf", "Cookie12Sided", "Cookie4Sided", "Cookie6Sided", "Cookie7Sided",
                "Cookie9Sided", "Diamond", "Fan", "Flower", "Gem", "Ghostish", "Heart", "Oval",
                "Pentagon", "Pill", "PixelCircle", "PixelTriangle", "Puffy", "PuffyDiamond",
                "SemiCircle", "Slanted", "SoftBoom", "SoftBurst", "Square", "Sunny", "Triangle", "VerySunny"
            ]

            Repeater {
                model: parent.shapes35
                delegate: Column {
                    spacing: 4 * MeoTheme.globalScale
                    width: 72 * MeoTheme.globalScale

                    MeoShape {
                        width: 60 * MeoTheme.globalScale
                        height: 60 * MeoTheme.globalScale
                        anchors.horizontalCenter: parent.horizontalCenter
                        type: modelData
                        color: MeoTheme.primaryContainer
                        radius: 12 * MeoTheme.globalScale

                        MeoText {
                            anchors.centerIn: parent
                            text: modelData.substring(0, 2).toUpperCase()
                            typeRole: "label"
                            typeSize: "small"
                            emphasized: true
                            color: MeoTheme.contentOnPrimaryContainer
                        }
                    }

                    MeoText {
                        width: parent.width
                        text: modelData
                        typeRole: "label"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    // 🌟 3. Shape Morphing Playground (MeoShapeMorph)
    ShowcaseSection {
        title: qsTr("Shape morphing")
        subtitle: qsTr("Choose two shapes and adjust the transition, rotation, and spring response.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            RowLayout {
                spacing: MeoTheme.space24
                Layout.alignment: Qt.AlignHCenter

                MeoShapeMorph {
                    id: labMorpher
                    width: 96 * MeoTheme.globalScale
                    height: 96 * MeoTheme.globalScale
                    color: MeoTheme.primary
                    fromShape: fromCombo.text
                    toShape: toCombo.text
                    morphProgress: progressSlider.value
                    rawSpringProgress: progressSlider.value + (overshootCheck.checked ? 0.25 * Math.sin(progressSlider.value * Math.PI) : 0)
                    rotationAngle: rotSlider.value
                }

                ColumnLayout {
                    spacing: MeoTheme.space8

                    RowLayout {
                        spacing: MeoTheme.space8
                        MeoText { text: qsTr("From shape:"); typeRole: "label"; typeSize: "medium"; Layout.preferredWidth: 100 }
                        MeoExposedDropdown {
                            id: fromCombo
                            label: qsTr("Starting shape")
                            model: ["SoftBurst", "Circle", "Cookie9Sided", "Pentagon", "Pill", "Sunny", "Cookie4Sided", "Oval", "Heart"]
                            currentIndex: 0
                        }
                    }

                    RowLayout {
                        spacing: MeoTheme.space8
                        MeoText { text: qsTr("To shape:"); typeRole: "label"; typeSize: "medium"; Layout.preferredWidth: 100 }
                        MeoExposedDropdown {
                            id: toCombo
                            label: qsTr("Ending shape")
                            model: ["Cookie9Sided", "SoftBurst", "Pentagon", "Pill", "Sunny", "Cookie4Sided", "Oval", "Circle", "Heart"]
                            currentIndex: 0
                        }
                    }

                    RowLayout {
                        spacing: MeoTheme.space8
                        MeoText { text: qsTr("Progress") + " (0–1):"; typeRole: "label"; typeSize: "medium"; Layout.preferredWidth: 100 }
                        MeoSlider {
                            id: progressSlider
                            accessibleName: qsTr("Shape morph progress")
                            accessibleDescription: qsTr("Adjust how far the shape has changed.")
                            from: 0.0
                            to: 1.0
                            value: 0.5
                        }
                    }

                    RowLayout {
                        spacing: MeoTheme.space8
                        MeoText { text: qsTr("Rotation angle:"); typeRole: "label"; typeSize: "medium"; Layout.preferredWidth: 100 }
                        MeoSlider {
                            id: rotSlider
                            accessibleName: qsTr("Shape rotation")
                            accessibleDescription: qsTr("Adjust the shape rotation in degrees.")
                            from: 0
                            to: 360
                            value: 0
                        }
                    }

                    MeoCheckbox {
                        id: overshootCheck
                        label: qsTr("Use spring scale bounce")
                        checked: true
                    }
                }
            }
        }
    }

    // 🌟 4. M3 Expressive Loading Indicator Suite
    ShowcaseSection {
        title: qsTr("Expressive loading indicators")
        subtitle: qsTr("Compare looping, contained, known-progress, and wavy loading states.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            RowLayout {
                spacing: MeoTheme.space32
                Layout.alignment: Qt.AlignHCenter

                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.alignment: Qt.AlignHCenter
                    MeoLoadingIndicator {
                        variant: "default"
                        size: "m"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    MeoText { text: qsTr("Looping indicator (seven shapes)"); typeRole: "label"; typeSize: "small" }
                }

                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.alignment: Qt.AlignHCenter
                    MeoLoadingIndicator {
                        variant: "contained"
                        size: "m"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    MeoText { text: qsTr("Contained morphing indicator"); typeRole: "label"; typeSize: "small" }
                }

                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.alignment: Qt.AlignHCenter
                    MeoLoadingIndicator {
                        indeterminate: false
                        value: detSlider.value
                        size: "m"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    MeoText { text: qsTr("Known-progress morphing indicator"); typeRole: "label"; typeSize: "small" }
                }
            }

            RowLayout {
                spacing: MeoTheme.space12
                Layout.alignment: Qt.AlignHCenter
                MeoText { text: qsTr("Known progress:"); typeRole: "label"; typeSize: "medium" }
                MeoSlider {
                    id: detSlider
                    accessibleName: qsTr("Known progress")
                    accessibleDescription: qsTr("Adjust the progress shown by the indicators.")
                    from: 0.0
                    to: 1.0
                    value: 0.65
                }
            }

            // Wavy Linear and Circular Progress
            ColumnLayout {
                spacing: MeoTheme.space12
                Layout.fillWidth: true

                MeoText { text: qsTr("Wavy progress indicators"); typeRole: "title"; typeSize: "small"; emphasized: true }

                RowLayout {
                    spacing: MeoTheme.space24
                    Layout.fillWidth: true

                    MeoProgressBar {
                        type: "linear"
                        wavy: true
                        value: detSlider.value
                        Layout.fillWidth: true
                    }

                    MeoProgressBar {
                        type: "circular"
                        wavy: true
                        value: detSlider.value
                    }
                }
            }
        }
    }


    // 🌟 5. M3 Expressive Range Slider
    ShowcaseSection {
        title: qsTr("Expressive range slider")
        subtitle: qsTr("Adjust a range with a wavy progress track.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            MeoText { text: qsTr("Wavy range slider:"); typeRole: "title"; typeSize: "small"; emphasized: true }

            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                MeoRangeSlider {
                    wavy: true
                    Layout.fillWidth: true
                }
            }
        }
    }

    // 🌟 5. Bouncy Interactive Cards & Surfaces
    ShowcaseSection {
        title: qsTr("Responsive cards and surfaces")
        subtitle: qsTr("These samples grow gently on hover and press, then settle with a soft spring.")
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoMotionSurface {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "elevated"
                interactive: true
                bouncy: true

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "MeoMotionSurface"; typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: qsTr("Interactive and springy"); typeRole: "body"; typeSize: "small" }
                }
            }

            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "filled"
                interactive: true
                bouncy: true
                Accessible.name: qsTr("Filled interactive card")

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: qsTr("Filled card"); typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: qsTr("Interactive and springy"); typeRole: "body"; typeSize: "small" }
                }
            }

            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "outlined"
                interactive: true
                bouncy: true
                Accessible.name: qsTr("Outlined interactive card")

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: qsTr("Outlined card"); typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: qsTr("Interactive and springy"); typeRole: "body"; typeSize: "small" }
                }
            }
        }
    }

    // 🌟 6. Account Switcher Widget Integration
    ShowcaseSection {
        title: qsTr("Account switcher")
        subtitle: qsTr("Preview account identity and the menu states used to switch accounts.")
        width: parent.width

        RowLayout {
            width: parent.width
            Layout.alignment: Qt.AlignHCenter

            MeoAccountSwitcher {
                Layout.alignment: Qt.AlignHCenter
                model: [
                    { name: "Meo Developer", email: "dev@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Meo" },
                    { name: "Design Lead", email: "design@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Design" }
                ]
            }
        }
    }
}
