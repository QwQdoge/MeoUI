import QtQuick
import QtQuick.Controls
import MeoUI

// Embedded counterpart to MeoSearchView's docked layout. menuContent is kept
// for source compatibility; new code may use content and suggestions directly.
Rectangle {
    id: control

    property string text: ""
    property string placeholder: "Search..."
    property Component menuContent: null
    property Component content: null
    property var suggestions: []
    property string resultsTitle: ""
    property string style: "contained" // "contained" | "divided"
    property bool isExpanded: false

    readonly property bool containedStyle: style !== "divided"
    readonly property Component effectiveContent: content || menuContent
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themeSurfaceContainerHigh: MeoTheme.surfaceContainerHigh
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool reducedMotion: MeoTheme.reduceMotion

    signal clicked()

    function activateSearch() {
        isExpanded = true
        searchBar.activateSearch()
        clicked()
    }

    function deactivateSearch() {
        searchBar.active = false
        isExpanded = false
    }

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: isExpanded ? 400 * themeGlobalScale : 56 * themeGlobalScale
    // Only the collapsed input is a pill. Once results are present the
    // contained view becomes a stable rounded surface instead of an oval.
    radius: containedStyle ? (isExpanded ? MeoTheme.windowRadius : height / 2) : 0
    color: containedStyle ? themeSurfaceContainer : themeSurface
    clip: true
    Accessible.role: Accessible.Pane
    Accessible.name: resultsTitle.length > 0 ? resultsTitle : qsTr("Search")

    Behavior on implicitHeight {
        enabled: !control.reducedMotion
        NumberAnimation { duration: MeoTheme.motionDurationMedium; easing.bezierCurve: MeoTheme.motionEasingSoul }
    }
    Behavior on radius {
        enabled: !control.reducedMotion
        NumberAnimation { duration: MeoTheme.motionDurationMedium; easing.bezierCurve: MeoTheme.motionEasingSoul }
    }

    Column {
        anchors.fill: parent
        spacing: 0

        Item {
            width: parent.width
            height: searchBar.height

            MeoSearchBar {
                id: searchBar
                x: control.containedStyle ? 8 * control.themeGlobalScale : 0
                width: parent.width - (control.containedStyle ? 16 * control.themeGlobalScale : 0)
                anchors.verticalCenter: parent.verticalCenter
                text: control.text
                placeholder: control.placeholder
                active: control.isExpanded
                trailingIcon: ""
                radius: control.containedStyle ? height / 2 : 0
                color: control.containedStyle ? control.themeSurfaceContainerHigh : "transparent"
                border.width: 0
                onTextChanged: control.text = text
                onActivated: {
                    control.isExpanded = true
                    control.clicked()
                }
                onActiveChanged: if (!active) control.isExpanded = false
            }
        }

        Rectangle {
            width: parent.width
            height: control.isExpanded && !control.containedStyle ? Math.max(1, MeoTheme.strokeWidthThin) : 0
            color: control.themeOutlineVariant
        }

        Item {
            width: parent.width
            height: Math.max(0, parent.height - searchBar.height)
            visible: control.isExpanded
            clip: true

            Column {
                anchors.fill: parent
                anchors.margins: control.containedStyle ? 8 * control.themeGlobalScale : 16 * control.themeGlobalScale
                spacing: 4 * control.themeGlobalScale

                Text {
                    id: resultsTitleLabel
                    visible: text.length > 0
                    width: parent.width
                    text: control.resultsTitle
                    color: MeoTheme.contentOnSurfaceVariant
                    font.pixelSize: MeoTheme.titleMedium.size * control.themeGlobalScale
                    font.weight: MeoTheme.titleMedium.weight
                }

                Item {
                    width: parent.width
                    height: parent.height - (resultsTitleLabel.visible ? resultsTitleLabel.height + parent.spacing : 0)

                    MeoSearchSuggestions {
                        anchors.fill: parent
                        model: control.suggestions
                        highlightText: control.text
                        visible: control.suggestions.length > 0 && control.effectiveContent === null
                        onSelected: (index, data) => control.text = data.label
                    }

                    Loader {
                        anchors.fill: parent
                        sourceComponent: control.effectiveContent
                        visible: control.effectiveContent !== null
                    }
                }
            }
        }
    }
}
