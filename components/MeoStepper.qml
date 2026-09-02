import QtQuick
import QtQuick.Controls
import MeoUI

// A compact progress stepper for multi-step flows. It deliberately stays a
// display component by default; set interactive to opt into changing the
// current step from pointer or keyboard input.
Control {
    id: control

    property var model: [] // ["Account", { label: "Profile" }, ...]
    property int currentIndex: 0
    property string orientation: "horizontal" // "horizontal" | "vertical"
    property bool interactive: false
    signal stepActivated(int index)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property int stepCount: {
        if (!model)
            return 0
        if (typeof model.count === "number")
            return model.count
        return typeof model.length === "number" ? model.length : 0
    }
    readonly property bool vertical: orientation === "vertical"
    readonly property int activeStep: currentIndex >= 0 && currentIndex < stepCount
                                  ? currentIndex : -1

    implicitWidth: vertical ? 240 * themeGlobalScale
                            : Math.max(320 * themeGlobalScale, stepCount * 112 * themeGlobalScale)
    implicitHeight: vertical ? Math.max(192 * themeGlobalScale, stepCount * 64 * themeGlobalScale)
                             : 72 * themeGlobalScale
    Accessible.role: Accessible.List
    Accessible.name: qsTr("Progress steps")
    Accessible.description: activeStep >= 0
                            ? qsTr("Step %1 of %2: %3").arg(activeStep + 1)
                                                       .arg(stepCount)
                                                       .arg(stepLabel(activeStep))
                            : qsTr("%1 steps").arg(stepCount)

    function entryAt(index) {
        if (!model || index < 0 || index >= stepCount)
            return null
        return typeof model.get === "function" ? model.get(index) : model[index]
    }

    function stepLabel(index) {
        const entry = entryAt(index)
        if (entry === null || typeof entry === "undefined")
            return ""
        if (typeof entry === "string" || typeof entry === "number")
            return String(entry)
        return entry.label || entry.title || ""
    }

    function stepIsComplete(index) {
        return currentIndex >= stepCount || index < activeStep
    }

    function activateStep(index) {
        if (!interactive || !enabled || index < 0 || index >= stepCount)
            return
        if (currentIndex !== index)
            currentIndex = index
        stepActivated(index)
    }

    contentItem: Item {
        id: container

        Row {
            visible: !control.vertical
            anchors.fill: parent

            Repeater {
                model: control.stepCount

                delegate: Item {
                    id: horizontalStep
                    required property int index
                    width: container.width / Math.max(1, control.stepCount)
                    height: container.height
                    readonly property bool completed: control.stepIsComplete(index)
                    readonly property bool active: control.activeStep === index
                    readonly property bool canActivate: control.interactive && control.enabled

                    Rectangle {
                        visible: index < control.stepCount - 1
                        x: parent.width / 2
                        y: touchTarget.y + touchTarget.height / 2 - height / 2
                        width: parent.width
                        height: Math.max(1, control.themeGlobalScale)
                        color: horizontalStep.completed ? MeoTheme.primary : MeoTheme.outlineVariant
                    }

                    Item {
                        id: touchTarget
                        width: 48 * control.themeGlobalScale
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 2 * control.themeGlobalScale
                        activeFocusOnTab: horizontalStep.canActivate
                        Accessible.role: control.interactive ? Accessible.Button : Accessible.StaticText
                        Accessible.name: control.stepLabel(index)
                        Accessible.description: horizontalStep.completed ? qsTr("Completed")
                                                             : horizontalStep.active ? qsTr("Current step")
                                                                                     : qsTr("Upcoming step")

                        function activate() { control.activateStep(index) }
                        Keys.onReturnPressed: activate()
                        Keys.onSpacePressed: activate()

                        HoverHandler { id: horizontalHover; enabled: horizontalStep.canActivate }
                        TapHandler { id: horizontalTap; enabled: horizontalStep.canActivate; onTapped: touchTarget.activate() }

                        MeoStateLayer {
                            anchors.fill: parent
                            radius: width / 2
                            color: MeoTheme.primary
                            hovered: horizontalHover.hovered
                            focused: touchTarget.activeFocus
                            pressed: horizontalTap.pressed
                        }

                        Rectangle {
                            width: 24 * control.themeGlobalScale
                            height: width
                            radius: width / 2
                            anchors.centerIn: parent
                            color: horizontalStep.completed || horizontalStep.active
                                   ? MeoTheme.primary : MeoTheme.surface
                            border.width: Math.max(1, control.themeGlobalScale)
                            border.color: horizontalStep.completed || horizontalStep.active
                                          ? MeoTheme.primary : MeoTheme.outline

                            MeoIcon {
                                anchors.centerIn: parent
                                visible: horizontalStep.completed
                                icon: "check"
                                size: 16 * control.themeGlobalScale
                                color: MeoTheme.contentOnPrimary
                            }

                            MeoText {
                                anchors.centerIn: parent
                                visible: !horizontalStep.completed
                                text: String(index + 1)
                                typeRole: "label"
                                typeSize: "small"
                                emphasized: horizontalStep.active
                                color: horizontalStep.active ? MeoTheme.contentOnPrimary
                                                              : MeoTheme.contentOnSurfaceVariant
                            }
                        }
                    }

                    MeoText {
                        anchors.top: touchTarget.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.max(0, parent.width - 8 * control.themeGlobalScale)
                        text: control.stepLabel(index)
                        typeRole: "label"
                        typeSize: "small"
                        emphasized: horizontalStep.active
                        color: horizontalStep.active ? MeoTheme.primary
                                                     : MeoTheme.contentOnSurfaceVariant
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Column {
            visible: control.vertical
            anchors.fill: parent

            Repeater {
                model: control.stepCount

                delegate: Item {
                    id: verticalStep
                    required property int index
                    width: container.width
                    height: container.height / Math.max(1, control.stepCount)
                    readonly property bool completed: control.stepIsComplete(index)
                    readonly property bool active: control.activeStep === index
                    readonly property bool canActivate: control.interactive && control.enabled

                    Rectangle {
                        visible: index < control.stepCount - 1
                        x: touchTarget.x + touchTarget.width / 2 - width / 2
                        y: touchTarget.y + touchTarget.height / 2
                        width: Math.max(1, control.themeGlobalScale)
                        height: parent.height
                        color: verticalStep.completed ? MeoTheme.primary : MeoTheme.outlineVariant
                    }

                    Item {
                        id: touchTarget
                        width: 48 * control.themeGlobalScale
                        height: width
                        anchors.left: parent.left
                        anchors.leftMargin: 4 * control.themeGlobalScale
                        anchors.verticalCenter: parent.verticalCenter
                        activeFocusOnTab: verticalStep.canActivate
                        Accessible.role: control.interactive ? Accessible.Button : Accessible.StaticText
                        Accessible.name: control.stepLabel(index)
                        Accessible.description: verticalStep.completed ? qsTr("Completed")
                                                           : verticalStep.active ? qsTr("Current step")
                                                                                 : qsTr("Upcoming step")

                        function activate() { control.activateStep(index) }
                        Keys.onReturnPressed: activate()
                        Keys.onSpacePressed: activate()

                        HoverHandler { id: verticalHover; enabled: verticalStep.canActivate }
                        TapHandler { id: verticalTap; enabled: verticalStep.canActivate; onTapped: touchTarget.activate() }

                        MeoStateLayer {
                            anchors.fill: parent
                            radius: width / 2
                            color: MeoTheme.primary
                            hovered: verticalHover.hovered
                            focused: touchTarget.activeFocus
                            pressed: verticalTap.pressed
                        }

                        Rectangle {
                            width: 24 * control.themeGlobalScale
                            height: width
                            radius: width / 2
                            anchors.centerIn: parent
                            color: verticalStep.completed || verticalStep.active
                                   ? MeoTheme.primary : MeoTheme.surface
                            border.width: Math.max(1, control.themeGlobalScale)
                            border.color: verticalStep.completed || verticalStep.active
                                          ? MeoTheme.primary : MeoTheme.outline

                            MeoIcon {
                                anchors.centerIn: parent
                                visible: verticalStep.completed
                                icon: "check"
                                size: 16 * control.themeGlobalScale
                                color: MeoTheme.contentOnPrimary
                            }

                            MeoText {
                                anchors.centerIn: parent
                                visible: !verticalStep.completed
                                text: String(index + 1)
                                typeRole: "label"
                                typeSize: "small"
                                emphasized: verticalStep.active
                                color: verticalStep.active ? MeoTheme.contentOnPrimary
                                                            : MeoTheme.contentOnSurfaceVariant
                            }
                        }
                    }

                    MeoText {
                        anchors.left: touchTarget.right
                        anchors.leftMargin: 8 * control.themeGlobalScale
                        anchors.right: parent.right
                        anchors.rightMargin: 8 * control.themeGlobalScale
                        anchors.verticalCenter: parent.verticalCenter
                        text: control.stepLabel(index)
                        typeRole: "body"
                        typeSize: "medium"
                        emphasized: verticalStep.active
                        color: verticalStep.active ? MeoTheme.primary
                                                   : MeoTheme.contentOnSurfaceVariant
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    opacity: enabled ? 1.0 : MeoTheme.disabledContentOpacity
    Behavior on opacity {
        enabled: !MeoTheme.reduceMotion
        NumberAnimation { duration: MeoTheme.motionDurationState }
    }
}
