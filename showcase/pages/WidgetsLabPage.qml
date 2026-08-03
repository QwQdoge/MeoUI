import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    categoryId: "search"

    // 🌟 1. Account Switcher Widget
    ShowcaseSection {
        title: "Account Management Widget"
        subtitle: "MD3 Expressive Account Switcher widget."
        width: parent.width

        MeoAccountSwitcher {
            Layout.alignment: Text.AlignHCenter
            model: [
                { name: "Meo Developer", email: "dev@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Meo" },
                { name: "Design Lead", email: "design@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Design" }
            ]
        }
    }

    // 🌟 2. Page Host Navigation Lifecycle Lab (MeoPageHost)
    ShowcaseSection {
        title: "Page Host Lifecycle Lab (MeoPageHost)"
        subtitle: "Page Host container managing page instance lifecycle, route history, and transition states."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            RowLayout {
                spacing: MeoTheme.space16

                MeoButton {
                    text: "Load Page Alpha"
                    type: "tonal"
                    onClicked: pageHost.sourceComponent = pageAlphaComp
                }

                MeoButton {
                    text: "Load Page Beta"
                    type: "tonal"
                    onClicked: pageHost.sourceComponent = pageBetaComp
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 160 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.outlineVariant
                border.width: 1

                MeoPageHost {
                    id: pageHost
                    anchors.fill: parent
                    anchors.margins: MeoTheme.space16
                    sourceComponent: pageAlphaComp
                }
            }

            Component {
                id: pageAlphaComp
                Column {
                    spacing: MeoTheme.space8
                    MeoText { text: "Active Page: Alpha"; typeRole: "title"; typeSize: "medium"; emphasized: true }
                    MeoText { text: "Page Host maintains memory lifecycle and clean entry/exit transitions."; typeRole: "body"; typeSize: "small" }
                }
            }

            Component {
                id: pageBetaComp
                Column {
                    spacing: MeoTheme.space8
                    MeoText { text: "Active Page: Beta"; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.primary }
                    MeoText { text: "Swapping page source demonstrates seamless lifecycle management."; typeRole: "body"; typeSize: "small" }
                }
            }
        }
    }
}
