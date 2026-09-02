import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // Media model
    property string title: "Untitled Track"
    property string artist: "Unknown Artist"
    property string album: ""
    property string sourceName: ""
    property string coverSource: ""
    property bool isPlaying: false
    property int duration: 180000
    property int position: 45000
    property int bufferedPosition: 0
    property real volume: 0.7

    // Playback capabilities / state
    property bool canSeek: true
    property bool canSkipPrevious: true
    property bool canSkipNext: true
    property bool canAdjustVolume: true
    property bool shuffleEnabled: false
    property string repeatMode: "off" // "off" | "all" | "one"
    property bool liked: false
    property string outputDevice: "This device"

    // Pixel media presentations
    property string presentation: "adaptive" // "adaptive" | "compact" | "controlCenter" | "lockScreen" | "fullScreen"
    property bool showArtwork: true
    property bool showVolume: true
    property bool showSecondaryActions: true
    property bool useWavyProgress: true
    property bool useArtworkAccent: true
    property color artworkAccentColor: "transparent"
    property color artworkOnAccentColor: themeOnPrimaryContainer

    signal playRequested()
    signal pauseRequested()
    signal nextRequested()
    signal previousRequested()
    signal seekRequested(int newPosition)
    signal volumeRequested(real newVolume)
    signal shuffleRequested(bool enabled)
    signal repeatRequested(string mode)
    signal likedRequested(bool liked)
    signal outputRequested()

    readonly property bool isDarkMode: MeoTheme.isDarkMode
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themeSurfaceContainerHigh: MeoTheme.surfaceContainerHigh
    readonly property color themeSurfaceContainerHighest: MeoTheme.surfaceContainerHighest
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property int motionFast: MeoTheme.motionDurationState
    readonly property int motionMedium: MeoTheme.motionDurationSelection
    readonly property int motionPage: MeoTheme.motionDurationPage
    readonly property bool reducedMotion: MeoTheme.reduceMotion

    readonly property bool hasArtworkAccent: useArtworkAccent && artworkAccentColor.a > 0.001
    readonly property color mediaAccent: hasArtworkAccent ? artworkAccentColor : themePrimary
    readonly property color mediaAccentContainer: hasArtworkAccent ? artworkAccentColor : themePrimaryContainer
    readonly property color mediaOnAccent: hasArtworkAccent ? artworkOnAccentColor : themeOnPrimaryContainer
    readonly property color mediaTrackColor: Qt.rgba(themeOnSurfaceVariant.r, themeOnSurfaceVariant.g, themeOnSurfaceVariant.b, isDarkMode ? 0.24 : 0.16)

    onDurationChanged: {
        if (duration < 0) {
            duration = 0
            return
        }
        if (position > duration)
            position = duration
        if (bufferedPosition > duration)
            bufferedPosition = duration
    }
    onPositionChanged: {
        var normalized = Math.max(0, Math.min(duration, position))
        if (position !== normalized)
            position = normalized
    }
    onBufferedPositionChanged: {
        var normalized = Math.max(0, Math.min(duration, bufferedPosition))
        if (bufferedPosition !== normalized)
            bufferedPosition = normalized
    }
    onVolumeChanged: {
        var normalized = Math.max(0, Math.min(1, volume))
        if (volume !== normalized)
            volume = normalized
    }
    onRepeatModeChanged: {
        if (repeatMode !== "off" && repeatMode !== "all" && repeatMode !== "one")
            repeatMode = "off"
    }

    function tintedSurface(base, strength) {
        return Qt.tint(base, Qt.rgba(mediaAccent.r, mediaAccent.g, mediaAccent.b, strength))
    }

    readonly property string resolvedPresentation: {
        if (presentation !== "adaptive")
            return presentation
        var effectiveWidth = width / Math.max(0.1, themeGlobalScale)
        var effectiveHeight = height / Math.max(0.1, themeGlobalScale)
        if (effectiveWidth >= 820 && effectiveHeight >= 480)
            return "fullScreen"
        if (effectiveWidth < 330)
            return "compact"
        return "controlCenter"
    }
    readonly property string implicitPresentation: presentation === "adaptive" ? "controlCenter" : presentation

    readonly property color resolvedContainerColor: {
        if (resolvedPresentation === "compact")
            return tintedSurface(themeSurfaceContainerLow, isDarkMode ? 0.10 : 0.06)
        if (resolvedPresentation === "controlCenter")
            return tintedSurface(themeSurfaceContainerHigh, isDarkMode ? 0.16 : 0.10)
        if (resolvedPresentation === "lockScreen")
            return tintedSurface(themeSurfaceContainer, isDarkMode ? 0.20 : 0.13)
        return tintedSurface(themeSurface, isDarkMode ? 0.22 : 0.15)
    }

    readonly property real cornerRadius: {
        if (resolvedPresentation === "compact") return 20 * themeGlobalScale
        if (resolvedPresentation === "controlCenter") return 28 * themeGlobalScale
        if (resolvedPresentation === "lockScreen") return 32 * themeGlobalScale
        return 36 * themeGlobalScale
    }

    readonly property real contentPadding: {
        if (resolvedPresentation === "compact") return 12 * themeGlobalScale
        if (resolvedPresentation === "controlCenter") return 20 * themeGlobalScale
        if (resolvedPresentation === "lockScreen") return 24 * themeGlobalScale
        return 32 * themeGlobalScale
    }

    implicitWidth: {
        if (implicitPresentation === "compact") return 328 * themeGlobalScale
        if (implicitPresentation === "lockScreen") return 440 * themeGlobalScale
        if (implicitPresentation === "fullScreen") return 960 * themeGlobalScale
        return 460 * themeGlobalScale
    }
    implicitHeight: {
        if (implicitPresentation === "compact") return 120 * themeGlobalScale
        if (implicitPresentation === "lockScreen") return 700 * themeGlobalScale
        if (implicitPresentation === "fullScreen") return 620 * themeGlobalScale
        return 236 * themeGlobalScale
    }

    padding: 0
    hoverEnabled: true
    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("%1 by %2").arg(title).arg(artist)

    background: Rectangle {
        radius: control.cornerRadius
        color: control.resolvedContainerColor
        border.width: control.activeFocus ? 2 * control.themeGlobalScale : 0
        border.color: control.mediaAccent
        Behavior on radius {
            enabled: !control.reducedMotion
            NumberAnimation {
                duration: control.motionMedium
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
        Behavior on color { enabled: !control.reducedMotion; ColorAnimation { duration: control.motionPage } }
    }

    contentItem: Loader {
        anchors.fill: parent
        anchors.margins: control.contentPadding
        sourceComponent: {
            if (control.resolvedPresentation === "compact") return compactPresentation
            if (control.resolvedPresentation === "lockScreen") return lockScreenPresentation
            if (control.resolvedPresentation === "fullScreen") return fullScreenPresentation
            return controlCenterPresentation
        }
    }

    component MediaArtwork: Rectangle {
        id: artworkRoot
        property real artworkSize: 72 * control.themeGlobalScale
        property real artworkRadius: Math.min(24 * control.themeGlobalScale, artworkSize * 0.22)
        width: artworkSize
        height: artworkSize
        radius: artworkRadius
        clip: true
        color: control.mediaAccentContainer

        Image {
            anchors.fill: parent
            source: control.coverSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: control.showArtwork && control.coverSource !== ""
        }

        Rectangle {
            anchors.fill: parent
            visible: !control.showArtwork || control.coverSource === ""
            color: control.mediaAccentContainer
            MeoIcon {
                anchors.centerIn: parent
                icon: control.isPlaying ? "graphic_eq" : "music_note"
                size: Math.max(24, artworkRoot.artworkSize / control.themeGlobalScale * 0.34)
                color: control.mediaOnAccent
                fill: control.isPlaying
            }
        }

        scale: control.isPlaying ? 1.0 : 0.97
        Behavior on scale {
            enabled: !control.reducedMotion
            NumberAnimation {
                duration: control.motionMedium
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
    }

    component MediaActionButton: Button {
        id: mediaButton
        property string glyph: "play_arrow"
        property string accessibleName: ""
        property bool prominent: false
        property bool active: false
        property real diameter: 44 * control.themeGlobalScale

        width: diameter
        height: diameter
        padding: 0
        hoverEnabled: true
        Accessible.name: accessibleName

        background: Rectangle {
            radius: mediaButton.pressed ? Math.min(width, height) * 0.34 : width / 2
            color: {
                if (!mediaButton.enabled)
                    return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08)
                if (mediaButton.prominent)
                    return control.mediaAccentContainer
                if (mediaButton.active)
                    return control.tintedSurface(control.themeSurfaceContainerHighest, control.isDarkMode ? 0.28 : 0.18)
                if (mediaButton.hovered)
                    return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08)
                return "transparent"
            }
            Behavior on radius { enabled: !control.reducedMotion; NumberAnimation { duration: control.motionFast } }
            Behavior on color { enabled: !control.reducedMotion; ColorAnimation { duration: control.motionFast } }
        }

        contentItem: MeoIcon {
            anchors.centerIn: parent
            icon: mediaButton.glyph
            fill: mediaButton.prominent || mediaButton.active
            size: mediaButton.prominent ? 32 : 24
            color: mediaButton.prominent ? control.mediaOnAccent : control.themeOnSurface
        }

        scale: pressed ? 0.94 : hovered ? 1.025 : 1.0
        Behavior on scale {
            enabled: !control.reducedMotion
            NumberAnimation {
                duration: control.motionFast
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
    }

    component MediaMetadata: Column {
        id: metadataRoot
        property bool centered: false
        property bool large: false
        property bool showAlbum: true
        spacing: (large ? 8 : 3) * control.themeGlobalScale

        Text {
            width: parent.width
            text: control.title
            font.family: MeoTheme.typefacePlain
            font.pixelSize: (metadataRoot.large ? 28 : 16) * control.themeGlobalScale
            font.weight: Font.DemiBold
            color: control.themeOnSurface
            elide: Text.ElideRight
            horizontalAlignment: metadataRoot.centered ? Text.AlignHCenter : Text.AlignLeft
        }
        Text {
            width: parent.width
            text: control.artist
            font.family: MeoTheme.typefacePlain
            font.pixelSize: (metadataRoot.large ? 16 : 14) * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
            elide: Text.ElideRight
            horizontalAlignment: metadataRoot.centered ? Text.AlignHCenter : Text.AlignLeft
        }
        Text {
            width: parent.width
            text: control.album !== "" ? control.album : control.sourceName
            visible: metadataRoot.showAlbum && text !== ""
            font.family: MeoTheme.typefacePlain
            font.pixelSize: (metadataRoot.large ? 13 : 12) * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
            opacity: 0.78
            elide: Text.ElideRight
            horizontalAlignment: metadataRoot.centered ? Text.AlignHCenter : Text.AlignLeft
        }
    }

    component SeekSlider: MeoSlider {
        property string mediaSize: "s"
        from: 0
        to: Math.max(1, control.duration)
        value: Math.max(0, Math.min(control.duration, control.position))
        size: mediaSize
        expressive: true
        trackStyle: "split"
        wavy: control.useWavyProgress && control.isPlaying
        valueLabelEnabled: false
        enabled: control.canSeek
        activeTrackColor: control.mediaAccentContainer
        inactiveTrackColor: control.mediaTrackColor
        thumbColor: control.mediaAccentContainer
        onMoved: (newValue) => {
            control.position = Math.round(newValue)
            control.seekRequested(control.position)
        }
    }

    component TimeLabels: Item {
        height: 16 * control.themeGlobalScale
        Text {
            anchors.left: parent.left
            text: control.formatTime(control.position)
            font.pixelSize: 11 * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
        }
        Text {
            anchors.right: parent.right
            text: control.formatTime(control.duration)
            font.pixelSize: 11 * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
        }
    }

    component SecondaryActions: Row {
        spacing: 16 * control.themeGlobalScale
        MediaActionButton {
            glyph: "shuffle"
            accessibleName: "Shuffle"
            active: control.shuffleEnabled
            onClicked: {
                control.shuffleEnabled = !control.shuffleEnabled
                control.shuffleRequested(control.shuffleEnabled)
            }
        }
        MediaActionButton {
            glyph: control.repeatMode === "one" ? "repeat_one" : "repeat"
            accessibleName: "Repeat"
            active: control.repeatMode !== "off"
            onClicked: control.cycleRepeat()
        }
        MediaActionButton {
            glyph: control.liked ? "favorite" : "favorite_border"
            accessibleName: "Favorite"
            active: control.liked
            onClicked: {
                control.liked = !control.liked
                control.likedRequested(control.liked)
            }
        }
        MediaActionButton {
            glyph: "devices"
            accessibleName: "Output device"
            onClicked: control.outputRequested()
        }
    }

    Component {
        id: compactPresentation
        Column {
            spacing: 8 * control.themeGlobalScale
            Row {
                width: parent.width
                height: 60 * control.themeGlobalScale
                spacing: 12 * control.themeGlobalScale
                MediaArtwork {
                    artworkSize: 56 * control.themeGlobalScale
                    artworkRadius: 18 * control.themeGlobalScale
                    anchors.verticalCenter: parent.verticalCenter
                }
                MediaMetadata {
                    width: Math.max(0, parent.width - 56 * control.themeGlobalScale - compactPlay.width - parent.spacing * 2)
                    anchors.verticalCenter: parent.verticalCenter
                    showAlbum: false
                }
                MediaActionButton {
                    id: compactPlay
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: control.isPlaying ? "pause" : "play_arrow"
                    accessibleName: control.isPlaying ? "Pause" : "Play"
                    prominent: true
                    diameter: 48 * control.themeGlobalScale
                    onClicked: control.togglePlayback()
                }
            }
            SeekSlider {
                width: parent.width
                height: 28 * control.themeGlobalScale
                mediaSize: "xs"
                wavy: false
            }
        }
    }

    Component {
        id: controlCenterPresentation
        Column {
            spacing: 12 * control.themeGlobalScale
            Row {
                width: parent.width
                height: 76 * control.themeGlobalScale
                spacing: 14 * control.themeGlobalScale
                MediaArtwork {
                    artworkSize: 72 * control.themeGlobalScale
                    artworkRadius: 22 * control.themeGlobalScale
                    anchors.verticalCenter: parent.verticalCenter
                }
                Column {
                    width: Math.max(0, parent.width - 72 * control.themeGlobalScale - centerPlay.width - parent.spacing * 2)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6 * control.themeGlobalScale
                    MediaMetadata { width: parent.width; showAlbum: false }
                    Button {
                        id: outputPill
                        visible: control.outputDevice !== ""
                        height: 28 * control.themeGlobalScale
                        width: Math.min(parent.width, outputRow.implicitWidth + 20 * control.themeGlobalScale)
                        padding: 0
                        hoverEnabled: true
                        onClicked: control.outputRequested()
                        background: Rectangle {
                            radius: height / 2
                            color: outputPill.hovered ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.10)
                                                      : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.06)
                        }
                        contentItem: Row {
                            id: outputRow
                            anchors.centerIn: parent
                            spacing: 6 * control.themeGlobalScale
                            MeoIcon { icon: "cast"; size: 16; color: control.themeOnSurfaceVariant }
                            Text {
                                text: control.outputDevice
                                font.pixelSize: 11 * control.themeGlobalScale
                                font.weight: Font.Medium
                                color: control.themeOnSurfaceVariant
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
                MediaActionButton {
                    id: centerPlay
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: control.isPlaying ? "pause" : "play_arrow"
                    accessibleName: control.isPlaying ? "Pause" : "Play"
                    prominent: true
                    diameter: 56 * control.themeGlobalScale
                    onClicked: control.togglePlayback()
                }
            }
            SeekSlider { width: parent.width; height: 40 * control.themeGlobalScale; mediaSize: "s" }
            Row {
                width: parent.width
                height: 44 * control.themeGlobalScale
                spacing: 8 * control.themeGlobalScale
                MediaActionButton {
                    glyph: "skip_previous"
                    accessibleName: "Previous"
                    enabled: control.canSkipPrevious
                    onClicked: control.previousRequested()
                }
                MediaActionButton {
                    glyph: "skip_next"
                    accessibleName: "Next"
                    enabled: control.canSkipNext
                    onClicked: control.nextRequested()
                }
                Item {
                    width: Math.max(0, parent.width - 44 * control.themeGlobalScale * 4 - parent.spacing * 4)
                    height: 1
                }
                MediaActionButton {
                    glyph: control.liked ? "favorite" : "favorite_border"
                    accessibleName: "Favorite"
                    active: control.liked
                    onClicked: {
                        control.liked = !control.liked
                        control.likedRequested(control.liked)
                    }
                }
                MediaActionButton {
                    glyph: "more_vert"
                    accessibleName: "More"
                    onClicked: control.outputRequested()
                }
            }
        }
    }

    Component {
        id: lockScreenPresentation
        Column {
            spacing: 18 * control.themeGlobalScale
            MediaArtwork {
                artworkSize: Math.min(parent.width, 300 * control.themeGlobalScale)
                artworkRadius: 32 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
            }
            MediaMetadata {
                width: parent.width
                centered: true
                large: true
                showAlbum: true
            }
            Column {
                width: parent.width
                spacing: 4 * control.themeGlobalScale
                SeekSlider { width: parent.width; height: 44 * control.themeGlobalScale; mediaSize: "m" }
                TimeLabels { width: parent.width }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 22 * control.themeGlobalScale
                MediaActionButton {
                    glyph: "skip_previous"
                    accessibleName: "Previous"
                    diameter: 52 * control.themeGlobalScale
                    enabled: control.canSkipPrevious
                    onClicked: control.previousRequested()
                }
                MediaActionButton {
                    glyph: control.isPlaying ? "pause" : "play_arrow"
                    accessibleName: control.isPlaying ? "Pause" : "Play"
                    prominent: true
                    diameter: 72 * control.themeGlobalScale
                    onClicked: control.togglePlayback()
                }
                MediaActionButton {
                    glyph: "skip_next"
                    accessibleName: "Next"
                    diameter: 52 * control.themeGlobalScale
                    enabled: control.canSkipNext
                    onClicked: control.nextRequested()
                }
            }
            SecondaryActions {
                visible: control.showSecondaryActions
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Component {
        id: fullScreenPresentation
        Row {
            spacing: 36 * control.themeGlobalScale
            Item {
                id: artworkPane
                width: Math.min(parent.width * 0.46, parent.height)
                height: parent.height
                MediaArtwork {
                    artworkSize: Math.min(artworkPane.width, artworkPane.height)
                    artworkRadius: 40 * control.themeGlobalScale
                    anchors.centerIn: parent
                }
            }
            Column {
                width: Math.max(0, parent.width - artworkPane.width - parent.spacing)
                anchors.verticalCenter: parent.verticalCenter
                spacing: 22 * control.themeGlobalScale
                MediaMetadata { width: parent.width; large: true; showAlbum: true }
                Column {
                    width: parent.width
                    spacing: 6 * control.themeGlobalScale
                    SeekSlider { width: parent.width; height: 48 * control.themeGlobalScale; mediaSize: "l" }
                    TimeLabels { width: parent.width }
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 24 * control.themeGlobalScale
                    MediaActionButton {
                        glyph: "skip_previous"
                        accessibleName: "Previous"
                        diameter: 56 * control.themeGlobalScale
                        enabled: control.canSkipPrevious
                        onClicked: control.previousRequested()
                    }
                    MediaActionButton {
                        glyph: control.isPlaying ? "pause" : "play_arrow"
                        accessibleName: control.isPlaying ? "Pause" : "Play"
                        prominent: true
                        diameter: 80 * control.themeGlobalScale
                        onClicked: control.togglePlayback()
                    }
                    MediaActionButton {
                        glyph: "skip_next"
                        accessibleName: "Next"
                        diameter: 56 * control.themeGlobalScale
                        enabled: control.canSkipNext
                        onClicked: control.nextRequested()
                    }
                }
                SecondaryActions {
                    visible: control.showSecondaryActions
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Row {
                    visible: control.showVolume && control.canAdjustVolume
                    width: parent.width
                    spacing: 12 * control.themeGlobalScale
                    MeoIcon {
                        icon: control.volume <= 0 ? "volume_off" : (control.volume < 0.5 ? "volume_down" : "volume_up")
                        size: 22
                        color: control.themeOnSurfaceVariant
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    MeoSlider {
                        width: Math.max(0, parent.width - 34 * control.themeGlobalScale)
                        height: 40 * control.themeGlobalScale
                        from: 0
                        to: 1
                        value: control.volume
                        size: "s"
                        trackStyle: "split"
                        leadingIcon: "volume_up"
                        valueLabelEnabled: false
                        activeTrackColor: control.mediaAccentContainer
                        inactiveTrackColor: control.mediaTrackColor
                        thumbColor: control.mediaAccentContainer
                        onMoved: (newValue) => {
                            control.volume = newValue
                            control.volumeRequested(newValue)
                        }
                    }
                }
            }
        }
    }

    function togglePlayback() {
        if (isPlaying) {
            isPlaying = false
            pauseRequested()
        } else {
            isPlaying = true
            playRequested()
        }
    }

    function cycleRepeat() {
        if (repeatMode === "off") repeatMode = "all"
        else if (repeatMode === "all") repeatMode = "one"
        else repeatMode = "off"
        repeatRequested(repeatMode)
    }

    function formatTime(ms) {
        var safeMs = Math.max(0, ms || 0)
        var totalSeconds = Math.floor(safeMs / 1000)
        var hours = Math.floor(totalSeconds / 3600)
        var minutes = Math.floor((totalSeconds % 3600) / 60)
        var seconds = totalSeconds % 60
        var secondsText = seconds < 10 ? "0" + seconds : seconds.toString()
        if (hours > 0) {
            var minutesText = minutes < 10 ? "0" + minutes : minutes.toString()
            return hours + ":" + minutesText + ":" + secondsText
        }
        return minutes + ":" + secondsText
    }
}
