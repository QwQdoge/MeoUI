import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    categoryId: "search"

    // 🌟 1. Account Switcher Widget
    ShowcaseSection {
        title: qsTr("Account switcher")
        subtitle: qsTr("Preview a clear account menu and the states people see when switching accounts.")
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
        title: qsTr("Page transitions")
        subtitle: qsTr("Switch between pages while the host keeps the current view and transition state consistent.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            RowLayout {
                spacing: MeoTheme.space16

                MeoButton {
                    text: qsTr("Show page Alpha")
                    type: "tonal"
                    onClicked: pageHost.sourceComponent = pageAlphaComp
                }

                MeoButton {
                    text: qsTr("Show page Beta")
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
                    MeoText { text: qsTr("Current page: Alpha"); typeRole: "title"; typeSize: "medium"; emphasized: true }
                    MeoText { text: qsTr("The page host keeps this page ready while you move between views."); typeRole: "body"; typeSize: "small" }
                }
            }

            Component {
                id: pageBetaComp
                Column {
                    spacing: MeoTheme.space8
                    MeoText { text: qsTr("Current page: Beta"); typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.primary }
                    MeoText { text: qsTr("Changing pages keeps the handoff smooth and the view easy to follow."); typeRole: "body"; typeSize: "small" }
                }
            }
        }
    }
}
