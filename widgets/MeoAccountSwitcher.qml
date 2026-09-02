import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    // model: [{ name: "User Name", email: "user@example.com", avatar: "path/to/img", active: true }]
    property var model: []
    property int currentIndex: 0

    signal accountSelected(int index, var data)
    signal addAccountRequested()
    signal manageAccountsRequested()
    signal signOutRequested(int index, var data)

    // Reuse the shared semantic theme and density contract.
    readonly property bool isDarkMode: MeoTheme.isDarkMode
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themePrimary: MeoTheme.primary
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int accountCount: model && typeof model.length !== "undefined" ? model.length : 0
    readonly property int normalizedCurrentIndex: accountCount > 0 ? Math.max(0, Math.min(accountCount - 1, currentIndex)) : -1
    readonly property var currentAccount: normalizedCurrentIndex >= 0 ? model[normalizedCurrentIndex] : null

    onCurrentIndexChanged: {
        if (accountCount > 0 && currentIndex !== normalizedCurrentIndex)
            currentIndex = normalizedCurrentIndex
    }
    onModelChanged: {
        if (accountCount > 0 && currentIndex !== normalizedCurrentIndex)
            currentIndex = normalizedCurrentIndex
    }

    implicitWidth: 280 * themeGlobalScale
    implicitHeight: mainLayout.implicitHeight + padding * 2
    padding: 16 * themeGlobalScale
    Accessible.role: Accessible.Pane
    Accessible.name: currentAccount ? qsTr("Account switcher for %1").arg(currentAccount.name || "Account") : qsTr("Account switcher")

    function selectAccount(index) {
        if (!enabled || index < 0 || index >= accountCount)
            return
        currentIndex = index
        accountSelected(index, model[index])
    }

    function initialsFor(account) {
        if (!account)
            return "U"
        if (account.initials)
            return account.initials
        var words = (account.name || "U").trim().split(/\s+/)
        if (words.length === 1)
            return words[0].slice(0, 2)
        return (words[0].slice(0, 1) + words[words.length - 1].slice(0, 1))
    }

    background: Rectangle {
        radius: 28 * themeGlobalScale
        color: control.themeSurfaceContainerLow
        border.color: MeoTheme.outlineVariant
        border.width: 1 * themeGlobalScale
    }

    contentItem: ColumnLayout {
        id: mainLayout
        spacing: 12 * control.themeGlobalScale

        // Active Account Info
        RowLayout {
            Layout.fillWidth: true
            spacing: 16 * control.themeGlobalScale

            MeoAvatar {
                size: 48
                source: control.currentAccount ? (control.currentAccount.avatar || "") : ""
                initials: control.initialsFor(control.currentAccount)
            }

            Column {
                Layout.fillWidth: true
                spacing: 0
                MeoText {
                    width: parent.width
                    text: control.currentAccount ? (control.currentAccount.name || "Account") : "Account"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                    color: control.themeOnSurface
                    elide: Text.ElideRight
                }
                MeoText {
                    width: parent.width
                    text: control.currentAccount ? (control.currentAccount.email || "") : ""
                    typeRole: "body"
                    typeSize: "small"
                    color: control.themeOnSurfaceVariant
                    elide: Text.ElideRight
                }
            }

            MeoIconButton {
                icon.name: "expand_more"
                type: "standard"
                onClicked: accountMenu.open()
            }
        }

        // Quick Switcher Avatars (Other accounts)
        Row {
            Layout.fillWidth: true
            spacing: 12 * control.themeGlobalScale
            visible: control.accountCount > 1

            Repeater {
                model: control.model || []
                delegate: MeoAvatar {
                    visible: index !== control.normalizedCurrentIndex
                    size: 32
                    source: modelData.avatar || ""
                    initials: control.initialsFor(modelData)
                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Switch to %1").arg(modelData.name || qsTr("account"))
                    Accessible.onPressAction: control.selectAccount(index)

                    MouseArea {
                        anchors.fill: parent
                        enabled: control.enabled
                        onClicked: control.selectAccount(index)
                    }
                }
            }

            // Add Account Button
            Rectangle {
                width: 32 * control.themeGlobalScale
                height: 32 * control.themeGlobalScale
                radius: width / 2
                color: "transparent"
                border.color: control.themeOnSurfaceVariant
                border.width: 1 * control.themeGlobalScale
                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Add account")
                Accessible.onPressAction: control.addAccountRequested()

                MeoIcon {
                    anchors.centerIn: parent
                    icon: "add"
                    size: 18
                    color: control.themeOnSurfaceVariant
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: control.addAccountRequested()
                }
            }
        }
    }

    MeoMenu {
        id: accountMenu
        width: parent.width
        model: [
            { label: "Manage Accounts", icon: "manage_accounts", action: () => control.manageAccountsRequested() },
            {
                label: "Sign Out",
                icon: "logout",
                action: () => control.signOutRequested(
                    control.normalizedCurrentIndex,
                    control.currentAccount
                )
            }
        ]
    }
}
