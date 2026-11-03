import QtQuick
import QtQuick.Controls
import MeoUI

// The application About page from docs/design/APP_SHELL.md section 3. It
// describes the application only; device and OS facts belong to Meo Settings.
// The host supplies the compile-time version and the installed notices text so
// that nothing here can drift from the binary that is actually running.
Item {
    id: control

    property string appName: ""
    property string appIcon: ""        // MeoIcon name, used when appIconSource is empty
    property url appIconSource: ""     // application icon image
    property string version: ""
    property string channel: ""        // "Stable" | "Beta" | ...; empty hides the badge
    property string description: ""
    // [{ title, subtitle, url, icon }]
    property var links: []
    property string licenseName: ""    // SPDX identifier, e.g. "GPL-3.0-only"
    property string licenseText: ""
    // Installed THIRD_PARTY_NOTICES.md (Markdown). Empty means unavailable.
    property string noticesText: ""
    property url sourceUrl: ""
    property string copyright: ""
    property Item popupParent: null

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontHeadline: MeoTheme.headlineSmallEmphasized
    readonly property var fontBody: MeoTheme.bodyMedium
    readonly property var fontBodySmall: MeoTheme.bodySmall
    readonly property var fontLabel: MeoTheme.labelLarge

    property string sheetTitle: ""
    property string sheetText: ""
    property int sheetFormat: Text.PlainText

    function linkRows() {
        const rows = []
        for (let index = 0; index < control.links.length; ++index) {
            const link = control.links[index]
            rows.push({
                "objectName": "meoAboutLink" + index,
                "title": String(link.title || ""),
                "subtitle": String(link.subtitle || link.url || ""),
                "leadingIcon": String(link.icon || "open_in_new"),
                "trailingKind": "navigation",
                "action": function() { Qt.openUrlExternally(link.url) }
            })
        }
        return rows
    }

    function showSheet(title, text, format) {
        control.sheetTitle = title
        control.sheetText = text
        control.sheetFormat = format
        textSheet.open()
    }

    function legalRows() {
        const rows = []
        if (control.licenseName.length > 0 || control.licenseText.length > 0)
            rows.push({
                "objectName": "meoAboutLicense",
                "title": qsTr("License"),
                "subtitle": control.licenseName,
                "leadingIcon": "gavel",
                "trailingKind": control.licenseText.length > 0 ? "navigation" : "none",
                "interactive": control.licenseText.length > 0,
                "action": function() { control.showSheet(qsTr("License"), control.licenseText, Text.PlainText) }
            })
        const hasNotices = control.noticesText.length > 0
        rows.push({
            "objectName": "meoAboutNotices",
            "title": qsTr("Open-source licenses"),
            "subtitle": hasNotices ? qsTr("Components and assets this app uses")
                                   : qsTr("License information is not available in this build"),
            "leadingIcon": "description",
            "trailingKind": hasNotices || control.sourceUrl.toString().length > 0 ? "navigation" : "none",
            "interactive": hasNotices || control.sourceUrl.toString().length > 0,
            "action": function() {
                if (hasNotices)
                    control.showSheet(qsTr("Open-source licenses"), control.noticesText, Text.MarkdownText)
                else
                    Qt.openUrlExternally(control.sourceUrl)
            }
        })
        return rows
    }

    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("About %1").arg(control.appName)

    ScrollView {
        id: scroll
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            id: column
            width: Math.min(scroll.availableWidth - 2 * MeoTheme.space24, 760 * control.themeGlobalScale)
            x: (scroll.availableWidth - width) / 2
            topPadding: MeoTheme.space32
            bottomPadding: MeoTheme.space32
            spacing: MeoTheme.space16

            Item {
                width: parent.width
                height: 96 * control.themeGlobalScale

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.height
                    height: parent.height
                    source: control.appIconSource
                    sourceSize.width: width
                    sourceSize.height: height
                    visible: control.appIconSource.toString().length > 0
                    Accessible.ignored: true
                }
                MeoIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon: control.appIcon
                    size: parent.height
                    color: MeoTheme.primary
                    visible: control.appIconSource.toString().length === 0 && control.appIcon.length > 0
                }
            }

            Text {
                objectName: "meoAboutName"
                width: parent.width
                text: control.appName
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.family: MeoTheme.typefaceBrand
                font.pixelSize: control.fontHeadline.size * control.themeGlobalScale
                font.weight: control.fontHeadline.weight
                color: MeoTheme.contentOnSurface
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: MeoTheme.space8
                visible: control.version.length > 0 || control.channel.length > 0

                Text {
                    objectName: "meoAboutVersion"
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Version %1").arg(control.version)
                    visible: control.version.length > 0
                    font.pixelSize: control.fontBody.size * control.themeGlobalScale
                    color: MeoTheme.contentOnSurfaceVariant
                }
                Rectangle {
                    objectName: "meoAboutChannel"
                    anchors.verticalCenter: parent.verticalCenter
                    visible: control.channel.length > 0
                    width: channelText.implicitWidth + 2 * MeoTheme.space12
                    height: channelText.implicitHeight + MeoTheme.space8
                    radius: height / 2
                    color: MeoTheme.secondaryContainer
                    Text {
                        id: channelText
                        anchors.centerIn: parent
                        text: control.channel
                        font.pixelSize: control.fontLabel.size * control.themeGlobalScale
                        font.weight: control.fontLabel.weight
                        color: MeoTheme.contentOnSecondaryContainer
                    }
                }
            }

            Text {
                width: parent.width
                text: control.description
                visible: text.length > 0
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: control.fontBody.size * control.themeGlobalScale
                color: MeoTheme.contentOnSurfaceVariant
            }

            Item { width: 1; height: MeoTheme.space8 }

            MeoSettingsGroup {
                width: parent.width
                visible: control.links.length > 0
                title: qsTr("Links")
                model: control.linkRows()
            }

            MeoSettingsGroup {
                width: parent.width
                title: qsTr("Legal")
                model: control.legalRows()
            }

            Text {
                width: parent.width
                text: control.copyright
                visible: text.length > 0
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: control.fontBodySmall.size * control.themeGlobalScale
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }

    // Level three: a read-only drill-in that retracts on dismissal.
    MeoSettingsTaskSheet {
        id: textSheet
        popupParent: control.popupParent ? control.popupParent : control
        title: control.sheetTitle
        content: Component {
            ScrollView {
                implicitWidth: 560 * MeoTheme.globalScale
                implicitHeight: 520 * MeoTheme.globalScale
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                TextEdit {
                    width: parent.width
                    readOnly: true
                    selectByMouse: true
                    wrapMode: Text.WordWrap
                    textFormat: control.sheetFormat
                    text: control.sheetText
                    font.family: control.sheetFormat === Text.PlainText ? MeoTheme.fontFamilyMonospace : MeoTheme.fontFamily
                    font.pixelSize: control.fontBodySmall.size * MeoTheme.globalScale
                    color: MeoTheme.contentOnSurface
                    onLinkActivated: (link) => Qt.openUrlExternally(link)
                }
            }
        }
    }
}
