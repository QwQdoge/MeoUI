import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property int count: 0
    property int currentIndex: 0
    property string orientation: "horizontal" // "horizontal" | "vertical"
    property bool interactive: false
    spacing: 8 * themeGlobalScale
    property real dotSize: 8 * themeGlobalScale
    property real activeDotWidth: 24 * themeGlobalScale
    readonly property bool isHorizontal: orientation !== "vertical"
    readonly property int resolvedCurrentIndex: count > 0 ? Math.max(0, Math.min(count - 1, currentIndex)) : -1
    readonly property real indicatorLength: count <= 0 ? 0
                                                : count * dotSize + (count - 1) * spacing + activeDotWidth - dotSize
    readonly property bool reducedMotion: MeoTheme.reduceMotion
    signal activated(int index)

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale

    function activate(index) {
        if (!interactive || count <= 0)
            return

        const clampedIndex = Math.max(0, Math.min(count - 1, index))
        currentIndex = clampedIndex
        activated(clampedIndex)
    }

    implicitHeight: isHorizontal ? dotSize : indicatorLength
    implicitWidth: isHorizontal ? indicatorLength : dotSize

    activeFocusOnTab: interactive
    Accessible.role: interactive ? Accessible.Button : Accessible.StaticText
    Accessible.name: count > 0
                     ? qsTr("Page %1 of %2").arg(resolvedCurrentIndex + 1).arg(count)
                       + (interactive ? qsTr(". Use arrow keys to change page") : "")
                     : qsTr("No pages")
    Accessible.onPressAction: activate(resolvedCurrentIndex + 1)

    Keys.onPressed: function(event) {
        if (!interactive || count <= 0)
            return

        const previousKey = isHorizontal ? Qt.Key_Left : Qt.Key_Up
        const nextKey = isHorizontal ? Qt.Key_Right : Qt.Key_Down
        if (event.key === previousKey) {
            activate(resolvedCurrentIndex - 1)
            event.accepted = true
        } else if (event.key === nextKey) {
            activate(resolvedCurrentIndex + 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Home) {
            activate(0)
            event.accepted = true
        } else if (event.key === Qt.Key_End) {
            activate(count - 1)
            event.accepted = true
        }
    }

    contentItem: Item {
        implicitWidth: control.implicitWidth
        implicitHeight: control.implicitHeight

        Repeater {
            model: control.count
            delegate: Rectangle {
                objectName: "meoPageIndicatorDot_" + index
                readonly property bool selected: index === control.resolvedCurrentIndex
                x: control.isHorizontal
                   ? index * (control.dotSize + control.spacing) + (index > control.resolvedCurrentIndex ? control.activeDotWidth - control.dotSize : 0)
                   : 0
                y: control.isHorizontal
                   ? 0
                   : index * (control.dotSize + control.spacing) + (index > control.resolvedCurrentIndex ? control.activeDotWidth - control.dotSize : 0)
                width: control.isHorizontal ? (selected ? control.activeDotWidth : control.dotSize) : control.dotSize
                height: control.isHorizontal ? control.dotSize : (selected ? control.activeDotWidth : control.dotSize)
                radius: height / 2
                color: selected ? control.themePrimary : control.themeOutlineVariant
                Accessible.role: control.interactive ? Accessible.Button : Accessible.StaticText
                Accessible.name: qsTr("Page %1 of %2").arg(index + 1).arg(control.count)
                Accessible.checked: selected
                Accessible.onPressAction: control.activate(index)

                Behavior on width {
                    enabled: !control.reducedMotion
                    NumberAnimation { duration: MeoTheme.motionDurationMedium1; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
                }
                Behavior on height {
                    enabled: !control.reducedMotion
                    NumberAnimation { duration: MeoTheme.motionDurationMedium1; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
                }
                Behavior on color {
                    enabled: !control.reducedMotion
                    ColorAnimation { duration: MeoTheme.motionDurationShort4; easing.bezierCurve: MeoTheme.motionEasingStandard }
                }

                TapHandler {
                    enabled: control.interactive
                    onTapped: control.activate(index)
                }
            }
        }
    }
}
