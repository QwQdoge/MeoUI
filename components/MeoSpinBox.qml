import QtQuick
import QtQuick.Controls
import MeoUI

SpinBox {
    id: control

    // Numeric range
    from: 0
    to: 100
    stepSize: 1
    value: 0
    editable: true

    readonly property color themePrimary: (typeof MeoTheme !== "undefined" && typeof MeoTheme.primary !== "undefined") ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOutline: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outline !== "undefined") ? MeoTheme.outline : "#79747E"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined") ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0

    readonly property var fontBodyLarge: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyLarge !== "undefined") ? MeoTheme.bodyLarge : { "size": 16, "weight": Font.Normal }

    implicitWidth: 144 * themeGlobalScale
    implicitHeight: 48 * themeGlobalScale // Standard MD3 target size

    // Format display text if necessary
    textFromValue: function(value, locale) {
        return Number(value).toString()
    }

    valueFromText: function(text, locale) {
        return Number.fromLocaleString(locale, text)
    }

    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)
        font.family: (typeof MeoTheme !== "undefined" && typeof MeoTheme.typefacePlain !== "undefined") ? MeoTheme.typefacePlain : "Roboto"
        font.pixelSize: control.fontBodyLarge.size * control.themeGlobalScale
        font.weight: control.fontBodyLarge.weight
        color: control.enabled ? control.themeOnSurface : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.38)
        selectionColor: control.themePrimary
        selectedTextColor: (typeof MeoTheme !== "undefined" && typeof MeoTheme.onPrimary !== "undefined") ? MeoTheme.onPrimary : "#FFFFFF"
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        clip: true
    }

    up.indicator: Item {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        implicitWidth: 48 * control.themeGlobalScale
        implicitHeight: 48 * control.themeGlobalScale

        MeoIconButton {
            anchors.centerIn: parent
            size: "s"
            icon.name: "add"
            enabled: control.value < control.to
            onClicked: control.increase()
            onPressAndHold: {
                control.increase()
                upHoldTimer.start()
            }
            onReleased: upHoldTimer.stop()
        }

        Timer {
            id: upHoldTimer
            interval: 50
            repeat: true
            onTriggered: {
                if (control.value < control.to) {
                    control.increase()
                } else {
                    stop()
                }
            }
        }
    }

    down.indicator: Item {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: 48 * control.themeGlobalScale
        implicitHeight: 48 * control.themeGlobalScale

        MeoIconButton {
            anchors.centerIn: parent
            size: "s"
            icon.name: "remove"
            enabled: control.value > control.from
            onClicked: control.decrease()
            onPressAndHold: {
                control.decrease()
                downHoldTimer.start()
            }
            onReleased: downHoldTimer.stop()
        }

        Timer {
            id: downHoldTimer
            interval: 50
            repeat: true
            onTriggered: {
                if (control.value > control.from) {
                    control.decrease()
                } else {
                    stop()
                }
            }
        }
    }

    background: Rectangle {
        implicitWidth: 144 * control.themeGlobalScale
        implicitHeight: 48 * control.themeGlobalScale
        // Use the shared shape token so this compact numeric control responds
        // to the same dynamic corner scale as the Pixel shell surfaces.
        radius: MeoTheme.shapeSmall
        color: "transparent"
        border.color: control.activeFocus ? control.themePrimary : (control.enabled ? control.themeOutline : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.12))
        border.width: (control.activeFocus ? 2 : 1) * control.themeGlobalScale

        Behavior on border.color {
            ColorAnimation {
                duration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationState !== "undefined") ? MeoTheme.motionDurationState : 150
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: MeoTheme.motionDurationShapeSettle
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
    }
}
