import QtQuick
import QtQuick.Controls

Item {
    id: control

    // M3 dividers are normally a 1dp outline-variant line. Insets apply to
    // the visible line while the component retains its full layout target.
    property string orientation: "horizontal" // "horizontal" | "vertical"
    property real thickness: 1 * themeGlobalScale
    property real inset: 0
    property real leftInset: inset
    property real rightInset: inset
    property real topInset: inset
    property real bottomInset: inset
    property alias color: dividerLine.color

    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property bool isHorizontal: orientation !== "vertical"

    implicitWidth: isHorizontal ? (parent ? parent.width : 100 * themeGlobalScale) : thickness
    implicitHeight: isHorizontal ? thickness : (parent ? parent.height : 100 * themeGlobalScale)
    width: implicitWidth
    height: implicitHeight

    Accessible.role: Accessible.Separator
    Accessible.name: qsTr("Divider")

    Rectangle {
        id: dividerLine
        objectName: "meoDividerLine"
        x: control.isHorizontal ? control.leftInset : (parent.width - control.thickness) / 2
        y: control.isHorizontal ? (parent.height - control.thickness) / 2 : control.topInset
        width: control.isHorizontal ? Math.max(0, parent.width - control.leftInset - control.rightInset) : control.thickness
        height: control.isHorizontal ? control.thickness : Math.max(0, parent.height - control.topInset - control.bottomInset)
        color: control.themeOutlineVariant
    }
}
