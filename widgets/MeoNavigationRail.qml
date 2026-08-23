import QtQuick
import MeoUI

Rectangle {
    id: control

    // [{ id, icon, label, badgeText, badgeCount, badgeDot }]
    // A { type: "header", label } entry creates an optional destination group.
    property var model: []
    property int currentIndex: 0
    property string currentId: ""
    property bool isExpanded: false
    property Component header: null
    property Component footer: null
    property string labelType: "always" // "always" | "selected" | "none"
    property string shape: "pill"
    // During a live window drag, layout must follow the pointer rather than
    // queueing a rail-width animation behind every resize event.
    property bool resizeInstantly: false

    signal clicked(int index)
    signal activated(var item, int index)

    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLow !== "undefined") ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outlineVariant !== "undefined") ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSecondaryContainer !== "undefined") ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.secondaryContainer !== "undefined") ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property var fontLabelLarge: (typeof MeoTheme !== "undefined" && typeof MeoTheme.labelLarge !== "undefined") ? MeoTheme.labelLarge : ({ "size": 14, "weight": Font.Medium })

    width: (isExpanded ? 240 : 80) * themeGlobalScale
    height: parent ? parent.height : 600 * themeGlobalScale
    color: themeSurfaceContainerLow
    clip: true

    function destinationAt(index) {
        if (!model || index < 0 || index >= model.length)
            return null
        return typeof model.get === "function" ? model.get(index) : model[index]
    }

    function syncCurrentId() {
        const item = destinationAt(currentIndex)
        if (!item || item.type === "header" || item.id === undefined || item.id === null)
            return
        currentId = String(item.id)
    }

    function activateDestination(index, item) {
        if (!item || item.type === "header")
            return
        currentIndex = index
        if (item.id !== undefined && item.id !== null)
            currentId = String(item.id)
        clicked(index)
        activated(item, index)
    }

    onCurrentIndexChanged: syncCurrentId()
    onModelChanged: syncCurrentId()
    onCurrentIdChanged: {
        if (currentId === "")
            return
        for (let i = 0; i < model.length; ++i) {
            const item = destinationAt(i)
            if (item && item.type !== "header" && item.id !== undefined && String(item.id) === currentId) {
                if (currentIndex !== i)
                    currentIndex = i
                return
            }
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: control.resizeInstantly || MeoTheme.reduceMotion
                      ? 0
                      : ((typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSelection !== "undefined") ? MeoTheme.motionDurationSelection : 220)
            easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
        }
    }

    // The expanded state is a docked navigation pane, rather than a widened
    // 80 dp rail. The divider keeps the page and navigation surfaces legible.
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: Math.max(1, control.themeGlobalScale)
        color: control.themeOutlineVariant
        opacity: 0.56
    }

    Loader {
        id: headerLoader
        anchors.top: parent.top
        anchors.topMargin: (control.isExpanded ? 16 : 24) * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        sourceComponent: control.header
        active: control.header !== null
        visible: active
        height: visible ? implicitHeight : 0
    }

    Flickable {
        id: destinationFlickable
        anchors.top: headerLoader.bottom
        anchors.topMargin: (headerLoader.visible ? 8 : (control.isExpanded ? 16 : 24)) * control.themeGlobalScale
        anchors.bottom: footerLoader.visible ? footerLoader.top : parent.bottom
        anchors.bottomMargin: (footerLoader.visible ? 8 : (control.isExpanded ? 16 : 24)) * control.themeGlobalScale
        anchors.left: parent.left
        anchors.right: parent.right
        contentWidth: width
        contentHeight: destinations.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        clip: true

        Column {
            id: destinations
            width: destinationFlickable.width
            spacing: (control.isExpanded ? 4 : 12) * control.themeGlobalScale

            Repeater {
                model: control.model

                delegate: Loader {
                    id: rowLoader
                    required property int index
                    required property var modelData
                    property int navigationIndex: index
                    property var navigationItem: modelData

                    width: destinations.width
                    sourceComponent: navigationItem && navigationItem.type === "header" ? groupHeader : destinationItem
                    height: item ? item.implicitHeight : 0

                    Component {
                        id: groupHeader

                        Item {
                            implicitWidth: rowLoader.width
                            implicitHeight: (control.isExpanded ? 36 : 12) * control.themeGlobalScale

                            MeoListHeader {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 28 * control.themeGlobalScale
                                anchors.rightMargin: 16 * control.themeGlobalScale
                                text: rowLoader.navigationItem.label || ""
                                topPadding: 0
                                bottomPadding: 0
                                visible: control.isExpanded
                            }
                        }
                    }

                    Component {
                        id: destinationItem

                        Item {
                            id: destination
                            readonly property var navigationItem: rowLoader.navigationItem || ({})
                            readonly property int navigationIndex: rowLoader.navigationIndex
                            readonly property bool isSelected: control.currentIndex === navigationIndex
                            readonly property string badgeText: navigationItem.badgeText !== undefined
                                                               ? String(navigationItem.badgeText)
                                                               : (navigationItem.badgeCount !== undefined ? String(navigationItem.badgeCount) : "")

                            implicitWidth: rowLoader.width
                            implicitHeight: (control.isExpanded ? 52 : 64) * control.themeGlobalScale
                            activeFocusOnTab: true
                            Accessible.role: Accessible.PageTab
                            Accessible.name: navigationItem.label || ""
                            Accessible.selected: isSelected
                            Accessible.focusable: true
                            Accessible.onPressAction: activate()

                            function activate() {
                                control.activateDestination(navigationIndex, navigationItem)
                            }

                            Item {
                                id: wrapper
                                anchors.fill: parent
                                anchors.leftMargin: (control.isExpanded ? 12 : 0) * control.themeGlobalScale
                                anchors.rightMargin: (control.isExpanded ? 12 : 0) * control.themeGlobalScale

                                // Expanded destinations receive a complete, 48 dp
                                // selection surface; compact rails retain their
                                // compact icon indicator.
                                MeoShape {
                                    id: expandedIndicator
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 48 * control.themeGlobalScale
                                    radius: height / 2
                                    type: control.shape
                                    color: destination.isSelected ? control.themeSecondaryContainer : "transparent"
                                    visible: control.isExpanded

                                    MeoStateLayer {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        hovered: mouseArea.containsMouse
                                        pressed: mouseArea.pressed
                                        focused: destination.activeFocus
                                        pressX: expandedIndicator.mapFromItem(mouseArea, mouseArea.mouseX, mouseArea.mouseY).x
                                        pressY: expandedIndicator.mapFromItem(mouseArea, mouseArea.mouseX, mouseArea.mouseY).y
                                        color: destination.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: MeoTheme.motionDurationState
                                            easing.bezierCurve: destination.isSelected ? MeoTheme.motionEasingEnter : MeoTheme.motionEasingExit
                                        }
                                    }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 3 * control.themeGlobalScale
                                    visible: !control.isExpanded

                                    Item {
                                        width: 56 * control.themeGlobalScale
                                        height: 32 * control.themeGlobalScale
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        MeoShape {
                                            id: collapsedIndicator
                                            width: destination.isSelected ? parent.width : 32 * control.themeGlobalScale
                                            height: parent.height
                                            anchors.centerIn: parent
                                            radius: height / 2
                                            type: control.shape
                                            color: destination.isSelected ? control.themeSecondaryContainer : "transparent"

                                            MeoStateLayer {
                                                anchors.fill: parent
                                                radius: parent.radius
                                                hovered: mouseArea.containsMouse
                                                pressed: mouseArea.pressed
                                                focused: destination.activeFocus
                                                pressX: collapsedIndicator.mapFromItem(mouseArea, mouseArea.mouseX, mouseArea.mouseY).x
                                                pressY: collapsedIndicator.mapFromItem(mouseArea, mouseArea.mouseX, mouseArea.mouseY).y
                                                color: destination.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                            }

                                            Behavior on width {
                                                NumberAnimation {
                                                    duration: MeoTheme.motionDurationSelection
                                                    easing.bezierCurve: MeoTheme.motionEasingEnter
                                                }
                                            }
                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: MeoTheme.motionDurationState
                                                    easing.bezierCurve: destination.isSelected ? MeoTheme.motionEasingEnter : MeoTheme.motionEasingExit
                                                }
                                            }
                                        }

                                        MeoIcon {
                                            anchors.centerIn: parent
                                            icon: destination.navigationItem.icon || ""
                                            fill: destination.isSelected
                                            size: 24
                                            color: destination.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                        }

                                        MeoBadge {
                                            text: destination.badgeText
                                            isDot: destination.navigationItem.badgeDot || false
                                            visible: text !== "" || isDot
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.horizontalCenterOffset: 12 * control.themeGlobalScale
                                            anchors.verticalCenterOffset: -12 * control.themeGlobalScale
                                        }
                                    }

                                    Text {
                                        text: destination.navigationItem.label || ""
                                        width: parent.width
                                        font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                                        font.pixelSize: 12 * control.themeGlobalScale
                                        font.weight: Font.Medium
                                        color: destination.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                        visible: control.labelType === "always" || (control.labelType === "selected" && destination.isSelected)
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 20 * control.themeGlobalScale
                                    anchors.rightMargin: 16 * control.themeGlobalScale
                                    spacing: 12 * control.themeGlobalScale
                                    visible: control.isExpanded

                                    Item {
                                        width: 24 * control.themeGlobalScale
                                        height: 24 * control.themeGlobalScale
                                        anchors.verticalCenter: parent.verticalCenter

                                        MeoIcon {
                                            anchors.centerIn: parent
                                            icon: destination.navigationItem.icon || ""
                                            fill: destination.isSelected
                                            size: 24
                                            color: destination.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                        }

                                        MeoBadge {
                                            text: destination.badgeText
                                            isDot: destination.navigationItem.badgeDot || false
                                            visible: text !== "" || isDot
                                            anchors.horizontalCenter: parent.right
                                            anchors.verticalCenter: parent.top
                                            anchors.horizontalCenterOffset: -2 * control.themeGlobalScale
                                            anchors.verticalCenterOffset: 2 * control.themeGlobalScale
                                        }
                                    }

                                    Text {
                                        text: destination.navigationItem.label || ""
                                        width: Math.max(0, parent.width - 24 * control.themeGlobalScale - 12 * control.themeGlobalScale)
                                        font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                                        font.pixelSize: control.fontLabelLarge.size * control.themeGlobalScale
                                        font.weight: destination.isSelected ? Font.DemiBold : control.fontLabelLarge.weight
                                        color: destination.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                        anchors.verticalCenter: parent.verticalCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    destination.forceActiveFocus(Qt.MouseFocusReason)
                                    destination.activate()
                                }
                            }
                            Keys.onReturnPressed: activate()
                            Keys.onEnterPressed: activate()
                            Keys.onSpacePressed: activate()
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: footerLoader
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (control.isExpanded ? 16 : 24) * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        sourceComponent: control.footer
        active: control.footer !== null
        visible: active
        height: visible ? implicitHeight : 0
    }
}
