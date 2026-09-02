import QtQuick
import QtQuick.Effects
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string source: "" // Image source
    property string initials: "" // Fallback initials (e.g. "JD")
    property real size: 40 // MD3 Standard: 40dp
    property string variant: "circle" // "circle" | "square" | "squircle" | "hexagon" | ...
    property color color: MeoTheme.primaryContainer
    property color textColor: MeoTheme.contentOnPrimaryContainer

    readonly property real themeGlobalScale: MeoTheme.globalScale

    implicitWidth: size * themeGlobalScale
    implicitHeight: size * themeGlobalScale
    width: implicitWidth
    height: implicitHeight
    readonly property bool hasLoadedImage: source !== "" && avatarImage.status === Image.Ready

    Accessible.role: Accessible.Graphic
    Accessible.name: initials !== "" ? qsTr("Avatar for %1").arg(initials.toUpperCase()) : qsTr("Avatar")

    Item {
        anchors.fill: parent
        clip: true

        MeoShape {
            id: shapeBg
            anchors.fill: parent
            type: (control.variant === "circle" || control.variant === "square") ? "rect" : control.variant
            radius: control.variant === "circle" ? width / 2 : 8 * themeGlobalScale
            color: control.color
        }

        // Initial fallback
        Text {
            objectName: "meoAvatarInitials"
            anchors.centerIn: parent
            text: control.initials.toUpperCase()
            visible: !control.hasLoadedImage && control.initials !== ""
            textFormat: Text.PlainText
            font.family: MeoTheme.typefacePlain
            font.pixelSize: (control.size * 0.4) * themeGlobalScale
            font.weight: Font.Medium
            color: control.textColor
        }

        // Image (with clipping to shape via OpacityMask)
        Image {
            id: avatarImage
            anchors.fill: parent
            source: control.source
            visible: control.source !== ""
            fillMode: Image.PreserveAspectCrop

            layer.enabled: avatarImage.visible
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: shapeBg
            }
        }

        // Icon fallback if no source and no initials
        MeoIcon {
            objectName: "meoAvatarFallbackIcon"
            anchors.centerIn: parent
            icon: "person"
            visible: !control.hasLoadedImage && control.initials === ""
            size: control.size * 0.6
            color: control.textColor
        }
    }
}
