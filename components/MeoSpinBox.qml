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

    // This is a MeoUI numeric-input primitive, not an M3 component port. The
    // native Qt SpinBox remains the only range/edit semantic owner.
    property string accessibleName: qsTr("Numeric value")
    property string accessibleDescription: qsTr("Current value %1. Range %2 to %3.")
                                           .arg(value).arg(Math.min(from, to)).arg(Math.max(from, to))
    property string increaseAccessibleName: qsTr("Increase %1").arg(accessibleName)
    property string decreaseAccessibleName: qsTr("Decrease %1").arg(accessibleName)

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOutline: MeoTheme.outline
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontBodyLarge: MeoTheme.bodyLarge

    implicitWidth: 144 * themeGlobalScale
    implicitHeight: 48 * themeGlobalScale
    Accessible.name: accessibleName
    Accessible.description: accessibleDescription

    // Format display text if necessary
    textFromValue: function(value, locale) {
        return Number(value).toString()
    }

    valueFromText: function(text, locale) {
        return Number.fromLocaleString(locale, text)
    }

    contentItem: TextInput {
        objectName: "meoSpinBoxInput"
        z: 2
        text: control.textFromValue(control.value, control.locale)
        font.family: MeoTheme.typefacePlain
        font.pixelSize: control.fontBodyLarge.size * control.themeGlobalScale
        font.weight: control.fontBodyLarge.weight
        color: control.enabled ? control.themeOnSurface
                               : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g,
                                         control.themeOnSurface.b, MeoTheme.disabledContentOpacity)
        selectionColor: control.themePrimary
        selectedTextColor: MeoTheme.contentOnPrimary
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
            objectName: "meoSpinBoxIncrement"
            anchors.centerIn: parent
            size: "s"
            icon.name: "add"
            enabled: control.enabled && control.up.enabled
            Accessible.name: control.increaseAccessibleName
            onClicked: control.increase()
        }
    }

    down.indicator: Item {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: 48 * control.themeGlobalScale
        implicitHeight: 48 * control.themeGlobalScale

        MeoIconButton {
            objectName: "meoSpinBoxDecrement"
            anchors.centerIn: parent
            size: "s"
            icon.name: "remove"
            enabled: control.enabled && control.down.enabled
            Accessible.name: control.decreaseAccessibleName
            onClicked: control.decrease()
        }
    }

    background: Rectangle {
        implicitWidth: 144 * control.themeGlobalScale
        implicitHeight: 48 * control.themeGlobalScale
        // Shared shape and semantic roles keep this product primitive aligned
        // with the rest of the MeoUI field vocabulary.
        radius: MeoTheme.shapeSmall
        color: "transparent"
        border.color: control.activeFocus ? control.themePrimary
                                          : (control.enabled ? control.themeOutline
                                                             : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g,
                                                                       control.themeOnSurface.b,
                                                                       MeoTheme.disabledContainerOpacity))
        border.width: (control.activeFocus ? 2 : 1) * control.themeGlobalScale

        Behavior on border.color {
            enabled: !MeoTheme.reduceMotion
            ColorAnimation {
                duration: MeoTheme.motionDurationState
            }
        }
        Behavior on radius {
            enabled: !MeoTheme.reduceMotion
            NumberAnimation {
                duration: MeoTheme.motionDurationShapeSettle
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
    }
}
