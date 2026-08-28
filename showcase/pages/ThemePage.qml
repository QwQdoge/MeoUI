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
        title: "Dynamic Theme Tokens & Corner Radius Tuner (主题与圆角参数调整)"
        subtitle: "Drag sliders to dynamically adjust corner radius scale (0.2x–2.5x), font scale, global UI scale, and dark mode in real time."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Dark Mode & Expressive Toggles
            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                MeoSwitch {
                    label: "Dark Mode (深色模式)"
                    checked: MeoTheme.isDarkMode
                    onToggled: (val) => { MeoTheme.isDarkMode = val }
                }

                MeoSwitch {
                    label: "Expressive Motion (M3E 表达性微动效)"
                    checked: MeoTheme.isExpressive
                    onToggled: (val) => { MeoTheme.isExpressive = val }
                }

                MeoSwitch {
                    label: "Reduced Motion (减弱动画)"
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
                        MeoText { text: "Corner Radius Scale (圆角倍率):"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.cornerScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    Slider {
                        Layout.fillWidth: true
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
                        MeoText { text: "Global UI Scale (全局界面缩放):"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.globalScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    Slider {
                        Layout.fillWidth: true
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
                        MeoText { text: "Font Size Scale (字号缩放):"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.fontScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    Slider {
                        Layout.fillWidth: true
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
                        MeoText { text: "Motion Speed Scale (动画时长倍率):"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.motionScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0.5
                        to: 2.0
                        value: MeoTheme.motionScale
                        onValueChanged: { MeoTheme.motionScale = value }
                    }
                }
            }

            // Reset Button
            MeoButton {
                text: "Reset Tokens to Default (重置默认参数)"
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
        title: "Live Component Corner & Scale Preview (实时组件圆角与尺寸联动)"
        subtitle: "Components automatically update their corner radii, padding, scale, and colors as tokens change above."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            MeoButton {
                text: "Filled Button"
                type: "filled"
                size: "m"
            }

            MeoButton {
                text: "Tonal Button"
                type: "tonal"
                size: "m"
            }

            MeoButton {
                text: "Outlined Button"
                type: "outlined"
                size: "m"
            }

            MeoChip {
                label: "Filter Chip"
                icon: "filter_list"
                selected: true
            }

            MeoTextField {
                placeholder: "Live TextField..."
                width: 220 * MeoTheme.globalScale
            }

            MeoCard {
                width: 240 * MeoTheme.globalScale
                height: 90 * MeoTheme.globalScale
                type: "elevated"
                interactive: true
                bouncy: true

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Dynamic Shape Card"; typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: "Radius: " + Math.round(MeoTheme.cardRadius) + "px"; typeRole: "body"; typeSize: "small" }
                }
            }
        }
    }

    // 🌟 3. Semantic Corner Tokens Readout (语义圆角 Token 实时读数)
    ShowcaseSection {
        title: "Semantic Corner Radius Tokens Readout (语义圆角实时 Token 读数)"
        subtitle: "Current active pixel radius values computed from globalScale * cornerScale."
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
        title: "Control Geometry Contract (跨工具包控件几何契约)"
        subtitle: "The same semantic roles drive MeoUI, Plasma surfaces, native Qt controls, and KWin decoration."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space8
                MeoText { text: "Button · " + Math.round(MeoTheme.controlHeight) + " px"; typeRole: "label"; typeSize: "medium"; emphasized: true }
                MeoButton { text: "Primary action"; type: "filled"; size: "s" }
            }

            Column {
                spacing: MeoTheme.space8
                MeoText { text: "Icon targets · 32–56 px"; typeRole: "label"; typeSize: "medium"; emphasized: true }
                Row {
                    spacing: MeoTheme.space8
                    Repeater {
                        model: ["xs", "s", "m", "l", "xl"]
                        delegate: MeoIconButton {
                            required property string modelData
                            size: modelData
                            type: modelData === "m" ? "tonal" : "outlined"
                            icon.name: "favorite"
                            Accessible.name: "Icon button size " + modelData
                        }
                    }
                }
            }

            Column {
                spacing: MeoTheme.space8
                MeoText { text: "Surface roles"; typeRole: "label"; typeSize: "medium"; emphasized: true }
                Row {
                    spacing: MeoTheme.space8
                    Repeater {
                        model: [
                            { label: "Control", radius: MeoTheme.controlRadius },
                            { label: "Window", radius: MeoTheme.windowRadius },
                            { label: "Card", radius: MeoTheme.cardRadius },
                            { label: "Dialog", radius: MeoTheme.dialogRadius }
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
