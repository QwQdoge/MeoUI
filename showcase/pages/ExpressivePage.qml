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
        title: "Expressive XS-XL Sizing Scale"
        subtitle: "A 5-step expressive scale for buttons and chips mapping container heights from 24dp to 72dp."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoText {
                text: "MeoButton Sizing Scale"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoButton { text: "XS Button"; size: "xs"; type: "filled" }
                MeoButton { text: "S Button"; size: "s"; type: "filled" }
                MeoButton { text: "M Button"; size: "m"; type: "filled" }
                MeoButton { text: "L Button"; size: "l"; type: "filled" }
                MeoButton { text: "XL Button"; size: "xl"; type: "filled" }
            }

            MeoText {
                text: "MeoChip Sizing Scale"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoChip { label: "XS Chip"; size: "xs"; icon: "tag" }
                MeoChip { label: "S Chip"; size: "s"; icon: "tag" }
                MeoChip { label: "M Chip"; size: "m"; icon: "tag" }
                MeoChip { label: "L Chip"; size: "l"; icon: "tag" }
                MeoChip { label: "XL Chip"; size: "xl"; icon: "tag" }
            }
        }
    }

    // 🌟 2. Official 35 MaterialShapes Gallery
    ShowcaseSection {
        title: "Complete 35 MaterialShapes Gallery"
        subtitle: "All 35 official Android Material 3 Expressive shapes rendered from normalized vector geometry."
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
        title: "Shape Morphing Lab (MeoShapeMorph Engine)"
        subtitle: "Topological control point interpolation between shapes with spring scale bounce and local rotation."
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
                    fromShape: fromCombo.currentText
                    toShape: toCombo.currentText
                    morphProgress: progressSlider.value
                    rawSpringProgress: progressSlider.value + (overshootCheck.checked ? 0.25 * Math.sin(progressSlider.value * Math.PI) : 0)
                    rotationAngle: rotSlider.value
                }

                ColumnLayout {
                    spacing: MeoTheme.space8

                    RowLayout {
                        spacing: MeoTheme.space8
                        MeoText { text: "From Shape:"; typeRole: "label"; typeSize: "medium"; Layout.preferredWidth: 100 }
                        ComboBox {
                            id: fromCombo
                            model: ["SoftBurst", "Circle", "Cookie9Sided", "Pentagon", "Pill", "Sunny", "Cookie4Sided", "Oval", "Heart"]
                            currentIndex: 0
                        }
                    }

                    RowLayout {
                        spacing: MeoTheme.space8
                        MeoText { text: "To Shape:"; typeRole: "label"; typeSize: "medium"; Layout.preferredWidth: 100 }
                        ComboBox {
                            id: toCombo
                            model: ["Cookie9Sided", "SoftBurst", "Pentagon", "Pill", "Sunny", "Cookie4Sided", "Oval", "Circle", "Heart"]
                            currentIndex: 0
                        }
                    }

                    RowLayout {
                        spacing: MeoTheme.space8
                        MeoText { text: "Progress (0..1):"; typeRole: "label"; typeSize: "medium"; Layout.preferredWidth: 100 }
                        Slider {
                            id: progressSlider
                            from: 0.0
                            to: 1.0
                            value: 0.5
                        }
                    }

                    RowLayout {
                        spacing: MeoTheme.space8
                        MeoText { text: "Rotation Angle:"; typeRole: "label"; typeSize: "medium"; Layout.preferredWidth: 100 }
                        Slider {
                            id: rotSlider
                            from: 0
                            to: 360
                            value: 0
                        }
                    }

                    MeoCheckbox {
                        id: overshootCheck
                        label: "Enable Spring Scale Bounce Overshoot"
                        checked: true
                    }
                }
            }
        }
    }

    // 🌟 4. M3 Expressive Loading Indicator Suite
    ShowcaseSection {
        title: "M3 Expressive Loading Indicator Suite"
        subtitle: "Indeterminate 7-shape morphing sequence, contained morphing, determinate morphing, wavy linear and wavy circular progress indicators."
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
                        variant: "uncontained"
                        size: "m"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    MeoText { text: "Indeterminate Uncontained (7-Shape Loop)"; typeRole: "label"; typeSize: "small" }
                }

                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.alignment: Qt.AlignHCenter
                    MeoLoadingIndicator {
                        variant: "contained"
                        size: "m"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    MeoText { text: "Contained Morphing (48dp Container)"; typeRole: "label"; typeSize: "small" }
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
                    MeoText { text: "Determinate Morph (Circle -> SoftBurst)"; typeRole: "label"; typeSize: "small" }
                }
            }

            RowLayout {
                spacing: MeoTheme.space12
                Layout.alignment: Qt.AlignHCenter
                MeoText { text: "Determinate Progress:"; typeRole: "label"; typeSize: "medium" }
                Slider {
                    id: detSlider
                    from: 0.0
                    to: 1.0
                    value: 0.65
                }
            }

            // Wavy Linear and Circular Progress
            ColumnLayout {
                spacing: MeoTheme.space12
                Layout.fillWidth: true

                MeoText { text: "M3E Wavy Progress Indicators (Sine Wave Equation):"; typeRole: "title"; typeSize: "small"; emphasized: true }

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
        title: "M3 Expressive Range Slider"
        subtitle: "MD3 Expressive wavy range sliders."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            MeoText { text: "Wavy Range Slider:"; typeRole: "title"; typeSize: "small"; emphasized: true }

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
        title: "Bouncy Interactive Cards & Surfaces (MeoMotionSurface)"
        subtitle: "MD3 Cards and Motion Surfaces with bouncy=true scale smoothly on hover and press, utilizing standard overshoot curves."
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
                    MeoText { text: "Interactive & Bouncy"; typeRole: "body"; typeSize: "small" }
                }
            }

            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "filled"
                interactive: true
                bouncy: true

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Filled Card"; typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: "Interactive & Bouncy"; typeRole: "body"; typeSize: "small" }
                }
            }

            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "outlined"
                interactive: true
                bouncy: true

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Outlined Card"; typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: "Interactive & Bouncy"; typeRole: "body"; typeSize: "small" }
                }
            }
        }
    }

    // 🌟 6. Account Switcher Widget Integration
    ShowcaseSection {
        title: "Account Switcher Widget"
        subtitle: "MD3 Expressive account identity and switching component with dynamic menu states."
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
