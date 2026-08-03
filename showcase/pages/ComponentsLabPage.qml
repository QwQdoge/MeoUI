import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: componentsLabPage
    categoryId: "content-media"

    // 🌟 1. Segmented List Section (MeoSegmentedList)
    ShowcaseSection {
        title: "Segmented List Component (MeoSegmentedList)"
        subtitle: "Items with connected corner radii forming unified container shapes for group items."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoSegmentedList {
                width: parent.width
                model: [
                    { label: "Account Overview", icon: "person", trailingText: "Active" },
                    { label: "Security & Privacy", icon: "security", trailingText: "Protected" },
                    { label: "Notifications & Alerts", icon: "notifications", trailingText: "Enabled" },
                    { label: "Connected Devices", icon: "devices", trailingText: "3 Online" }
                ]
            }
        }
    }

    // 🌟 2. Motion Popup Playground (MeoMotionPopup)
    ShowcaseSection {
        title: "Motion Popup Playground (MeoMotionPopup)"
        subtitle: "M3 Expressive motion popup container supporting anchored directional transitions."
        width: parent.width

        RowLayout {
            spacing: MeoTheme.space16
            Layout.alignment: Qt.AlignLeft

            MeoButton {
                text: "Toggle Motion Popup"
                type: "filled"
                onClicked: motionPop.open()
            }

            MeoMotionPopup {
                id: motionPop
                y: 40 * MeoTheme.globalScale
                x: 0

                ColumnLayout {
                    spacing: MeoTheme.space8
                    MeoText { text: "Expressive Motion Popup"; typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: "Supports interruptible spring physics and anchor positioning."; typeRole: "body"; typeSize: "small" }
                    MeoButton { text: "Close"; size: "s"; onClicked: motionPop.close() }
                }
            }
        }
    }

    // 🌟 3. Size Configurations Section
    ShowcaseSection {
        title: "Media Card Sizes"
        subtitle: "A 3-step size variant scale ('s', 'm', 'l') with automatically scaled typography and layout metrics."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            // S Size
            MeoMediaCard {
                cardSize: "s"
                type: "filled"
                mediaSource: "https://picsum.photos/400/300?random=1"
                aspectRatio: 16/9
                title: "Small Card"
                supportingText: "A highly compact size variant designed for grid list layouts and tight spaces."
                actions: [
                    { "label": "View" },
                    { "label": "Share" }
                ]
            }

            // M Size
            MeoMediaCard {
                cardSize: "m"
                type: "filled"
                mediaSource: "https://picsum.photos/400/300?random=2"
                aspectRatio: 16/9
                title: "Medium Card"
                supportingText: "The standard default size variant. Excellent balance of media area and readability."
                actions: [
                    { "label": "View" },
                    { "label": "Share" }
                ]
            }

            // L Size
            MeoMediaCard {
                cardSize: "l"
                type: "filled"
                mediaSource: "https://picsum.photos/400/300?random=3"
                aspectRatio: 16/9
                title: "Large Card"
                supportingText: "Generous spacing and prominent typography for high-impact media features."
                actions: [
                    { "label": "View" },
                    { "label": "Share" }
                ]
            }
        }
    }

    // 🌟 4. Aspect Ratios Section
    ShowcaseSection {
        title: "Media Aspect Ratios"
        subtitle: "Supports customizable media aspect ratios such as 16:9, 4:3, or 1:1 square for different content layouts."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            MeoMediaCard {
                type: "elevated"
                mediaSource: "https://picsum.photos/400/300?random=4"
                aspectRatio: 16/9
                title: "Cinematic 16:9"
                supportingText: "Perfect for video previews, movie posters, and horizontal landscapes."
            }

            MeoMediaCard {
                type: "elevated"
                mediaSource: "https://picsum.photos/400/300?random=5"
                aspectRatio: 4/3
                title: "Classic 4:3"
                supportingText: "Traditional photograph aspect ratio. Great for portrait and landscape scenes."
            }

            MeoMediaCard {
                type: "elevated"
                mediaSource: "https://picsum.photos/400/300?random=6"
                aspectRatio: 1/1
                title: "Square 1:1"
                supportingText: "Modern square crop. Highly popular for product showcases and social media avatars."
            }
        }
    }

    // 🌟 5. States Section
    ShowcaseSection {
        title: "Card States & Positions"
        subtitle: "Demonstrates interactive feedback, selected checkbox indicator, disabled opacity, and horizontal positions."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoMediaCard {
                    type: "elevated"
                    interactive: true
                    mediaSource: "https://picsum.photos/400/300?random=10"
                    aspectRatio: 16/9
                    title: "Interactive Card"
                    supportingText: "Click on this card to see organic hover scaling, smooth pressed response, and ripples."
                    actions: [
                        { "label": "Explore" }
                    ]
                }

                MeoMediaCard {
                    type: "elevated"
                    selected: true
                    mediaSource: "https://picsum.photos/400/300?random=11"
                    aspectRatio: 16/9
                    title: "Selected State"
                    supportingText: "Features an MD3 check badge in the corner and primaryContainer colored background."
                    actions: [
                        { "label": "Deselect" }
                    ]
                }

                MeoMediaCard {
                    type: "elevated"
                    enabled: false
                    mediaSource: "https://picsum.photos/400/300?random=12"
                    aspectRatio: 16/9
                    title: "Disabled State"
                    supportingText: "Container and contents are visually dimmed and interaction is completely disabled."
                    actions: [
                        { "label": "Action", "enabled": false }
                    ]
                }
            }
        }
    }
}
