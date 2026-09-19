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
        title: qsTr("Segmented list")
        subtitle: qsTr("Keep related items together in one continuous surface.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoSegmentedList {
                width: parent.width
                model: [
                    { label: qsTr("Account overview"), icon: "person", trailingText: qsTr("Active") },
                    { label: qsTr("Security and privacy"), icon: "security", trailingText: qsTr("Protected") },
                    { label: qsTr("Notifications"), icon: "notifications", trailingText: qsTr("Enabled") },
                    { label: qsTr("Connected devices"), icon: "devices", trailingText: qsTr("3 online") }
                ]
            }
        }
    }

    // 🌟 2. Motion Popup Playground (MeoMotionPopup)
    ShowcaseSection {
        title: qsTr("Motion popup")
        subtitle: qsTr("Open a popup that stays anchored and moves smoothly with its controls.")
        width: parent.width

        RowLayout {
            spacing: MeoTheme.space16
            Layout.alignment: Qt.AlignLeft

            MeoButton {
                text: qsTr("Open motion popup")
                type: "filled"
                onClicked: motionPop.open()
            }

            MeoMotionPopup {
                id: motionPop
                y: 40 * MeoTheme.globalScale
                x: 0

                ColumnLayout {
                    spacing: MeoTheme.space8
                    MeoText { text: qsTr("Motion popup"); typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: qsTr("It follows its anchor and responds smoothly when you interact with it."); typeRole: "body"; typeSize: "small" }
                    MeoButton { text: qsTr("Close"); size: "s"; onClicked: motionPop.close() }
                }
            }
        }
    }

    // 🌟 3. Size Configurations Section
    ShowcaseSection {
        title: qsTr("Media card sizes")
        subtitle: qsTr("Compare compact, standard, and spacious cards with matching type and spacing.")
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
                title: qsTr("Compact card")
                supportingText: qsTr("A space-saving card for dense grids and short lists.")
                actions: [
                    { "label": qsTr("View") },
                    { "label": qsTr("Share") }
                ]
            }

            // M Size
            MeoMediaCard {
                cardSize: "m"
                type: "filled"
                mediaSource: "https://picsum.photos/400/300?random=2"
                aspectRatio: 16/9
                title: qsTr("Standard card")
                supportingText: qsTr("A balanced card for comfortable reading and media previews.")
                actions: [
                    { "label": qsTr("View") },
                    { "label": qsTr("Share") }
                ]
            }

            // L Size
            MeoMediaCard {
                cardSize: "l"
                type: "filled"
                mediaSource: "https://picsum.photos/400/300?random=3"
                aspectRatio: 16/9
                title: qsTr("Spacious card")
                supportingText: qsTr("Extra room gives featured media and longer text more presence.")
                actions: [
                    { "label": qsTr("View") },
                    { "label": qsTr("Share") }
                ]
            }
        }
    }

    // 🌟 4. Aspect Ratios Section
    ShowcaseSection {
        title: qsTr("Media aspect ratios")
        subtitle: qsTr("Choose an aspect ratio that fits video, photography, or square artwork.")
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            MeoMediaCard {
                type: "elevated"
                mediaSource: "https://picsum.photos/400/300?random=4"
                aspectRatio: 16/9
                title: qsTr("Cinematic 16:9")
                supportingText: qsTr("A wide frame for video previews, posters, and landscapes.")
            }

            MeoMediaCard {
                type: "elevated"
                mediaSource: "https://picsum.photos/400/300?random=5"
                aspectRatio: 4/3
                title: qsTr("Classic 4:3")
                supportingText: qsTr("A familiar photo frame for portraits and everyday scenes.")
            }

            MeoMediaCard {
                type: "elevated"
                mediaSource: "https://picsum.photos/400/300?random=6"
                aspectRatio: 1/1
                title: qsTr("Square 1:1")
                supportingText: qsTr("A balanced square crop for products, artwork, and avatars.")
            }
        }
    }

    // 🌟 5. States Section
    ShowcaseSection {
        title: qsTr("Card states")
        subtitle: qsTr("See how a card communicates when it is ready, selected, or unavailable.")
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
                    title: qsTr("Interactive card")
                    supportingText: qsTr("Select this card to preview hover, press, and ripple feedback.")
                    actions: [
                        { "label": qsTr("Explore") }
                    ]
                }

                MeoMediaCard {
                    type: "elevated"
                    selected: true
                    mediaSource: "https://picsum.photos/400/300?random=11"
                    aspectRatio: 16/9
                    title: qsTr("Selected")
                    supportingText: qsTr("The check badge and highlighted surface make this selection clear.")
                    actions: [
                        { "label": qsTr("Deselect") }
                    ]
                }

                MeoMediaCard {
                    type: "elevated"
                    enabled: false
                    mediaSource: "https://picsum.photos/400/300?random=12"
                    aspectRatio: 16/9
                    title: qsTr("Unavailable")
                    supportingText: qsTr("This card is visually muted and cannot be selected right now.")
                    actions: [
                        { "label": qsTr("Action"), "enabled": false }
                    ]
                }
            }
        }
    }
}
