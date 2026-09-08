import QtQuick
import QtQuick.Layouts
import MeoUI

// Platform-neutral content for a compositor or shell-owned launch surface.
// The host owns window placement and lifecycle; this component owns only the
// bounded, non-interactive visual response.
Item {
    id: control

    property string appName: qsTr("Opening application")
    property string supportingText: qsTr("Getting things ready")
    property string fallbackIcon: "apps"
    property url backgroundSource
    property color accentColor: MeoTheme.primary
    property bool active: true
    property bool showSkeleton: true
    property alias iconContent: iconHost.data

    implicitWidth: 520 * MeoTheme.globalScale
    implicitHeight: 320 * MeoTheme.globalScale
    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("Opening %1").arg(appName)

    MeoSpringValue {
        id: scaleSpring
        value: 0.985
        targetValue: control.active ? 1 : 0.985
        spring: MeoMotion.defaultSpatial
    }

    scale: scaleSpring.value

    MeoMotionSurface {
        anchors.fill: parent
        interactive: false
        radius: MeoTheme.shapeExtraLargeIncreased
        elevation: 3
        color: MeoTheme.surfaceContainerLow

        Image {
            anchors.fill: parent
            source: control.backgroundSource
            visible: source.toString().length > 0
            asynchronous: true
            cache: true
            fillMode: Image.PreserveAspectCrop
            opacity: MeoTheme.transparencyEnabled ? 0.34 : 0.18
        }

        Rectangle {
            anchors.fill: parent
            radius: MeoTheme.shapeExtraLargeIncreased
            color: Qt.rgba(control.accentColor.r, control.accentColor.g,
                           control.accentColor.b,
                           MeoTheme.isDarkMode ? 0.18 : 0.12)
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width - 48 * MeoTheme.globalScale,
                            320 * MeoTheme.globalScale)
            spacing: MeoTheme.space12

            Item {
                id: iconHost
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 72 * MeoTheme.globalScale
                Layout.preferredHeight: Layout.preferredWidth

                Rectangle {
                    anchors.fill: parent
                    radius: MeoTheme.shapeLargeIncreased
                    color: MeoTheme.primaryContainer
                }

                MeoIcon {
                    anchors.centerIn: parent
                    icon: control.fallbackIcon
                    size: 40
                    color: MeoTheme.onPrimaryContainer
                    visible: iconHost.children.length <= 2
                }
            }

            MeoText {
                Layout.fillWidth: true
                text: control.appName
                typeRole: "title"
                typeSize: "large"
                emphasized: true
                horizontalAlignment: Text.AlignHCenter
                color: MeoTheme.onSurface
                elide: Text.ElideRight
            }

            MeoText {
                Layout.fillWidth: true
                text: control.supportingText
                typeRole: "body"
                typeSize: "medium"
                horizontalAlignment: Text.AlignHCenter
                color: MeoTheme.onSurfaceVariant
                elide: Text.ElideRight
            }

            MeoSkeleton {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: MeoTheme.space8
                Layout.preferredWidth: 152 * MeoTheme.globalScale
                Layout.preferredHeight: 4 * MeoTheme.globalScale
                type: "pill"
                active: control.active && control.showSkeleton
                visible: control.showSkeleton
                animationStyle: "breathing"
            }
        }
    }
}
