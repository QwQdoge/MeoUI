import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    categoryId: "layouts"

    // 🌟 1. Responsive Viewport & Window Metrics Simulator (MeoWindowMetrics)
    ShowcaseSection {
        title: "Responsive Viewport & Window Metrics Simulator"
        subtitle: "Live effective-pixel inspector: Compact <600, Medium 600-839, Expanded 840-1199, Large 1200-1599, Extra-large >=1600."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            RowLayout {
                spacing: MeoTheme.space16

                MeoText {
                    text: "Current Window Size Class:"
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
                        text: windowMetrics.widthSizeClass
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
        title: "Internal State Layer Engine (MeoStateLayer)"
        subtitle: "Visualization of MD3 overlay opacities for hover (8%), focus (10%), pressed (10%), and dragged (16%)."
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

                MeoText { anchors.centerIn: parent; text: "Hover State Layer (10%)"; typeRole: "label"; typeSize: "small"; emphasized: true }
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

                MeoText { anchors.centerIn: parent; text: "Pressed State Layer (14%)"; typeRole: "label"; typeSize: "small"; emphasized: true }
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

                MeoText { anchors.centerIn: parent; text: "Dragged State Layer (16%)"; typeRole: "label"; typeSize: "small"; emphasized: true }
            }
        }
    }

    // 🌟 3. Experimental & Legacy Components
    ShowcaseSection {
        title: "Experimental & Legacy Components"
        subtitle: "Internal test scripts and legacy components documented for architectural completeness."
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
                        color: Qt.rgba(1, 0, 0, 0.12)
                        MeoText { anchors.centerIn: parent; text: "EXPERIMENTAL"; typeRole: "label"; typeSize: "small"; color: MeoTheme.error }
                    }
                }

                MeoText {
                    text: "Source: examples/test-import.qml | Purpose: Module import validation script."
                    typeRole: "body"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                }
            }
        }
    }
}
