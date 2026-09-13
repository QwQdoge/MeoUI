pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import MeoUI

// A desktop-hosted widget catalogue surface.  The host supplies catalog
// metadata and owns placement; this platform-neutral component never loads a
// widget package itself. That keeps third-party Plasma QML out of the picker
// while still showing a useful, safe content representation before the user
// adds it.
FocusScope {
    id: control

    property var catalog: []
    property string searchText: ""
    property string selectedCategory: "featured"
    property string feedbackText: ""
    property bool feedbackIsError: false
    property bool showRefreshAction: true
    property bool showCloseAction: true
    property date previewTime: new Date()
    // Selecting a card is deliberately separate from adding it.  The host only
    // receives widgetActivated() after the user confirms from the selection
    // surface below, so catalogue browsing cannot change the desktop.
    property string selectedWidgetKey: ""

    signal widgetActivated(var widget)
    signal widgetContextRequested(var widget, var anchor)
    signal refreshRequested()
    signal closeRequested()

    readonly property var categoryModel: [
        { "id": "featured", "label": qsTr("Featured"), "icon": "star" },
        { "id": "meo", "label": qsTr("Meo"), "icon": "auto_awesome" },
        { "id": "plasma", "label": qsTr("Plasma"), "icon": "extension" },
        { "id": "clock", "label": qsTr("Clock & calendar"), "icon": "schedule" },
        { "id": "weather", "label": qsTr("Weather"), "icon": "partly_cloudy_day" },
        { "id": "media", "label": qsTr("Media"), "icon": "music_note" },
        { "id": "system", "label": qsTr("System"), "icon": "monitoring" }
    ]
    readonly property var filteredCatalog: filteredEntries()
    readonly property var selectedEntry: selectedEntryForKey()
    readonly property int matchingCount: filteredCatalog.length
    readonly property real railWidth: 216 * MeoTheme.globalScale
    readonly property real minimumSheetWidth: 720 * MeoTheme.globalScale
    readonly property real minimumSheetHeight: 500 * MeoTheme.globalScale

    implicitWidth: 1080 * MeoTheme.globalScale
    implicitHeight: 660 * MeoTheme.globalScale
    activeFocusOnTab: true
    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("Add Widgets")
    Accessible.description: qsTr("Search and add Meo and compatible Plasma desktop widgets")

    function normalizedText(widget) {
        return ((widget.title || "") + " " + (widget.description || "")
                + " " + (widget.id || "") + " " + (widget.pluginId || ""))
                .toLocaleLowerCase()
    }

    function previewKindFor(widget) {
        const explicitKind = (widget.previewKind || "").toString().toLocaleLowerCase()
        if (["clock", "calendar", "weather", "media", "system", "generic"].indexOf(explicitKind) >= 0)
            return explicitKind

        const identity = ((widget.id || "") + " " + (widget.pluginId || "")
                          + " " + (widget.title || "")).toLocaleLowerCase()
        if (identity.indexOf("weather") >= 0 || identity.indexOf("forecast") >= 0)
            return "weather"
        if (identity.indexOf("media") >= 0 || identity.indexOf("music") >= 0
                || identity.indexOf("player") >= 0 || identity.indexOf("mpris") >= 0)
            return "media"
        if (identity.indexOf("calendar") >= 0 || identity.indexOf("agenda") >= 0)
            return "calendar"
        if (identity.indexOf("clock") >= 0 || identity.indexOf("date") >= 0
                || identity.indexOf("time") >= 0)
            return "clock"

        const text = normalizedText(widget)
        if (text.indexOf("weather") >= 0 || text.indexOf("forecast") >= 0)
            return "weather"
        if (text.indexOf("media") >= 0 || text.indexOf("music") >= 0
                || text.indexOf("player") >= 0 || text.indexOf("mpris") >= 0)
            return "media"
        if (text.indexOf("calendar") >= 0 || text.indexOf("agenda") >= 0)
            return "calendar"
        if (text.indexOf("clock") >= 0 || text.indexOf("date") >= 0
                || text.indexOf("time") >= 0)
            return "clock"
        return "system"
    }

    function categoryFor(widget) {
        const kind = previewKindFor(widget)
        return kind === "calendar" || kind === "generic" ? "clock" : kind
    }

    function isInCategory(widget, category) {
        if (category === "featured")
            return true
        if (category === "meo")
            return widget.host === "meo"
        if (category === "plasma")
            return widget.host === "plasma"
        return categoryFor(widget) === category
    }

    function filteredEntries() {
        const query = searchText.trim().toLocaleLowerCase()
        return catalog.filter(function(widget) {
            return isInCategory(widget, selectedCategory)
                    && (query === "" || normalizedText(widget).indexOf(query) >= 0)
        })
    }

    function categoryCount(category) {
        return catalog.filter(function(widget) {
            return isInCategory(widget, category)
        }).length
    }

    function categoryTitle() {
        for (let index = 0; index < categoryModel.length; ++index) {
            if (categoryModel[index].id === selectedCategory)
                return categoryModel[index].label
        }
        return qsTr("Widgets")
    }

    function sourceLabel(widget) {
        return widget.host === "meo" ? qsTr("Meo") : qsTr("Plasma compatibility")
    }

    function entryKey(widget) {
        if (!widget)
            return ""
        return (widget.host || "unknown") + ":" + (widget.pluginId || widget.id || widget.title || "")
    }

    function selectedEntryForKey() {
        for (let index = 0; index < catalog.length; ++index) {
            if (entryKey(catalog[index]) === selectedWidgetKey)
                return catalog[index]
        }
        return null
    }

    function isSelected(widget) {
        return selectedWidgetKey !== "" && entryKey(widget) === selectedWidgetKey
    }

    function selectWidget(widget) {
        selectedWidgetKey = entryKey(widget)
    }

    function isAvailable(widget) {
        return widget && widget.available !== false
    }

    function previewAspect(widget) {
        const width = Number(widget.defaultWidth || 0)
        const height = Number(widget.defaultHeight || 0)
        if (width > 0 && height > 0)
            return Math.max(0.75, Math.min(2.4, width / height))
        if (categoryFor(widget) === "media")
            return 2
        return 1.25
    }

    function previewHeightFor(width, widget) {
        return Math.max(108 * MeoTheme.globalScale,
                        Math.min(196 * MeoTheme.globalScale,
                                 width / previewAspect(widget)))
    }

    function previewCardWidthFor(availableWidth) {
        const gap = MeoTheme.space16
        const twoColumnMinimum = 196 * MeoTheme.globalScale
        if (availableWidth >= 2 * twoColumnMinimum + gap)
            return Math.min(280 * MeoTheme.globalScale, (availableWidth - gap) / 2)
        // A narrow sheet deliberately switches to one complete card. A Flow
        // child must never be wider than its viewport, otherwise its preview
        // content is silently clipped instead of becoming readable.
        return Math.max(1, Math.min(availableWidth, 360 * MeoTheme.globalScale))
    }

    function sizeLabelFor(widget) {
        const aspect = previewAspect(widget)
        if (aspect >= 1.7)
            return qsTr("Wide")
        if (aspect <= 0.9)
            return qsTr("Tall")
        return qsTr("Medium")
    }

    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: control.previewTime = new Date()
    }

    Keys.onEscapePressed: control.closeRequested()

    MeoShape {
        id: sheetSurface
        anchors.fill: parent
        type: "rect"
        radius: MeoTheme.dialogRadius
        color: MeoTheme.surfaceContainerLow
        strokeWidth: MeoTheme.strokeWidthThin
        strokeColor: MeoTheme.outlineVariant

        Behavior on radius {
            enabled: !MeoTheme.reduceMotion
            NumberAnimation {
                duration: MeoTheme.motionDurationShapeSettle
                easing.type: Easing.BezierSpline
                easing.bezierCurve: MeoTheme.motionEasingStandard
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: MeoTheme.space24
        spacing: MeoTheme.space16

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 48 * MeoTheme.globalScale

            MeoText {
                anchors.centerIn: parent
                text: qsTr("Add widgets")
                typeRole: "title"
                typeSize: "large"
                emphasized: true
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: MeoTheme.space4

                MeoIconButton {
                    visible: control.showRefreshAction
                    icon.name: "refresh"
                    type: "standard"
                    Accessible.name: qsTr("Refresh widget catalog")
                    onClicked: control.refreshRequested()
                }
                MeoIconButton {
                    visible: control.showCloseAction
                    icon.name: "close"
                    type: "standard"
                    Accessible.name: qsTr("Close Add Widgets")
                    onClicked: control.closeRequested()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: MeoTheme.space16

            ColumnLayout {
                Layout.preferredWidth: control.railWidth
                Layout.minimumWidth: 192 * MeoTheme.globalScale
                Layout.fillHeight: true
                spacing: MeoTheme.space12

                MeoTextField {
                    id: searchField
                    Layout.fillWidth: true
                    size: "s"
                    placeholder: qsTr("Search widgets")
                    leadingIcon: "search"
                    showClearButton: true
                    text: control.searchText
                    Accessible.name: qsTr("Search widgets")
                    onTextChanged: control.searchText = text
                }

                QQC2.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: MeoTheme.space4

                        Repeater {
                            model: control.categoryModel

                            delegate: QQC2.AbstractButton {
                                id: categoryButton
                                required property var modelData
                                width: parent.width
                                height: 48 * MeoTheme.globalScale
                                hoverEnabled: true
                                checkable: true
                                checked: control.selectedCategory === modelData.id
                                Accessible.name: modelData.label
                                Accessible.description: qsTr("%1 widgets").arg(control.categoryCount(modelData.id))
                                onClicked: control.selectedCategory = modelData.id

                                background: MeoShape {
                                    radius: height / 2
                                    type: "rect"
                                    color: categoryButton.checked
                                           ? MeoTheme.secondaryContainer
                                           : "transparent"

                                    MeoStateLayer {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        hovered: categoryButton.hovered
                                        pressed: categoryButton.down
                                        focused: categoryButton.visualFocus
                                        color: MeoTheme.contentOnSecondaryContainer
                                    }
                                }

                                contentItem: Item {
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: MeoTheme.space12
                                        anchors.rightMargin: MeoTheme.space12
                                        spacing: MeoTheme.space12

                                        MeoIcon {
                                            icon: categoryButton.modelData.icon
                                            size: 22
                                            color: categoryButton.checked
                                                   ? MeoTheme.contentOnSecondaryContainer
                                                   : MeoTheme.contentOnSurfaceVariant
                                        }
                                        MeoText {
                                            Layout.fillWidth: true
                                            text: categoryButton.modelData.label
                                            typeRole: "body"
                                            typeSize: "medium"
                                            emphasized: categoryButton.checked
                                            color: categoryButton.checked
                                                   ? MeoTheme.contentOnSecondaryContainer
                                                   : MeoTheme.contentOnSurface
                                            elide: Text.ElideRight
                                        }
                                        MeoText {
                                            text: control.categoryCount(categoryButton.modelData.id)
                                            typeRole: "label"
                                            typeSize: "small"
                                            visible: categoryButton.checked
                                            color: categoryButton.checked
                                                   ? MeoTheme.contentOnSecondaryContainer
                                                   : MeoTheme.contentOnSurfaceVariant
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                MeoText {
                    Layout.fillWidth: true
                    text: qsTr("Choose, then add")
                    typeRole: "label"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            MeoShape {
                Layout.preferredWidth: MeoTheme.strokeWidthThin
                Layout.fillHeight: true
                type: "rect"
                radius: width / 2
                color: MeoTheme.outlineVariant
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: MeoTheme.space8

                RowLayout {
                    Layout.fillWidth: true
                    MeoText {
                        Layout.fillWidth: true
                        text: control.searchText.trim() === ""
                              ? control.categoryTitle()
                              : qsTr("Search results")
                        typeRole: "title"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoText {
                        text: qsTr("%1 available").arg(control.matchingCount)
                        typeRole: "label"
                        typeSize: "medium"
                        color: MeoTheme.contentOnSurfaceVariant
                    }
                }

                MeoText {
                    Layout.fillWidth: true
                    visible: control.feedbackText !== ""
                    text: control.feedbackText
                    typeRole: "body"
                    typeSize: "small"
                    color: control.feedbackIsError ? MeoTheme.error : MeoTheme.primary
                    wrapMode: Text.WordWrap
                }

                // This compact selection surface carries compatibility and
                // placement information only after a user has chosen a card.
                // Keeping it out of every thumbnail lets the previews read as
                // actual widgets rather than a catalogue of technical badges.
                MeoShape {
                    id: selectedWidgetSurface
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? 76 * MeoTheme.globalScale : 0
                    visible: control.selectedEntry !== null
                    type: "rect"
                    radius: MeoTheme.shapeLarge
                    color: MeoTheme.surfaceContainer

                    Behavior on radius {
                        enabled: !MeoTheme.reduceMotion
                        NumberAnimation {
                            duration: MeoTheme.motionDurationShapeSettle
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: MeoTheme.motionEasingStandard
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: MeoTheme.space12
                        anchors.rightMargin: MeoTheme.space12
                        spacing: MeoTheme.space12

                        MeoShape {
                            Layout.preferredWidth: 40 * MeoTheme.globalScale
                            Layout.preferredHeight: width
                            type: "rect"
                            radius: width / 2
                            color: control.selectedEntry && control.selectedEntry.host === "meo"
                                   ? MeoTheme.secondaryContainer : MeoTheme.primaryContainer
                            MeoIcon {
                                anchors.centerIn: parent
                                icon: control.selectedEntry ? (control.selectedEntry.icon || "widgets") : "widgets"
                                size: 22
                                color: control.selectedEntry && control.selectedEntry.host === "meo"
                                       ? MeoTheme.contentOnSecondaryContainer
                                       : MeoTheme.contentOnPrimaryContainer
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: MeoTheme.space2
                            MeoText {
                                Layout.fillWidth: true
                                text: control.selectedEntry ? control.selectedEntry.title : ""
                                typeRole: "title"
                                typeSize: "small"
                                emphasized: true
                                elide: Text.ElideRight
                            }
                            MeoText {
                                Layout.fillWidth: true
                                text: control.selectedEntry
                                      ? qsTr("%1 · %2").arg(control.sourceLabel(control.selectedEntry))
                                                          .arg(control.sizeLabelFor(control.selectedEntry))
                                      : ""
                                typeRole: "label"
                                typeSize: "small"
                                color: MeoTheme.contentOnSurfaceVariant
                                elide: Text.ElideRight
                            }
                        }

                        MeoButton {
                            Layout.alignment: Qt.AlignVCenter
                            text: qsTr("Add widget")
                            icon.name: "add"
                            type: "filled"
                            size: "s"
                            enabled: control.isAvailable(control.selectedEntry)
                            Accessible.name: control.selectedEntry
                                             ? qsTr("Add %1 to desktop").arg(control.selectedEntry.title)
                                             : qsTr("Add selected widget to desktop")
                            onClicked: {
                                if (control.selectedEntry)
                                    control.widgetActivated(control.selectedEntry)
                            }
                        }

                        MeoIconButton {
                            id: selectedWidgetActions
                            Layout.alignment: Qt.AlignVCenter
                            icon.name: "more_vert"
                            type: "standard"
                            enabled: control.isAvailable(control.selectedEntry)
                            Accessible.name: control.selectedEntry
                                             ? qsTr("Actions for %1").arg(control.selectedEntry.title)
                                             : qsTr("Selected widget actions")
                            onClicked: {
                                if (control.selectedEntry)
                                    control.widgetContextRequested(control.selectedEntry, selectedWidgetActions)
                            }
                        }
                    }
                }

                QQC2.ScrollView {
                    id: previewScrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Flow {
                        id: previewFlow
                        // Do not bind a Flow to its Flickable content width:
                        // that forms a content-width feedback loop in
                        // ScrollView and can shrink cards until their preview
                        // is clipped. The control's viewport is authoritative.
                        width: previewScrollView.availableWidth
                        spacing: MeoTheme.space16

                        Repeater {
                            model: control.filteredCatalog

                            delegate: MeoCard {
                                id: previewCard
                                required property var modelData
                                readonly property real cardWidth: control.previewCardWidthFor(previewFlow.width)
                                width: cardWidth
                                height: previewStage.height + cardTitle.implicitHeight + MeoTheme.space16
                                type: "filled"
                                interactive: true
                                bouncy: true
                                selected: control.isSelected(modelData)
                                enabled: control.isAvailable(modelData)
                                Accessible.name: modelData.title
                                Accessible.description: qsTr("%1. %2. %3 placement preview. Select to see details.")
                                                        .arg(control.sourceLabel(modelData))
                                                        .arg(modelData.description || qsTr("Desktop widget"))
                                                        .arg(control.sizeLabelFor(modelData))
                                onClicked: control.selectWidget(modelData)

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: MeoTheme.space12
                                    spacing: MeoTheme.space8

                                    Item {
                                        id: previewStage
                                        width: parent.width
                                        height: control.previewHeightFor(width, previewCard.modelData)

                                        // This is a content preview, not a hidden instance of third-
                                        // party QML. A Plasma package starts only after an explicit
                                        // Add action enters the real containment lifecycle.
                                        MeoShape {
                                            id: previewCanvas
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, Math.max(96 * MeoTheme.globalScale,
                                                                                   parent.height * control.previewAspect(previewCard.modelData)))
                                            height: Math.min(parent.height, Math.max(96 * MeoTheme.globalScale,
                                                                                    parent.width / control.previewAspect(previewCard.modelData)))
                                            type: "rect"
                                            radius: Math.min(MeoTheme.cardRadius, height / 3)
                                            color: previewCard.modelData.host === "meo"
                                                   ? MeoTheme.secondaryContainer
                                                   : MeoTheme.surfaceContainerHighest
                                            strokeWidth: previewCard.modelData.host === "plasma"
                                                         ? MeoTheme.strokeWidthThin : 0
                                            strokeColor: MeoTheme.outlineVariant

                                            readonly property string previewKind: control.previewKindFor(previewCard.modelData)
                                            readonly property color previewContent: previewCard.modelData.host === "meo"
                                                                                  ? MeoTheme.contentOnSecondaryContainer
                                                                                  : MeoTheme.contentOnSurface
                                            readonly property color previewMuted: previewCard.modelData.host === "meo"
                                                                                ? MeoTheme.contentOnSecondaryContainer
                                                                                : MeoTheme.contentOnSurfaceVariant

                                            // Clock widgets show the current, non-sensitive local time.
                                            // The other templates intentionally use labelled sample data:
                                            // catalogue browsing must never reveal private media, location,
                                            // calendar, or system telemetry before a widget is added.
                                            Item {
                                                objectName: "widgetPreviewClock"
                                                anchors.fill: parent
                                                visible: previewCanvas.previewKind === "clock"

                                                MeoText {
                                                    anchors.top: parent.top
                                                    anchors.topMargin: MeoTheme.space12
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    width: parent.width - 2 * MeoTheme.space12
                                                    text: Qt.formatDate(control.previewTime, "ddd, MMM d")
                                                    typeRole: "label"
                                                    typeSize: "small"
                                                    color: previewCanvas.previewMuted
                                                    horizontalAlignment: Text.AlignHCenter
                                                    elide: Text.ElideRight
                                                }
                                                Text {
                                                    anchors.centerIn: parent
                                                    anchors.verticalCenterOffset: 6 * MeoTheme.globalScale
                                                    text: Qt.formatTime(control.previewTime, "HH:mm")
                                                    color: previewCanvas.previewContent
                                                    font.family: MeoTheme.typefaceBrand
                                                    font.pixelSize: Math.min(42 * MeoTheme.globalScale,
                                                                            parent.height * 0.40)
                                                    font.letterSpacing: -0.8 * MeoTheme.globalScale
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                                MeoShape {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    anchors.bottom: parent.bottom
                                                    anchors.bottomMargin: MeoTheme.space8
                                                    width: Math.min(parent.width - 2 * MeoTheme.space16,
                                                                    112 * MeoTheme.globalScale)
                                                    height: 22 * MeoTheme.globalScale
                                                    type: "rect"
                                                    radius: height / 2
                                                    color: previewCard.modelData.host === "meo"
                                                           ? MeoTheme.secondary
                                                           : MeoTheme.primaryContainer
                                                    MeoIcon {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.left: parent.left
                                                        anchors.leftMargin: MeoTheme.space8
                                                        icon: "partly_cloudy_day"
                                                        size: 14
                                                        color: previewCard.modelData.host === "meo"
                                                               ? MeoTheme.contentOnSecondary
                                                               : MeoTheme.contentOnPrimaryContainer
                                                    }
                                                    MeoText {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.right: parent.right
                                                        anchors.rightMargin: MeoTheme.space8
                                                        text: qsTr("Sample weather")
                                                        typeRole: "label"
                                                        typeSize: "small"
                                                        color: previewCard.modelData.host === "meo"
                                                               ? MeoTheme.contentOnSecondary
                                                               : MeoTheme.contentOnPrimaryContainer
                                                    }
                                                }
                                            }

                                            Item {
                                                objectName: "widgetPreviewCalendar"
                                                anchors.fill: parent
                                                visible: previewCanvas.previewKind === "calendar"

                                                Row {
                                                    id: calendarPreviewRow
                                                    anchors.fill: parent
                                                    anchors.margins: MeoTheme.space12
                                                    spacing: MeoTheme.space8

                                                    MeoShape {
                                                        id: calendarDateTile
                                                        width: Math.min(56 * MeoTheme.globalScale, parent.width * 0.30)
                                                        height: width
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        type: "rect"
                                                        radius: Math.min(MeoTheme.shapeLarge, width / 2)
                                                        color: previewCard.modelData.host === "meo"
                                                               ? MeoTheme.secondary
                                                               : MeoTheme.primaryContainer
                                                        Column {
                                                            anchors.centerIn: parent
                                                            spacing: 0
                                                            MeoText {
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                text: Qt.formatDate(control.previewTime, "MMM")
                                                                typeRole: "label"
                                                                typeSize: "small"
                                                                color: previewCard.modelData.host === "meo"
                                                                       ? MeoTheme.contentOnSecondary
                                                                       : MeoTheme.contentOnPrimaryContainer
                                                            }
                                                            Text {
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                text: Qt.formatDate(control.previewTime, "d")
                                                                color: previewCard.modelData.host === "meo"
                                                                       ? MeoTheme.contentOnSecondary
                                                                       : MeoTheme.contentOnPrimaryContainer
                                                                font.family: MeoTheme.typefaceBrand
                                                                font.pixelSize: 24 * MeoTheme.globalScale
                                                            }
                                                        }
                                                    }
                                                    Column {
                                                        id: calendarAgendaColumn
                                                        width: calendarPreviewRow.width - calendarDateTile.width
                                                               - calendarPreviewRow.spacing
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: MeoTheme.space8
                                                        MeoText {
                                                            width: parent.width
                                                            text: qsTr("Today")
                                                            typeRole: "title"
                                                            typeSize: "small"
                                                            emphasized: true
                                                            color: previewCanvas.previewContent
                                                        }
                                                        Repeater {
                                                            model: [qsTr("Focus time"), qsTr("Sample event")]
                                                            delegate: Row {
                                                                id: calendarAgendaItem
                                                                required property string modelData
                                                                required property int index
                                                                spacing: MeoTheme.space4
                                                                MeoShape {
                                                                    width: 6 * MeoTheme.globalScale
                                                                    height: width
                                                                    anchors.verticalCenter: parent.verticalCenter
                                                                    type: "rect"
                                                                    radius: width / 2
                                                                    color: calendarAgendaItem.index === 0
                                                                           ? MeoTheme.primary : MeoTheme.tertiary
                                                                }
                                                                MeoText {
                                                                    text: calendarAgendaItem.modelData
                                                                    typeRole: "label"
                                                                    typeSize: "small"
                                                                    color: previewCanvas.previewMuted
                                                                    elide: Text.ElideRight
                                                                    width: Math.max(36 * MeoTheme.globalScale,
                                                                                    calendarAgendaColumn.width
                                                                                    - 18 * MeoTheme.globalScale)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Item {
                                                objectName: "widgetPreviewWeather"
                                                anchors.fill: parent
                                                visible: previewCanvas.previewKind === "weather"

                                                Row {
                                                    anchors.fill: parent
                                                    anchors.margins: MeoTheme.space16
                                                    spacing: MeoTheme.space12
                                                    MeoIcon {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        icon: "partly_cloudy_day"
                                                        size: Math.min(42, 32 + previewCanvas.height / (20 * MeoTheme.globalScale))
                                                        color: previewCard.modelData.host === "meo"
                                                               ? MeoTheme.contentOnSecondaryContainer
                                                               : MeoTheme.primary
                                                    }
                                                    Column {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: MeoTheme.space2
                                                        Text {
                                                            text: qsTr("22°")
                                                            color: previewCanvas.previewContent
                                                            font.family: MeoTheme.typefaceBrand
                                                            font.pixelSize: Math.min(34 * MeoTheme.globalScale,
                                                                                    previewCanvas.height * 0.34)
                                                        }
                                                        MeoText {
                                                            text: qsTr("Partly cloudy")
                                                            typeRole: "label"
                                                            typeSize: "small"
                                                            color: previewCanvas.previewMuted
                                                        }
                                                        MeoText {
                                                            text: qsTr("Sample forecast")
                                                            typeRole: "label"
                                                            typeSize: "small"
                                                            color: previewCanvas.previewMuted
                                                        }
                                                    }
                                                }
                                            }

                                            Item {
                                                objectName: "widgetPreviewMedia"
                                                anchors.fill: parent
                                                visible: previewCanvas.previewKind === "media"

                                                Row {
                                                    id: mediaPreviewRow
                                                    anchors.fill: parent
                                                    anchors.margins: MeoTheme.space12
                                                    spacing: MeoTheme.space8
                                                    MeoShape {
                                                        id: mediaArtwork
                                                        width: Math.min(parent.height, 76 * MeoTheme.globalScale)
                                                        height: width
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        type: "rect"
                                                        radius: Math.min(MeoTheme.shapeLarge, width / 3)
                                                        color: MeoTheme.tertiaryContainer
                                                        MeoIcon {
                                                            anchors.centerIn: parent
                                                            icon: "music_note"
                                                            size: Math.max(22, parent.width / (2.6 * MeoTheme.globalScale))
                                                            color: MeoTheme.contentOnTertiaryContainer
                                                        }
                                                    }
                                                    Column {
                                                        id: mediaPreviewContent
                                                        width: Math.max(56 * MeoTheme.globalScale,
                                                                        mediaPreviewRow.width - mediaArtwork.width
                                                                        - mediaPreviewRow.spacing)
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: MeoTheme.space4
                                                        MeoText {
                                                            width: parent.width
                                                            text: qsTr("Preview track")
                                                            typeRole: "title"
                                                            typeSize: "small"
                                                            emphasized: true
                                                            color: previewCanvas.previewContent
                                                            elide: Text.ElideRight
                                                        }
                                                        MeoText {
                                                            width: parent.width
                                                            text: qsTr("Sample playlist")
                                                            typeRole: "label"
                                                            typeSize: "small"
                                                            color: previewCanvas.previewMuted
                                                            elide: Text.ElideRight
                                                        }
                                                        MeoShape {
                                                            width: parent.width
                                                            height: 4 * MeoTheme.globalScale
                                                            type: "rect"
                                                            radius: height / 2
                                                            color: MeoTheme.outlineVariant
                                                            MeoShape {
                                                                width: parent.width * 0.45
                                                                height: parent.height
                                                                type: "rect"
                                                                radius: height / 2
                                                                color: MeoTheme.primary
                                                            }
                                                        }
                                                        Row {
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            spacing: MeoTheme.space8
                                                            Repeater {
                                                                model: ["skip_previous", "play_arrow", "skip_next"]
                                                                delegate: MeoIcon {
                                                                    required property string modelData
                                                                    icon: modelData
                                                                    size: modelData === "play_arrow" ? 20 : 16
                                                                    color: previewCanvas.previewContent
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Item {
                                                objectName: "widgetPreviewSystem"
                                                anchors.fill: parent
                                                visible: previewCanvas.previewKind === "system"

                                                Column {
                                                    id: systemPreviewColumn
                                                    anchors.fill: parent
                                                    anchors.margins: MeoTheme.space12
                                                    spacing: MeoTheme.space8
                                                    Row {
                                                        spacing: MeoTheme.space4
                                                        MeoIcon {
                                                            icon: previewCard.modelData.icon || "monitoring"
                                                            size: 18
                                                            color: previewCard.modelData.host === "meo"
                                                                   ? MeoTheme.contentOnSecondaryContainer
                                                                   : MeoTheme.primary
                                                        }
                                                        MeoText {
                                                            text: qsTr("System overview")
                                                            typeRole: "title"
                                                            typeSize: "small"
                                                            emphasized: true
                                                            color: previewCanvas.previewContent
                                                        }
                                                    }
                                                    Repeater {
                                                        model: [
                                                            { "label": qsTr("CPU"), "value": "24%", "progress": 0.24, "color": MeoTheme.primary },
                                                            { "label": qsTr("Memory"), "value": "61%", "progress": 0.61, "color": MeoTheme.tertiary }
                                                        ]
                                                        delegate: Column {
                                                            id: systemMetric
                                                            required property var modelData
                                                            width: systemPreviewColumn.width
                                                            spacing: MeoTheme.space2
                                                            Row {
                                                                width: parent.width
                                                                MeoText {
                                                                    width: parent.width - valueText.implicitWidth
                                                                    text: systemMetric.modelData.label
                                                                    typeRole: "label"
                                                                    typeSize: "small"
                                                                    color: previewCanvas.previewMuted
                                                                }
                                                                MeoText {
                                                                    id: valueText
                                                                    text: systemMetric.modelData.value
                                                                    typeRole: "label"
                                                                    typeSize: "small"
                                                                    emphasized: true
                                                                    color: previewCanvas.previewContent
                                                                }
                                                            }
                                                            MeoShape {
                                                                width: parent.width
                                                                height: 6 * MeoTheme.globalScale
                                                                type: "rect"
                                                                radius: height / 2
                                                                color: MeoTheme.outlineVariant
                                                                MeoShape {
                                                                    width: parent.width * systemMetric.modelData.progress
                                                                    height: parent.height
                                                                    type: "rect"
                                                                    radius: height / 2
                                                                    color: systemMetric.modelData.color
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Item {
                                                objectName: "widgetPreviewGeneric"
                                                anchors.fill: parent
                                                visible: previewCanvas.previewKind === "generic"

                                                Column {
                                                    id: genericPreviewColumn
                                                    anchors.fill: parent
                                                    anchors.margins: MeoTheme.space12
                                                    spacing: MeoTheme.space8
                                                    Row {
                                                        spacing: MeoTheme.space8
                                                        MeoShape {
                                                            width: 30 * MeoTheme.globalScale
                                                            height: width
                                                            type: "rect"
                                                            radius: width / 2
                                                            color: MeoTheme.primaryContainer
                                                            MeoIcon {
                                                                anchors.centerIn: parent
                                                                icon: previewCard.modelData.icon || "widgets"
                                                                size: 18
                                                                color: MeoTheme.contentOnPrimaryContainer
                                                            }
                                                        }
                                                        Column {
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            MeoText {
                                                                text: previewCard.modelData.title
                                                                typeRole: "title"
                                                                typeSize: "small"
                                                                emphasized: true
                                                                color: previewCanvas.previewContent
                                                                elide: Text.ElideRight
                                                                width: Math.max(72 * MeoTheme.globalScale,
                                                                                previewCanvas.width - 76 * MeoTheme.globalScale)
                                                            }
                                                            MeoText {
                                                                text: qsTr("Preview content")
                                                                typeRole: "label"
                                                                typeSize: "small"
                                                                color: previewCanvas.previewMuted
                                                            }
                                                        }
                                                    }
                                                    Row {
                                                        id: genericBarsRow
                                                        width: parent.width
                                                        spacing: MeoTheme.space8
                                                        Repeater {
                                                            model: [0.66, 0.42, 0.82]
                                                            delegate: MeoShape {
                                                                id: genericBar
                                                                required property real modelData
                                                                required property int index
                                                                width: (genericBarsRow.width
                                                                        - 2 * genericBarsRow.spacing) / 3
                                                                height: Math.max(20 * MeoTheme.globalScale,
                                                                                 genericPreviewColumn.height
                                                                                 - 60 * MeoTheme.globalScale)
                                                                type: "rect"
                                                                radius: Math.min(MeoTheme.shapeMedium, height / 2)
                                                                color: genericBar.index === 1 ? MeoTheme.tertiaryContainer
                                                                                   : MeoTheme.surfaceContainerHighest
                                                                MeoShape {
                                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                                    anchors.bottom: parent.bottom
                                                                    anchors.bottomMargin: MeoTheme.space4
                                                                    width: parent.width - 2 * MeoTheme.space4
                                                                    height: Math.max(4 * MeoTheme.globalScale,
                                                                                     (parent.height - 2 * MeoTheme.space12)
                                                                                     * genericBar.modelData)
                                                                    type: "rect"
                                                                    radius: height / 2
                                                                    color: genericBar.index === 1 ? MeoTheme.tertiary
                                                                                       : MeoTheme.primary
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    RowLayout {
                                        id: cardTitle
                                        width: parent.width
                                        spacing: MeoTheme.space8

                                        MeoText {
                                            Layout.fillWidth: true
                                            text: previewCard.modelData.title
                                            typeRole: "title"
                                            typeSize: "small"
                                            emphasized: true
                                            elide: Text.ElideRight
                                        }
                                        MeoIcon {
                                            visible: previewCard.selected
                                            icon: "check_circle"
                                            size: 20
                                            color: MeoTheme.primary
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                MeoEmptyState {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: control.matchingCount === 0
                    icon: "search_off"
                    title: qsTr("No matching widgets")
                    description: qsTr("Try another search or category.")
                }
            }
        }
    }
}
