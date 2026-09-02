import QtQuick
import QtQuick.Layouts
import MeoUI

MeoPageLayout {
    id: page

    property string categoryId: "foundations"
    property var categoryIds: [categoryId]
    // Optional validation-only filter.  It lets the screenshot harness inspect
    // one public export without changing the normal, complete catalog view.
    property string componentFilter: ""
    property string navigationTitle: ""
    property string navigationSubtitle: ""
    ShowcaseCatalog {
        id: catalog
    }

    readonly property var category: catalog.categoryById(categoryId)

    title: navigationTitle || category.label
    subtitle: navigationSubtitle || category.subtitle

    Repeater {
        model: page.categoryIds

        delegate: Column {
            id: categoryColumn

            required property string modelData
            readonly property var categoryData: catalog.categoryById(modelData)
            readonly property var visibleComponents: {
                if (page.componentFilter === "")
                    return categoryData.components
                const matches = []
                for (let index = 0; index < categoryData.components.length; ++index) {
                    const entry = categoryData.components[index]
                    if (entry.name === page.componentFilter)
                        matches.push(entry)
                }
                return matches
            }

            width: parent.width
            height: visible ? implicitHeight : 0
            visible: visibleComponents.length > 0
            spacing: MeoTheme.space16

            Column {
                width: parent.width
                spacing: MeoTheme.space8

                MeoText {
                    width: parent.width
                    text: categoryColumn.categoryData.label
                    typeRole: "title"
                    typeSize: "medium"
                    emphasized: true
                    color: MeoTheme.contentOnSurface
                }

                MeoText {
                    width: parent.width
                    text: categoryColumn.categoryData.subtitle
                    typeRole: "body"
                    typeSize: "medium"
                    color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                }
            }

            Flow {
                width: parent.width
                spacing: MeoTheme.space8

                Repeater {
                    model: categoryColumn.visibleComponents
                    delegate: Rectangle {
                        required property var modelData

                        implicitWidth: Math.max(150 * MeoTheme.globalScale, indexLabel.implicitWidth + MeoTheme.space24)
                        implicitHeight: MeoTheme.buttonHeightM
                        radius: MeoTheme.shapeMedium
                        color: MeoTheme.surfaceContainerLow
                        border.color: MeoTheme.outlineVariant

                        MeoText {
                            id: indexLabel
                            anchors.centerIn: parent
                            text: modelData.name
                            typeRole: "label"
                            typeSize: "medium"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                    }
                }
            }

            Repeater {
                model: categoryColumn.visibleComponents
                delegate: ShowcaseSection {
                    required property var modelData
                    width: parent.width
                    componentData: modelData

                    ShowcaseStateGrid {
                        Layout.fillWidth: true
                        Layout.preferredHeight: height
                        stateSummary: modelData.states || ""
                    }

                    ShowcaseVariantRow {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight
                        title: "Live sample"

                        ShowcaseSampleDelegate {
                            componentData: modelData
                        }
                    }

                    ShowcaseApiTable {
                        Layout.fillWidth: true
                        variants: modelData.variants
                        stateSummary: modelData.states
                        api: modelData.api
                    }

                    ShowcaseSnippet {
                        Layout.fillWidth: true
                        code: modelData.usage
                    }
                }
            }
        }
    }
}
