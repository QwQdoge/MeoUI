import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Button {
    id: control

    // type: "small" | "regular" | "medium" | "large" | "extended"
    property string type: "regular"
    // M3 Expressive color styles. The default preserves the baseline M3
    // primary-container surface; the direct color roles are expressive-only.
    property string colorStyle: "primaryContainer" // primaryContainer | secondaryContainer | tertiaryContainer | primary | secondary | tertiary
    property bool collapsed: false
    // Optional overrides make the reusable FAB suitable as the animated
    // trigger of a Material FAB menu without forking the control.
    property real containerSizeOverride: -1
    property real containerRadiusOverride: -1
    property real iconSizeOverride: -1
    property color containerColorOverride: "transparent"
    property color contentColorOverride: "transparent"
    readonly property string effectiveType: type === "standard" ? "regular" : type
    icon.name: "add"

    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themeTertiaryContainer: MeoTheme.tertiaryContainer
    readonly property color themeOnTertiaryContainer: MeoTheme.contentOnTertiaryContainer
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themeSecondary: MeoTheme.secondary
    readonly property color themeOnSecondary: MeoTheme.contentOnSecondary
    readonly property color themeTertiary: MeoTheme.tertiary
    readonly property color themeOnTertiary: MeoTheme.contentOnTertiary
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontLabelLarge: MeoTheme.labelLarge
    readonly property bool showsLabel: effectiveType === "extended" && text.length > 0
    readonly property real baseSize: effectiveType === "small" ? 40 * themeGlobalScale
                                      : effectiveType === "medium" ? 80 * themeGlobalScale
                                      : effectiveType === "large" ? 96 * themeGlobalScale
                                      : 56 * themeGlobalScale
    readonly property real restRadius: effectiveType === "small" ? 12 * themeGlobalScale
                                      : effectiveType === "medium" ? 20 * themeGlobalScale
                                      : effectiveType === "large" ? 28 * themeGlobalScale
                                      : 16 * themeGlobalScale
    readonly property real resolvedSize: containerSizeOverride > 0 ? containerSizeOverride : baseSize
    readonly property real resolvedRadius: containerRadiusOverride >= 0 ? containerRadiusOverride : restRadius
    readonly property color styleContainerColor: colorStyle === "secondaryContainer" ? themeSecondaryContainer
                                                : colorStyle === "tertiaryContainer" ? themeTertiaryContainer
                                                : colorStyle === "primary" ? themePrimary
                                                : colorStyle === "secondary" ? themeSecondary
                                                : colorStyle === "tertiary" ? themeTertiary
                                                : themePrimaryContainer
    readonly property color styleContentColor: colorStyle === "secondaryContainer" ? themeOnSecondaryContainer
                                              : colorStyle === "tertiaryContainer" ? themeOnTertiaryContainer
                                              : colorStyle === "primary" ? themeOnPrimary
                                              : colorStyle === "secondary" ? themeOnSecondary
                                              : colorStyle === "tertiary" ? themeOnTertiary
                                              : themeOnPrimaryContainer
    readonly property color resolvedContainerColor: containerColorOverride.a > 0 ? containerColorOverride
                                                                                   : styleContainerColor
    readonly property color resolvedContentColor: contentColorOverride.a > 0 ? contentColorOverride
                                                                               : styleContentColor
    // AndroidX uses level 3 at rest/focus/press and level 4 on hover. The
    // shared elevation tokens remain the single source for QML's shadow
    // translation rather than inventing a per-FAB visual scale.
    readonly property real resolvedElevation: !enabled ? 0
                                             : hovered ? MeoTheme.elevationLevel4
                                                       : MeoTheme.elevationLevel3

    implicitWidth: showsLabel && !collapsed
                   ? Math.max(112 * themeGlobalScale, fabContent.implicitWidth + 32 * themeGlobalScale)
                   : resolvedSize
    implicitHeight: resolvedSize
    // A FAB is often anchored rather than managed by a Qt Quick Layout.
    // Anchoring one edge alone does not consume implicit dimensions, so keep
    // the visual hit target concrete unless a caller explicitly overrides it.
    width: implicitWidth
    height: implicitHeight
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
    }
    Behavior on implicitHeight {
        NumberAnimation {
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
    }

    // Keep the visual surface in the control's content tree. Some Qt Quick
    // layouts leave a custom Button background without a resolved geometry;
    // a direct child has the same hit rectangle as the control in both Layout
    // and anchored placement.
    Rectangle {
        id: fabBackground
        objectName: "meoFabBackground"
        anchors.fill: parent
        z: 1
        radius: control.resolvedRadius
        color: !control.enabled
               ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b,
                         MeoTheme.disabledContainerOpacity)
               : control.resolvedContainerColor
        layer.enabled: control.visible && control.resolvedElevation > 0
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: control.resolvedElevation * 0.12
            shadowVerticalOffset: control.resolvedElevation * control.themeGlobalScale
            shadowOpacity: 0.12
            shadowColor: MeoTheme.shadow
        }

        Behavior on radius {
            enabled: !MeoTheme.reduceMotion
            NumberAnimation { duration: MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
        }
        Behavior on color {
            enabled: !MeoTheme.reduceMotion
            ColorAnimation { duration: MeoTheme.motionDurationSelection }
        }

        MeoStateLayer {
            anchors.fill: parent
            radius: parent.radius
            pressed: control.pressed
            hovered: control.hovered
            focused: control.visualFocus
            pressX: control.pressX
            pressY: control.pressY
            color: control.enabled ? control.resolvedContentColor : control.themeOnSurface
        }
    }

    background: null

    contentItem: Item {
        id: contentRoot
        objectName: "meoFabContent"
        z: 2
        implicitWidth: fabContent.implicitWidth
        implicitHeight: fabContent.implicitHeight
        clip: true

        Row {
            id: fabContent
            anchors.centerIn: parent
            height: Math.max(fabIcon.height, labelText.height)
            spacing: 8 * control.themeGlobalScale * labelText.reveal
            layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

            MeoIcon {
                id: fabIcon
                icon: control.icon.name || control.icon.source.toString()
                size: control.iconSizeOverride >= 0 ? control.iconSizeOverride
                      : control.effectiveType === "medium" ? 28 * control.themeGlobalScale
                      : control.effectiveType === "large" ? 32 * control.themeGlobalScale
                      : 24 * control.themeGlobalScale
                color: control.enabled ? control.resolvedContentColor : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: labelText
                property real reveal: control.showsLabel && !control.collapsed ? 1 : 0
                width: implicitWidth * reveal
                height: implicitHeight
                clip: true
                visible: reveal > 0
                text: control.text
                font.family: MeoTheme.typefacePlain
                font.pixelSize: control.fontLabelLarge.size * control.themeGlobalScale
                font.weight: control.fontLabelLarge.weight
                color: control.enabled ? control.resolvedContentColor : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
                lineHeightMode: Text.FixedHeight
                lineHeight: (control.fontLabelLarge.lineHeight || 20) * control.themeGlobalScale
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                opacity: reveal
                anchors.verticalCenter: parent.verticalCenter

                Behavior on reveal {
                    NumberAnimation {
                        duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection
                        easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                    }
                }
            }
        }
    }
}
