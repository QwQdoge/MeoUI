import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import "../components/MeoMaterialShapes.js" as ShapesEngine

Item {
    id: control

    property var componentData: ({})

    implicitWidth: sampleLoader.implicitWidth
    implicitHeight: sampleLoader.implicitHeight
    width: parent ? Math.min(implicitWidth, parent.width) : implicitWidth
    clip: width < implicitWidth

    // Match Qt's configured mouse wheel rate while preserving the touchpad's
    // pixel-precise deltas. The overflow sample is horizontal, so vertical
    // wheel input is intentionally mapped to x without an extra animation.
    readonly property real systemWheelStep: Math.max(1, Application.styleHints.wheelScrollLines) * 20

    WheelHandler {
        enabled: control.width < control.implicitWidth
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const delta = event.pixelDelta.y !== 0
                    ? event.pixelDelta.y
                    : event.angleDelta.y / 120 * control.systemWheelStep
            const next = sampleLoader.x + delta
            sampleLoader.x = Math.max(control.width - sampleLoader.implicitWidth, Math.min(0, next))
        }
    }

    readonly property var navItems: [
        { "label": "Home", "icon": "home" },
        { "label": "Explore", "icon": "explore", "badgeText": "3" },
        { "label": "Profile", "icon": "person" }
    ]
    readonly property var chipItems: [
        { "label": "All", "icon": "apps" },
        { "label": "Design", "icon": "palette" },
        { "label": "Code", "icon": "code" }
    ]
    readonly property var tableColumns: [
        { "label": "Dessert", "property": "name", "width": 160, "sortable": true },
        { "label": "Calories", "property": "calories", "width": 100, "sortable": true },
        { "label": "Status", "property": "status", "width": 100 }
    ]
    readonly property var tableRows: [
        { "name": "Cupcake", "calories": 305, "status": "High", "selected": true },
        { "name": "Donut", "calories": 452, "status": "High" },
        { "name": "Eclair", "calories": 262, "status": "Normal" }
    ]
    readonly property var carouselItems: [
        { "title": "Color", "icon": "palette" },
        { "title": "Type", "icon": "text_fields" },
        { "title": "Motion", "icon": "animation" },
        { "title": "Shape", "icon": "category" },
        { "title": "Layout", "icon": "view_quilt" }
    ]

    Loader {
        id: sampleLoader
        sourceComponent: sampleFor(control.componentData.name || "")
    }

    function sampleFor(name) {
        if (name === "MeoTheme") return foundationsSample
        if (name === "MeoMotion") return motionTokensSample
        if (name === "MeoWindowMetrics") return windowMetricsSample
        if (name === "MeoText") return textSample
        if (name === "MeoIcon") return iconSample
        if (name === "MeoAiMark") return aiMarkSample
        if (name === "MeoStateLayer") return stateLayerSample
        if (name === "MeoButton") return buttonSample
        if (name === "MeoIconButton") return iconButtonSample
        if (name === "MeoIconToggleButton") return iconToggleButtonSample
        if (name === "MeoFAB") return fabSample
        if (name === "MeoFABMenu") return fabMenuSample
        if (name === "MeoSplitButton") return splitButtonSample
        if (name === "MeoButtonGroup") return buttonGroupSample
        if (name === "MeoSegmentedButtons") return segmentedSample
        if (name === "MeoTextField") return textFieldSample
        if (name === "MeoColorField") return colorFieldSample
        if (name === "MeoTextArea") return textAreaSample
        if (name === "MeoExposedDropdown") return dropdownSample
        if (name === "MeoChipDropdown") return chipDropdownSample
        if (name === "MeoDateInput") return dateInputSample
        if (name === "MeoTimeInput") return timeInputSample
        if (name === "MeoDatePicker") return datePickerSample
        if (name === "MeoDateRangePicker") return dateRangeSample
        if (name === "MeoMonthCalendar") return monthCalendarSample
        if (name === "MeoSpinBox") return spinBoxSample
        if (name === "MeoTimePicker") return timePickerSample
        if (name === "MeoCheckbox") return checkboxSample
        if (name === "MeoRadioButton") return radioSample
        if (name === "MeoSwitch") return switchSample
        if (name === "MeoSlider") return sliderSample
        if (name === "MeoScrollBar") return scrollBarSample
        if (name === "MeoSteppedSlider") return steppedSliderSample
        if (name === "MeoQuickControlSlider") return quickControlSliderSample
        if (name === "MeoQuickSettingsTile") return quickSettingsTileSample
        if (name === "MeoRangeSlider") return rangeSliderSample
        if (name === "MeoRatingBar") return ratingBarSample
        if (name === "MeoSelectionGroup") return selectionGroupSample
        if (name === "MeoFilterGroup") return filterGroupSample
        if (name === "MeoStepper") return stepperSample
        if (name === "MeoNavigationBar") return navigationBarSample
        if (name === "MeoNavigationRail") return navigationRailSample
        if (name === "MeoNavigationRailModal") return navigationRailModalSample
        if (name === "MeoNavigationDrawer") return navigationDrawerSample
        if (name === "MeoNavigationDrawerModal") return modalDrawerSample
        if (name === "MeoNavigationDrawerItem") return drawerItemSample
        if (name === "MeoAppGridItem") return appGridItemSample
        if (name === "MeoNavigationSuite") return navigationSuiteSample
        if (name === "MeoBreadcrumbs") return breadcrumbsSample
        if (name === "MeoTabs") return tabsSample
        if (name === "MeoTopAppBar") return topAppBarSample
        if (name === "MeoBottomAppBar") return bottomAppBarSample
        if (name === "MeoMenu") return menuSample
        if (name === "MeoDataTable") return dataTableSample
        if (name === "MeoListItem") return listItemSample
        if (name === "MeoExpansionPanel") return expansionPanelSample
        if (name === "MeoSettingsRow") return settingsRowSample
        if (name === "MeoListHeader") return listHeaderSample
        if (name === "MeoGroupedList") return groupedListSample
        if (name === "MeoSegmentedList") return segmentedListSample
        if (name === "MeoStatusCenter") return statusCenterSample
        if (name === "MeoBadge") return badgeSample
        if (name === "MeoAvatar") return avatarSample
        if (name === "MeoDivider") return dividerSample
        if (name === "MeoSkeleton") return skeletonSample
        if (name === "MeoCard") return cardSample
        if (name === "MeoMotionSurface") return motionSurfaceSample
        if (name === "MeoDialog") return dialogSample
        if (name === "MeoFullScreenDialog") return fullDialogSample
        if (name === "MeoExpressiveDialog") return expressiveDialogSample
        if (name === "MeoBottomSheet") return bottomSheetSample
        if (name === "MeoStandardBottomSheet") return standardSheetSample
        if (name === "MeoSideSheet") return sideSheetSample
        if (name === "MeoSideSheetModal") return modalSideSheetSample
        if (name === "MeoActionSheet") return actionSheetSample
        if (name === "MeoMotionPopup") return motionPopupSample
        if (name === "MeoBanner") return bannerSample
        if (name === "MeoSnackbar") return snackbarSample
        if (name === "MeoTooltip") return tooltipSample
        if (name === "MeoRichTooltip") return richTooltipSample
        if (name === "MeoProgressBar") return progressSample
        if (name === "MeoLoadingIndicator") return loadingSample
        if (name === "MeoPullToRefresh") return pullRefreshSample
        if (name === "MeoEmptyState") return emptyStateSample
        if (name === "MeoSearchBar") return searchBarSample
        if (name === "MeoDockedSearchBar") return dockedSearchSample
        if (name === "MeoSearchAppBar") return searchAppBarSample
        if (name === "MeoSearchView") return searchViewSample
        if (name === "MeoSearchSuggestions") return searchSuggestionsSample
        if (name === "MeoSearchHeader") return searchHeaderSample
        if (name === "MeoSearchFilterBar") return searchFilterSample
        if (name === "MeoCarousel") return carouselSample
        if (name === "MeoPageIndicator") return pageIndicatorSample
        if (name === "MeoMediaCard") return mediaCardSample
        if (name === "MeoMediaController") return mediaSample
        if (name === "MeoToolbar") return toolbarSample
        if (name === "MeoDockedToolbar") return dockedToolbarSample
        if (name === "MeoFloatingToolbar") return floatingToolbarSample
        if (name === "MeoAccountHeader") return accountHeaderSample
        if (name === "MeoAccountSwitcher") return accountSwitcherSample
        if (name === "MeoSettingsAccountCard") return settingsAccountCardSample
        if (name === "MeoSwipeToDismiss") return swipeToDismissSample
        if (name === "MeoChip") return chipSample
        if (name === "MeoAssistChip") return assistChipSample
        if (name === "MeoFilterChip") return filterChipSample
        if (name === "MeoInputChip") return inputChipSample
        if (name === "MeoSuggestionChip") return suggestionChipSample
        if (name === "MeoPageLayout") return pageLayoutSample
        if (name === "MeoScaffold") return scaffoldSample
        if (name === "MeoAppLayout") return appLayoutSample
        if (name === "MeoDashboardLayout") return dashboardSample
        if (name === "MeoFeedLayout") return feedSample
        if (name === "MeoListDetailLayout") return listDetailSample
        if (name === "MeoPageHost") return pageHostSample
        if (name === "MeoSettingsLayout") return settingsSample
        if (name === "MeoSettingsGroup") return settingsGroupSample
        if (name === "MeoSettingsTaskSheet") return settingsTaskSheetSample
        if (name === "MeoQuickSettingsEditor") return quickSettingsEditorSample
        if (name === "MeoSupportingPaneLayout") return supportingPaneSample
        if (name === "MeoShape") return shapeSample
        if (name === "MeoShapeMorph") return shapeMorphSample
        return fallbackSample
    }

    Component {
        id: foundationsSample
        Flow {
            spacing: MeoTheme.space8
            TokenSwatch { label: "Primary"; swatchColor: MeoTheme.primary; contentColor: MeoTheme.contentOnPrimary }
            TokenSwatch { label: "Primary container"; swatchColor: MeoTheme.primaryContainer; contentColor: MeoTheme.contentOnPrimaryContainer }
            TokenSwatch { label: "Surface low"; swatchColor: MeoTheme.surfaceContainerLow; contentColor: MeoTheme.contentOnSurface }
            TokenSwatch { label: "Error"; swatchColor: MeoTheme.error; contentColor: MeoTheme.contentOnError }
            TokenSwatch { label: "Inverse surface"; swatchColor: MeoTheme.inverseSurface; contentColor: MeoTheme.contentOnInverseSurface }
        }
    }
    Component {
        id: motionTokensSample
        Flow {
            spacing: MeoTheme.space8

            Repeater {
                model: [
                    { "label": "Default spatial", "spec": MeoMotion.defaultSpatial },
                    { "label": "Fast spatial", "spec": MeoMotion.fastSpatial },
                    { "label": "Slow spatial", "spec": MeoMotion.slowSpatial },
                    { "label": "Default effects", "spec": MeoMotion.defaultEffects },
                    { "label": "Fast effects", "spec": MeoMotion.fastEffects },
                    { "label": "Slow effects", "spec": MeoMotion.slowEffects }
                ]
                delegate: MeoChip {
                    required property var modelData
                    label: modelData.label + " · ζ " + modelData.spec.dampingRatio
                           + " · k " + modelData.spec.stiffness
                    selected: index === 0
                }
            }
        }
    }
    Component { id: windowMetricsSample; Flow { spacing: MeoTheme.space8; Repeater { model: [{"label":"Compact","width":599},{"label":"Medium","width":600},{"label":"Expanded","width":840},{"label":"Large","width":1200},{"label":"Extra-large","width":1600}]; delegate: MeoChip { required property var modelData; label: modelData.label + " · " + modelData.width; selected: modelData.width === 840 } } } }
    Component { id: textSample; Column { spacing: MeoTheme.space4; MeoText { text: "Display title"; typeRole: "title"; typeSize: "big"; emphasized: true; color: MeoTheme.contentOnSurface } MeoText { text: "Roboto body text with semantic type tokens."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component {
        id: iconSample

        Flow {
            spacing: MeoTheme.space16

            Repeater {
                model: [
                    { "label": "Regular", "icon": "palette" },
                    { "label": "Filled", "icon": "favorite", "fill": true },
                    { "label": "Bold", "icon": "edit", "weight": 700 },
                    { "label": "Grade", "icon": "auto_awesome", "grade": 200 },
                    { "label": "48 opsz", "icon": "search", "opticalSize": 48 }
                ]

                delegate: Column {
                    required property var modelData
                    spacing: MeoTheme.space4

                    MeoIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon: modelData.icon
                        fill: Boolean(modelData.fill)
                        weight: modelData.weight === undefined ? 400 : modelData.weight
                        grade: modelData.grade === undefined ? 0 : modelData.grade
                        opticalSize: modelData.opticalSize === undefined ? 24 : modelData.opticalSize
                        color: MeoTheme.primary
                        size: 32
                    }
                    MeoText {
                        text: modelData.label
                        typeRole: "label"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                    }
                }
            }
        }
    }
    Component {
        id: stateLayerSample
        Flow {
            spacing: MeoTheme.space12

            Repeater {
                model: [
                    { "label": "Rest" },
                    { "label": "Hover", "hovered": true },
                    { "label": "Focus", "focused": true },
                    { "label": "Pressed", "pressed": true },
                    { "label": "Dragged", "dragged": true }
                ]

                delegate: Column {
                    required property var modelData
                    spacing: MeoTheme.space8

                    Rectangle {
                        width: 132 * MeoTheme.globalScale
                        height: MeoTheme.buttonHeightM
                        radius: MeoTheme.shapeMedium
                        color: MeoTheme.surfaceContainer

                        MeoStateLayer {
                            anchors.fill: parent
                            radius: parent.radius
                            color: MeoTheme.primary
                            hovered: modelData.hovered || false
                            focused: modelData.focused || false
                            pressed: modelData.pressed || false
                            dragged: modelData.dragged || false
                        }
                    }

                    MeoText {
                        width: 132 * MeoTheme.globalScale
                        text: modelData.label
                        horizontalAlignment: Text.AlignHCenter
                        typeRole: "label"
                        typeSize: "medium"
                        color: MeoTheme.contentOnSurfaceVariant
                    }
                }
            }
        }
    }
    Component {
        id: buttonSample
        GridLayout {
            columns: 5
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space12

            SampleLabel { label: "Type" }
            SampleLabel { label: "Text" }
            SampleLabel { label: "With icon" }
            SampleLabel { label: "Disabled" }
            SampleLabel { label: "Loading" }

            SampleLabel { label: "Filled" }
            MeoButton { text: "Filled"; type: "filled" }
            MeoButton { text: "Icon"; type: "filled"; icon.name: "add" }
            MeoButton { text: "Filled"; type: "filled"; enabled: false }
            MeoButton { text: "Loading"; type: "filled"; loading: true; loadingWithContainer: true }

            SampleLabel { label: "Tonal" }
            MeoButton { text: "Tonal"; type: "tonal" }
            MeoButton { text: "Icon"; type: "tonal"; icon.name: "star" }
            MeoButton { text: "Tonal"; type: "tonal"; enabled: false }
            MeoButton { text: "Loading"; type: "tonal"; loading: true }

            SampleLabel { label: "Outlined" }
            MeoButton { text: "Outlined"; type: "outlined" }
            MeoButton { text: "Icon"; type: "outlined"; icon.name: "add" }
            MeoButton { text: "Outlined"; type: "outlined"; enabled: false }
            MeoButton { text: "Loading"; type: "outlined"; loading: true }

            SampleLabel { label: "Elevated" }
            MeoButton { text: "Elevated"; type: "elevated" }
            MeoButton { text: "Icon"; type: "elevated"; icon.name: "add" }
            MeoButton { text: "Elevated"; type: "elevated"; enabled: false }
            MeoButton { text: "Loading"; type: "elevated"; loading: true }

            SampleLabel { label: "Text" }
            MeoButton { text: "Text"; type: "text" }
            MeoButton { text: "Icon"; type: "text"; icon.name: "add" }
            MeoButton { text: "Text"; type: "text"; enabled: false }
            MeoButton { text: "Loading"; type: "text"; loading: true }

            SampleLabel { label: "Toggle" }
            MeoButton { text: "Filled off"; type: "filled"; toggle: true }
            MeoButton { text: "Filled on"; type: "filled"; toggle: true; selected: true }
            MeoButton { text: "Outlined on"; type: "outlined"; toggle: true; selected: true }
            MeoButton { text: "Tonal on"; type: "tonal"; toggle: true; selected: true }

            SampleLabel { label: "M3E size" }
            Row {
                Layout.columnSpan: 4
                spacing: MeoTheme.space8

                MeoButton { text: "XS"; type: "filled"; size: "xs" }
                MeoButton { text: "S"; type: "filled"; size: "s" }
                MeoButton { text: "M"; type: "filled"; size: "m" }
                MeoButton { text: "L"; type: "filled"; size: "l" }
                MeoButton { text: "XL"; type: "filled"; size: "xl" }
            }
        }
    }

    Component {
        id: iconButtonSample
        GridLayout {
            columns: 4
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space24

            IconButtonColumn { label: "Standard"; buttonType: "standard"; buttonIcon: "settings" }
            IconButtonColumn { label: "Filled (default)"; buttonType: "filled"; buttonIcon: "favorite" }
            IconButtonColumn { label: "Tonal"; buttonType: "tonal"; buttonIcon: "bookmark"; badgeDot: true }
            IconButtonColumn { label: "Outlined"; buttonType: "outlined"; buttonIcon: "share" }
            IconButtonColumn { label: "Selected"; buttonType: "standard"; buttonIcon: "star"; toggle: true; selected: true }
            IconButtonColumn { label: "Selected"; buttonType: "filled"; buttonIcon: "favorite"; toggle: true; selected: true }
            IconButtonColumn { label: "Selected"; buttonType: "tonal"; buttonIcon: "bookmark"; toggle: true; selected: true }
            IconButtonColumn { label: "Selected"; buttonType: "outlined"; buttonIcon: "share"; toggle: true; selected: true }
            IconButtonColumn { label: "Narrow XS"; buttonType: "filled"; buttonIcon: "add"; buttonSize: "xs"; buttonWidth: "narrow" }
            IconButtonColumn { label: "Uniform M"; buttonType: "filled"; buttonIcon: "edit"; buttonSize: "m" }
            IconButtonColumn { label: "Wide S"; buttonType: "filled"; buttonIcon: "wifi"; buttonWidth: "wide" }
            IconButtonColumn { label: "Disabled"; buttonType: "standard"; buttonIcon: "settings"; enabledState: false }
            IconButtonColumn { label: "Disabled"; buttonType: "filled"; buttonIcon: "favorite"; enabledState: false }
            IconButtonColumn { label: "Disabled"; buttonType: "tonal"; buttonIcon: "bookmark"; enabledState: false }
            IconButtonColumn { label: "Disabled"; buttonType: "outlined"; buttonIcon: "share"; enabledState: false }
        }
    }

    Component {
        id: fabSample
        Flow {
            spacing: MeoTheme.space24
            FabColumn { label: "Small"; fabType: "small"; fabIcon: "edit" }
            FabColumn { label: "Regular"; fabType: "regular"; fabIcon: "add" }
            FabColumn { label: "Medium"; fabType: "medium"; fabIcon: "edit"; fabColorStyle: "secondary" }
            FabColumn { label: "Large"; fabType: "large"; fabIcon: "palette" }
            FabColumn { label: "Extended"; fabType: "extended"; fabIcon: "send"; fabText: "Send" }
            FabColumn { label: "Collapsed"; fabType: "extended"; fabIcon: "send"; fabText: "Send"; fabCollapsed: true }
        }
    }
    Component {
        id: fabMenuSample
        Item {
            width: 620 * MeoTheme.globalScale
            height: 224 * MeoTheme.globalScale

            MeoFABMenu { x: 8 * MeoTheme.globalScale; y: 168 * MeoTheme.globalScale; model: control.chipItems }
            MeoFABMenu { x: 90 * MeoTheme.globalScale; y: 184 * MeoTheme.globalScale; fabType: "small"; model: control.chipItems }
            MeoFABMenu { x: 162 * MeoTheme.globalScale; y: 144 * MeoTheme.globalScale; fabType: "medium"; colorStyle: "secondary"; model: control.chipItems }
            MeoFABMenu {
                x: 340 * MeoTheme.globalScale
                y: 168 * MeoTheme.globalScale
                opened: true
                enableScrim: false
                model: [
                    { "label": "Note", "icon": "note_add" },
                    { "label": "Task", "icon": "check" }
                ]
            }
            MeoFABMenu {
                x: 492 * MeoTheme.globalScale
                y: 128 * MeoTheme.globalScale
                fabType: "large"
                colorStyle: "tertiary"
                enableScrim: false
                model: [{ "icon": "bookmark" }]
            }
        }
    }
    Component {
        id: splitButtonSample
        Column {
            width: 760 * MeoTheme.globalScale
            spacing: MeoTheme.space12
            Flow {
                width: parent.width
                spacing: MeoTheme.space12
                MeoSplitButton { text: "Create"; icon: "add"; type: "filled"; size: "xs"; menuModel: control.chipItems }
                MeoSplitButton { text: "Save"; icon: "save"; type: "tonal"; size: "s"; menuModel: control.chipItems }
                MeoSplitButton { text: "Export"; icon: "download"; type: "outlined"; size: "m"; menuModel: control.chipItems }
            }
            Flow {
                width: parent.width
                spacing: MeoTheme.space12
                MeoSplitButton { text: "Add"; icon: "add"; type: "elevated"; size: "l"; menuModel: control.chipItems }
                MeoSplitButton { text: "Deploy"; icon: "rocket_launch"; type: "filled"; size: "xl"; menuModel: control.chipItems }
                MeoSplitButton { text: "Disabled"; icon: "block"; type: "filled"; size: "s"; enabled: false; menuModel: control.chipItems }
            }
        }
    }
    Component {
        id: buttonGroupSample
        Grid {
            columns: 2
            spacing: MeoTheme.space8
            SampleLabel { label: "1. Standard: selection expands and changes shape" }
            MeoButtonGroup {
                type: "tonal"
                model: [
                    { "label": "Bluetooth", "icon": "bluetooth", "compactWhenUnselected": true },
                    { "label": "Timer", "icon": "timer", "compactWhenUnselected": true },
                    { "label": "Share", "icon": "share", "compactWhenUnselected": true }
                ]
                currentIndex: 1
            }
            SampleLabel { label: "2. Standard action trio" }
            MeoButtonGroup { type: "filled"; model: [{ "label": "Back", "icon": "arrow_back" }, { "label": "Pause", "icon": "pause" }, { "label": "Next", "icon": "arrow_forward" }]; currentIndex: 1 }
            SampleLabel { label: "3. Connected: stable view selection" }
            MeoButtonGroup { width: 420 * MeoTheme.globalScale; variant: "connected"; type: "outlined"; model: [{ "label": "List", "icon": "view_list" }, { "label": "Grid", "icon": "grid_view" }, { "label": "Map", "icon": "map" }]; currentIndex: 1 }
            SampleLabel { label: "4. Connected multi-select" }
            MeoButtonGroup { width: 420 * MeoTheme.globalScale; variant: "connected"; type: "outlined"; multiSelect: true; selectedIndices: [0, 2]; model: [{ "label": "Photos" }, { "label": "Videos" }, { "label": "Files" }] }
            SampleLabel { label: "5. Disabled" }
            MeoButtonGroup { model: [{ "label": "Day" }, { "label": "Week" }, { "label": "Month" }]; currentIndex: 1; enabled: false }
            SampleLabel { label: "6. Standard size spacing (XS / S; M shown above)" }
            Flow {
                width: 590 * MeoTheme.globalScale
                spacing: MeoTheme.space12
                MeoButtonGroup { size: "xs"; model: [{ "label": "A" }, { "label": "B" }, { "label": "C" }] }
                MeoButtonGroup { size: "s"; model: [{ "label": "A" }, { "label": "B" }, { "label": "C" }] }
            }
        }
    }
    Component {
        id: segmentedSample
        Column {
            spacing: MeoTheme.space8
            SampleLabel { label: "Single selection" }
            MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: ["List", "Grid", "Map"]; currentIndex: 1 }
            SampleLabel { label: "Single with icons" }
            MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: [{ "label": "List", "icon": "view_list" }, { "label": "Grid", "icon": "grid_view" }, { "label": "Map", "icon": "map" }]; currentIndex: 1 }
            SampleLabel { label: "Multi selection" }
            MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: ["Bold", "Italic", "Underline"]; multiSelect: true; selectedIndices: [0, 2] }
            SampleLabel { label: "Disabled" }
            MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: ["List", "Grid", "Map"]; currentIndex: 1; enabled: false }
            SampleLabel { label: "Compact" }
            MeoSegmentedButtons { width: 300 * MeoTheme.globalScale; size: "xs"; model: ["A", "B", "C"]; currentIndex: 1 }
        }
    }
    Component {
        id: textFieldSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space16

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: "Filled"
                placeholder: "Filled input"
                helperText: "Supporting text"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: "Outlined"
                placeholder: "Outlined input"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: "Search"
                leadingIcon: "search"
                trailingIcon: "close"
                showClearButton: true
                text: "Material"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: "Password"
                placeholder: "Enter password"
                trailingIcon: "visibility"
                echoMode: TextInput.Password
                text: "secret"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: "Error"
                text: "bad input"
                isError: true
                errorText: "Invalid input"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: "Counter"
                text: "Short note"
                maxLength: 24
                showCounter: true
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: "Prefix / suffix"
                prefixText: "$"
                suffixText: "USD"
                text: "128"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: "Disabled"
                text: "Disabled"
                enabled: false
            }
        }
    }
    Component {
        id: textAreaSample
        Grid {
            columns: 3
            spacing: MeoTheme.space12
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: "Summary"; placeholder: "Write a short summary"; helperText: "Filled" }
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: "Description"; type: "outlined"; text: "Outlined multi-line input" }
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: "Notes"; text: "Too short"; isError: true; errorText: "Add more detail" }
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: "Bio"; text: "A concise profile"; maxLength: 40; showCounter: true }
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: "Disabled"; text: "Unavailable"; enabled: false }
        }
    }
    Component {
        id: dropdownSample
        Grid {
            columns: 3
            spacing: MeoTheme.space12
            MeoExposedDropdown { width: 260 * MeoTheme.globalScale; label: "Environment"; model: ["Development", "Staging", "Production"]; currentIndex: 0 }
            MeoExposedDropdown { width: 260 * MeoTheme.globalScale; label: "Region"; type: "outlined"; model: ["Americas", "Europe", "Asia"]; currentIndex: 2 }
            MeoExposedDropdown { width: 260 * MeoTheme.globalScale; label: "Workspace"; model: ["Personal", "Team"]; isError: true; errorText: "Choose a workspace" }
            MeoExposedDropdown {
                width: 260 * MeoTheme.globalScale
                label: "Open menu"
                model: ["Inbox", "Later", "Archived"]
                Timer {
                    interval: 300
                    running: true
                    repeat: false
                    onTriggered: parent.openMenu()
                }
            }
            MeoExposedDropdown { width: 260 * MeoTheme.globalScale; label: "Disabled"; model: ["Unavailable"]; currentIndex: 0; enabled: false }
        }
    }
    Component {
        id: dateInputSample
        Grid {
            columns: 2
            spacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "ISO value" }
                MeoDateInput { width: 220 * MeoTheme.globalScale; value: new Date(2026, 7, 31) }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Slash format" }
                MeoDateInput { width: 220 * MeoTheme.globalScale; format: "yyyy/MM/dd"; value: new Date(2024, 1, 29) }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Empty allowed" }
                MeoDateInput { width: 220 * MeoTheme.globalScale; allowEmpty: true; value: new Date(0) }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Clear affordance" }
                MeoDateInput { width: 220 * MeoTheme.globalScale; value: new Date(2025, 11, 24); showClearButton: true }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Validation error" }
                MeoDateInput {
                    width: 220 * MeoTheme.globalScale
                    Timer {
                        interval: 100
                        running: true
                        repeat: false
                        onTriggered: parent.text = "2024-02-30"
                    }
                }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Disabled" }
                MeoDateInput { width: 220 * MeoTheme.globalScale; value: new Date(2027, 0, 1); enabled: false }
            }
        }
    }
    Component {
        id: timeInputSample
        Grid {
            columns: 2
            spacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Morning" }
                MeoTimeInput { width: 220 * MeoTheme.globalScale; value: "09:30" }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Clear affordance" }
                MeoTimeInput { width: 220 * MeoTheme.globalScale; value: "18:45"; showClearButton: true }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Empty allowed" }
                MeoTimeInput { width: 220 * MeoTheme.globalScale; allowEmpty: true }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Validation error" }
                MeoTimeInput {
                    width: 220 * MeoTheme.globalScale
                    Timer {
                        interval: 100
                        running: true
                        repeat: false
                        onTriggered: parent.text = "25:80"
                    }
                }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Disabled" }
                MeoTimeInput { width: 220 * MeoTheme.globalScale; value: "07:15"; enabled: false }
            }
        }
    }
    Component {
        id: datePickerSample
        Grid {
            columns: 5
            spacing: MeoTheme.space12

            Item { width: 188 * MeoTheme.globalScale; height: 270 * MeoTheme.globalScale; MeoDatePicker { scale: 0.5; transformOrigin: Item.TopLeft; selectedDate: new Date(2026, 6, 4); displayDate: new Date(2026, 6, 1) } }
            Item { width: 188 * MeoTheme.globalScale; height: 270 * MeoTheme.globalScale; MeoDatePicker { scale: 0.5; transformOrigin: Item.TopLeft; selectedDate: new Date(2028, 1, 29); displayDate: new Date(2028, 1, 1) } }
            Item { width: 188 * MeoTheme.globalScale; height: 270 * MeoTheme.globalScale; MeoDatePicker { scale: 0.5; transformOrigin: Item.TopLeft; selectedDate: new Date(2026, 7, 31); displayDate: new Date(2026, 8, 1) } }
            Item { width: 188 * MeoTheme.globalScale; height: 270 * MeoTheme.globalScale; MeoDatePicker { scale: 0.5; transformOrigin: Item.TopLeft; selectedDate: new Date(2026, 0, 1); displayDate: new Date(2025, 11, 1) } }
            Item { width: 188 * MeoTheme.globalScale; height: 270 * MeoTheme.globalScale; MeoDatePicker { scale: 0.5; transformOrigin: Item.TopLeft; selectedDate: new Date(2030, 10, 15); displayDate: new Date(2030, 10, 1); interactive: false } }
        }
    }
    Component {
        id: dateRangeSample
        Grid {
            columns: 3
            spacing: MeoTheme.space12

            Item { width: 188 * MeoTheme.globalScale; height: 320 * MeoTheme.globalScale; MeoDateRangePicker { scale: 0.5; transformOrigin: Item.TopLeft; startDate: new Date(2026, 6, 1); endDate: new Date(2026, 6, 12); displayDate: new Date(2026, 6, 1) } }
            Item { width: 188 * MeoTheme.globalScale; height: 320 * MeoTheme.globalScale; MeoDateRangePicker { scale: 0.5; transformOrigin: Item.TopLeft; startDate: new Date(2026, 1, 14); endDate: new Date(2026, 1, 14); displayDate: new Date(2026, 1, 1) } }
            Item { width: 188 * MeoTheme.globalScale; height: 320 * MeoTheme.globalScale; MeoDateRangePicker { scale: 0.5; transformOrigin: Item.TopLeft; startDate: new Date(2026, 8, 19); displayDate: new Date(2026, 8, 1) } }
            Item { width: 188 * MeoTheme.globalScale; height: 320 * MeoTheme.globalScale; MeoDateRangePicker { scale: 0.5; transformOrigin: Item.TopLeft; endDate: new Date(2026, 10, 4); displayDate: new Date(2026, 10, 1) } }
            Item { width: 188 * MeoTheme.globalScale; height: 320 * MeoTheme.globalScale; MeoDateRangePicker { scale: 0.5; transformOrigin: Item.TopLeft; startDate: new Date(2026, 4, 3); endDate: new Date(2026, 4, 18); displayDate: new Date(2026, 4, 1); interactive: false } }
        }
    }
    Component {
        id: spinBoxSample
        Grid {
            columns: 5
            spacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Step 2" }
                MeoSpinBox { from: 0; to: 100; value: 42; stepSize: 2 }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Minimum" }
                MeoSpinBox { from: 0; to: 10; value: 0 }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Maximum" }
                MeoSpinBox { from: 0; to: 10; value: 10 }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Read only" }
                MeoSpinBox { from: -5; to: 5; value: -2; editable: false }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Disabled" }
                MeoSpinBox { from: 0; to: 10; value: 6; enabled: false }
            }
        }
    }
    Component {
        id: timePickerSample
        Grid {
            columns: 3
            spacing: MeoTheme.space12

            Item { width: 160 * MeoTheme.globalScale; height: 264 * MeoTheme.globalScale; MeoTimePicker { scale: 0.5; transformOrigin: Item.TopLeft; hours: 10; minutes: 30 } }
            Item { width: 160 * MeoTheme.globalScale; height: 264 * MeoTheme.globalScale; MeoTimePicker { scale: 0.5; transformOrigin: Item.TopLeft; hours: 7; minutes: 45; isPM: true } }
            Item { width: 160 * MeoTheme.globalScale; height: 264 * MeoTheme.globalScale; MeoTimePicker { scale: 0.5; transformOrigin: Item.TopLeft; hours: 12; minutes: 0; activeUnit: "minute" } }
            Item { width: 160 * MeoTheme.globalScale; height: 264 * MeoTheme.globalScale; MeoTimePicker { scale: 0.5; transformOrigin: Item.TopLeft; hours: 18; minutes: 15; use24Hour: true } }
            Item { width: 160 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; MeoTimePicker { scale: 0.5; transformOrigin: Item.TopLeft; hours: 1; minutes: 59; isPM: true; inputMode: true } }
        }
    }
    Component {
        id: checkboxSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space24

            MeoCheckbox { label: "Checked"; checked: true }
            MeoCheckbox { label: "Unchecked" }
            MeoCheckbox { label: "Indeterminate"; indeterminate: true }
            MeoCheckbox { label: "Error"; checked: true; isError: true; errorText: "Required" }
            MeoCheckbox { label: "Disabled"; checked: true; enabled: false }
        }
    }
    Component {
        id: radioSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space24

            MeoRadioButton { label: "Selected"; checked: true }
            MeoRadioButton { label: "Unselected" }
            MeoRadioButton { label: "Error"; checked: true; isError: true; errorText: "Choose an option" }
            MeoRadioButton { label: "Disabled selected"; checked: true; enabled: false }
            MeoRadioButton { label: "Disabled"; enabled: false }
        }
    }
    Component {
        id: switchSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space24

            MeoSwitch { label: "No icons"; checked: true }
            MeoSwitch { label: "Selected icon"; checked: true; showIcon: true; icon: "check" }
            MeoSwitch { label: "Both icons"; uncheckedIcon: "close" }
            MeoSwitch { label: "Error"; checked: true; showIcon: true; icon: "check"; isError: true; errorText: "Unavailable" }
            MeoSwitch { label: "Disabled on"; checked: true; showIcon: true; icon: "check"; enabled: false }
            MeoSwitch { label: "Disabled off"; uncheckedIcon: "close"; enabled: false }
        }
    }
    Component {
        id: sliderSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "1. Standard" }
                MeoSlider { width: 360 * MeoTheme.globalScale; value: 35 }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "2. Expressive split" }
                MeoSlider {
                    width: 360 * MeoTheme.globalScale
                    value: 35
                    expressive: true
                    trackStyle: "split"
                    insetIcon: "volume_up"
                }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "3. Centered" }
                MeoSlider { width: 360 * MeoTheme.globalScale; from: -100; to: 100; value: 35; centerValue: 0; variant: "centered"; trackStyle: "standard" }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "4. Stops" }
                MeoSlider { width: 360 * MeoTheme.globalScale; value: 40; stops: true; stepSize: 20; size: "xs" }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "5. Vertical" }
                MeoSlider {
                    width: 64 * MeoTheme.globalScale
                    height: 52 * MeoTheme.globalScale
                    value: 35
                    orientation: Qt.Vertical
                }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "6. Disabled" }
                MeoSlider { width: 360 * MeoTheme.globalScale; value: 35; enabled: false }
            }

        }
    }
    Component {
        id: scrollBarSample
        Flow {
            spacing: MeoTheme.space16
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "1. Vertical always on" }
                MeoScrollBar { height: 120 * MeoTheme.globalScale; orientation: Qt.Vertical; policy: ScrollBar.AlwaysOn; position: 0.28; size: 0.35 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "2. Horizontal always on" }
                MeoScrollBar { width: 132 * MeoTheme.globalScale; orientation: Qt.Horizontal; policy: ScrollBar.AlwaysOn; position: 0.28; size: 0.35 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "3. Vertical auto" }
                MeoScrollBar { height: 120 * MeoTheme.globalScale; orientation: Qt.Vertical; policy: ScrollBar.AsNeeded; active: true; position: 0.52; size: 0.30 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "4. Horizontal auto" }
                MeoScrollBar { width: 132 * MeoTheme.globalScale; orientation: Qt.Horizontal; policy: ScrollBar.AsNeeded; active: true; position: 0.52; size: 0.30 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "5. Disabled" }
                MeoScrollBar { height: 120 * MeoTheme.globalScale; orientation: Qt.Vertical; policy: ScrollBar.AlwaysOn; position: 0.28; size: 0.35; enabled: false }
            }
        }
    }
    Component {
        id: rangeSliderSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space16

            SampleLabel { label: "1. Standard range" }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 24; secondValue: 78 }

            SampleLabel { label: "2. Expressive split" }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 24; secondValue: 78; expressive: true; trackStyle: "split" }

            SampleLabel { label: "3. Discrete stops" }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 20; secondValue: 80; discrete: true; stepSize: 20 }

            SampleLabel { label: "4. Narrow range" }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 46; secondValue: 54 }

            SampleLabel { label: "5. Disabled" }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 24; secondValue: 78; enabled: false }
        }
    }
    Component {
        id: quickControlSliderSample
        Column {
            width: 360 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            SampleLabel { label: "1. Low" }
            MeoQuickControlSlider { width: parent.width; iconName: "light_mode"; label: "Brightness"; accessibleName: "Brightness"; iconAccessibleName: "Display options"; value: 24 }

            SampleLabel { label: "2. Mid" }
            MeoQuickControlSlider { width: parent.width; iconName: "volume_up"; label: "Output volume"; accessibleName: "Output volume"; iconAccessibleName: "Mute output"; value: 52 }

            SampleLabel { label: "3. High" }
            MeoQuickControlSlider { width: parent.width; iconName: "wifi"; label: "Wi-Fi strength"; accessibleName: "Wi-Fi strength"; iconAccessibleName: "Network options"; value: 88 }

            SampleLabel { label: "4. Details expanded" }
            MeoQuickControlSlider { width: parent.width; iconName: "volume_up"; label: "Output volume"; accessibleName: "Output volume"; iconAccessibleName: "Mute output"; value: 64; detailsAvailable: true; expanded: true }

            SampleLabel { label: "5. Disabled" }
            MeoQuickControlSlider { width: parent.width; iconName: "light_mode"; label: "Brightness"; accessibleName: "Brightness"; iconAccessibleName: "Display options"; value: 38; enabled: false }
        }
    }
    Component {
        id: quickSettingsTileSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space16

            SampleLabel { label: "1. Pixel wide active" }
            MeoQuickSettingsTile { title: "Wi-Fi"; supportingText: "Connected"; iconName: "wifi"; active: true; wide: true; visualStyle: "pixel"; detailsEnabled: true }

            SampleLabel { label: "2. Pixel wide inactive" }
            MeoQuickSettingsTile { title: "Bluetooth"; supportingText: "Off"; iconName: "bluetooth"; wide: true; visualStyle: "pixel" }

            SampleLabel { label: "3. Pixel compact active" }
            MeoQuickSettingsTile { title: "Flashlight"; iconName: "flashlight_on"; active: true; wide: false; visualStyle: "pixel" }

            SampleLabel { label: "4. Pixel compact inactive" }
            MeoQuickSettingsTile { title: "Airplane"; iconName: "flight"; wide: false; visualStyle: "pixel" }

            SampleLabel { label: "5. Edit state" }
            MeoQuickSettingsTile { title: "Quick Share"; supportingText: "Contacts"; iconName: "share"; active: true; wide: true; visualStyle: "pixel"; editMode: true; editSelected: true }
        }
    }
    Component {
        id: selectionGroupSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space24

            SampleLabel { label: "1. Checkbox mixed" }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "checkbox"; showSelectAll: true; model: [{ "label": "Design", "checked": true }, { "label": "Code", "checked": false }, { "label": "Research", "checked": true }] }

            SampleLabel { label: "2. Checkbox all selected" }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "checkbox"; showSelectAll: true; model: [{ "label": "Alerts", "checked": true }, { "label": "Updates", "checked": true }] }

            SampleLabel { label: "3. Radio selection" }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "radio"; model: [{ "label": "Light", "checked": false }, { "label": "System", "checked": true }, { "label": "Dark", "checked": false }] }

            SampleLabel { label: "4. Supporting text" }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "radio"; model: [{ "label": "Automatic", "supportingText": "Follow the device", "checked": true }, { "label": "Manual", "supportingText": "Choose a fixed mode", "checked": false }] }

            SampleLabel { label: "5. Disabled" }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "checkbox"; showSelectAll: true; model: [{ "label": "Design", "checked": true }, { "label": "Code", "checked": false }]; enabled: false }
        }
    }
    Component {
        id: filterGroupSample
        Column {
            width: 520 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            SampleLabel { label: "1. Single selection" }
            MeoFilterGroup { width: parent.width; model: ["All", "Open", "Archived"]; currentIndex: 0 }

            SampleLabel { label: "2. Multiple selection" }
            MeoFilterGroup { width: parent.width; multiSelect: true; selectedIndices: [0, 2]; model: ["Updates", "Assigned", "Mentioned"] }

            SampleLabel { label: "3. With icons" }
            MeoFilterGroup { width: parent.width; model: [{ "label": "Design", "icon": "palette" }, { "label": "Code", "icon": "code" }, { "label": "Docs", "icon": "article" }]; currentIndex: 1 }

            SampleLabel { label: "4. Required selection" }
            MeoFilterGroup { width: parent.width; allowEmptySelection: false; currentIndex: 1; model: ["List", "Grid", "Cards"] }

            SampleLabel { label: "5. Disabled" }
            MeoFilterGroup { width: parent.width; model: [{ "label": "Available" }, { "label": "Unavailable", "enabled": false }, { "label": "Selected" }]; currentIndex: 2 }
        }
    }
    Component {
        id: stepperSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space24

            SampleLabel { label: "1. Horizontal current" }
            MeoStepper { width: 420 * MeoTheme.globalScale; model: ["Account", "Profile", "Review"]; currentIndex: 1 }

            SampleLabel { label: "2. Vertical completed" }
            MeoStepper { height: 220 * MeoTheme.globalScale; orientation: "vertical"; model: ["Draft", "Check", "Publish"]; currentIndex: 3 }

            SampleLabel { label: "3. First step" }
            MeoStepper { width: 420 * MeoTheme.globalScale; model: ["Choose", "Configure", "Finish"]; currentIndex: 0 }

            SampleLabel { label: "4. Interactive" }
            MeoStepper { height: 220 * MeoTheme.globalScale; orientation: "vertical"; model: ["Source", "Preview", "Save"]; currentIndex: 1; interactive: true }

            SampleLabel { label: "5. Disabled" }
            MeoStepper { width: 420 * MeoTheme.globalScale; model: ["Sign in", "Verify", "Done"]; currentIndex: 1; enabled: false }
        }
    }
    Component {
        id: navigationBarSample
        Column {
            width: 440 * MeoTheme.globalScale
            spacing: MeoTheme.space8

            SampleLabel { label: "1. Always labels · active indicator" }
            MeoNavigationBar {
                width: parent.width
                model: [
                    { "id": "home", "label": "Home", "icon": "home" },
                    { "id": "explore", "label": "Explore", "icon": "explore" },
                    { "id": "library", "label": "Library", "icon": "folder" }
                ]
                currentId: "explore"
            }

            SampleLabel { label: "2. Selected label" }
            MeoNavigationBar {
                width: parent.width
                labelType: "selected"
                model: [
                    { "id": "home", "label": "Home", "icon": "home" },
                    { "id": "browse", "label": "Browse", "icon": "explore" },
                    { "id": "radio", "label": "Radio", "icon": "radio" },
                    { "id": "library", "label": "Library", "icon": "folder" }
                ]
                currentId: "home"
            }

            SampleLabel { label: "3. Icon-only with notification dot" }
            MeoNavigationBar {
                width: parent.width
                labelType: "none"
                model: [
                    { "id": "home", "label": "Home", "icon": "home" },
                    { "id": "inbox", "label": "Inbox", "icon": "inbox", "badgeDot": true },
                    { "id": "saved", "label": "Saved", "icon": "favorite" }
                ]
                currentId: "inbox"
            }

            SampleLabel { label: "4. Numeric badge" }
            MeoNavigationBar {
                width: parent.width
                model: [
                    { "id": "home", "label": "Home", "icon": "home" },
                    { "id": "updates", "label": "Updates", "icon": "notifications", "badgeText": "24" },
                    { "id": "settings", "label": "Settings", "icon": "settings" }
                ]
                currentId: "updates"
            }

            SampleLabel { label: "5. Disabled destination" }
            MeoNavigationBar {
                width: parent.width
                compact: true
                model: [
                    { "id": "home", "label": "Home", "icon": "home" },
                    { "id": "locked", "label": "Locked", "icon": "lock", "enabled": false },
                    { "id": "profile", "label": "Profile", "icon": "person" }
                ]
                currentId: "profile"
            }
        }
    }
    Component {
        id: navigationRailSample
        Grid {
            id: railExamples
            columns: 3
            rowSpacing: MeoTheme.space24
            columnSpacing: MeoTheme.space24
            readonly property var railItems: [
                { "id": "inbox", "label": "Inbox", "icon": "inbox", "badgeText": "24" },
                { "id": "outbox", "label": "Outbox", "icon": "send" },
                { "id": "favorites", "label": "Favorites", "icon": "favorite" },
                { "id": "trash", "label": "Trash", "icon": "delete" },
                { "type": "header", "label": "Labels" },
                { "id": "label", "label": "Label", "icon": "folder", "badgeDot": true }
            ]
            readonly property var compactRailItems: [
                { "id": "inbox", "label": "Inbox", "icon": "inbox", "badgeText": "24" },
                { "id": "outbox", "label": "Outbox", "icon": "send" },
                { "id": "favorites", "label": "Favorites", "icon": "favorite" },
                { "id": "trash", "label": "Trash", "icon": "delete" }
            ]

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Collapsed · 96dp" }
                MeoNavigationRail {
                    height: 380 * MeoTheme.globalScale
                    model: railExamples.compactRailItems
                    currentIndex: 0
                    labelType: "always"
                    header: Component {
                        Column {
                            spacing: MeoTheme.space12
                            MeoIconButton { anchors.horizontalCenter: parent.horizontalCenter; icon.name: "menu"; type: "standard" }
                            MeoFAB { anchors.horizontalCenter: parent.horizontalCenter; type: "small"; icon.name: "edit" }
                        }
                    }
                    footer: Component {
                        MeoIconButton { anchors.horizontalCenter: parent.horizontalCenter; icon.name: "settings"; type: "standard" }
                    }
                }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Collapsed · selected label" }
                MeoNavigationRail {
                    height: 380 * MeoTheme.globalScale
                    model: railExamples.compactRailItems
                    currentIndex: 1
                    labelType: "selected"
                }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Expanded · 220dp" }
                MeoNavigationRail {
                    height: 380 * MeoTheme.globalScale
                    model: railExamples.compactRailItems
                    currentIndex: 0
                    isExpanded: true
                    expandedWidth: 220 * MeoTheme.globalScale
                }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Expanded · menu and FAB" }
                MeoNavigationRail {
                    height: 500 * MeoTheme.globalScale
                    model: railExamples.railItems
                    currentIndex: 0
                    isExpanded: true
                    expandedWidth: 280 * MeoTheme.globalScale
                    header: Component {
                        Row {
                            spacing: MeoTheme.space8
                            MeoIconButton { icon.name: "menu"; type: "standard" }
                            MeoButton { text: "Compose"; type: "filled"; icon.name: "edit" }
                        }
                    }
                }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Expanded · 360dp groups" }
                MeoNavigationRail {
                    height: 500 * MeoTheme.globalScale
                    model: railExamples.railItems
                    currentIndex: 5
                    isExpanded: true
                    expandedWidth: 360 * MeoTheme.globalScale
                }
            }
        }
    }
    Component {
        id: navigationDrawerSample
        Column {
            spacing: MeoTheme.space8
            SampleLabel { label: "Legacy compatibility · 360dp baseline; prefer expanded MeoNavigationRail" }
            MeoNavigationDrawer { width: 360 * MeoTheme.globalScale; height: 300 * MeoTheme.globalScale; model: control.navItems; currentIndex: 0; title: "MeoUI" }
        }
    }
    Component {
        id: navigationRailModalSample
        Column {
            spacing: MeoTheme.space8

            Timer {
                interval: 0
                running: Qt.application.arguments.indexOf("--open-navigation-rail-modal") !== -1
                onTriggered: modalRail.open()
            }

            MeoButton {
                text: "Open modal navigation rail"
                icon.name: "menu"
                onClicked: modalRail.open()
            }

            MeoNavigationRailModal {
                id: modalRail
                model: control.navItems
                currentIndex: 0
                expandedWidth: 280 * MeoTheme.globalScale
                closeOnDestination: true
                header: Component {
                    Row {
                        spacing: MeoTheme.space8
                        MeoIconButton { icon.name: "menu"; type: "standard" }
                        MeoButton { text: "Compose"; icon.name: "edit" }
                    }
                }
            }
        }
    }
    Component {
        id: modalDrawerSample
        Column {
            spacing: MeoTheme.space8

            Timer {
                interval: 0
                running: Qt.application.arguments.indexOf("--open-navigation-drawer-modal") !== -1
                onTriggered: drawer.open()
            }

            MeoButton { text: "Open modal navigation rail"; icon.name: "menu"; onClicked: drawer.open() }
            MeoNavigationDrawerModal { id: drawer; model: control.navItems }
        }
    }
    Component {
        id: drawerItemSample

        Column {
            width: 360 * MeoTheme.globalScale
            spacing: MeoTheme.space4

            MeoNavigationDrawerItem { width: parent.width; label: "Inbox"; icon: "inbox"; selected: true; badgeText: "8" }
            MeoNavigationDrawerItem { width: parent.width; label: "Archive"; icon: "archive" }
            MeoNavigationDrawerItem { width: parent.width; label: "Updates"; icon: "update"; mode: "group"; selected: true; supportingText: "Grouped row"; showDivider: true; roundedBottom: false }
            MeoNavigationDrawerItem { width: parent.width; label: "Advanced"; icon: "tune"; mode: "group"; supportingText: "Supporting text"; roundedTop: false }
            MeoNavigationDrawerItem { width: parent.width; label: "Settings"; icon: "settings"; selected: true; visualStyle: "settings" }
        }
    }
    Component {
        id: navigationSuiteSample
        Item {
            width: 520 * MeoTheme.globalScale
            height: 180 * MeoTheme.globalScale

            MeoNavigationSuite {
                id: navigationSuite
                anchors.fill: parent
                model: [
                    { "id": "home", "label": "Home", "icon": "home" },
                    { "id": "explore", "label": "Explore", "icon": "explore", "badgeText": "3" },
                    { "id": "profile", "label": "Profile", "icon": "person" },
                    { "id": "library", "label": "Library", "icon": "library_music" },
                    { "id": "settings", "label": "Settings", "icon": "settings" },
                    { "id": "help", "label": "Help", "icon": "help" }
                ]
                currentIndex: 0
                availableWidth: width
                // Keep the compact default visible in the Showcase. The
                // optional modal rail remains available through More and the
                // --open-navigation-suite-modal validation argument below.
                compactPresentation: "bottomBar"
            }

            Timer {
                interval: 0
                running: Qt.application.arguments.indexOf("--open-navigation-suite-modal") !== -1
                onTriggered: navigationSuite.openOverflow()
            }
        }
    }
    Component {
        id: breadcrumbsSample
        Grid {
            width: 704 * MeoTheme.globalScale
            columns: 2
            columnSpacing: MeoTheme.space16
            rowSpacing: MeoTheme.space12

            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "1. Icons" }
                MeoBreadcrumbs { model: [{ "label": "Home", "icon": "home" }, { "label": "Library", "icon": "folder" }, { "label": "Component" }] }
            }
            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "2. Text-only" }
                MeoBreadcrumbs { model: [{ "label": "Home" }, { "label": "Articles" }, { "label": "M3 navigation" }] }
            }
            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "3. Custom separator" }
                MeoBreadcrumbs { separator: "arrow_forward"; model: [{ "label": "Drive", "icon": "folder" }, { "label": "Shared" }, { "label": "Preview" }] }
            }
            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "4. Explicit current item" }
                MeoBreadcrumbs { currentIndex: 1; model: [{ "label": "Projects", "icon": "folder" }, { "label": "MeoUI" }, { "label": "Archive" }] }
            }
            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "5. Disabled link" }
                MeoBreadcrumbs { model: [{ "label": "Home", "icon": "home" }, { "label": "Restricted", "enabled": false }, { "label": "Current" }] }
            }
        }
    }
    Component {
        id: tabsSample
        Row {
            spacing: MeoTheme.space24

            Column {
                width: 340 * MeoTheme.globalScale
                spacing: MeoTheme.space12

                SampleLabel { label: "1. Primary with icons" }
                MeoTabs {
                    width: parent.width
                    model: [{ "label": "Video", "icon": "videocam" }, { "label": "Photos", "icon": "photo", "badgeDot": true }, { "label": "Audio", "icon": "audiotrack" }]
                    currentIndex: 1
                }

                SampleLabel { label: "2. Primary text" }
                MeoTabs {
                    width: parent.width
                    model: ["Overview", "Specs", "Reviews"]
                    currentIndex: 0
                }

                SampleLabel { label: "3. Secondary" }
                MeoTabs {
                    width: parent.width
                    type: "secondary"
                    model: ["Explore", "Flights", "Trips"]
                    currentIndex: 2
                }
            }

            Column {
                width: 340 * MeoTheme.globalScale
                spacing: MeoTheme.space12

                SampleLabel { label: "4. Expressive pill" }
                MeoTabs {
                    width: parent.width
                    style: "expressive"
                    model: [{ "label": "For you", "icon": "auto_awesome" }, { "label": "Following", "icon": "groups" }, { "label": "Saved", "icon": "bookmark" }]
                    currentIndex: 0
                }

                SampleLabel { label: "5. Scrollable" }
                MeoTabs {
                    width: parent.width
                    isScrollable: true
                    model: ["Overview", "Specifications", "Reviews", "Support"]
                    currentIndex: 1
                }
            }
        }
    }
    Component {
        id: topAppBarSample
        Row {
            width: 760 * MeoTheme.globalScale
            spacing: MeoTheme.space16

            Column {
                width: 372 * MeoTheme.globalScale
                spacing: MeoTheme.space8

                SampleLabel { label: "1. Small" }
                MeoTopAppBar {
                    width: parent.width
                    title: "Inbox"
                    type: "small"
                    navigationIcon: Component { MeoIconButton { icon.name: "menu"; type: "standard" } }
                    actions: [Component { MeoIconButton { icon.name: "search" } }, Component { MeoIconButton { icon.name: "more_vert" } }]
                }

                SampleLabel { label: "2. Center-aligned" }
                MeoTopAppBar {
                    width: parent.width
                    title: "Now playing"
                    type: "center"
                    navigationIcon: Component { MeoIconButton { icon.name: "arrow_back"; type: "standard" } }
                    actions: [Component { MeoIconButton { icon.name: "cast" } }]
                }

                SampleLabel { label: "3. Medium" }
                MeoTopAppBar {
                    width: parent.width
                    title: "Library"
                    type: "medium"
                    navigationIcon: Component { MeoIconButton { icon.name: "arrow_back"; type: "standard" } }
                    actions: [Component { MeoIconButton { icon.name: "search" } }, Component { MeoIconButton { icon.name: "favorite" } }]
                }
            }

            Column {
                width: 372 * MeoTheme.globalScale
                spacing: MeoTheme.space8

                SampleLabel { label: "4. Large flexible · collapsed pose" }
                MeoTopAppBar {
                    width: parent.width
                    title: "Discover"
                    type: "large"
                    flexible: true
                    scrollProgress: 0
                    navigationIcon: Component { MeoIconButton { icon.name: "menu"; type: "standard" } }
                    actions: [Component { MeoIconButton { icon.name: "search" } }]
                }

                SampleLabel { label: "5. Contextual selection" }
                MeoTopAppBar {
                    width: parent.width
                    title: "Ignored when contextual"
                    type: "small"
                    isContextual: true
                    selectionCount: 3
                    navigationIcon: Component { MeoIconButton { icon.name: "close"; type: "standard" } }
                    actions: [Component { MeoIconButton { icon.name: "delete" } }, Component { MeoIconButton { icon.name: "archive" } }]
                }
            }
        }
    }
    Component {
        id: bottomAppBarSample
        MeoBottomAppBar {
            width: 500 * MeoTheme.globalScale
            navigationIcons: ["check_box", "edit", "search", "more_vert"]
            fab: Component { MeoFAB { type: "regular"; icon.name: "add" } }
        }
    }
    Component {
        id: menuSample
        Item {
            id: menuRoot
            width: 560 * MeoTheme.globalScale
            height: 392 * MeoTheme.globalScale

            Column {
                x: MeoTheme.space8
                y: MeoTheme.space8
                spacing: MeoTheme.space12

                MeoText {
                    text: "M3 menus"
                    typeRole: "title"
                    typeSize: "small"
                }

                MeoText {
                    text: "Standard, vibrant, checked, keyboard, shortcuts, labels, dividers, and submenus."
                    typeRole: "body"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                }

                Flow {
                    spacing: MeoTheme.space8
                    MeoButton { text: "Open standard"; icon.name: "more_vert"; onClicked: standardMenu.openFrom(this) }
                    MeoButton { text: "Open vibrant"; type: "tonal"; icon.name: "palette"; onClicked: vibrantMenu.openFrom(this) }
                    MeoButton { text: "Open submenu"; type: "outlined"; icon.name: "arrow_right"; onClicked: standardMenu.openSubmenu(4, standardMenu.model[4], standardMenu.menuItemAt(4)) }
                }
            }

            Timer {
                interval: 0
                running: Qt.application.arguments.indexOf("--open-menu=standard") !== -1
                onTriggered: standardMenu.open()
            }

            Timer {
                interval: 0
                running: Qt.application.arguments.indexOf("--open-menu=vibrant") !== -1
                onTriggered: vibrantMenu.open()
            }

            Timer {
                interval: 90
                running: Qt.application.arguments.indexOf("--open-menu=submenu") !== -1
                onTriggered: {
                    standardMenu.open()
                    submenuScreenshotTimer.start()
                }
            }

            Timer {
                id: submenuScreenshotTimer
                interval: 180
                repeat: false
                onTriggered: standardMenu.openSubmenu(4, standardMenu.model[4], standardMenu.menuItemAt(4))
            }

            MeoMenu {
                id: standardMenu
                parent: menuRoot
                z: 1000
                x: MeoTheme.space8
                y: 112 * MeoTheme.globalScale
                itemSpacing: MeoTheme.space4
                model: [
                    { "type": "label", "label": "EDIT" },
                    { "label": "Copy", "icon": "content_copy", "trailingText": "Ctrl+C" },
                    { "label": "Share", "icon": "share", "selected": true },
                    { "label": "Offline mode", "icon": "cloud_off", "checked": true, "supportingText": "Saved locally" },
                    { "label": "More tools", "icon": "folder", "subItems": [{ "label": "Document", "icon": "article" }, { "label": "Image", "icon": "image", "selected": true }, { "label": "Slides", "icon": "slideshow" }] },
                    { "type": "separator" },
                    { "label": "Paste", "icon": "content_paste", "trailingText": "Ctrl+V", "enabled": false },
                    { "label": "Delete", "icon": "delete", "trailingIcon": "keyboard_return" }
                ]
            }

            MeoMenu {
                id: vibrantMenu
                parent: menuRoot
                z: 1001
                x: 280 * MeoTheme.globalScale
                y: 112 * MeoTheme.globalScale
                vibrant: true
                itemSpacing: MeoTheme.space4
                model: [
                    { "label": "Create", "icon": "edit" },
                    { "label": "Offline mode", "icon": "cloud_off", "checked": true },
                    { "label": "Settings", "icon": "settings" },
                    { "label": "Help & feedback", "icon": "help" }
                ]
            }
        }
    }
    Component { id: dataTableSample; MeoDataTable { width: 520 * MeoTheme.globalScale; columns: control.tableColumns; model: control.tableRows; selectable: true; sortProperty: "calories" } }
    Component {
        id: listItemSample
        Column {
            width: 420 * MeoTheme.globalScale
            spacing: MeoTheme.space4

            SampleLabel { label: "1. One-line with badge" }
            MeoListItem { width: parent.width; headline: "Inbox"; leadingIcon: "inbox"; badgeText: "3" }

            SampleLabel { label: "2. Supporting text" }
            MeoListItem { width: parent.width; headline: "Release notes"; supportingText: "Updated 10 minutes ago"; leadingIcon: "article" }

            SampleLabel { label: "3. Tonal selected" }
            MeoListItem { width: parent.width; headline: "Selected row"; supportingText: "Secondary container"; leadingIcon: "check_circle"; selected: true; isSegmented: true }

            SampleLabel { label: "4. Expressive vibrant" }
            MeoListItem { width: parent.width; headline: "Pinned item"; supportingText: "Primary in expressive mode"; leadingIcon: "push_pin"; selected: true; isSegmented: true; vibrant: true }

            SampleLabel { label: "5. Disabled" }
            MeoListItem { width: parent.width; headline: "Unavailable item"; supportingText: "This action is disabled"; leadingIcon: "block"; enabled: false }
        }
    }
    Component {
        id: listHeaderSample
        Row {
            spacing: MeoTheme.space16

            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "1. Standard"; horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: "Recent" }
            }
            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "2. Emphasized"; horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: "Pinned"; type: "emphasized" }
            }
            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "3. Compact padding"; horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: "Today"; leftPadding: 8 * MeoTheme.globalScale; rightPadding: 8 * MeoTheme.globalScale }
            }
            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "4. Long text"; horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: "Very long section title that truncates"; type: "emphasized" }
            }
            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "5. Spacious"; horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: "Archives"; topPadding: 8 * MeoTheme.globalScale; bottomPadding: 8 * MeoTheme.globalScale }
            }
        }
    }
    Component {
        id: groupedListSample
        Row {
            spacing: MeoTheme.space24
            MeoGroupedList {
                width: 360 * MeoTheme.globalScale
                title: "Recent files"
                subtitle: "A connected list has one shared surface."
                selectedIndex: 1
                model: [
                    { "label": "Release notes", "icon": "article", "trailingText": "Today" },
                    { "label": "Component audit", "icon": "fact_check", "supportingText": "Updated 10 minutes ago", "badgeText": "3" },
                    { "label": "Archived draft", "icon": "archive", "enabled": false }
                ]
            }
            MeoGroupedList {
                width: 300 * MeoTheme.globalScale
                title: "No dividers"
                showDividers: false
                showChevron: false
                model: [
                    { "label": "One surface", "icon": "layers" },
                    { "label": "Tonal selection", "icon": "check_circle" }
                ]
                selectedIndex: 1
            }
        }
    }
    Component {
        id: badgeSample
        Grid {
            width: 560 * MeoTheme.globalScale
            columns: 3
            columnSpacing: MeoTheme.space20
            rowSpacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: "1. Dot" }
                MeoBadge { isDot: true }
            }
            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: "2. Single digit" }
                MeoBadge { text: "8" }
            }
            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: "3. Two digits" }
                MeoBadge { text: "24" }
            }
            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: "4. Overflow" }
                MeoBadge { text: "120"; maxCount: 99 }
            }
            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: "5. Attached target" }
                Item {
                    width: 48 * MeoTheme.globalScale
                    height: width
                    MeoIconButton { id: inboxTarget; anchors.centerIn: parent; icon.name: "inbox"; type: "standard" }
                    MeoBadge { target: inboxTarget; text: "3" }
                }
            }
        }
    }
    Component {
        id: avatarSample
        Row {
            spacing: MeoTheme.space20
            Column {
                width: 86 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "1. Circle"; horizontalAlignment: Text.AlignHCenter }
                MeoAvatar { anchors.horizontalCenter: parent.horizontalCenter; initials: "ME"; size: 32; variant: "circle" }
            }
            Column {
                width: 86 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "2. Squircle"; horizontalAlignment: Text.AlignHCenter }
                MeoAvatar { anchors.horizontalCenter: parent.horizontalCenter; initials: "UI"; size: 40; variant: "squircle" }
            }
            Column {
                width: 86 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "3. Hexagon"; horizontalAlignment: Text.AlignHCenter }
                MeoAvatar { anchors.horizontalCenter: parent.horizontalCenter; initials: "M3"; size: 48; variant: "hexagon" }
            }
            Column {
                width: 104 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "4. Icon fallback"; horizontalAlignment: Text.AlignHCenter }
                MeoAvatar { anchors.horizontalCenter: parent.horizontalCenter; size: 40; variant: "circle" }
            }
            Column {
                width: 112 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: "5. Large diamond"; horizontalAlignment: Text.AlignHCenter }
                MeoAvatar { anchors.horizontalCenter: parent.horizontalCenter; initials: "AI"; size: 56; variant: "diamond" }
            }
        }
    }
    Component {
        id: dividerSample
        Row {
            spacing: MeoTheme.space24

            Column {
                width: 230 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { label: "1. Horizontal · 1dp" }
                MeoDivider { width: parent.width }
                SampleLabel { label: "2. Horizontal inset · 24dp" }
                MeoDivider { width: parent.width; leftInset: 24 * MeoTheme.globalScale; rightInset: 24 * MeoTheme.globalScale }
                SampleLabel { label: "3. Horizontal · 2dp" }
                MeoDivider { width: parent.width; thickness: 2 * MeoTheme.globalScale }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "4. Vertical · 1dp" }
                MeoDivider { anchors.horizontalCenter: parent.horizontalCenter; orientation: "vertical"; height: 52 * MeoTheme.globalScale }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "5. Vertical inset · 3dp" }
                MeoDivider {
                    anchors.horizontalCenter: parent.horizontalCenter
                    orientation: "vertical"
                    height: 52 * MeoTheme.globalScale
                    topInset: 8 * MeoTheme.globalScale
                    bottomInset: 12 * MeoTheme.globalScale
                    thickness: 3 * MeoTheme.globalScale
                }
            }
        }
    }
    Component {
        id: skeletonSample
        Row {
            spacing: MeoTheme.space20

            Column {
                width: 200 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: "1. Text · animated"; horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "text"; width: 180 * MeoTheme.globalScale }
            }
            Column {
                width: 180 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: "2. Text · static"; horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "text"; width: 140 * MeoTheme.globalScale; active: false }
            }
            Column {
                width: 90 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: "3. Avatar"; horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "avatar" }
            }
            Column {
                width: 140 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: "4. Pill"; horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "pill" }
            }
            Column {
                width: 180 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: "5. Card"; horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "card"; width: 168 * MeoTheme.globalScale; height: 88 * MeoTheme.globalScale }
            }
        }
    }
    Component {
        id: cardSample
        Grid {
            columns: 3
            spacing: MeoTheme.space24
            SurfaceCard { title: "Elevated"; cardType: "elevated" }
            SurfaceCard { title: "Filled"; cardType: "filled" }
            SurfaceCard { title: "Outlined"; cardType: "outlined" }
            SurfaceCard { title: "Selected"; cardType: "filled"; selected: true }
            SurfaceCard { title: "Interactive"; cardType: "elevated"; interactive: true }
            SurfaceCard { title: "Disabled"; cardType: "filled"; enabledState: false }
        }
    }

    Component {
        id: dialogSample
        Column {
            spacing: MeoTheme.space12

            Timer {
                interval: 0
                running: Qt.application.arguments.indexOf("--open-dialog=basic") !== -1
                onTriggered: basicDialog.open()
            }

            Flow {
                spacing: MeoTheme.space8

                MeoButton {
                    text: "Basic dialog"
                    onClicked: basicDialog.open()
                }

                MeoButton {
                    text: "Dialog with icon"
                    type: "tonal"
                    onClicked: iconDialog.open()
                }

                MeoButton {
                    text: "Single select"
                    type: "outlined"
                    onClicked: singleSelectDialog.open()
                }

                MeoButton {
                    text: "Multi select"
                    type: "outlined"
                    onClicked: multiSelectDialog.open()
                }
            }

            MeoDialog {
                id: basicDialog
                title: "Basic dialog"
                message: "This dialog asks for a focused decision."
                confirmText: "Accept"
                cancelText: "Cancel"
            }

            MeoDialog {
                id: iconDialog
                icon: "info"
                title: "Dialog with icon"
                message: "A hero icon reinforces the message."
                confirmText: "Confirm"
                cancelText: "Dismiss"
            }

            MeoExpressiveDialog {
                id: singleSelectDialog
                title: "Choose density"
                message: "Selection dialogs keep choices in one focused surface."
                confirmText: "Apply"
                cancelText: "Cancel"
                content: Component {
                    Column {
                        spacing: MeoTheme.space8
                        MeoRadioButton { label: "Comfortable"; checked: true }
                        MeoRadioButton { label: "Compact" }
                        MeoRadioButton { label: "Expanded" }
                    }
                }
            }

            MeoExpressiveDialog {
                id: multiSelectDialog
                title: "Visible columns"
                message: "Use checkboxes when multiple items can stay selected."
                confirmText: "Save"
                cancelText: "Cancel"
                content: Component {
                    Column {
                        spacing: MeoTheme.space8
                        MeoCheckbox { label: "Name"; checked: true }
                        MeoCheckbox { label: "Status"; checked: true }
                        MeoCheckbox { label: "Owner" }
                    }
                }
            }
        }
    }
    Component {
        id: fullDialogSample
        Column {
            spacing: MeoTheme.space8

            Timer {
                interval: 0
                running: Qt.application.arguments.indexOf("--open-dialog=full") !== -1
                onTriggered: full.open()
            }

            MeoButton {
                text: "Open full-screen dialog"
                icon.name: "edit"
                onClicked: full.open()
            }

            MeoFullScreenDialog {
                id: full
                title: "Edit event"
                showDivider: true
                actions: [{ "text": "Save" }]
                bottomActions: [{ "text": "Cancel" }, { "text": "Apply" }]
                content: Component {
                    Column {
                        width: parent ? parent.width : 0
                        spacing: MeoTheme.space16

                        MeoTextField {
                            width: parent.width
                            label: "Event name"
                            placeholder: "Design review"
                            type: "outlined"
                        }

                        MeoTextField {
                            width: parent.width
                            label: "Location"
                            placeholder: "Studio"
                            type: "outlined"
                            leadingIcon: "place"
                        }

                        MeoDivider { width: parent.width }

                        MeoText {
                            text: "Schedule"
                            typeRole: "title"
                            typeSize: "small"
                            color: MeoTheme.contentOnSurface
                        }

                        Row {
                            width: parent.width
                            spacing: MeoTheme.space12

                            MeoExposedDropdown {
                                width: (parent.width - MeoTheme.space12) / 2
                                label: "From"
                                model: ["09:00", "10:00", "11:00"]
                            }

                            MeoExposedDropdown {
                                width: (parent.width - MeoTheme.space12) / 2
                                label: "To"
                                model: ["10:00", "11:00", "12:00"]
                            }
                        }
                    }
                }
            }
        }
    }
    Component { id: expressiveDialogSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open expressive dialog"; onClicked: dialog.open() } MeoExpressiveDialog { id: dialog; title: "Expressive"; message: "Custom content and shape."; icon: "auto_awesome" } } }
    Component { id: bottomSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open bottom sheet"; onClicked: sheet.open() } MeoBottomSheet { id: sheet; content: Component { MeoText { text: "Bottom sheet content"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: standardSheetSample; Item { width: 420 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; MeoStandardBottomSheet { anchors.fill: parent; isOpen: true; content: Component { MeoText { text: "Standard sheet"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: sideSheetSample; Item { width: 420 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; MeoSideSheet { anchors.right: parent.right; width: 240 * MeoTheme.globalScale; height: parent.height; isOpen: true; content: Component { MeoText { text: "Details"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: modalSideSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open side sheet"; onClicked: sheet.open() } MeoSideSheetModal { id: sheet; content: Component { MeoText { text: "Modal side sheet"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: actionSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open action sheet"; onClicked: sheet.open() } MeoActionSheet { id: sheet; title: "Share"; model: [{ "label": "Messages", "icon": "chat" }, { "label": "Email", "icon": "mail" }] } } }
    Component {
        id: bannerSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            MeoBanner { width: parent.width; title: "Information"; text: "This banner uses a tonal semantic container."; icon: "info" }
            MeoBanner { width: parent.width; title: "Network restored"; text: "Your work is syncing again."; icon: "cloud_done"; tone: "success" }
            MeoBanner { width: parent.width; title: "Storage almost full"; text: "Free space before creating a backup."; icon: "error"; tone: "error" }
            MeoBanner { width: parent.width; text: "This banner includes two actions."; icon: "info"; confirmText: "Action"; cancelText: "Dismiss" }
            MeoBanner { width: parent.width; title: "Title-only alert"; icon: "notifications" }
        }
    }
    Component {
        id: snackbarSample
        Column {
            spacing: MeoTheme.space8

            Flow {
                spacing: MeoTheme.space8

                MeoButton {
                    text: "Show snackbar"
                    type: "filled"
                    onClicked: {
                        snackbar.message = "Message sent"
                        snackbar.actionText = ""
                        snackbar.open()
                    }
                }

                MeoButton {
                    text: "With action"
                    type: "outlined"
                    onClicked: {
                        snackbar.message = "Photo deleted"
                        snackbar.actionText = "Undo"
                        snackbar.open()
                    }
                }
            }

            MeoSnackbar {
                id: snackbar
                message: "Saved"
                actionText: "Undo"
                Component.onCompleted: open()
            }
        }
    }

    Component {
        id: tooltipSample
        Item {
            width: 260 * MeoTheme.globalScale
            height: MeoTheme.buttonHeightL

            MeoButton {
                id: hoverButton
                anchors.centerIn: parent
                text: "Hover target"
                type: "outlined"
            }

            MouseArea {
                anchors.fill: hoverButton
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onEntered: tip.open()
                onExited: tip.close()
            }

            MeoTooltip {
                id: tip
                text: "Tooltip on hover"
                x: hoverButton.x + hoverButton.width / 2 - width / 2
                y: hoverButton.y - height - MeoTheme.space8
                Component.onCompleted: open()
            }
        }
    }
    Component {
        id: richTooltipSample
        Column {
            spacing: MeoTheme.space8
            MeoButton { text: "Open rich tooltip"; onClicked: tip.open() }
            MeoRichTooltip {
                id: tip
                title: "Rich tooltip"
                text: "Useful supporting detail with one focused action."
                actions: [{ "text": "Learn more" }]
                Component.onCompleted: open()
            }
        }
    }
    Component {
        id: progressSample
        Grid {
            columns: 3
            spacing: MeoTheme.space12

            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: "1. Determinate linear" }
                MeoProgressBar { width: parent.width; value: 0.42 }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: "2. Indeterminate linear" }
                MeoProgressBar { width: parent.width; indeterminate: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: "3. 8dp linear" }
                MeoProgressBar { width: parent.width; value: 0.62; isThick: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: "4. Circle · 4dp" }
                MeoProgressBar { type: "circular"; value: 0.62 }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: "5. Circle · 8dp" }
                MeoProgressBar { type: "circular"; value: 0.62; isThick: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: "6. Wavy circle · 4dp" }
                MeoProgressBar { type: "circular"; value: 0.62; wavy: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: "7. Wavy circle · 8dp" }
                MeoProgressBar { type: "circular"; value: 0.62; wavy: true; isThick: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: "8. Linear wave · 10dp bounds" }
                MeoProgressBar { width: parent.width; wavy: true; value: 0.72 }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: "9. Linear wave · 14dp bounds" }
                MeoProgressBar { width: parent.width; wavy: true; isThick: true; value: 0.72 }
            }
        }
    }

    Component {
        id: loadingSample
        Flow {
            spacing: MeoTheme.space16
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "1. Default · indeterminate" }
                MeoLoadingIndicator { running: true }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "2. Contained · indeterminate" }
                MeoLoadingIndicator { variant: "contained"; running: true }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "3. Default · 42%" }
                MeoLoadingIndicator { indeterminate: false; value: 0.42 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "4. Contained · 78%" }
                MeoLoadingIndicator { variant: "contained"; indeterminate: false; value: 0.78 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "5. Paused · stable pose" }
                MeoLoadingIndicator { running: false }
            }
        }
    }
    Component {
        id: pullRefreshSample
        Row {
            spacing: MeoTheme.space24

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Idle (hidden)" }
                MeoPullToRefresh { pullDistance: 0 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Partial pull · 45%" }
                MeoPullToRefresh { pullDistance: 0.45 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Threshold ready" }
                MeoPullToRefresh { pullDistance: 1 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Refreshing" }
                MeoPullToRefresh { refreshing: true }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: "Disabled" }
                MeoPullToRefresh { pullDistance: 1; pullEnabled: false }
            }
        }
    }
    Component { id: emptyStateSample; MeoEmptyState { width: 420 * MeoTheme.globalScale; icon: "inbox"; title: "No messages"; description: "Empty states explain what happened."; actionText: "Refresh" } }
    Component {
        id: searchBarSample
        Column {
            spacing: MeoTheme.space8
            SampleLabel { label: "Standard" }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: "Search components" }
            SampleLabel { label: "Active query" }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: "Search components"; active: true; text: "MeoTheme" }
            SampleLabel { label: "Pixel" }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: "Search apps"; visualStyle: "pixel" }
            SampleLabel { label: "Settings" }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: "Search settings"; visualStyle: "settings" }
            SampleLabel { label: "Launcher" }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: "Search device"; visualStyle: "launcher" }
        }
    }
    Component {
        id: dockedSearchSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space16
            SampleLabel { label: "Contained (recommended)" }
            MeoDockedSearchBar {
                width: parent.width
                text: "meo"
                placeholder: "Search components"
                resultsTitle: "Results"
                isExpanded: true
                suggestions: [{ "label": "MeoTheme tokens", "icon": "palette" }, { "label": "MeoButton usage", "icon": "smart_button" }]
            }
            SampleLabel { label: "Divided (legacy compatibility)" }
            MeoDockedSearchBar {
                width: parent.width
                text: "meo"
                placeholder: "Search components"
                resultsTitle: "Results"
                style: "divided"
                isExpanded: true
                suggestions: [{ "label": "MeoSlider usage", "icon": "tune" }, { "label": "MeoToolbar actions", "icon": "toolbar" }]
            }
        }
    }
    Component {
        id: searchAppBarSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            SampleLabel { label: "Default" }
            MeoSearchAppBar { width: parent.width; placeholder: "Searchable page" }
            SampleLabel { label: "Active input" }
            MeoSearchAppBar { width: parent.width; placeholder: "Searchable page"; active: true; text: "MeoTheme" }
        }
    }
    Component {
        id: searchViewSample
        Item {
            width: 560 * MeoTheme.globalScale
            height: 420 * MeoTheme.globalScale
            Rectangle { anchors.fill: parent; radius: MeoTheme.windowRadius; color: MeoTheme.surfaceContainerLow }
            MeoSearchView {
                parent: parent
                layout: "docked"
                style: "contained"
                dockedWidth: parent.width
                dockedHeight: parent.height
                edgeMargin: 0
                text: "meo"
                placeholder: "Search components"
                resultsTitle: "Results"
                suggestions: [{ "label": "MeoTheme tokens", "icon": "palette" }, { "label": "MeoButton usage", "icon": "smart_button" }, { "label": "MeoSlider usage", "icon": "tune" }]
                Component.onCompleted: open()
            }
        }
    }
    Component {
        id: searchSuggestionsSample
        Column {
            width: 420 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            SampleLabel { label: "Query highlight" }
            MeoSearchSuggestions { width: parent.width; highlightText: "meo"; model: [{ "label": "MeoTheme tokens", "icon": "palette" }, { "label": "MeoButton usage", "icon": "smart_button" }] }
            SampleLabel { label: "History removal" }
            MeoSearchSuggestions { width: parent.width; model: [{ "label": "Recent MeoTheme search", "isHistory": true }] }
            SampleLabel { label: "Literal query" }
            MeoSearchSuggestions { width: parent.width; highlightText: "["; model: [{ "label": "Search [components]", "icon": "search" }] }
        }
    }
    Component { id: searchHeaderSample; MeoSearchHeader { width: 520 * MeoTheme.globalScale; title: "Library"; placeholder: "Search"; actions: [Component { MeoIconButton { icon.name: "help" } }] } }
    Component { id: searchFilterSample; MeoSearchFilterBar { width: 520 * MeoTheme.globalScale; placeholder: "Search issues"; filterModel: control.chipItems; selectedFilterIndices: [0, 2] } }
    Component {
        id: carouselSample
        Column {
            width: 560 * MeoTheme.globalScale
            spacing: MeoTheme.space16

            SampleLabel { label: "Multi-browse" }
            MeoCarousel {
                width: parent.width
                itemHeight: 140 * MeoTheme.globalScale
                type: "multi-browse"
                model: control.carouselItems
                delegate: Component { CarouselTile {} }
            }

            SampleLabel { label: "Hero" }
            MeoCarousel {
                width: parent.width
                itemHeight: 170 * MeoTheme.globalScale
                type: "hero"
                model: control.carouselItems
                delegate: Component { CarouselTile { tileType: "hero" } }
            }

            SampleLabel { label: "Uncontained" }
            MeoCarousel {
                width: parent.width
                itemHeight: 120 * MeoTheme.globalScale
                type: "uncontained"
                showPageIndicator: false
                model: control.carouselItems
                delegate: Component { CarouselTile { tileType: "outlined" } }
            }
        }
    }
    Component {
        id: pageIndicatorSample
        Row {
            spacing: MeoTheme.space24

            PageIndicatorColumn { label: "1. First"; count: 5; currentIndex: 0 }
            PageIndicatorColumn { label: "2. Middle"; count: 5; currentIndex: 2 }
            PageIndicatorColumn { label: "3. Last"; count: 5; currentIndex: 4 }
            PageIndicatorColumn { label: "4. Dense"; count: 8; currentIndex: 5; dotSize: 6 * MeoTheme.globalScale; activeDotWidth: 18 * MeoTheme.globalScale }
            PageIndicatorColumn { label: "5. Vertical click"; count: 4; currentIndex: 1; orientation: "vertical"; interactive: true }
        }
    }
    Component {
        id: mediaSample
        Grid {
            columns: 3
            columnSpacing: MeoTheme.space16
            rowSpacing: MeoTheme.space16
            width: 704 * MeoTheme.globalScale

            Item {
                width: 224 * MeoTheme.globalScale
                height: 150 * MeoTheme.globalScale
                MeoMediaController {
                    width: 328 * MeoTheme.globalScale
                    presentation: "compact"
                    title: "Soul Curve"
                    artist: "MeoUI Sessions"
                    isPlaying: true
                    position: 45000
                    scale: 0.65
                    transformOrigin: Item.TopLeft
                }
            }
            Item {
                width: 224 * MeoTheme.globalScale
                height: 150 * MeoTheme.globalScale
                MeoMediaController {
                    width: 360 * MeoTheme.globalScale
                    presentation: "controlCenter"
                    title: "Paused track"
                    artist: "MeoUI Sessions"
                    isPlaying: false
                    liked: true
                    repeatMode: "all"
                    scale: 0.6
                    transformOrigin: Item.TopLeft
                }
            }
            Item {
                width: 224 * MeoTheme.globalScale
                height: 150 * MeoTheme.globalScale
                MeoMediaController {
                    width: 360 * MeoTheme.globalScale
                    presentation: "controlCenter"
                    title: "Unavailable seek"
                    artist: "Downloaded episode"
                    isPlaying: true
                    canSeek: false
                    canSkipNext: false
                    position: 99000
                    duration: 180000
                    scale: 0.6
                    transformOrigin: Item.TopLeft
                }
            }
            Item {
                width: 224 * MeoTheme.globalScale
                height: 250 * MeoTheme.globalScale
                MeoMediaController {
                    width: 440 * MeoTheme.globalScale
                    presentation: "lockScreen"
                    title: "Lock screen"
                    artist: "Ambient System"
                    isPlaying: true
                    scale: 0.34
                    transformOrigin: Item.TopLeft
                }
            }
            Item {
                width: 224 * MeoTheme.globalScale
                height: 160 * MeoTheme.globalScale
                MeoMediaController {
                    width: 960 * MeoTheme.globalScale
                    presentation: "fullScreen"
                    title: "Full-screen player"
                    artist: "MeoUI Orchestra"
                    isPlaying: true
                    volume: 0.42
                    scale: 0.23
                    transformOrigin: Item.TopLeft
                }
            }
        }
    }
    Component {
        id: toolbarSample
        Column {
            width: 704 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            MeoToolbar { width: parent.width; title: "1. Regular toolbar" }
            MeoToolbar {
                width: parent.width
                title: "2. Search"
                actions: [Component { MeoIconButton { icon.name: "search"; Accessible.name: "Search" } }]
            }
            MeoToolbar {
                width: parent.width
                title: "3. Actions"
                actions: [
                    Component { MeoIconButton { icon.name: "edit"; Accessible.name: "Edit" } },
                    Component { MeoIconButton { icon.name: "more_vert"; Accessible.name: "More options" } }
                ]
            }
            MeoToolbar {
                width: parent.width
                title: "4. Compact toolbar"
                isCompact: true
                actions: [Component { MeoIconButton { icon.name: "close"; Accessible.name: "Close" } }]
            }
            MeoToolbar {
                width: parent.width
                title: "5. Long title elides before actions in a narrow region"
                actions: [
                    Component { MeoIconButton { icon.name: "share"; Accessible.name: "Share" } },
                    Component { MeoIconButton { icon.name: "more_vert"; Accessible.name: "More options" } }
                ]
            }
        }
    }
    Component {
        id: dockedToolbarSample
        Grid {
            width: 704 * MeoTheme.globalScale
            columns: 2
            columnSpacing: MeoTheme.space16
            rowSpacing: MeoTheme.space12

            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "1. Standard selected action" }
                MeoDockedToolbar {
                    width: parent.width
                    actionIcons: ["arrow_back", "arrow_forward", "view_agenda", "more_vert"]
                    selectedActionIndex: 2
                }
            }

            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "2. Standard with primary action" }
                MeoDockedToolbar {
                    width: parent.width
                    actionIcons: ["archive", "delete", "more_vert"]
                    selectedActionIndex: 0
                    primaryAction: Component { MeoButton { text: "Create"; type: "filled"; icon.name: "add" } }
                }
            }

            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "3. Arbitrary action slot" }
                MeoDockedToolbar {
                    width: parent.width
                    actionIcons: ["format_bold", "format_italic"]
                    actions: [Component { MeoButton { text: "Back"; type: "text" } }]
                }
            }

            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "4. Vibrant" }
                MeoDockedToolbar {
                    width: parent.width
                    colorStyle: "vibrant"
                    actionIcons: ["archive", "delete", "mark_email_unread", "snooze", "more_vert"]
                    selectedActionIndex: 3
                }
            }

            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: "5. Disabled action" }
                MeoDockedToolbar {
                    width: parent.width
                    actionIcons: [
                        { "icon": "undo", "accessibleName": "Undo" },
                        { "icon": "redo", "accessibleName": "Redo", "enabled": false },
                        { "icon": "more_vert", "accessibleName": "More" }
                    ]
                    selectedActionIndex: 0
                }
            }
        }
    }
    Component {
        id: floatingToolbarSample
        Flow {
            width: 560 * MeoTheme.globalScale
            spacing: MeoTheme.space24
            MeoFloatingToolbar {
                actionIcons: ["format_bold", "format_italic", "format_underlined", "format_color_text", "more_vert"]
                selectedActionIndex: 0
            }
            MeoFloatingToolbar {
                colorStyle: "vibrant"
                actionIcons: ["archive", "delete", "mark_email_unread", "snooze", "more_vert"]
                selectedActionIndex: 2
                fab: Component { MeoFAB { type: "regular"; icon.name: "add" } }
            }
            MeoFloatingToolbar {
                orientation: "vertical"
                actionIcons: ["format_bold", "format_italic", "format_underlined", "format_color_text"]
                selectedActionIndex: 0
            }
        }
    }
    Component {
        id: accountHeaderSample
        Grid {
            width: 704 * MeoTheme.globalScale
            columns: 2
            columnSpacing: MeoTheme.space16
            rowSpacing: MeoTheme.space8
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: "1. Icon fallback"; email: "hello@meoarch.dev" }
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: "2. Initials"; email: "design@meoarch.dev"; avatarInitials: "MD" }
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: "3. No dropdown"; email: "local session"; avatarInitials: "LS"; showDropdown: false }
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: "4. A deliberately long account name that elides"; email: "very-long-address@meoarch.example"; avatarInitials: "LT" }
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: "5. Disabled"; email: "Interaction unavailable"; avatarInitials: "DS"; enabled: false }
        }
    }
    Component {
        id: settingsAccountCardSample
        Grid {
            columns: 2
            spacing: MeoTheme.space12
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: "1. Settings account"; subtitle: "Local session · shekong-laptop"; initials: "SH" }
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: "2. Initials fallback"; subtitle: "No avatar asset required"; initials: "IF"; avatarColor: MeoTheme.tertiaryContainer; avatarContentColor: MeoTheme.contentOnTertiaryContainer }
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: "3. Read-only identity"; subtitle: "No navigation affordance"; initials: "RO"; showChevron: false; interactive: false }
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: "4. A deliberately long account name that elides"; subtitle: "A deliberately long local session descriptor that also elides"; initials: "LT" }
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: "5. Disabled account"; subtitle: "Interaction unavailable"; initials: "DS"; enabled: false }
        }
    }
    Component {
        id: swipeToDismissSample
        Grid {
            columns: 2
            spacing: MeoTheme.space8
            Repeater {
                model: [
                    { "headline": "1. Archive or delete", "supporting": "Both swipe directions", "left": true, "right": true },
                    { "headline": "2. Archive only", "supporting": "Swipe right only", "left": true, "right": false },
                    { "headline": "3. Delete only", "supporting": "Swipe left only", "left": false, "right": true },
                    { "headline": "4. Long content label that elides", "supporting": "Text stays within the row", "left": true, "right": true },
                    { "headline": "5. Disabled", "supporting": "Swipe unavailable", "left": true, "right": true, "enabled": false }
                ]
                delegate: MeoSwipeToDismiss {
                    required property var modelData
                    width: 400 * MeoTheme.globalScale
                    enabled: modelData.enabled === undefined ? true : modelData.enabled
                    content: Component {
                        MeoListItem {
                            width: parent ? parent.width : 400 * MeoTheme.globalScale
                            headline: modelData.headline
                            supportingText: modelData.supporting
                            leadingIcon: "mail"
                        }
                    }
                    leftAction: modelData.left ? leftActionSample : null
                    rightAction: modelData.right ? rightActionSample : null
                }
            }
            Component {
                id: leftActionSample
                MeoIcon { icon: "archive"; color: MeoTheme.contentOnPrimary }
            }
            Component {
                id: rightActionSample
                MeoIcon { icon: "delete"; color: MeoTheme.contentOnError }
            }
        }
    }
    Component {
        id: chipSample
        Flow {
            spacing: MeoTheme.space8
            MeoChip { label: "1. Generic"; icon: "bolt" }
            MeoChip { label: "2. Selected"; selected: true }
            MeoChip { label: "3. Closable"; closable: true }
            MeoChip { label: "4. XL"; size: "xl"; selected: true }
            MeoChip { label: "5. Disabled"; icon: "block"; enabled: false }
        }
    }
    Component {
        id: assistChipSample
        Flow {
            spacing: MeoTheme.space8
            MeoAssistChip { label: "1. Directions"; icon: "directions" }
            MeoAssistChip { label: "2. Elevated"; icon: "star"; elevated: true }
            MeoAssistChip { label: "3. Outlined"; icon: "share"; visualStyle: "outlined" }
            MeoAssistChip { label: "4. No icon" }
            MeoAssistChip { label: "5. XL disabled"; icon: "block"; size: "xl"; enabled: false }
        }
    }
    Component {
        id: filterChipSample
        Flow {
            spacing: MeoTheme.space8
            MeoFilterChip { label: "1. Selected"; selected: true }
            MeoFilterChip { label: "2. Unselected" }
            MeoFilterChip { label: "3. Icon"; leadingIcon: "palette" }
            MeoFilterChip { label: "4. No icon" }
            MeoFilterChip { label: "5. Disabled"; leadingIcon: "code"; enabled: false }
        }
    }
    Component {
        id: inputChipSample
        Flow {
            spacing: MeoTheme.space8
            MeoInputChip { label: "1. Avery"; leadingIcon: "person" }
            MeoInputChip { label: "2. Selected"; leadingIcon: "task_alt"; selected: true }
            MeoInputChip { label: "3. Icon"; leadingIcon: "attach_file" }
            MeoInputChip { label: "4. Avatar"; avatarInitials: "AV" }
            MeoInputChip { label: "5. Disabled"; leadingIcon: "block"; enabled: false }
        }
    }
    Component {
        id: suggestionChipSample
        Flow {
            spacing: MeoTheme.space8
            MeoSuggestionChip { label: "1. Material" }
            MeoSuggestionChip { label: "2. Icon"; icon: "auto_awesome" }
            MeoSuggestionChip { label: "3. Outlined"; icon: "tips_and_updates"; visualStyle: "outlined" }
            MeoSuggestionChip { label: "4. No icon" }
            MeoSuggestionChip { label: "5. Disabled"; icon: "block"; enabled: false }
        }
    }
    Component { id: pageLayoutSample; Rectangle { width: 420 * MeoTheme.globalScale; height: 170 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.surfaceContainerLow; Column { anchors.fill: parent; anchors.margins: MeoTheme.space16; spacing: MeoTheme.space8; MeoText { text: "Page title"; typeRole: "title"; typeSize: "medium"; color: MeoTheme.contentOnSurface } MeoText { text: "Max width, padding and section spacing."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap; width: parent.width } } } }
    Component { id: scaffoldSample; Rectangle { width: 420 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.surfaceContainer; MeoText { anchors.centerIn: parent; text: "Top bar + content + bottom bar + FAB slots"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component { id: appLayoutSample; Rectangle { width: 420 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.surfaceContainerLow; Row { anchors.fill: parent; Rectangle { width: 90 * MeoTheme.globalScale; height: parent.height; color: MeoTheme.secondaryContainer; radius: MeoTheme.shapeLarge } MeoText { anchors.verticalCenter: parent.verticalCenter; text: "Drawer / rail / bottom navigation shell"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; width: 260 * MeoTheme.globalScale; wrapMode: Text.WordWrap } } } }
    Component { id: dashboardSample; MeoDashboardLayout { width: 520 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; columns: 3; model: [{ "title": "Tokens" }, { "title": "Controls" }, { "title": "Patterns" }]; delegate: Component { Rectangle { property var modelData: ({ "title": "" }); radius: MeoTheme.shapeMedium; color: MeoTheme.surfaceContainerLow; MeoText { anchors.centerIn: parent; text: modelData.title; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: feedSample; MeoFeedLayout { width: 420 * MeoTheme.globalScale; height: 190 * MeoTheme.globalScale; model: [{ "title": "Release note" }, { "title": "Component update" }]; delegate: Component { MeoListItem { property var modelData: ({ "title": "" }); width: parent.width; headline: modelData.title; leadingIcon: "article" } } } }
    Component {
        id: listDetailSample
        MeoListDetailLayout {
            width: 520 * MeoTheme.globalScale
            height: 190 * MeoTheme.globalScale
            showDetail: true
            listComponent: Component {
                MeoGroupedList {
                    model: [{ "label": "Inbox" }, { "label": "Archive" }]
                    selectedIndex: 0
                }
            }
            detailComponent: Component {
                Rectangle {
                    color: MeoTheme.surfaceContainerLow
                    radius: MeoTheme.shapeLarge
                    MeoText {
                        anchors.centerIn: parent
                        text: "Detail pane"
                        typeRole: "title"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurface
                    }
                }
            }
        }
    }
    Component { id: settingsSample; MeoSettingsLayout { width: 420 * MeoTheme.globalScale; height: 220 * MeoTheme.globalScale; title: "Settings"; model: [{ "sectionTitle": "Appearance", "items": [{ "title": "Dark theme", "subtitle": "Use dark colors", "icon": "dark_mode", "type": "switch", "checked": true }] }] } }
    Component {
        id: shapeSample
        Grid {
            columns: 5
            columnSpacing: MeoTheme.space12
            rowSpacing: MeoTheme.space16

            Repeater {
                model: ShapesEngine.materialShapeCatalog()

                delegate: Column {
                    required property var modelData
                    width: 96 * MeoTheme.globalScale
                    spacing: MeoTheme.space6

                    MeoShape {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 72 * MeoTheme.globalScale
                        height: width
                        type: modelData.name
                        color: MeoTheme.primaryContainer
                    }

                    MeoText {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.label
                        typeRole: "label"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
    Component {
        id: aiMarkSample
        Flow {
            spacing: MeoTheme.space16
            MeoAiMark { width: 48 * MeoTheme.globalScale; height: width }
            MeoAiMark { width: 64 * MeoTheme.globalScale; height: width; containerColor: MeoTheme.primary; markColor: MeoTheme.contentOnPrimary; cornerRadius: MeoTheme.shapeMedium }
            MeoAiMark { width: 64 * MeoTheme.globalScale; height: width; containerColor: MeoTheme.tertiaryContainer; markColor: MeoTheme.contentOnTertiaryContainer; cornerRadius: MeoTheme.shapeLarge }
            MeoAiMark { width: 64 * MeoTheme.globalScale; height: width; containerColor: MeoTheme.inverseSurface; markColor: MeoTheme.contentOnInverseSurface; cornerRadius: 32 * MeoTheme.globalScale }
            MeoAiMark { width: 32 * MeoTheme.globalScale; height: width; containerColor: MeoTheme.secondaryContainer; markColor: MeoTheme.contentOnSecondaryContainer; cornerRadius: MeoTheme.shapeSmall }
        }
    }

    Component {
        id: iconToggleButtonSample
        Flow {
            spacing: MeoTheme.space12
            MeoIconToggleButton { icon.name: "favorite_border"; checkedIcon: "favorite"; checked: true }
            MeoIconToggleButton { icon.name: "favorite_border"; checkedIcon: "favorite"; type: "filled"; checked: true }
            MeoIconToggleButton { icon.name: "bookmark_border"; checkedIcon: "bookmark"; type: "tonal"; checked: true }
            MeoIconToggleButton { icon.name: "notifications_none"; checkedIcon: "notifications"; type: "outlined"; badgeText: "3" }
            MeoIconToggleButton { icon.name: "favorite_border"; checkedIcon: "favorite"; enabled: false }
        }
    }

    Component {
        id: colorFieldSample
        Grid {
            columns: 2
            spacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Primary seed" }
                MeoColorField { width: 260 * MeoTheme.globalScale; label: "Theme seed"; color: "#6750A4"; helperText: "Valid #RRGGBB seed" }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Tonal seed" }
                MeoColorField { width: 260 * MeoTheme.globalScale; label: "Tonal seed"; color: "#146C94" }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Prefilled text" }
                MeoColorField { width: 260 * MeoTheme.globalScale; label: "Accent"; text: "#FF8800" }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Validation error" }
                MeoColorField {
                    width: 260 * MeoTheme.globalScale
                    label: "Theme seed"
                    Timer {
                        interval: 100
                        running: true
                        repeat: false
                        onTriggered: parent.text = "#12AB"
                    }
                }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Disabled" }
                MeoColorField { width: 260 * MeoTheme.globalScale; label: "Locked seed"; color: "#4285F4"; enabled: false }
            }
        }
    }

    Component {
        id: chipDropdownSample
        Grid {
            columns: 2
            spacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Selected with counter" }
                MeoChipDropdown { width: 320 * MeoTheme.globalScale; label: "Included platforms"; placeholder: "Choose platforms"; model: ["Desktop", "Mobile", "Web"]; selectedIndices: [0, 2]; showCounter: true }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Empty placeholder" }
                MeoChipDropdown { width: 260 * MeoTheme.globalScale; label: "Categories"; placeholder: "Choose categories"; model: ["Design", "Code", "Research"] }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Outlined" }
                MeoChipDropdown { width: 260 * MeoTheme.globalScale; type: "outlined"; label: "Reviewers"; model: ["Avery", "Mika", "Rin"]; selectedIndices: [1] }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Validation error" }
                MeoChipDropdown { width: 260 * MeoTheme.globalScale; label: "Required tags"; placeholder: "Choose at least one"; model: ["Urgent"]; isError: true; errorText: "Select a tag" }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: "Disabled" }
                MeoChipDropdown { width: 260 * MeoTheme.globalScale; type: "outlined"; label: "Disabled"; model: ["Unavailable"]; selectedIndices: [0]; enabled: false }
            }
        }
    }

    Component {
        id: monthCalendarSample
        Grid {
            columns: 3
            spacing: MeoTheme.space12

            MeoMonthCalendar { width: 220 * MeoTheme.globalScale; height: 324 * MeoTheme.globalScale; selectedDate: new Date(2026, 7, 26); displayDate: new Date(2026, 7, 1) }
            MeoMonthCalendar { width: 220 * MeoTheme.globalScale; height: 324 * MeoTheme.globalScale; selectedDate: new Date(2026, 1, 29); displayDate: new Date(2026, 1, 1) }
            MeoMonthCalendar { width: 220 * MeoTheme.globalScale; height: 324 * MeoTheme.globalScale; selectedDate: new Date(2026, 0, 1); displayDate: new Date(2026, 0, 1); firstDayOfWeek: Qt.Monday }
            MeoMonthCalendar { width: 220 * MeoTheme.globalScale; height: 324 * MeoTheme.globalScale; selectedDate: new Date(2026, 7, 31); displayDate: new Date(2026, 8, 1) }
            MeoMonthCalendar { width: 220 * MeoTheme.globalScale; height: 324 * MeoTheme.globalScale; selectedDate: new Date(2026, 10, 15); displayDate: new Date(2026, 10, 1); interactive: false }
        }
    }

    Component {
        id: steppedSliderSample
        Column {
            width: 360 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            SampleLabel { label: "1. Labelled value" }
            MeoSteppedSlider { width: parent.width; title: "Volume"; supportingText: "Room speaker"; value: 60; stepSize: 10; valueSuffix: "%"; showValueLabel: true }

            SampleLabel { label: "2. Compact steps" }
            MeoSteppedSlider { width: parent.width; title: "Brightness"; value: 4; from: 0; to: 5; stepSize: 1; showValueLabel: true }

            SampleLabel { label: "3. Minimum boundary" }
            MeoSteppedSlider { width: parent.width; title: "Text size"; value: 0; from: 0; to: 4; stepSize: 1; valueSuffix: "/4"; showValueLabel: true }

            SampleLabel { label: "4. Maximum boundary" }
            MeoSteppedSlider { width: parent.width; title: "Playback speed"; value: 2; from: 0.5; to: 2; stepSize: 0.25; valueSuffix: "×"; showValueLabel: true }

            SampleLabel { label: "5. Disabled" }
            MeoSteppedSlider { width: parent.width; title: "Contrast"; supportingText: "Unavailable for this display"; value: 50; stepSize: 10; valueSuffix: "%"; showValueLabel: true; enabled: false }
        }
    }

    Component {
        id: ratingBarSample
        Flow {
            spacing: MeoTheme.space24
            MeoRatingBar { rating: 0; size: "s" }
            MeoRatingBar { rating: 2.5 }
            MeoRatingBar { rating: 5; size: "l" }
            MeoRatingBar { rating: 4; size: "l"; readOnly: true }
            MeoRatingBar { rating: 3; enabled: false }
        }
    }

    Component {
        id: appGridItemSample
        Flow {
            spacing: MeoTheme.space12
            MeoAppGridItem { title: "Settings"; iconName: "settings"; selected: true }
            MeoAppGridItem { title: "Files"; iconName: "folder" }
            MeoAppGridItem { title: "AI Studio"; iconName: "auto_awesome"; compact: true }
            MeoAppGridItem {
                title: "Custom"
                iconContent: Component {
                    Rectangle {
                        implicitWidth: 40 * MeoTheme.globalScale
                        implicitHeight: 40 * MeoTheme.globalScale
                        radius: width / 2
                        color: MeoTheme.primaryContainer
                        MeoIcon {
                            anchors.centerIn: parent
                            icon: "palette"
                            size: 24 * MeoTheme.globalScale
                            color: MeoTheme.contentOnPrimaryContainer
                        }
                    }
                }
            }
            MeoAppGridItem { title: "Disabled"; iconName: "lock"; enabled: false }
        }
    }

    Component {
        id: expansionPanelSample
        Column {
            width: 440 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            MeoExpansionPanel {
                width: parent.width
                title: "Release notes"
                subtitle: "What changed in this update"
                icon: "article"
                expanded: true
                contentItem: Component {
                    MeoText {
                        width: 408 * MeoTheme.globalScale
                        text: "Expanded content keeps secondary information available without overwhelming the primary screen."
                        typeRole: "body"
                        typeSize: "medium"
                        color: MeoTheme.contentOnSurfaceVariant
                        wrapMode: Text.WordWrap
                    }
                }
            }
            MeoExpansionPanel { width: parent.width; title: "Earlier updates"; icon: "history" }
            MeoExpansionPanel { width: parent.width; title: "Unavailable section"; subtitle: "Disabled state"; icon: "block"; enabled: false }
        }
    }

    Component {
        id: settingsRowSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space4
            MeoSettingsRow { width: parent.width; title: "Wi-Fi"; subtitle: "Meo Network"; leadingIcon: "wifi"; trailingKind: "navigation"; selected: true }
            MeoSettingsRow { width: parent.width; title: "Dark theme"; subtitle: "Use dark colors"; leadingIcon: "dark_mode"; trailingKind: "switch"; checked: true }
            MeoSettingsRow { width: parent.width; title: "Storage"; leadingIcon: "storage"; trailingKind: "value"; valueText: "68% used" }
            MeoSettingsRow { width: parent.width; title: "System update"; leadingIcon: "system_update"; trailingKind: "status"; trailingText: "Up to date"; statusTone: "primary" }
            MeoSettingsRow { width: parent.width; title: "Reset settings"; leadingIcon: "restart_alt"; trailingKind: "action"; actionText: "Reset"; enabled: false }
        }
    }

    Component {
        id: segmentedListSample
        MeoSegmentedList {
            width: 420 * MeoTheme.globalScale
            title: "Recent components"
            subtitle: "A custom delegate receives its item data and rounded position."
            selectedIndex: 1
            model: [
                { "label": "Buttons", "icon": "smart_button", "supportingText": "Action surfaces" },
                { "label": "Navigation", "icon": "explore", "supportingText": "Tabs and rails" },
                { "label": "Feedback", "icon": "info", "supportingText": "Progress and messages", "enabled": false }
            ]
            delegate: Component {
                MeoListItem {
                    property var modelData: null
                    property int index: -1
                    headline: modelData ? modelData.label : ""
                    supportingText: modelData ? modelData.supportingText : ""
                    leadingIcon: modelData ? modelData.icon : ""
                    interactive: enabled
                }
            }
        }
    }

    Component {
        id: expressiveListItemSample
        Column {
            width: 420 * MeoTheme.globalScale
            spacing: MeoTheme.space2
            MeoListItem { width: parent.width; headline: "Selected expressive item"; supportingText: "Top rounding"; leadingIcon: "auto_awesome"; selected: true; isSegmented: true; roundingStrategy: "top"; vibrant: true }
            MeoListItem { width: parent.width; headline: "Adjacent item"; supportingText: "Bottom rounding"; leadingIcon: "palette"; isSegmented: true; roundingStrategy: "bottom" }
        }
    }

    Component {
        id: fallbackSample
        MeoText { text: "Sample registered in catalog"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
    }

    Component {
        id: pageHostSample
        MeoPageHost {
            width: 440 * MeoTheme.globalScale
            height: 180 * MeoTheme.globalScale
            sourceComponent: Component {
                Rectangle {
                    color: MeoTheme.secondaryContainer
                    radius: MeoTheme.shapeLarge
                    MeoText {
                        anchors.centerIn: parent
                        text: "Hosted page component"
                        typeRole: "title"
                        typeSize: "medium"
                        color: MeoTheme.contentOnSecondaryContainer
                    }
                }
            }
        }
    }

    Component {
        id: settingsGroupSample
        MeoSettingsGroup {
            width: 460 * MeoTheme.globalScale
            title: "Connections"
            subtitle: "Account and network controls"
            model: [
                { "title": "Wi-Fi", "subtitle": "Meo Network", "leadingIcon": "wifi", "trailingKind": "navigation" },
                { "title": "Bluetooth", "subtitle": "Headphones", "leadingIcon": "bluetooth", "trailingKind": "switch", "checked": true }
            ]
        }
    }

    Component {
        id: settingsTaskSheetSample
        Column {
            spacing: MeoTheme.space8
            MeoButton { text: "Open settings task"; onClicked: taskSheet.open() }
            MeoSettingsTaskSheet {
                id: taskSheet
                title: "Choose display density"
                subtitle: "This preview changes nothing outside the Showcase."
                acceptText: "Apply"
                rejectText: "Cancel"
                content: Component {
                    MeoSegmentedButtons {
                        width: 300 * MeoTheme.globalScale
                        model: ["Compact", "Default", "Comfortable"]
                        currentIndex: 1
                    }
                }
            }
        }
    }

    Component {
        id: quickSettingsEditorSample
        MeoQuickSettingsEditor {
            width: 512 * MeoTheme.globalScale
            tiles: [
                { "title": "Wi-Fi", "supportingText": "Meo Network", "iconName": "wifi", "active": true, "span": 2 },
                { "title": "Bluetooth", "supportingText": "Headphones", "iconName": "bluetooth", "active": true, "span": 2 },
                { "title": "Flashlight", "iconName": "flashlight_on", "span": 1 },
                { "title": "Do not disturb", "iconName": "do_not_disturb_on", "span": 1 }
            ]
            availableTiles: [
                { "title": "Night light", "iconName": "nightlight" },
                { "title": "Airplane mode", "iconName": "flight" }
            ]
            selectedIndex: 0
        }
    }

    Component {
        id: supportingPaneSample
        MeoSupportingPaneLayout {
            width: 620 * MeoTheme.globalScale
            height: 220 * MeoTheme.globalScale
            adaptiveMode: "side-by-side"
            showSupportingPane: true
            mainPane: Component {
                Rectangle {
                    color: MeoTheme.surfaceContainerLow
                    radius: MeoTheme.shapeLarge
                    MeoText { anchors.centerIn: parent; text: "Main pane"; typeRole: "title"; typeSize: "medium"; color: MeoTheme.contentOnSurface }
                }
            }
            supportingPane: Component {
                Rectangle {
                    color: MeoTheme.secondaryContainer
                    radius: MeoTheme.shapeLarge
                    MeoText { anchors.centerIn: parent; text: "Supporting pane"; typeRole: "label"; typeSize: "large"; color: MeoTheme.contentOnSecondaryContainer }
                }
            }
        }
    }

    Component {
        id: shapeMorphSample
        Grid {
            columns: 5
            spacing: MeoTheme.space16

            Repeater {
                model: [
                    { "label": "Circle → Square", "from": "Circle", "to": "Square", "progress": 0.50 },
                    { "label": "Pill → Diamond", "from": "Pill", "to": "Diamond", "progress": 0.45 },
                    { "label": "Soft burst → Cookie", "from": "SoftBurst", "to": "Cookie9Sided", "progress": 0.55 },
                    { "label": "Triangle → Arrow", "from": "Triangle", "to": "Arrow", "progress": 0.50 },
                    { "label": "Heart → Flower", "from": "Heart", "to": "Flower", "progress": 0.60 }
                ]

                delegate: Column {
                    required property var modelData
                    width: 128 * MeoTheme.globalScale
                    spacing: MeoTheme.space8

                    MeoShapeMorph {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 112 * MeoTheme.globalScale
                        height: width
                        fromShape: modelData.from
                        toShape: modelData.to
                        morphProgress: modelData.progress
                        rawSpringProgress: modelData.progress
                        color: MeoTheme.primary
                    }

                    SampleLabel {
                        width: parent.width
                        label: modelData.label
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

    Component {
        id: statusCenterSample
        MeoStatusCenter {
            width: 720 * MeoTheme.globalScale
            height: 432 * MeoTheme.globalScale
            unreadCount: 3
            notificationContent: Component {
                Column {
                    spacing: MeoTheme.space8
                    MeoListItem { width: parent.width; headline: "Build complete"; supportingText: "Showcase is ready to inspect"; leadingIcon: "task_alt" }
                    MeoListItem { width: parent.width; headline: "No new warnings"; supportingText: "All checked samples are mapped"; leadingIcon: "info" }
                }
            }
        }
    }

    Component {
        id: motionSurfaceSample
        MeoMotionSurface {
            width: 320 * MeoTheme.globalScale
            height: 132 * MeoTheme.globalScale
            color: MeoTheme.tertiaryContainer
            animateOnCompleted: true
            MeoText {
                anchors.centerIn: parent
                text: "Animated surface"
                typeRole: "title"
                typeSize: "medium"
                color: MeoTheme.contentOnTertiaryContainer
            }
        }
    }

    Component {
        id: motionPopupSample
        Column {
            spacing: MeoTheme.space8
            MeoButton { id: motionPopupTrigger; text: "Open motion popup"; onClicked: popup.openFrom(motionPopupTrigger) }
            MeoMotionPopup {
                id: popup
                width: 300 * MeoTheme.globalScale
                height: 132 * MeoTheme.globalScale
                presentation: MeoMotionPopup.Dialog
                MeoText {
                    anchors.centerIn: parent
                    width: parent.width - 2 * MeoTheme.space24
                    text: "The same primitive can become a dialog, menu, or sheet."
                    typeRole: "body"
                    typeSize: "medium"
                    color: MeoTheme.contentOnSurface
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Component {
        id: mediaCardSample
        Grid {
            spacing: MeoTheme.space16
            columns: 3
            width: 704 * MeoTheme.globalScale
            property string poster: "qrc:/qt/qml/MeoUI/assets/icons/meo-ai-f.svg"
            MeoMediaCard {
                width: 224 * MeoTheme.globalScale
                height: 250 * MeoTheme.globalScale
                cardSize: "s"
                type: "filled"
                mediaSource: parent.poster
                headerTitle: "MeoUI"
                headerSubtitle: "Design system"
                avatarInitials: "M"
                title: "Showcase coverage"
                supportingText: "Top media"
                interactive: true
                actions: [{ "label": "Open", "icon": "open_in_new", "type": "text" }]
            }
            MeoMediaCard {
                width: 224 * MeoTheme.globalScale
                height: 144 * MeoTheme.globalScale
                cardSize: "s"
                type: "outlined"
                mediaSource: parent.poster
                mediaPosition: "left"
                aspectRatio: 0.62
                title: "Media card"
                supportingText: "Side media layout"
            }
            MeoMediaCard {
                width: 224 * MeoTheme.globalScale
                height: 250 * MeoTheme.globalScale
                cardSize: "s"
                type: "filled"
                mediaSource: parent.poster
                mediaPosition: "bottom"
                title: "Selected"
                supportingText: "Bottom media"
                selected: true
            }
            MeoMediaCard {
                width: 224 * MeoTheme.globalScale
                height: 144 * MeoTheme.globalScale
                cardSize: "s"
                type: "elevated"
                mediaSource: parent.poster
                mediaPosition: "right"
                aspectRatio: 0.62
                title: "Elevated"
                supportingText: "Right media"
                showOverflowButton: true
            }
            MeoMediaCard {
                width: 224 * MeoTheme.globalScale
                height: 144 * MeoTheme.globalScale
                cardSize: "s"
                type: "filled"
                title: "Disabled"
                supportingText: "No interaction"
                enabled: false
                interactive: true
            }
        }
    }

    Component {
        id: accountSwitcherSample
        Grid {
            width: 576 * MeoTheme.globalScale
            columns: 2
            columnSpacing: MeoTheme.space16
            rowSpacing: MeoTheme.space16
            MeoAccountSwitcher { model: []; currentIndex: -3 }
            MeoAccountSwitcher { model: [{ "name": "Single account", "email": "single@meoarch.dev" }] }
            MeoAccountSwitcher {
                model: [
                    { "name": "Meo User", "email": "hello@meoarch.dev" },
                    { "name": "Design Review", "email": "design@meoarch.dev" },
                    { "name": "Preview", "email": "preview@meoarch.dev" }
                ]
                currentIndex: 0
            }
            MeoAccountSwitcher {
                model: [
                    { "name": "Meo User", "email": "hello@meoarch.dev" },
                    { "name": "Design Review", "email": "design@meoarch.dev" },
                    { "name": "Preview", "email": "preview@meoarch.dev" }
                ]
                currentIndex: 8
            }
            MeoAccountSwitcher {
                model: [{ "name": "Disabled account", "email": "unavailable@meoarch.dev" }]
                enabled: false
            }
        }
    }

    component TokenSwatch: Rectangle {
        property string label: ""
        property color swatchColor: MeoTheme.primary
        property color contentColor: MeoTheme.contentOnPrimary
        width: 150 * MeoTheme.globalScale
        height: 72 * MeoTheme.globalScale
        radius: MeoTheme.shapeMedium
        color: swatchColor
        MeoText { anchors.centerIn: parent; text: parent.label; typeRole: "label"; typeSize: "big"; color: parent.contentColor }
    }

    component SurfaceCard: MeoCard {
        id: surfaceCard
        property string title: ""
        property string cardType: "elevated"
        property bool enabledState: true
        width: 200 * MeoTheme.globalScale
        // Keep all six Card variants, including disabled, visible together in
        // the default Showcase viewport.
        height: 140 * MeoTheme.globalScale
        type: cardType
        interactive: true
        enabled: enabledState

        MeoIconButton {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: MeoTheme.space8
            icon.name: "more_vert"
            type: "standard"
            enabled: surfaceCard.enabledState
        }

        MeoText {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: MeoTheme.space16
            text: surfaceCard.title
            typeRole: "title"
            typeSize: "small"
            emphasized: true
            color: MeoTheme.contentOnSurface
            opacity: surfaceCard.enabledState ? 1 : MeoTheme.disabledContentOpacity
        }
    }

    component SampleLabel: MeoText {
        property string label: ""
        text: label
        typeRole: "label"
        typeSize: "medium"
        color: MeoTheme.contentOnSurfaceVariant
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
    }

    component PageIndicatorColumn: Column {
        property string label: ""
        property int count: 0
        property int currentIndex: 0
        property string orientation: "horizontal"
        property bool interactive: false
        property real dotSize: 8 * MeoTheme.globalScale
        property real activeDotWidth: 24 * MeoTheme.globalScale

        readonly property real columnWidth: Math.max(sampleLabel.implicitWidth, indicator.implicitWidth)
        width: columnWidth
        spacing: MeoTheme.space8

        SampleLabel {
            id: sampleLabel
            width: parent.width
            label: parent.label
            horizontalAlignment: Text.AlignHCenter
        }
        MeoPageIndicator {
            id: indicator
            x: (parent.width - width) / 2
            count: parent.count
            currentIndex: parent.currentIndex
            orientation: parent.orientation
            interactive: parent.interactive
            dotSize: parent.dotSize
            activeDotWidth: parent.activeDotWidth
        }
    }

    component IconButtonColumn: Column {
        property string label: ""
        property string buttonType: "standard"
        property string buttonIcon: "settings"
        property string buttonSize: "s"
        property string buttonWidth: "uniform"
        property bool toggle: false
        property bool selected: false
        property bool badgeDot: false
        property bool enabledState: true

        spacing: MeoTheme.space8
        Layout.alignment: Qt.AlignHCenter

        MeoIconButton {
            anchors.horizontalCenter: parent.horizontalCenter
            type: parent.buttonType
            icon.name: parent.buttonIcon
            size: parent.buttonSize
            widthOption: parent.buttonWidth
            toggle: parent.toggle
            selected: parent.selected
            badgeDot: parent.badgeDot
            enabled: parent.enabledState
        }

        SampleLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            label: parent.label
            opacity: parent.enabledState ? 1.0 : 0.62
        }
    }

    component FabColumn: Column {
        property string label: ""
        property string fabType: "regular"
        property string fabIcon: "add"
        property string fabText: ""
        property string fabColorStyle: "primaryContainer"
        property bool fabCollapsed: false

        spacing: MeoTheme.space8

        MeoFAB {
            anchors.horizontalCenter: parent.horizontalCenter
            type: parent.fabType
            colorStyle: parent.fabColorStyle
            icon.name: parent.fabIcon
            text: parent.fabText
            collapsed: parent.fabCollapsed
        }

        SampleLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            label: parent.label
        }
    }

    component CarouselTile: Rectangle {
        id: carouselTile
        property var modelData: ({ "title": "", "icon": "" })
        property string tileType: "filled"

        radius: MeoTheme.shapeLarge
        color: carouselTile.tileType === "outlined" ? MeoTheme.surface : (carouselTile.tileType === "hero" ? MeoTheme.tertiaryContainer : MeoTheme.primaryContainer)
        border.color: carouselTile.tileType === "outlined" ? MeoTheme.outlineVariant : "transparent"
        border.width: carouselTile.tileType === "outlined" ? 1 * MeoTheme.globalScale : 0

        Column {
            anchors.centerIn: parent
            spacing: MeoTheme.space8

            MeoIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                icon: carouselTile.modelData.icon
                size: carouselTile.tileType === "hero" ? 32 : 24
                color: carouselTile.tileType === "outlined" ? MeoTheme.primary : (carouselTile.tileType === "hero" ? MeoTheme.contentOnTertiaryContainer : MeoTheme.contentOnPrimaryContainer)
            }

            MeoText {
                text: carouselTile.modelData.title
                typeRole: "label"
                typeSize: "big"
                color: carouselTile.tileType === "outlined" ? MeoTheme.contentOnSurface : (carouselTile.tileType === "hero" ? MeoTheme.contentOnTertiaryContainer : MeoTheme.contentOnPrimaryContainer)
            }
        }
    }
}
