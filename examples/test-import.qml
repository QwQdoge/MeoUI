import QtQuick
import QtQuick.Controls
import MeoUI 1.0

ApplicationWindow {
    width: 360
    height: 220
    visible: true
    color: MeoTheme.background

    MeoButton {
        anchors.centerIn: parent
        text: "MeoUI works"
    }
}
