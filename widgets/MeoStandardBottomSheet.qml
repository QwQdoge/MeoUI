import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Item {
    id: control

    // 🌟 核心对外属性
    property Component content: null
    property bool isOpen: false
    // AndroidX BottomSheetDefaults.SheetPeekHeight is 56dp. The expanded
    // height remains caller-controlled because this QML primitive is not a
    // full BottomSheetScaffold state machine.
    property real peekHeight: 56 * MeoTheme.globalScale
    property real expandedHeight: 400 * MeoTheme.globalScale

    implicitWidth: parent ? parent.width : 360 * MeoTheme.globalScale
    implicitHeight: isOpen ? resolvedExpandedHeight : peekHeight

    // A standard sheet cannot extend outside its scaffold viewport. The old
    // fixed 400dp background overflowed small hosts such as the Showcase
    // sample instead of behaving like BottomSheetScaffold's constrained sheet.
    readonly property real availableHeight: parent ? parent.height : expandedHeight
    readonly property real resolvedExpandedHeight: Math.min(expandedHeight, availableHeight)
    readonly property real resolvedPeekHeight: Math.min(peekHeight, resolvedExpandedHeight)

    z: 10
    clip: true

    readonly property real targetY: control.isOpen
                                  ? Math.max(0, control.availableHeight - control.resolvedExpandedHeight)
                                  : Math.max(0, control.availableHeight - control.resolvedPeekHeight)

    Rectangle {
        id: sheetBackground
        width: parent.width
        height: control.resolvedExpandedHeight
        y: targetY

        color: MeoTheme.surfaceContainerLow
        radius: MeoTheme.shapeExtraLarge

        // Ensure bottom corners are not rounded for persistent sheet
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Math.min(MeoTheme.shapeExtraLarge, parent.height)
            color: parent.color
        }

        // MD3 Elevation Shadow
        layer.enabled: control.visible
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: -2 * MeoTheme.globalScale
            shadowColor: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b, 0.10)
        }

        Behavior on y {
            id: yBehavior
            NumberAnimation {
                duration: MeoTheme.motionDurationSheetEnter
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }

        // 🌟 Drag Handle & Interaction Area
        Item {
            id: handleArea
            width: parent.width
            height: 32 * MeoTheme.globalScale
            anchors.top: parent.top

            Rectangle {
                anchors.centerIn: parent
                width: 32 * MeoTheme.globalScale
                height: 4 * MeoTheme.globalScale
                radius: 2 * MeoTheme.globalScale
                color: MeoTheme.contentOnSurfaceVariant
            }

            MouseArea {
                anchors.fill: parent
                drag.target: null // We'll handle drag manually for threshold logic

                property real startY: 0
                onPressed: (mouse) => startY = mouse.y
                onReleased: {
                    yBehavior.enabled = true
                        let threshold = (control.availableHeight - control.resolvedExpandedHeight
                                         + control.availableHeight - control.resolvedPeekHeight) / 2
                    control.isOpen = sheetBackground.y < threshold
                    sheetBackground.y = control.targetY // Re-bind to target
                }
                onPositionChanged: (mouse) => {
                    if (pressed) {
                        yBehavior.enabled = false
                        let delta = mouse.y - startY
                        sheetBackground.y = Math.max(control.availableHeight - control.resolvedExpandedHeight,
                                                     Math.min(control.availableHeight - control.resolvedPeekHeight,
                                                              sheetBackground.y + delta))
                    }
                }
                onClicked: control.isOpen = !control.isOpen
            }
        }

        // 🌟 Content Loader
        Loader {
            id: contentLoader
            anchors.top: handleArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            sourceComponent: control.content
            clip: true
            opacity: control.resolvedExpandedHeight > control.resolvedPeekHeight
                     ? (control.availableHeight - sheetBackground.y - control.resolvedPeekHeight)
                       / (control.resolvedExpandedHeight - control.resolvedPeekHeight)
                     : 1
        }
    }
}
