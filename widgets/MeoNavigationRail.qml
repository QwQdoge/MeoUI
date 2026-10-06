import QtQuick
import MeoUI

Rectangle {
    id: control

    // [{ id, icon, label, badgeText, badgeCount, badgeDot }]
    // A { type: "header", label } entry creates an optional destination group.
    property var model: []
    property int currentIndex: 0
    property string currentId: ""
    property Component header: null
    property Component footer: null
    // Retained for source compatibility. Expressive navigation rails always
    // use the specified pill-shaped active indicator.
    property string shape: "pill"
    // During a live window drag, layout must follow the pointer rather than
    // queueing a rail-width animation behind every resize event.
    property bool resizeInstantly: false

    signal clicked(int index)
    signal activated(var item, int index)

    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    // M3 Expressive distinguishes the vertical collapsed label from the
    // horizontal expanded label: an active vertical label uses secondary.
    readonly property color themeSecondary: MeoTheme.secondary
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontLabelLarge: MeoTheme.labelLarge
    readonly property int destinationCount: {
        if (!model)
            return 0
        if (typeof model.count === "number")
            return model.count
        return typeof model.length === "number" ? model.length : 0
    }

    readonly property real collapsedWidth: 96 * themeGlobalScale
    width: collapsedWidth
    height: parent ? parent.height : 600 * themeGlobalScale
    visible: true
    color: themeSurfaceContainer
    clip: true

    function destinationAt(index) {
        if (!model || index < 0 || index >= destinationCount)
            return null
        return typeof model.get === "function" ? model.get(index) : model[index]
    }

    function destinationEnabled(item) {
        return !!item && item.type !== "header" && item.enabled !== false
    }

    function syncCurrentId() {
        const item = destinationAt(currentIndex)
        if (!item || item.type === "header" || item.id === undefined || item.id === null)
            return
        currentId = String(item.id)
    }

    function activateDestination(index, item) {
        if (!destinationEnabled(item))
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
        for (let i = 0; i < destinationCount; ++i) {
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
                      : MeoTheme.motionDurationSelection
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
    }

    // Separate compact icon shortcuts from their detail content.
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
        anchors.topMargin: 24 * control.themeGlobalScale
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
        anchors.topMargin: (headerLoader.visible ? 8 : 24) * control.themeGlobalScale
        anchors.bottom: footerLoader.visible ? footerLoader.top : parent.bottom
        anchors.bottomMargin: (footerLoader.visible ? 8 : 24) * control.themeGlobalScale
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
            // AndroidX's vertical-rail token sets a 4dp item rhythm.
            spacing: 4 * control.themeGlobalScale

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
                            implicitHeight: 12 * control.themeGlobalScale


                        }
                    }

                    Component {
                        id: destinationItem

                        Item {
                            id: destination
                            objectName: "meoNavigationRailDestination_" + rowLoader.navigationIndex
                            readonly property var navigationItem: rowLoader.navigationItem || ({})
                            readonly property int navigationIndex: rowLoader.navigationIndex
                            readonly property bool isSelected: control.currentIndex === navigationIndex
                            readonly property bool isDestinationEnabled: control.destinationEnabled(navigationItem)
                            readonly property string badgeText: navigationItem.badgeText !== undefined
                                                               ? String(navigationItem.badgeText)
                                                               : (navigationItem.badgeCount !== undefined ? String(navigationItem.badgeCount) : "")

                            implicitWidth: rowLoader.width
                            // The target area always spans the full rail width.
                            // The selected container itself is a 56dp pill in
                            // compact icon configuration.
                            implicitHeight: 56 * control.themeGlobalScale
                            activeFocusOnTab: isDestinationEnabled
                            opacity: isDestinationEnabled ? 1.0 : 0.38
                            Accessible.role: Accessible.PageTab
                            Accessible.name: navigationItem.label || ""
                            Accessible.selected: isSelected
                            Accessible.focusable: isDestinationEnabled
                            Accessible.onPressAction: activate()

                            function activate() {
                                if (!isDestinationEnabled)
                                    return
                                control.activateDestination(navigationIndex, navigationItem)
                            }

                            Item {
                                id: wrapper
                                anchors.fill: parent
                                anchors.leftMargin: 0 * control.themeGlobalScale
                                anchors.rightMargin: 0 * control.themeGlobalScale

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4 * control.themeGlobalScale

                                    Item {
                                        width: 56 * control.themeGlobalScale
                                        height: 32 * control.themeGlobalScale
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        Rectangle {
                                            id: collapsedIndicator
                                            objectName: "meoNavigationRailCollapsedIndicator_" + destination.navigationIndex
                                            width: destination.isSelected ? parent.width : 32 * control.themeGlobalScale
                                            height: parent.height
                                            anchors.centerIn: parent
                                            radius: height / 2
                                            color: destination.isSelected ? control.themeSecondaryContainer : "transparent"

                                            Behavior on width {
                                                NumberAnimation {
                                                    duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSelection
                                                    easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEnter
                                                }
                                            }
                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState
                                                    easing.type: Easing.BezierSpline; easing.bezierCurve: destination.isSelected ? MeoTheme.motionEasingEnter : MeoTheme.motionEasingExit
                                                }
                                            }
                                        }

                                        // AndroidX sizes the interaction/ripple surface
                                        // to the 56dp indicator even while the inactive
                                        // visual indicator itself contracts.
                                        MeoStateLayer {
                                            id: collapsedStateLayer
                                            objectName: "meoNavigationRailCollapsedStateLayer_" + destination.navigationIndex
                                            width: parent.width
                                            height: parent.height
                                            anchors.centerIn: parent
                                            radius: height / 2
                                            hovered: mouseArea.containsMouse
                                            pressed: mouseArea.pressed
                                            focused: destination.activeFocus
                                            pressX: mapFromItem(mouseArea, mouseArea.mouseX, mouseArea.mouseY).x
                                            pressY: mapFromItem(mouseArea, mouseArea.mouseX, mouseArea.mouseY).y
                                            color: control.themeOnSecondaryContainer
                                            enabled: destination.isDestinationEnabled
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


                                }


                            }

                            MeoTooltip {
                                text: destination.navigationItem.label || ""
                                visible: mouseArea.containsMouse && !mouseArea.pressed
                                delay: 500
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: destination.isDestinationEnabled
                                cursorShape: destination.isDestinationEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    destination.forceActiveFocus(Qt.MouseFocusReason)
                                    destination.activate()
                                }
                            }
                            Keys.onPressed: function(event) {
                                if (!event.isAutoRepeat
                                        && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                            || event.key === Qt.Key_Space)) {
                                    collapsedStateLayer.triggerFromKeyboard()
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
        anchors.bottomMargin: 24 * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        sourceComponent: control.footer
        active: control.footer !== null
        visible: active
        height: visible ? implicitHeight : 0
    }
}
