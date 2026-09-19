import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: layoutsLabPage
    categoryId: "layouts"

    function localizedWidthSizeClass(sizeClass) {
        switch (sizeClass) {
        case "compact": return qsTr("Compact")
        case "medium": return qsTr("Medium")
        case "expanded": return qsTr("Expanded")
        case "large": return qsTr("Large")
        case "extraLarge": return qsTr("Extra large")
        default: return sizeClass
        }
    }

    // 🌟 1. Responsive Viewport & Window Metrics Simulator (MeoWindowMetrics)
    ShowcaseSection {
        title: qsTr("Responsive window sizes")
        subtitle: qsTr("See how the layout responds from compact to extra-large windows.")
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            RowLayout {
                spacing: MeoTheme.space16

                MeoText {
                    text: qsTr("Current window size:")
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                Rectangle {
                    height: 28 * MeoTheme.globalScale
                    width: 140 * MeoTheme.globalScale
                    radius: MeoTheme.shapeSmall
                    color: MeoTheme.primaryContainer

                    MeoText {
                        anchors.centerIn: parent
                        text: layoutsLabPage.localizedWidthSizeClass(windowMetrics.widthSizeClass)
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                        color: MeoTheme.contentOnPrimaryContainer
                    }
                }
            }

            MeoWindowMetrics {
                id: windowMetrics
                availableWidth: parent.width
                availableHeight: 400 * MeoTheme.globalScale
            }
        }
    }

    // 🌟 2. Internal State Layer Inspector (MeoStateLayer)
    ShowcaseSection {
        title: qsTr("State-layer feedback")
        subtitle: qsTr("Compare the visual feedback for hover, press, and drag states.")
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.outlineVariant
                border.width: 1

                MeoStateLayer {
                    hovered: true
                    color: MeoTheme.primary
                }

                MeoText { anchors.centerIn: parent; text: qsTr("Hover feedback (10%)"); typeRole: "label"; typeSize: "small"; emphasized: true }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.outlineVariant
                border.width: 1

                MeoStateLayer {
                    pressed: true
                    color: MeoTheme.primary
                }

                MeoText { anchors.centerIn: parent; text: qsTr("Press feedback (14%)"); typeRole: "label"; typeSize: "small"; emphasized: true }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.outlineVariant
                border.width: 1

                MeoStateLayer {
                    dragged: true
                    color: MeoTheme.primary
                }

                MeoText { anchors.centerIn: parent; text: qsTr("Drag feedback (16%)"); typeRole: "label"; typeSize: "small"; emphasized: true }
            }
        }
    }

    // 🌟 3. Experimental & Legacy Components
    ShowcaseSection {
        title: qsTr("Experimental and legacy components")
        subtitle: qsTr("These examples help maintain compatibility and are not part of the recommended product surface.")
        width: parent.width

        Rectangle {
            width: parent.width
            height: 90 * MeoTheme.globalScale
            radius: MeoTheme.shapeMedium
            color: MeoTheme.surfaceContainerLow
            border.color: MeoTheme.outlineVariant
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: MeoTheme.space16

                RowLayout {
                    MeoText { text: "test-import.qml"; typeRole: "title"; typeSize: "small"; emphasized: true }
                    Rectangle {
                        height: 20 * MeoTheme.globalScale
                        width: 110 * MeoTheme.globalScale
                        radius: MeoTheme.shapeExtraSmall
                        color: MeoTheme.errorContainer
                        MeoText { anchors.centerIn: parent; text: qsTr("EXPERIMENTAL"); typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnErrorContainer }
                    }
                }

                MeoText {
                    text: qsTr("This example verifies that the module can be imported correctly.")
                    typeRole: "body"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                }
            }
        }
    }
}
