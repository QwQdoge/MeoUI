import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    id: control
    contentWidth: width
    contentHeight: contentColumn.implicitHeight + padding * 2
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    property string title: "Settings"
    property alias model: repeater.model
    property real padding: (windowMetrics.pageMargin || 16 * themeGlobalScale)

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property var fontTitleLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleLarge !== 'undefined') ? MeoTheme.titleLarge : { "size": 22, "weight": Font.Normal }

    ScrollBar.vertical: ScrollBar {}

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.width
        availableHeight: control.height
    }

    WheelHandler {
        id: wheelHandler
        target: control
        property real stepSize: 140 * control.themeGlobalScale * (typeof MeoTheme !== 'undefined' && typeof MeoTheme.scrollSpeedScale !== 'undefined' ? MeoTheme.scrollSpeedScale : 1.0)
        onWheel: (event) => {
            let dy = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
            let scrollY = control.contentY - (dy / 120.0) * stepSize
            control.contentY = Math.max(0, Math.min(Math.max(0, control.contentHeight - control.height), scrollY))
        }
    }

    Column {
        id: contentColumn
        width: Math.min(parent.width - control.padding * 2, windowMetrics.maximumContentWidth || (parent.width - control.padding * 2))
        anchors.horizontalCenter: parent.horizontalCenter
        y: control.padding
        spacing: 0

        Text {
            text: control.title
            font.family: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontFamily !== 'undefined') ? MeoTheme.fontFamily : "sans-serif"
            font.pixelSize: fontTitleLarge.size * (typeof MeoTheme !== 'undefined' && typeof MeoTheme.fontScale !== 'undefined' ? MeoTheme.fontScale * control.themeGlobalScale : control.themeGlobalScale)
            font.weight: fontTitleLarge.weight
            color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
            bottomPadding: 16 * control.themeGlobalScale
            visible: text !== ""
        }

        Repeater {
            id: repeater
            delegate: Column {
                id: sectionColumn
                required property var modelData
                required property int index
                width: parent.width

                MeoListHeader {
                    text: sectionColumn.modelData.sectionTitle || ""
                    visible: text !== ""
                    type: "emphasized"
                    topPadding: 16 * control.themeGlobalScale
                    bottomPadding: 8 * control.themeGlobalScale
                }

                Repeater {
                    model: sectionColumn.modelData.items || []
                    delegate: MeoListItem {
                        id: itemDelegate
                        required property var modelData
                        width: parent.width
                        headline: itemDelegate.modelData.title || ""
                        supportingText: itemDelegate.modelData.subtitle || ""
                        leadingIcon: itemDelegate.modelData.icon || ""
                        trailingComponent: itemDelegate.modelData.type === "switch"
                                           ? switchComp
                                           : (itemDelegate.modelData.type === "chevron" ? chevronComp : null)

                        Component {
                            id: switchComp
                            MeoSwitch {
                                checked: itemDelegate.modelData.checked || false
                                onToggled: (checkedVal) => { itemDelegate.modelData.checked = checkedVal }
                            }
                        }

                        Component {
                            id: chevronComp
                            MeoIcon {
                                icon: "chevron_right"
                                size: 24 * control.themeGlobalScale
                                color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
                            }
                        }

                        onClicked: if (itemDelegate.modelData.action) itemDelegate.modelData.action()
                    }
                }

                Item {
                    width: parent.width
                    height: 17 * control.themeGlobalScale
                    visible: sectionColumn.index < repeater.count - 1

                    MeoDivider {
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
