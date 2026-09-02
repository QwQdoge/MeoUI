import QtQuick
import QtQuick.Controls
import MeoUI

// Reusable identity card for settings home pages.  Identity data remains
// product-owned; this component only supplies the Material settings surface.
Control {
    id: control

    property string title: ""
    property string subtitle: ""
    property string avatarSource: ""
    property string initials: ""
    property bool showChevron: true
    // Allows settings pages to reuse the identity surface as a read-only summary.
    property bool interactive: true
    property color avatarColor: MeoTheme.primaryContainer
    property color avatarContentColor: MeoTheme.contentOnPrimaryContainer

    signal clicked()

    readonly property bool pressed: hitArea.pressed
    readonly property bool focusVisible: activeFocus
    readonly property real scale: MeoTheme.globalScale
    readonly property bool reducedMotion: MeoTheme.reduceMotion

    implicitWidth: 480 * scale
    implicitHeight: MeoTheme.settingsAccountHeight
    leftPadding: 20 * scale
    rightPadding: 20 * scale
    topPadding: 0
    bottomPadding: 0
    activeFocusOnTab: enabled && interactive
    hoverEnabled: enabled && interactive

    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.description: subtitle
    Accessible.focusable: enabled && interactive
    Accessible.onPressAction: activate()

    function activate() {
        if (!enabled || !interactive)
            return
        forceActiveFocus(Qt.MouseFocusReason)
        clicked()
    }

    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: MeoTheme.settingsAccountRadius
            color: MeoTheme.surfaceContainerLow

            Behavior on color {
                enabled: !control.reducedMotion
                ColorAnimation {
                    duration: MeoTheme.motionDurationEffectDefault
                    easing.bezierCurve: MeoTheme.motionEasingStandard
                }
            }
        }

        MeoStateLayer {
            anchors.fill: parent
            radius: MeoTheme.settingsAccountRadius
            pressed: control.pressed
            hovered: control.hovered
            focused: control.activeFocus
            focusRingEnabled: false
            pressX: hitArea.mouseX
            pressY: hitArea.mouseY
            color: MeoTheme.contentOnSurface
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: MeoTheme.strokeWidthThin
            radius: Math.max(0, MeoTheme.settingsAccountRadius - MeoTheme.strokeWidthThin)
            color: "transparent"
            border.width: control.activeFocus ? MeoTheme.strokeWidthMedium : 0
            border.color: MeoTheme.primary
            opacity: control.activeFocus ? 1 : 0

            Behavior on opacity { enabled: !control.reducedMotion; NumberAnimation { duration: MeoTheme.motionDurationEffectDefault } }
        }

        MouseArea {
            id: hitArea
            anchors.fill: parent
            enabled: control.enabled && control.interactive
            hoverEnabled: control.interactive
            cursorShape: control.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: control.activate()
        }
    }

    contentItem: Row {
        spacing: MeoTheme.settingsIconTextGap
        opacity: control.enabled ? 1 : 0.38

        Behavior on opacity {
            enabled: !control.reducedMotion
            NumberAnimation { duration: MeoTheme.motionDurationEffectDefault }
        }

        MeoAvatar {
            anchors.verticalCenter: parent.verticalCenter
            source: control.avatarSource
            initials: control.initials
            size: MeoTheme.settingsAvatarSize / Math.max(0.1, MeoTheme.globalScale)
            color: control.avatarColor
            textColor: control.avatarContentColor
        }

        Column {
            width: Math.max(0, parent.width - MeoTheme.settingsAvatarSize
                            - parent.spacing
                            - (chevron.visible ? chevron.width + parent.spacing : 0))
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2 * control.scale

            Text {
                width: parent.width
                text: control.title
                font.family: MeoTheme.typefacePlain
                font.pixelSize: MeoTheme.titleMedium.size * control.scale
                font.weight: MeoTheme.titleMedium.weight
                color: MeoTheme.contentOnSurface
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            Text {
                width: parent.width
                text: control.subtitle
                visible: text !== ""
                font.family: MeoTheme.typefacePlain
                font.pixelSize: MeoTheme.bodyMedium.size * control.scale
                font.weight: MeoTheme.bodyMedium.weight
                color: MeoTheme.contentOnSurfaceVariant
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
        }

        MeoIcon {
            id: chevron
            anchors.verticalCenter: parent.verticalCenter
            visible: control.showChevron
            icon: "chevron_right"
            size: 20
            color: MeoTheme.contentOnSurfaceVariant
        }
    }
}
