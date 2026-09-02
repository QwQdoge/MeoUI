import QtQuick
import QtQuick.Controls
import MeoUI

// M3 Expressive search view. It keeps the established Popup API while adding
// the contained/docked composition used by larger desktop surfaces.
Popup {
    id: control

    property string text: ""
    property var suggestions: []
    property Component content: null
    property string placeholder: "Search..."
    property string resultsTitle: ""

    // "contained" is the expressive default. "divided" remains available so
    // applications migrating from the baseline M3 layout retain parity.
    property string style: "contained" // "contained" | "divided"
    property string layout: "full-screen" // "full-screen" | "docked"
    property real dockedWidth: 600 * themeGlobalScale
    property real dockedHeight: 560 * themeGlobalScale
    property real edgeMargin: 24 * themeGlobalScale

    readonly property bool containedStyle: style !== "divided"
    readonly property bool docked: layout === "docked"
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themeSurfaceContainerHigh: MeoTheme.surfaceContainerHigh
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real containerRadius: docked ? MeoTheme.windowRadius : 0
    readonly property Component effectiveContent: content
    readonly property bool reducedMotion: MeoTheme.reduceMotion

    width: docked
           ? Math.min(dockedWidth, Math.max(280 * themeGlobalScale,
                                             (parent ? parent.width : dockedWidth) - edgeMargin * 2))
           : (parent ? parent.width : 360 * themeGlobalScale)
    height: docked
            ? Math.min(dockedHeight, Math.max(240 * themeGlobalScale,
                                               (parent ? parent.height : dockedHeight) - edgeMargin * 2))
            : (parent ? parent.height : 600 * themeGlobalScale)
    x: docked ? Math.max(edgeMargin, ((parent ? parent.width : width) - width) / 2) : 0
    y: docked ? Math.max(edgeMargin, ((parent ? parent.height : height) - height) / 2) : 0
    padding: 0
    modal: !docked
    dim: !docked
    focus: true
    closePolicy: docked ? Popup.CloseOnEscape | Popup.CloseOnPressOutside : Popup.CloseOnEscape
    Accessible.role: Accessible.Dialog
    Accessible.name: resultsTitle.length > 0 ? resultsTitle : qsTr("Search")

    onOpened: searchBar.forceSearchFocus()

    background: Rectangle {
        color: control.docked ? control.themeSurfaceContainer : control.themeSurface
        radius: control.containerRadius
        clip: true
    }

    contentItem: Column {
        id: mainColumn
        width: parent.width
        height: parent.height
        spacing: 0

        Item {
            id: searchHeader
            width: parent.width
            height: searchBar.height + (control.containedStyle ? 32 * control.themeGlobalScale : 16 * control.themeGlobalScale)

            MeoSearchBar {
                id: searchBar
                anchors.verticalCenter: parent.verticalCenter
                x: control.containedStyle ? 16 * control.themeGlobalScale : 0
                width: parent.width - (control.containedStyle ? 32 * control.themeGlobalScale : 0)
                text: control.text
                active: control.opened
                placeholder: control.placeholder
                leadingIcon: "search"
                trailingIcon: ""
                radius: control.containedStyle ? height / 2 : 0
                color: control.containedStyle ? control.themeSurfaceContainerHigh : "transparent"
                border.width: 0

                onTextChanged: control.text = text
                onActivated: control.forceActiveFocus()
                onActiveChanged: if (!active && control.opened) control.close()
            }
        }

        Rectangle {
            id: dividedLine
            width: parent.width
            height: control.containedStyle ? 0 : Math.max(1, MeoTheme.strokeWidthThin)
            color: control.themeOutlineVariant
            visible: !control.containedStyle
        }

        Rectangle {
            id: resultsSurface
            x: control.containedStyle ? 16 * control.themeGlobalScale : 0
            width: parent.width - (control.containedStyle ? 32 * control.themeGlobalScale : 0)
            height: Math.max(0, parent.height - searchHeader.height - dividedLine.height
                             - (control.containedStyle ? 16 * control.themeGlobalScale : 0))
            color: control.containedStyle ? control.themeSurfaceContainerHigh : "transparent"
            radius: control.containedStyle ? MeoTheme.windowRadius : 0
            clip: true

            Column {
                anchors.fill: parent
                anchors.margins: control.containedStyle ? 8 * control.themeGlobalScale : 16 * control.themeGlobalScale
                spacing: 4 * control.themeGlobalScale

                Text {
                    id: resultsTitleLabel
                    width: parent.width
                    text: control.resultsTitle
                    visible: text.length > 0
                    color: MeoTheme.contentOnSurfaceVariant
                    font.pixelSize: MeoTheme.titleMedium.size * control.themeGlobalScale
                    font.weight: MeoTheme.titleMedium.weight
                    elide: Text.ElideRight
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

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: control.reducedMotion ? 0 : MeoTheme.motionDurationMedium; easing.bezierCurve: MeoTheme.motionEasingSoul }
            NumberAnimation { property: "scale"; from: control.docked ? 0.96 : 0.98; to: 1.0; duration: control.reducedMotion ? 0 : MeoTheme.motionDurationLong2; easing.bezierCurve: MeoTheme.motionEasingSoul }
            NumberAnimation { target: mainColumn; property: "opacity"; from: 0.0; to: 1.0; duration: control.reducedMotion ? 0 : MeoTheme.motionDurationMedium }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: control.reducedMotion ? 0 : MeoTheme.motionDurationMedium; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate }
            NumberAnimation { property: "scale"; from: 1.0; to: control.docked ? 0.96 : 0.98; duration: control.reducedMotion ? 0 : MeoTheme.motionDurationMedium; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate }
        }
    }
}
