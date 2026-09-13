import QtQuick
import QtTest
import MeoUI 1.0

Item {
    id: root
    width: 960
    height: 640

    MeoWidgetSheet {
        id: sheet
        width: parent.width
        height: parent.height
        catalog: [
            {
                "host": "meo", "id": "clock", "title": "Meo clock",
                "description": "Large date and time", "icon": "schedule",
                "defaultWidth": 320, "defaultHeight": 224, "available": true
            },
            {
                "host": "plasma", "id": "org.kde.plasma.digitalclock",
                "title": "Digital Clock", "description": "Calendar and time",
                "icon": "schedule", "available": true
            },
            {
                "host": "plasma", "id": "org.kde.plasma.systemmonitor",
                "title": "System Monitor", "description": "CPU sensor",
                "icon": "monitoring", "available": true
            },
            {
                "host": "meo", "id": "media", "title": "Meo media",
                "description": "Current-session MPRIS playback controls",
                "icon": "music_note", "defaultWidth": 384, "defaultHeight": 176,
                "available": true
            },
            {
                "host": "plasma", "id": "org.kde.plasma.weather",
                "title": "Weather Report", "description": "Local forecast",
                "icon": "partly_cloudy_day", "available": true
            }
        ]
    }

    TestCase {
        name: "MeoWidgetSheet"
        when: windowShown

        function init() {
            sheet.searchText = ""
            sheet.selectedCategory = "featured"
            sheet.selectedWidgetKey = ""
        }

        function test_unifiedCatalogKeepsSourcesTogether() {
            compare(sheet.filteredCatalog.length, 5)
            compare(sheet.sourceLabel(sheet.catalog[0]), "Meo")
            compare(sheet.sourceLabel(sheet.catalog[1]), "Plasma compatibility")
            compare(sheet.categoryCount("meo"), 2)
            compare(sheet.categoryCount("plasma"), 3)
        }

        function test_searchAndCategoryFilteringUseMetadataOnly() {
            sheet.searchText = "clock"
            compare(sheet.filteredCatalog.length, 2)
            sheet.selectedCategory = "plasma"
            compare(sheet.filteredCatalog.length, 1)
            compare(sheet.filteredCatalog[0].id, "org.kde.plasma.digitalclock")
        }

        function test_placementPreviewUsesKnownGeometryWithoutLoadingPackages() {
            const meoClock = sheet.catalog[0]
            verify(sheet.previewAspect(meoClock) > 1)
            verify(sheet.previewHeightFor(220, meoClock) >= 108 * MeoTheme.globalScale)
            compare(sheet.sizeLabelFor(meoClock), "Medium")
            compare(sheet.previewCardWidthFor(160), 160)
            verify(sheet.previewCardWidthFor(960) <= 280 * MeoTheme.globalScale)
            verify(sheet.minimumSheetWidth >= 720 * MeoTheme.globalScale)
            verify(sheet.minimumSheetHeight >= 500 * MeoTheme.globalScale)
        }

        function test_contentPreviewKindUsesSafeMetadataTemplates() {
            compare(sheet.previewKindFor(sheet.catalog[0]), "clock")
            compare(sheet.previewKindFor(sheet.catalog[1]), "clock")
            compare(sheet.previewKindFor(sheet.catalog[2]), "system")
            compare(sheet.previewKindFor(sheet.catalog[3]), "media")
            compare(sheet.previewKindFor(sheet.catalog[4]), "weather")
            compare(sheet.categoryFor(sheet.catalog[1]), "clock")
        }

        function test_selectionIsExplicitBeforeHostActivation() {
            compare(sheet.selectedEntry, null)
            sheet.selectWidget(sheet.catalog[3])
            compare(sheet.selectedWidgetKey, "meo:media")
            compare(sheet.selectedEntry.id, "media")
            verify(sheet.isSelected(sheet.catalog[3]))
            verify(!sheet.isSelected(sheet.catalog[0]))
        }
    }
}
