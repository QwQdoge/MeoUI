// Image lifecycle behavior adapted from selected DankMaterialShell CachingImage
// ideas (MIT, Copyright 2025 Avenge Media LLC). Reimplemented with Qt Quick's
// in-memory Image cache only: no DMS Paths, disk cache, or service imports.
import QtQuick

Item {
    id: control

    property url source: ""
    property bool active: visible
    property bool cache: true
    property bool smooth: true
    property int fillMode: Image.PreserveAspectCrop
    // Explicit dimensions avoid decoding original-size artwork for a thumbnail.
    property int requestedSourceWidth: 0
    property int requestedSourceHeight: 0
    // Animated artwork is deliberately opt-in. Thumbnail grids should leave
    // this false to avoid GUI-thread animation decode and continuous repaint.
    property bool allowAnimation: false

    readonly property bool loading: status === Image.Loading
    readonly property bool ready: status === Image.Ready
    readonly property bool failed: status === Image.Error
    readonly property int status: allowAnimation ? animatedImage.status : staticImage.status
    readonly property size decodedSourceSize: allowAnimation ? animatedImage.sourceSize : staticImage.sourceSize

    implicitWidth: allowAnimation ? animatedImage.implicitWidth : staticImage.implicitWidth
    implicitHeight: allowAnimation ? animatedImage.implicitHeight : staticImage.implicitHeight

    Image {
        id: staticImage
        anchors.fill: parent
        source: control.active && !control.allowAnimation ? control.source : ""
        asynchronous: true
        cache: control.cache
        smooth: control.smooth
        fillMode: control.fillMode
        sourceSize.width: control.requestedSourceWidth
        sourceSize.height: control.requestedSourceHeight
    }

    AnimatedImage {
        id: animatedImage
        anchors.fill: parent
        source: control.active && control.allowAnimation ? control.source : ""
        asynchronous: true
        cache: control.cache
        smooth: control.smooth
        fillMode: control.fillMode
        sourceSize.width: control.requestedSourceWidth
        sourceSize.height: control.requestedSourceHeight
        playing: control.active && visible && status === Image.Ready
        visible: control.allowAnimation
    }
}
