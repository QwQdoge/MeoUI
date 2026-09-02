import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // model: [{ label: "suggestion", icon: "history", isHistory: true, ... }]
    property var model: []
    property string highlightText: "" // Text to highlight in bold within the label

    signal selected(int index, var data)
    signal removed(int index, var data)

    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontBodyLarge: MeoTheme.bodyLarge

    function escapeHtml(value) {
        return String(value).replace(/&/g, "&amp;")
                            .replace(/</g, "&lt;")
                            .replace(/>/g, "&gt;")
                            .replace(/\"/g, "&quot;")
                            .replace(/'/g, "&#39;")
    }

    function highlightedLabel(value) {
        const label = String(value || "")
        const query = String(highlightText || "")
        if (query.length === 0)
            return escapeHtml(label)

        const expression = new RegExp(query.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "gi")
        let result = ""
        let lastIndex = 0
        let match
        while ((match = expression.exec(label)) !== null) {
            result += escapeHtml(label.slice(lastIndex, match.index))
            result += "<b>" + escapeHtml(match[0]) + "</b>"
            lastIndex = match.index + match[0].length
        }
        return result + escapeHtml(label.slice(lastIndex))
    }

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: Math.min(400 * themeGlobalScale, contentColumn.implicitHeight)

    contentItem: Column {
        id: contentColumn
        spacing: 0
        width: parent.width

        Repeater {
            model: control.model
            delegate: MeoListItem {
                width: parent.width
                implicitHeight: 48 * control.themeGlobalScale
                interactive: true

                leadingIcon: modelData.icon || (modelData.isHistory ? "history" : "search")
                Accessible.name: modelData.label || ""

                // Keep MeoListItem's built-in leading/trailing layout and state
                // layer. The text is escaped before the deliberate <b> markup.
                headline: control.highlightedLabel(modelData.label)

                trailingComponent: modelData.isHistory ? removeButtonComp : arrowButtonComp

                Component {
                    id: removeButtonComp
                    MeoIconButton {
                        icon.name: "close"
                        width: 40 * control.themeGlobalScale
                        height: 40 * control.themeGlobalScale
                        type: "standard"
                        Accessible.name: qsTr("Remove search history entry")
                        onClicked: control.removed(index, modelData)
                    }
                }

                Component {
                    id: arrowButtonComp
                    MeoIcon {
                        icon: "north_west" // MD3 standard for "use this suggestion"
                        size: 20
                        color: control.themeOnSurfaceVariant
                        anchors.centerIn: parent
                    }
                }

                onClicked: control.selected(index, modelData)
            }
        }
    }
}
