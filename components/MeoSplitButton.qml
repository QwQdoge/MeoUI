import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

// A Material 3 Expressive split button: two separate, adjacent action
// surfaces. The 2dp gap is intentional; it replaces the old divider line.
Control {
    id: control

    property string text: ""
    property string icon: ""
    property string type: "filled" // filled | tonal | outlined | elevated
    property bool isEmphasized: false
    property var menuModel: []
    property string size: "s" // xs | s | m | l | xl
    signal clicked()
    signal menuOpened()

    readonly property string effectiveType: type === "tonal" || type === "outlined" || type === "elevated"
                                              ? type : "filled"
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real containerHeight: size === "xs" ? MeoTheme.buttonHeightXS
                                           : size === "m" ? MeoTheme.buttonHeightM
                                           : size === "l" ? MeoTheme.buttonHeightL
                                           : size === "xl" ? MeoTheme.buttonHeightXL
                                           : MeoTheme.buttonHeightS
    readonly property real outerCorner: containerHeight / 2
    readonly property real innerCorner: size === "l" ? MeoTheme.shapeSmall
                                       : size === "xl" ? MeoTheme.shapeMedium
                                       : MeoTheme.shapeExtraSmall
    readonly property real innerActiveCorner: size === "xs" || size === "s" ? MeoTheme.shapeSmall
                                             : size === "m" ? MeoTheme.shapeMedium
                                             : MeoTheme.shapeLargeIncreased
    readonly property real betweenSpace: 2 * themeGlobalScale
    readonly property real leadingStartPadding: size === "xs" ? 12 * themeGlobalScale
                                              : size === "s" ? 16 * themeGlobalScale
                                              : size === "m" ? 24 * themeGlobalScale
                                              : size === "l" ? 48 * themeGlobalScale
                                              : 64 * themeGlobalScale
    readonly property real leadingEndPadding: size === "xs" ? 10 * themeGlobalScale
                                            : size === "s" ? 12 * themeGlobalScale
                                            : size === "m" ? 24 * themeGlobalScale
                                            : size === "l" ? 48 * themeGlobalScale
                                            : 64 * themeGlobalScale
    readonly property real trailingPadding: size === "xs" || size === "s" ? 13 * themeGlobalScale
                                           : size === "m" ? 15 * themeGlobalScale
                                           : size === "l" ? 29 * themeGlobalScale
                                           : 43 * themeGlobalScale
    readonly property real leadingIconSize: size === "xs" || size === "s" ? 20 * themeGlobalScale
                                         : size === "m" ? 24 * themeGlobalScale
                                         : size === "l" ? 32 * themeGlobalScale
                                         : 40 * themeGlobalScale
    readonly property real trailingIconSize: size === "xs" || size === "s" ? 22 * themeGlobalScale
                                          : size === "m" ? 26 * themeGlobalScale
                                          : size === "l" ? 38 * themeGlobalScale
                                          : 50 * themeGlobalScale
    readonly property real unselectedIconOffset: size === "xs" || size === "s" ? 1 * themeGlobalScale
                                                : size === "m" ? 2 * themeGlobalScale
                                                : size === "l" ? 3 * themeGlobalScale
                                                : 6 * themeGlobalScale
    readonly property color enabledContainerColor: effectiveType === "filled" ? MeoTheme.primary
                                                  : effectiveType === "tonal" ? MeoTheme.secondaryContainer
                                                  : effectiveType === "elevated" ? MeoTheme.surfaceContainerLow
                                                  : "transparent"
    readonly property color enabledContentColor: effectiveType === "filled" ? MeoTheme.contentOnPrimary
                                                : effectiveType === "tonal" ? MeoTheme.contentOnSecondaryContainer
                                                : effectiveType === "elevated" ? MeoTheme.primary
                                                : MeoTheme.contentOnSurfaceVariant
    readonly property color containerColor: enabled ? enabledContainerColor
                                          : Qt.rgba(MeoTheme.contentOnSurface.r, MeoTheme.contentOnSurface.g,
                                                    MeoTheme.contentOnSurface.b, MeoTheme.disabledContainerOpacity)
    readonly property color contentColor: enabled ? enabledContentColor
                                        : Qt.rgba(MeoTheme.contentOnSurface.r, MeoTheme.contentOnSurface.g,
                                                  MeoTheme.contentOnSurface.b, MeoTheme.disabledContentOpacity)
    readonly property bool outlined: effectiveType === "outlined"
    readonly property var labelFont: MeoTheme.labelLarge

    implicitWidth: primaryAction.implicitWidth + betweenSpace + menuAction.implicitWidth
    implicitHeight: containerHeight
    width: implicitWidth
    height: implicitHeight
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    background: null
    Accessible.name: text

    contentItem: Row {
        id: splitRow
        objectName: "meoSplitButtonContent"
        spacing: control.betweenSpace
        layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        Button {
            id: primaryAction
            objectName: "meoSplitButtonPrimaryAction"
            implicitWidth: Math.max(48 * control.themeGlobalScale,
                                    primaryContent.implicitWidth + control.leadingStartPadding + control.leadingEndPadding)
            implicitHeight: control.containerHeight
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            hoverEnabled: true
            Accessible.name: control.text

            readonly property real innerRadius: pressed || hovered || visualFocus
                                                ? control.innerActiveCorner : control.innerCorner
            background: Rectangle {
                id: primaryBackground
                objectName: "meoSplitButtonPrimaryBackground"
                anchors.fill: parent
                clip: true
                color: control.containerColor
                border.width: control.outlined ? MeoTheme.strokeWidthThin : 0
                border.color: MeoTheme.outlineVariant
                topLeftRadius: control.mirrored ? primaryAction.innerRadius : control.outerCorner
                bottomLeftRadius: control.mirrored ? primaryAction.innerRadius : control.outerCorner
                topRightRadius: control.mirrored ? control.outerCorner : primaryAction.innerRadius
                bottomRightRadius: control.mirrored ? control.outerCorner : primaryAction.innerRadius
                layer.enabled: control.effectiveType === "elevated" && control.enabled
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: MeoTheme.elevationLevel1 * 0.12
                    shadowVerticalOffset: MeoTheme.elevationLevel1 * control.themeGlobalScale
                    shadowOpacity: 0.12
                    shadowColor: MeoTheme.shadow
                }

                Behavior on topLeftRadius { NumberAnimation { duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection } }
                Behavior on topRightRadius { NumberAnimation { duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection } }
                Behavior on bottomLeftRadius { NumberAnimation { duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection } }
                Behavior on bottomRightRadius { NumberAnimation { duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection } }

                MeoStateLayer {
                    anchors.fill: parent
                    radius: control.outerCorner
                    pressed: primaryAction.pressed
                    hovered: primaryAction.hovered
                    focused: primaryAction.visualFocus
                    pressX: primaryAction.pressX
                    pressY: primaryAction.pressY
                    color: control.contentColor
                }
            }

            contentItem: Item {
                Row {
                    id: primaryContent
                    anchors.centerIn: parent
                    spacing: 8 * control.themeGlobalScale
                    layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

                    MeoIcon {
                        icon: control.icon
                        visible: icon.length > 0
                        size: control.leadingIconSize
                        color: control.contentColor
                    }
                    Text {
                        text: control.text
                        font.family: MeoTheme.typefacePlain
                        font.pixelSize: control.labelFont.size * MeoTheme.fontScale * control.themeGlobalScale
                        font.weight: control.isEmphasized ? Font.DemiBold : control.labelFont.weight
                        color: control.contentColor
                        lineHeightMode: Text.FixedHeight
                        lineHeight: (control.labelFont.lineHeight || 20) * control.themeGlobalScale
                    }
                }
            }
            onClicked: control.clicked()
        }

        Button {
            id: menuAction
            objectName: "meoSplitButtonMenuAction"
            implicitWidth: Math.max(48 * control.themeGlobalScale,
                                    control.trailingIconSize + 2 * control.trailingPadding)
            implicitHeight: control.containerHeight
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            hoverEnabled: true
            Accessible.name: qsTr("More options")
            Accessible.checked: menuPopup.opened

            readonly property real innerRadius: menuPopup.opened ? control.outerCorner
                                                : pressed || hovered || visualFocus
                                                  ? control.innerActiveCorner : control.innerCorner
            background: Rectangle {
                id: trailingBackground
                objectName: "meoSplitButtonMenuBackground"
                anchors.fill: parent
                clip: true
                color: control.containerColor
                border.width: control.outlined ? MeoTheme.strokeWidthThin : 0
                border.color: MeoTheme.outlineVariant
                topLeftRadius: control.mirrored ? control.outerCorner : menuAction.innerRadius
                bottomLeftRadius: control.mirrored ? control.outerCorner : menuAction.innerRadius
                topRightRadius: control.mirrored ? menuAction.innerRadius : control.outerCorner
                bottomRightRadius: control.mirrored ? menuAction.innerRadius : control.outerCorner
                layer.enabled: control.effectiveType === "elevated" && control.enabled
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: MeoTheme.elevationLevel1 * 0.12
                    shadowVerticalOffset: MeoTheme.elevationLevel1 * control.themeGlobalScale
                    shadowOpacity: 0.12
                    shadowColor: MeoTheme.shadow
                }

                Behavior on topLeftRadius { NumberAnimation { duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection } }
                Behavior on topRightRadius { NumberAnimation { duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection } }
                Behavior on bottomLeftRadius { NumberAnimation { duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection } }
                Behavior on bottomRightRadius { NumberAnimation { duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection } }

                MeoStateLayer {
                    anchors.fill: parent
                    radius: control.outerCorner
                    pressed: menuAction.pressed
                    hovered: menuAction.hovered
                    focused: menuAction.visualFocus
                    pressX: menuAction.pressX
                    pressY: menuAction.pressY
                    color: control.contentColor
                }
            }

            contentItem: Item {
                MeoIcon {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: menuPopup.opened ? 0
                                                 : control.mirrored ? control.unselectedIconOffset
                                                                    : -control.unselectedIconOffset
                    icon: "arrow_drop_down"
                    size: control.trailingIconSize
                    color: control.contentColor
                    rotation: menuPopup.opened ? 180 : 0
                    Behavior on rotation {
                        NumberAnimation {
                            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSpatialFast
                            easing.bezierCurve: MeoTheme.motionEasingStandard
                        }
                    }
                }
            }

            onClicked: {
                if (menuPopup.opened)
                    menuPopup.close()
                else {
                    menuPopup.open()
                    control.menuOpened()
                }
            }

            MeoMenu {
                id: menuPopup
                y: menuAction.height + 4 * control.themeGlobalScale
                x: control.mirrored ? 0 : menuAction.width - width
                model: control.menuModel
            }
        }
    }
}
