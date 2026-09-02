import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // Search is an input surface, not a compact page transition.  Its bounds
    // and pill silhouette stay stable while focus and query state change.
    property string text: ""
    property string placeholder: "Search..."
    property string leadingIcon: "search"
    property string trailingIcon: "person"
    property bool active: false // 🌟 MD3 Expressive: Active state for transition
    // A reference-preserving variant for Android/ChromeOS-like search-first
    // surfaces. It only changes geometry and semantic surface roles, so it
    // remains compatible with the active dynamic color scheme.
    property string visualStyle: "standard" // "standard" | "pixel" | "settings" | "launcher"
    readonly property bool settingsStyle: visualStyle === "settings"
    readonly property bool pixelStyle: visualStyle === "pixel" || settingsStyle || visualStyle === "launcher"
    readonly property bool launcherStyle: visualStyle === "launcher"
    readonly property bool mirrored: LayoutMirroring.enabled
    readonly property bool focusVisible: textField.activeFocus

    signal activated()
    signal accepted(string text)

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerHigh: MeoTheme.surfaceContainerHigh
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontBodyLarge: MeoTheme.bodyLarge
    readonly property color themeSurface: MeoTheme.surface

    implicitWidth: Math.min(720 * themeGlobalScale, parent ? parent.width : 720 * themeGlobalScale)
    // Pixel Settings uses a 56dp field, while the Chromium launcher reference
    // uses a 48dp field.  Both retain the same semantic border/surface roles.
    implicitHeight: settingsStyle ? MeoTheme.settingsSearchHeight
                                  : (launcherStyle ? 48 : 56) * themeGlobalScale

    function activateSearch() {
        if (!active) {
            active = true
            activated()
        }
        textField.forceActiveFocus()
    }

    function forceSearchFocus() {
        textField.forceActiveFocus()
    }

    radius: settingsStyle ? MeoTheme.settingsSearchRadius : height / 2
    color: settingsStyle ? MeoTheme.surfaceContainer
                         : pixelStyle ? MeoTheme.surfaceContainerLowest
                                      : themeSurfaceContainerHigh
    border.width: focusVisible ? MeoTheme.strokeWidthMedium
                  : pixelStyle && !settingsStyle ? MeoTheme.strokeWidthThin : 0
    border.color: focusVisible ? MeoTheme.primary
                               : pixelStyle ? MeoTheme.outlineVariant : "transparent"

    Behavior on border.color { ColorAnimation { duration: MeoTheme.motionDurationState; easing.bezierCurve: MeoTheme.motionEasingStandard } }
    Behavior on border.width { NumberAnimation { duration: MeoTheme.motionDurationState; easing.bezierCurve: MeoTheme.motionEasingStandard } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 4 * control.themeGlobalScale
        anchors.rightMargin: 4 * control.themeGlobalScale
        spacing: 4 * control.themeGlobalScale
        layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        MeoIconButton {
            id: leadingButton
            icon.name: control.active ? "arrow_back" : control.leadingIcon
            type: "standard"
            width: 40 * control.themeGlobalScale
            height: width
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                if (control.active) {
                    control.active = false
                    textField.focus = false
                } else {
                    control.activateSearch()
                }
            }

            Accessible.name: control.active ? qsTr("Exit search") : qsTr("Search")
        }

        TextField {
            id: textField
            width: Math.max(0, parent.width - leadingButton.width
                            - (trailingButton.visible ? trailingButton.width : 0)
                            - parent.spacing * (trailingButton.visible ? 2 : 1))
            height: parent.height
            background: null
            placeholderText: control.placeholder
            text: control.text
            font.pixelSize: fontBodyLarge.size * control.themeGlobalScale
            font.weight: fontBodyLarge.weight
            font.letterSpacing: (fontBodyLarge.letterSpacing || 0) * control.themeGlobalScale
            color: control.themeOnSurface
            placeholderTextColor: control.themeOnSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
            selectByMouse: true

            onTextChanged: control.text = text
            onActiveFocusChanged: if (activeFocus) control.activateSearch()
            onAccepted: control.accepted(text)
        }

        MeoIconButton {
            id: trailingButton
            icon.name: control.active && control.text !== "" ? "close" : control.trailingIcon
            type: "standard"
            width: 40 * control.themeGlobalScale
            height: width
            anchors.verticalCenter: parent.verticalCenter
            visible: icon.name !== ""
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }

            onClicked: {
                if (control.active && control.text !== "") {
                    control.text = ""
                    textField.text = ""
                    textField.forceActiveFocus()
                }
            }

            Accessible.name: control.active && control.text !== "" ? qsTr("Clear search") : control.trailingIcon
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: control.activateSearch()
    }
}
