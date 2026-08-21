import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: settingsPage
    categoryId: "settings"

    // 🌟 1. App Settings & Live Token Tuner (设置与动态变量调节)
    ShowcaseSection {
        title: "Showcase Settings & Dynamic Variable Editor (设置与圆角/变量调节)"
        subtitle: "Use the sliders and toggles below to dynamically modify corner radius, font scale, global scale, and motion speed across the entire MeoUI Showcase."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Dark Mode & Motion Switches
            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                MeoSwitch {
                    label: "Dark Mode (深色/浅色模式切换)"
                    checked: MeoTheme.isDarkMode
                    onToggled: (val) => { MeoTheme.isDarkMode = val }
                }

                MeoSwitch {
                    label: "Expressive Motion (M3E 微动效)"
                    checked: MeoTheme.isExpressive
                    onToggled: (val) => { MeoTheme.isExpressive = val }
                }

                MeoSwitch {
                    label: "Reduced Motion (减弱动画模式)"
                    checked: MeoTheme.reduceMotion
                    onToggled: (val) => { MeoTheme.reduceMotion = val }
                }
            }

            MeoDivider { Layout.fillWidth: true }

            // Sliders Section Header
            MeoText {
                text: "Variable Sliders (滑块编辑各类设计 Token 与变量):"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            // Sliders Row 1: Corner Radius Scale & Global UI Scale
            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                // Corner Radius Scale Slider
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    RowLayout {
                        MeoText { text: "1. Corner Radius Scale (圆角大小倍率):"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.cornerScale * 100) + "% (" + Math.round(MeoTheme.shapeMedium) + "px medium)"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    MeoSlider {
                        Layout.fillWidth: true
                        from: 0.2
                        to: 2.5
                        value: MeoTheme.cornerScale
                        leadingIcon: "rounded_corner"
                        valueLabelEnabled: false
                        onValueChanged: { MeoTheme.cornerScale = value }
                    }
                }

                // Global UI Scale Slider
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    RowLayout {
                        MeoText { text: "2. Global UI Scale (界面整体缩放):"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.globalScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    MeoSlider {
                        Layout.fillWidth: true
                        from: 0.8
                        to: 1.5
                        value: MeoTheme.globalScale
                        leadingIcon: "zoom_out_map"
                        valueLabelEnabled: false
                        onValueChanged: { MeoTheme.globalScale = value }
                    }
                }
            }

            // Sliders Row 2: Font Size Scale & Motion Speed Scale
            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                // Font Size Scale Slider
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    RowLayout {
                        MeoText { text: "3. Font Size Scale (字体大小缩放):"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.fontScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    MeoSlider {
                        Layout.fillWidth: true
                        from: 0.8
                        to: 1.4
                        value: MeoTheme.fontScale
                        leadingIcon: "text_fields"
                        valueLabelEnabled: false
                        onValueChanged: { MeoTheme.fontScale = value }
                    }
                }

                // Motion Duration Scale Slider
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    RowLayout {
                        MeoText { text: "4. Motion Speed Scale (动画速率倍率):"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.motionScale * 100) + "%"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    MeoSlider {
                        Layout.fillWidth: true
                        from: 0.5
                        to: 2.0
                        value: MeoTheme.motionScale
                        leadingIcon: "animation"
                        valueLabelEnabled: false
                        onValueChanged: { MeoTheme.motionScale = value }
                    }
                }
            }

            // Sliders Row 3: Mouse Wheel Scroll Speed
            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    RowLayout {
                        MeoText { text: "5. Mouse Wheel Scroll Speed (鼠标滚轮滚动速率):"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: Math.round(MeoTheme.scrollSpeedScale * 100) + "% (" + Math.round(140 * MeoTheme.scrollSpeedScale) + "px/step)"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.primary; emphasized: true }
                    }

                    MeoSlider {
                        Layout.fillWidth: true
                        from: 0.3
                        to: 3.5
                        value: MeoTheme.scrollSpeedScale
                        leadingIcon: "mouse"
                        valueLabelEnabled: false
                        onValueChanged: { MeoTheme.scrollSpeedScale = value }
                    }
                }
            }

            // Reset Button
            MeoButton {
                text: "Reset All Variables to Default (恢复默认设置)"
                type: "tonal"
                icon.name: "refresh"
                onClicked: {
                    MeoTheme.cornerScale = 1.0
                    MeoTheme.globalScale = 1.0
                    MeoTheme.fontScale = 1.0
                    MeoTheme.motionScale = 1.0
                    MeoTheme.scrollSpeedScale = 1.0
                    MeoTheme.isDarkMode = false
                    MeoTheme.reduceMotion = false
                }
            }
        }
    }

    // 🌟 2. Realtime Component Preview Area (组件实时反馈区域)
    ShowcaseSection {
        title: "Live Component Corner Reaction (组件圆角实时变化对比)"
        subtitle: "Watch how all UI components instantly transform as you drag the sliders above."
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
                placeholder: "Type text..."
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
                    MeoText { text: "Radius: " + Math.round(MeoTheme.shapeLarge) + "px"; typeRole: "body"; typeSize: "small" }
                }
            }
        }
    }
}
