import QtQuick
import QtQuick.Controls
import MeoUI

Row {
    id: control

    // 🌟 核心属性
    property int maxRating: 5
    property real rating: 0
    property bool readOnly: false
    property string size: "m" // "s" (16) | "m" (24) | "l" (32)

    // 🌟 M3 Context Colors
    property color activeColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    property color inactiveColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#CAC4D0"

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property real iconSize: size === "s" ? 16 : size === "l" ? 32 : 24
    readonly property real touchTargetSize: Math.max(48 * themeGlobalScale, iconSize * themeGlobalScale)

    spacing: 4 * themeGlobalScale

    signal ratingChanged(real newRating)

    Repeater {
        model: control.maxRating

        delegate: Item {
            id: starDelegate
            width: control.touchTargetSize
            height: control.touchTargetSize

            readonly property real starValue: index + 1
            readonly property bool isFullStar: control.rating >= starValue
            readonly property bool isHalfStar: control.rating > index && control.rating < starValue

            MeoStateLayer {
                anchors.fill: parent
                radius: parent.width / 2
                hovered: !control.readOnly && starMouseArea.containsMouse
                pressed: !control.readOnly && starMouseArea.pressed
                color: control.activeColor
            }

            MeoIcon {
                anchors.centerIn: parent
                size: control.iconSize
                icon: isFullStar ? "star" : (isHalfStar ? "star_half" : "star")
                fill: isFullStar || isHalfStar
                color: (isFullStar || isHalfStar) ? control.activeColor : control.inactiveColor
                opacity: control.enabled ? 1.0 : 0.38

                Behavior on color {
                    ColorAnimation {
                        duration: (typeof MeoTheme !== "undefined" && MeoTheme.motionDurationState) ? MeoTheme.motionDurationState : 150
                    }
                }
            }

            MouseArea {
                id: starMouseArea
                anchors.fill: parent
                hoverEnabled: !control.readOnly
                enabled: !control.readOnly

                onClicked: {
                    var newRating = starValue
                    if (control.rating === starValue) {
                        // Allows un-rating by clicking the same star again (common UX pattern)
                        newRating = 0
                    }
                    control.rating = newRating
                    control.ratingChanged(newRating)
                }

                onPositionChanged: (mouse) => {
                    if (starMouseArea.pressed) {
                        var localX = mouse.x
                        var currentItemIndex = index
                        // Update rating based on drag
                        if (localX > width * 0.5) {
                             control.rating = currentItemIndex + 1
                        } else if (localX > 0) {
                             // Can support half star dragging if needed, but standard is whole stars
                             control.rating = currentItemIndex + 1
                        }
                    }
                }
            }
        }
    }
}
