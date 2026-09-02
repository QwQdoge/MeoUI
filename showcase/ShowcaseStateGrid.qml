import QtQuick
import QtQuick.Layouts
import MeoUI

Flow {
    id: control

    // State labels are supplied by the canonical catalog entry.  Do not add a
    // generic disabled/error/loading matrix to components that do not expose
    // those semantics.  Five is the review ceiling for one component card;
    // richer combinations belong in its purpose-built live sample.
    property string stateSummary: ""
    readonly property var labels: stateSummary.length === 0 ? [] : stateSummary.split(",")
        .map(function(label) { return label.trim() })
        .filter(function(label) { return label.length > 0 })
        .slice(0, 5)

    width: parent ? parent.width : implicitWidth
    height: labels.length > 0 ? childrenRect.height : 0
    spacing: MeoTheme.space8

    Repeater {
        model: control.labels
        delegate: Rectangle {
            required property string modelData

            implicitWidth: stateLabel.implicitWidth + MeoTheme.space24
            implicitHeight: MeoTheme.buttonHeightXS
            radius: implicitHeight / 2
            color: MeoTheme.surfaceContainer
            border.color: MeoTheme.outlineVariant

            MeoText {
                id: stateLabel
                anchors.centerIn: parent
                text: modelData
                typeRole: "label"
                typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }
}
