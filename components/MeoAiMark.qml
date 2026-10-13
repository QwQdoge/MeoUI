import QtQuick
import MeoUI

/// Canonical Meo AI identity mark.
///
/// The mascot artwork is packaged locally so every native Meo surface can
/// reuse the same identity without depending on the network.
Item {
    id: root

    // Kept for source compatibility with older callers. The mascot itself
    // uses its canonical brand colors and a transparent background.
    property color containerColor: "transparent"
    property color markColor: "#3923D6"
    property real cornerRadius: 0
    property string accessibleName: qsTr("Meo AI")

    implicitWidth: 48
    implicitHeight: 48

    Accessible.role: Accessible.Graphic
    Accessible.name: accessibleName

    Image {
        anchors.fill: parent
        source: "qrc:/qt/qml/MeoUI/assets/icons/meo-ai-f.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        asynchronous: true
        sourceSize.width: Math.max(1, Math.round(width * 2))
        sourceSize.height: Math.max(1, Math.round(height * 2))
    }
}
