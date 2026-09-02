import QtQuick
import QtQuick.Controls
import MeoUI

Row {
    id: control

    // 🌟 核心属性
    property int maxRating: 5
    property real rating: 0
    property bool readOnly: false
    property bool allowHalfRating: true
    property bool clearOnReselect: true
    property string size: "m" // "s" (16) | "m" (24) | "l" (32)

    // 🌟 M3 Context Colors
    property color activeColor: MeoTheme.primary
    property color inactiveColor: MeoTheme.outlineVariant

    readonly property real themeGlobalScale: MeoTheme.globalScale

    readonly property real iconSize: size === "s" ? 16 : size === "l" ? 32 : 24
    readonly property real touchTargetSize: Math.max(48 * themeGlobalScale, iconSize * themeGlobalScale)

    spacing: 4 * themeGlobalScale
    activeFocusOnTab: enabled && !readOnly
    Accessible.role: Accessible.Slider
    Accessible.name: qsTr("Rating")
    Accessible.description: qsTr("%1 of %2 stars").arg(rating).arg(maxRating)
    Accessible.focusable: activeFocusOnTab

    function ratingForPosition(starIndex, x, width) {
        if (allowHalfRating && x < width / 2)
            return starIndex + 0.5
        return starIndex + 1
    }

    function setRatingFromUser(nextRating) {
        if (!enabled || readOnly)
            return
        rating = clearOnReselect && rating === nextRating ? 0 : nextRating
    }

    function adjustRating(delta) {
        if (!enabled || readOnly)
            return
        const step = allowHalfRating ? 0.5 : 1
        rating = Math.max(0, Math.min(maxRating, rating + delta * step))
    }

    Keys.onLeftPressed: adjustRating(control.mirrored ? 1 : -1)
    Keys.onRightPressed: adjustRating(control.mirrored ? -1 : 1)
    Keys.onPressed: function(event) {
        if (!enabled || readOnly)
            return
        if (event.key === Qt.Key_Home) {
            rating = 0
            event.accepted = true
        } else if (event.key === Qt.Key_End) {
            rating = maxRating
            event.accepted = true
        }
    }

    onMaxRatingChanged: {
        const normalizedMax = Math.max(1, Math.round(maxRating))
        if (maxRating !== normalizedMax) {
            maxRating = normalizedMax
            return
        }
        if (rating > maxRating)
            rating = maxRating
    }

    onRatingChanged: {
        const normalized = Math.max(0, Math.min(maxRating, rating))
        if (rating !== normalized)
            rating = normalized
    }

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
                        duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState
                        easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
            }

            MouseArea {
                id: starMouseArea
                anchors.fill: parent
                hoverEnabled: !control.readOnly
                enabled: !control.readOnly && control.enabled

                onClicked: function(mouse) {
                    control.setRatingFromUser(control.ratingForPosition(index, mouse.x, width))
                }

                onPositionChanged: (mouse) => {
                    if (starMouseArea.pressed) {
                        control.setRatingFromUser(control.ratingForPosition(index, mouse.x, width))
                    }
                }
            }
        }
    }
}
