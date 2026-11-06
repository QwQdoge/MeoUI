import QtQuick
import MeoUI

Text {
    id: control
    property string icon: ""
    property real size: 24

    // MD3 Material Symbols Properties
    property bool fill: false
    property int weight: 400 // 100-700
    // Defaults follow M3 guidance: grade from MeoTheme (dark/contrast), and an
    // optical size that matches the drawn size so small icons keep stroke
    // weight and large icons stay refined.
    property int grade: MeoTheme.iconGrade // -25, 0, 200
    property int opticalSize: Math.round(Math.max(20, Math.min(48, size)))
    // Material Symbols exposes FILL as a variable-font axis (0–100).  Keeping
    // it numeric lets selected icons morph instead of popping between glyphs.
    property real fillLevel: fill ? 100 : 0

    readonly property real themeGlobalScale: MeoTheme.globalScale

    text: icon
    font.family: MeoTheme.iconFontFamily
    font.pixelSize: size * themeGlobalScale

    font.weight: weight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    // Native hinting stays: Text.CurveRendering draws the variable font's
    // overlapping FILL contours as visible seams.
    renderType: Text.NativeRendering
    font.letterSpacing: 0

    // 🔤 Qt 6 variable-font axes used by Material Symbols.
    font.variableAxes: ({
        "FILL": control.fillLevel,
        "wght": control.weight,
        "GRAD": control.grade,
        "opsz": control.opticalSize
    })

    Behavior on fillLevel {
        NumberAnimation {
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
    }

    // Palette roles may change with the wallpaper-derived scheme.  Keep the
    // icon in sync with the selected-glyph morph instead of snapping colors.
    Behavior on color {
        ColorAnimation {
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasized
        }
    }
}
