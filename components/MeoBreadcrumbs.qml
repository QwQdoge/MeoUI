import QtQuick 2.15
import QtQuick.Controls 2.15
import MeoUI
pragma ComponentBehavior: Bound
Control {
    id: control

    // 🌟 核心属性
    property var model: [] // Array of { label: "", value: any, icon: "" }
    property string separator: "chevron_right"
    // -1 maintains the normal breadcrumb convention: the final item is the
    // current, non-interactive page. Hosts can point at an earlier item while
    // building a path progressively.
    property int currentIndex: -1
    spacing: 4 * themeGlobalScale

    signal clicked(int index, var data)

    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontLabelLarge: MeoTheme.labelLarge

    implicitHeight: 48 * themeGlobalScale
    implicitWidth: contentRow.implicitWidth + leftPadding + rightPadding

    padding: 8 * themeGlobalScale

    function resolvedCurrentIndex() {
        return currentIndex >= 0 && currentIndex < model.length ? currentIndex : model.length - 1
    }

    function crumbEnabled(item) {
        return !item || item.enabled === undefined || item.enabled
    }

    contentItem: Row {
        id: contentRow
        spacing: control.spacing
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: control.model
            delegate: Row {
                id: crumbDelegate
                required property int index
                required property var modelData
                spacing: control.spacing
                anchors.verticalCenter: parent.verticalCenter

                readonly property bool isCurrent: index === control.resolvedCurrentIndex()
                readonly property bool isEnabled: control.crumbEnabled(modelData)

                // Breadcrumb Item
                Item {
                    id: crumbTarget
                    width: breadcrumbRow.implicitWidth + 16 * control.themeGlobalScale
                    height: 32 * control.themeGlobalScale
                    anchors.verticalCenter: parent.verticalCenter
                    activeFocusOnTab: crumbDelegate.isEnabled && !crumbDelegate.isCurrent
                    opacity: crumbDelegate.isEnabled ? 1.0 : MeoTheme.disabledContentOpacity
                    objectName: "meoBreadcrumb_" + index

                    Accessible.role: crumbDelegate.isCurrent ? Accessible.StaticText : Accessible.Link
                    Accessible.name: modelData.label || ""
                    Accessible.focusable: activeFocusOnTab

                    MeoStateLayer {
                        anchors.fill: parent
                        radius: 8 * control.themeGlobalScale
                        hovered: mouseArea.containsMouse
                        pressed: mouseArea.pressed
                        focused: crumbTarget.activeFocus
                        pressX: mouseArea.mouseX
                        pressY: mouseArea.mouseY
                        color: control.themePrimary
                    }

                    Row {
                        id: breadcrumbRow
                        anchors.centerIn: parent
                        spacing: 4 * control.themeGlobalScale

                        MeoIcon {
                            icon: modelData.icon || ""
                            visible: icon !== ""
                            size: 18 * control.themeGlobalScale
                            color: crumbDelegate.isCurrent ? control.themeOnSurface
                                                            : crumbDelegate.isEnabled ? control.themePrimary
                                                                                     : control.themeOnSurfaceVariant
                        }

                        Text {
                            text: modelData.label
                            textFormat: Text.PlainText
                            font.family: MeoTheme.typefacePlain
                            font.pixelSize: control.fontLabelLarge.size * control.themeGlobalScale
                            font.weight: crumbDelegate.isCurrent ? Font.Bold : control.fontLabelLarge.weight
                            color: crumbDelegate.isCurrent ? control.themeOnSurface
                                                            : crumbDelegate.isEnabled ? control.themePrimary
                                                                                     : control.themeOnSurfaceVariant
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: crumbDelegate.isEnabled && !crumbDelegate.isCurrent
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            parent.forceActiveFocus(Qt.MouseFocusReason)
                            control.clicked(index, modelData)
                        }
                    }

                    Keys.onReturnPressed: if (mouseArea.enabled) control.clicked(index, modelData)
                    Keys.onEnterPressed: if (mouseArea.enabled) control.clicked(index, modelData)
                    Keys.onSpacePressed: if (mouseArea.enabled) control.clicked(index, modelData)
                }

                // Separator
                MeoIcon {
                    icon: control.separator
                    visible: index < control.model.length - 1
                    size: 16
                    color: control.themeOnSurfaceVariant
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
