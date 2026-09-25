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
        { "label": qsTr("Home"), "icon": "home" },
        { "label": qsTr("Explore"), "icon": "explore", "badgeText": "3" },
        { "label": qsTr("Profile"), "icon": "person" }
    ]
    readonly property var chipItems: [
        { "label": qsTr("All"), "icon": "apps" },
        { "label": qsTr("Design"), "icon": "palette" },
        { "label": qsTr("Code"), "icon": "code" }
    ]
    readonly property var tableColumns: [
        { "label": qsTr("Dessert"), "property": "name", "width": 160, "sortable": true },
        { "label": qsTr("Calories"), "property": "calories", "width": 100, "sortable": true },
        { "label": qsTr("Status"), "property": "status", "width": 100 }
    ]
    readonly property var tableRows: [
        { "name": qsTr("Cupcake"), "calories": 305, "status": qsTr("High"), "selected": true },
        { "name": qsTr("Donut"), "calories": 452, "status": qsTr("High") },
        { "name": qsTr("Eclair"), "calories": 262, "status": qsTr("Normal") }
    ]
    readonly property var carouselItems: [
        { "title": qsTr("Color"), "icon": "palette" },
        { "title": qsTr("Type"), "icon": "text_fields" },
        { "title": qsTr("Motion"), "icon": "animation" },
        { "title": qsTr("Shape"), "icon": "category" },
        { "title": qsTr("Layout"), "icon": "view_quilt" }
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
        if (name === "MeoContextMenu") return contextMenuSample
        if (name === "MeoWidget") return meoWidgetSample
        if (name === "MeoWidgetSheet") return meoWidgetSheetSample
        if (name === "MeoDataTable") return dataTableSample
        if (name === "MeoListItem") return listItemSample
        if (name === "MeoListView") return listViewSample
        if (name === "MeoListTransitions") return listTransitionsSample
        if (name === "MeoExpansionPanel") return expansionPanelSample
        if (name === "MeoSettingsRow") return settingsRowSample
        if (name === "MeoListHeader") return listHeaderSample
        if (name === "MeoGroupedList") return groupedListSample
        if (name === "MeoSegmentedList") return segmentedListSample
        if (name === "MeoStatusCenter") return statusCenterSample
        if (name === "MeoStatusStrip") return statusStripSample
        if (name === "MeoAmbientClock") return ambientClockSample
        if (name === "MeoBadge") return badgeSample
        if (name === "MeoAvatar") return avatarSample
        if (name === "MeoDivider") return dividerSample
        if (name === "MeoSkeleton") return skeletonSample
        if (name === "MeoCard") return cardSample
        if (name === "MeoAuthenticationSurface") return authenticationSurfaceSample
        if (name === "MeoCachedImage") return cachedImageSample
        if (name === "MeoMotionSurface") return motionSurfaceSample
        if (name === "MeoSpringValue") return springValueSample
        if (name === "MeoLaunchSurface") return launchSurfaceSample
        if (name === "MeoDialog") return dialogSample
        if (name === "MeoHoldToConfirm") return holdToConfirmSample
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
        if (name === "MeoLoadingFeedback") return loadingFeedbackSample
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
        if (name === "MeoWeatherStatus") return weatherStatusSample
        if (name === "MeoPrivacyNotificationSummary") return privacyNotificationSample
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
        if (name === "MeoSettingsSidebar") return settingsSidebarSample
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
            TokenSwatch { label: qsTr("Primary"); swatchColor: MeoTheme.primary; contentColor: MeoTheme.contentOnPrimary }
            TokenSwatch { label: qsTr("Primary container"); swatchColor: MeoTheme.primaryContainer; contentColor: MeoTheme.contentOnPrimaryContainer }
            TokenSwatch { label: qsTr("Surface low"); swatchColor: MeoTheme.surfaceContainerLow; contentColor: MeoTheme.contentOnSurface }
            TokenSwatch { label: qsTr("Error"); swatchColor: MeoTheme.error; contentColor: MeoTheme.contentOnError }
            TokenSwatch { label: qsTr("Inverse surface"); swatchColor: MeoTheme.inverseSurface; contentColor: MeoTheme.contentOnInverseSurface }
        }
    }
    Component {
        id: motionTokensSample
        Flow {
            spacing: MeoTheme.space8

            Repeater {
                model: [
                    { "label": qsTr("Default spatial"), "spec": MeoMotion.defaultSpatial },
                    { "label": qsTr("Fast spatial"), "spec": MeoMotion.fastSpatial },
                    { "label": qsTr("Slow spatial"), "spec": MeoMotion.slowSpatial },
                    { "label": qsTr("Default effects"), "spec": MeoMotion.defaultEffects },
                    { "label": qsTr("Fast effects"), "spec": MeoMotion.fastEffects },
                    { "label": qsTr("Slow effects"), "spec": MeoMotion.slowEffects }
                ]
                delegate: MeoChip {
                    required property int index
                    required property var modelData
                    label: modelData.label + " · ζ " + modelData.spec.dampingRatio
                           + " · k " + modelData.spec.stiffness
                    selected: index === 0
                }
            }

            Repeater {
                model: [
                    { "label": qsTr("State"), "duration": MeoTheme.motionDurationState },
                    { "label": qsTr("Selection"), "duration": MeoTheme.motionDurationSelection },
                    { "label": qsTr("Popup enter"), "duration": MeoTheme.motionDurationPopupEffectsEnter },
                    { "label": qsTr("Page enter"), "duration": MeoTheme.motionDurationPageEnter },
                    { "label": qsTr("Sheet enter"), "duration": MeoTheme.motionDurationSheetEnter },
                    { "label": qsTr("Indicator cycle"), "duration": MeoTheme.motionDurationIndeterminateCycle }
                ]
                delegate: MeoChip {
                    required property var modelData
                    label: modelData.label + " · " + modelData.duration + " ms"
                }
            }
        }
    }
    Component { id: windowMetricsSample; Flow { spacing: MeoTheme.space8; Repeater { model: [{"label":qsTr("Compact"),"width":599},{"label":qsTr("Medium"),"width":600},{"label":qsTr("Expanded"),"width":840},{"label":qsTr("Large"),"width":1200},{"label":qsTr("Extra-large"),"width":1600}]; delegate: MeoChip { required property var modelData; label: modelData.label + " · " + modelData.width; selected: modelData.width === 840 } } } }
    Component { id: textSample; Column { spacing: MeoTheme.space4; MeoText { text: qsTr("Display title"); typeRole: "title"; typeSize: "big"; emphasized: true; color: MeoTheme.contentOnSurface } MeoText { text: qsTr("Roboto body text with semantic type tokens."); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component {
        id: iconSample

        Flow {
            spacing: MeoTheme.space16

            Repeater {
                model: [
                    { "label": qsTr("Regular"), "icon": "palette" },
                    { "label": qsTr("Filled"), "icon": "favorite", "fill": true },
                    { "label": qsTr("Bold"), "icon": "edit", "weight": 700 },
                    { "label": qsTr("Grade"), "icon": "auto_awesome", "grade": 200 },
                    { "label": qsTr("48 opsz"), "icon": "search", "opticalSize": 48 }
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
                    { "label": qsTr("Rest") },
                    { "label": qsTr("Hover"), "hovered": true },
                    { "label": qsTr("Focus"), "focused": true },
                    { "label": qsTr("Pressed"), "pressed": true },
                    { "label": qsTr("Dragged"), "dragged": true }
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
                            id: sampleStateLayer
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
                        text: modelData.label + (sampleStateLayer._renderedBaseOpacity > 0
                              ? " · " + Math.round(sampleStateLayer._renderedBaseOpacity * 100) + "%"
                              : (sampleStateLayer._renderedFocusOpacity > 0 ? " · " + qsTr("focus") : ""))
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

            SampleLabel { label: qsTr("Type") }
            SampleLabel { label: qsTr("Text") }
            SampleLabel { label: qsTr("With icon") }
            SampleLabel { label: qsTr("Disabled") }
            SampleLabel { label: qsTr("Loading") }

            SampleLabel { label: qsTr("Filled") }
            MeoButton { text: qsTr("Filled"); type: "filled" }
            MeoButton { text: qsTr("Icon"); type: "filled"; icon.name: "add" }
            MeoButton { text: qsTr("Filled"); type: "filled"; enabled: false }
            MeoButton { text: qsTr("Loading"); type: "filled"; loading: true; loadingWithContainer: true }

            SampleLabel { label: qsTr("Tonal") }
            MeoButton { text: qsTr("Tonal"); type: "tonal" }
            MeoButton { text: qsTr("Icon"); type: "tonal"; icon.name: "star" }
            MeoButton { text: qsTr("Tonal"); type: "tonal"; enabled: false }
            MeoButton { text: qsTr("Loading"); type: "tonal"; loading: true }

            SampleLabel { label: qsTr("Outlined") }
            MeoButton { text: qsTr("Outlined"); type: "outlined" }
            MeoButton { text: qsTr("Icon"); type: "outlined"; icon.name: "add" }
            MeoButton { text: qsTr("Outlined"); type: "outlined"; enabled: false }
            MeoButton { text: qsTr("Loading"); type: "outlined"; loading: true }

            SampleLabel { label: qsTr("Elevated") }
            MeoButton { text: qsTr("Elevated"); type: "elevated" }
            MeoButton { text: qsTr("Icon"); type: "elevated"; icon.name: "add" }
            MeoButton { text: qsTr("Elevated"); type: "elevated"; enabled: false }
            MeoButton { text: qsTr("Loading"); type: "elevated"; loading: true }

            SampleLabel { label: qsTr("Text") }
            MeoButton { text: qsTr("Text"); type: "text" }
            MeoButton { text: qsTr("Icon"); type: "text"; icon.name: "add" }
            MeoButton { text: qsTr("Text"); type: "text"; enabled: false }
            MeoButton { text: qsTr("Loading"); type: "text"; loading: true }

            SampleLabel { label: qsTr("Toggle") }
            MeoButton { text: qsTr("Filled off"); type: "filled"; toggle: true }
            MeoButton { text: qsTr("Filled on"); type: "filled"; toggle: true; selected: true }
            MeoButton { text: qsTr("Outlined on"); type: "outlined"; toggle: true; selected: true }
            MeoButton { text: qsTr("Tonal on"); type: "tonal"; toggle: true; selected: true }

            SampleLabel { label: qsTr("M3E size") }
            Row {
                Layout.columnSpan: 4
                spacing: MeoTheme.space8

                MeoButton { text: qsTr("XS"); type: "filled"; size: "xs" }
                MeoButton { text: qsTr("S"); type: "filled"; size: "s" }
                MeoButton { text: qsTr("M"); type: "filled"; size: "m" }
                MeoButton { text: qsTr("L"); type: "filled"; size: "l" }
                MeoButton { text: qsTr("XL"); type: "filled"; size: "xl" }
            }
        }
    }

    Component {
        id: iconButtonSample
        GridLayout {
            columns: 4
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space24

            IconButtonColumn { label: qsTr("Standard"); buttonType: "standard"; buttonIcon: "settings" }
            IconButtonColumn { label: qsTr("Filled (default)"); buttonType: "filled"; buttonIcon: "favorite" }
            IconButtonColumn { label: qsTr("Tonal"); buttonType: "tonal"; buttonIcon: "bookmark"; badgeDot: true }
            IconButtonColumn { label: qsTr("Outlined"); buttonType: "outlined"; buttonIcon: "share" }
            IconButtonColumn { label: qsTr("Selected"); buttonType: "standard"; buttonIcon: "star"; toggle: true; selected: true }
            IconButtonColumn { label: qsTr("Selected"); buttonType: "filled"; buttonIcon: "favorite"; toggle: true; selected: true }
            IconButtonColumn { label: qsTr("Selected"); buttonType: "tonal"; buttonIcon: "bookmark"; toggle: true; selected: true }
            IconButtonColumn { label: qsTr("Selected"); buttonType: "outlined"; buttonIcon: "share"; toggle: true; selected: true }
            IconButtonColumn { label: qsTr("Narrow XS"); buttonType: "filled"; buttonIcon: "add"; buttonSize: "xs"; buttonWidth: "narrow" }
            IconButtonColumn { label: qsTr("Uniform M"); buttonType: "filled"; buttonIcon: "edit"; buttonSize: "m" }
            IconButtonColumn { label: qsTr("Wide S"); buttonType: "filled"; buttonIcon: "wifi"; buttonWidth: "wide" }
            IconButtonColumn { label: qsTr("Disabled"); buttonType: "standard"; buttonIcon: "settings"; enabledState: false }
            IconButtonColumn { label: qsTr("Disabled"); buttonType: "filled"; buttonIcon: "favorite"; enabledState: false }
            IconButtonColumn { label: qsTr("Disabled"); buttonType: "tonal"; buttonIcon: "bookmark"; enabledState: false }
            IconButtonColumn { label: qsTr("Disabled"); buttonType: "outlined"; buttonIcon: "share"; enabledState: false }
        }
    }

    Component {
        id: fabSample
        Flow {
            spacing: MeoTheme.space24
            FabColumn { label: qsTr("Small"); fabType: "small"; fabIcon: "edit" }
            FabColumn { label: qsTr("Regular"); fabType: "regular"; fabIcon: "add" }
            FabColumn { label: qsTr("Medium"); fabType: "medium"; fabIcon: "edit"; fabColorStyle: "secondary" }
            FabColumn { label: qsTr("Large"); fabType: "large"; fabIcon: "palette" }
            FabColumn { label: qsTr("Extended"); fabType: "extended"; fabIcon: "send"; fabText: qsTr("Send") }
            FabColumn { label: qsTr("Collapsed"); fabType: "extended"; fabIcon: "send"; fabText: qsTr("Send"); fabCollapsed: true }
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
                    { "label": qsTr("Note"), "icon": "note_add" },
                    { "label": qsTr("Task"), "icon": "check" }
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
                MeoSplitButton { text: qsTr("Create"); icon: "add"; type: "filled"; size: "xs"; menuModel: control.chipItems }
                MeoSplitButton { text: qsTr("Save"); icon: "save"; type: "tonal"; size: "s"; menuModel: control.chipItems }
                MeoSplitButton { text: qsTr("Export"); icon: "download"; type: "outlined"; size: "m"; menuModel: control.chipItems }
            }
            Flow {
                width: parent.width
                spacing: MeoTheme.space12
                MeoSplitButton { text: qsTr("Add"); icon: "add"; type: "elevated"; size: "l"; menuModel: control.chipItems }
                MeoSplitButton { text: qsTr("Deploy"); icon: "rocket_launch"; type: "filled"; size: "xl"; menuModel: control.chipItems }
                MeoSplitButton { text: qsTr("Disabled"); icon: "block"; type: "filled"; size: "s"; enabled: false; menuModel: control.chipItems }
            }
        }
    }
    Component {
        id: buttonGroupSample
        Grid {
            columns: 2
            spacing: MeoTheme.space8
            SampleLabel { label: qsTr("1. Standard: selection expands and changes shape") }
            MeoButtonGroup {
                type: "tonal"
                model: [
                    { "label": qsTr("Bluetooth"), "icon": "bluetooth", "compactWhenUnselected": true },
                    { "label": qsTr("Timer"), "icon": "timer", "compactWhenUnselected": true },
                    { "label": qsTr("Share"), "icon": "share", "compactWhenUnselected": true }
                ]
                currentIndex: 1
            }
            SampleLabel { label: qsTr("2. Standard action trio") }
            MeoButtonGroup { type: "filled"; model: [{ "label": qsTr("Back"), "icon": "arrow_back" }, { "label": qsTr("Pause"), "icon": "pause" }, { "label": qsTr("Next"), "icon": "arrow_forward" }]; currentIndex: 1 }
            SampleLabel { label: qsTr("3. Connected: stable view selection") }
            MeoButtonGroup { width: 420 * MeoTheme.globalScale; variant: "connected"; type: "outlined"; model: [{ "label": qsTr("List"), "icon": "view_list" }, { "label": qsTr("Grid"), "icon": "grid_view" }, { "label": qsTr("Map"), "icon": "map" }]; currentIndex: 1 }
            SampleLabel { label: qsTr("4. Connected multi-select") }
            MeoButtonGroup { width: 420 * MeoTheme.globalScale; variant: "connected"; type: "outlined"; multiSelect: true; selectedIndices: [0, 2]; model: [{ "label": qsTr("Photos") }, { "label": qsTr("Videos") }, { "label": qsTr("Files") }] }
            SampleLabel { label: qsTr("5. Disabled") }
            MeoButtonGroup { model: [{ "label": qsTr("Day") }, { "label": qsTr("Week") }, { "label": qsTr("Month") }]; currentIndex: 1; enabled: false }
            SampleLabel { label: qsTr("6. Standard size spacing (XS / S; M shown above)") }
            Flow {
                width: 590 * MeoTheme.globalScale
                spacing: MeoTheme.space12
                MeoButtonGroup { size: "xs"; model: [{ "label": qsTr("A") }, { "label": qsTr("B") }, { "label": qsTr("C") }] }
                MeoButtonGroup { size: "s"; model: [{ "label": qsTr("A") }, { "label": qsTr("B") }, { "label": qsTr("C") }] }
            }
        }
    }
    Component {
        id: segmentedSample
        Column {
            spacing: MeoTheme.space8
            SampleLabel { label: qsTr("Single selection") }
            MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: [qsTr("List"), qsTr("Grid"), qsTr("Map")]; currentIndex: 1 }
            SampleLabel { label: qsTr("Single with icons") }
            MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: [{ "label": qsTr("List"), "icon": "view_list" }, { "label": qsTr("Grid"), "icon": "grid_view" }, { "label": qsTr("Map"), "icon": "map" }]; currentIndex: 1 }
            SampleLabel { label: qsTr("Multi selection") }
            MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: [qsTr("Bold"), qsTr("Italic"), qsTr("Underline")]; multiSelect: true; selectedIndices: [0, 2] }
            SampleLabel { label: qsTr("Disabled") }
            MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: [qsTr("List"), qsTr("Grid"), qsTr("Map")]; currentIndex: 1; enabled: false }
            SampleLabel { label: qsTr("Compact") }
            MeoSegmentedButtons { width: 300 * MeoTheme.globalScale; size: "xs"; model: [qsTr("A"), qsTr("B"), qsTr("C")]; currentIndex: 1 }
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
                label: qsTr("Filled")
                placeholder: qsTr("Filled input")
                helperText: qsTr("Supporting text")
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: qsTr("Outlined")
                placeholder: qsTr("Outlined input")
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: qsTr("Search")
                leadingIcon: "search"
                trailingIcon: "close"
                showClearButton: true
                text: qsTr("Material")
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: qsTr("Password")
                placeholder: qsTr("Enter password")
                trailingIcon: "visibility"
                echoMode: TextInput.Password
                text: qsTr("secret")
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: qsTr("Error")
                text: qsTr("bad input")
                isError: true
                errorText: qsTr("Invalid input")
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: qsTr("Counter")
                text: qsTr("Short note")
                maxLength: 24
                showCounter: true
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: qsTr("Prefix / suffix")
                prefixText: "$"
                suffixText: "USD"
                text: "128"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: qsTr("Disabled")
                text: qsTr("Disabled")
                enabled: false
            }
        }
    }
    Component {
        id: textAreaSample
        Grid {
            columns: 3
            spacing: MeoTheme.space12
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: qsTr("Summary"); placeholder: qsTr("Write a short summary"); helperText: qsTr("Filled") }
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: qsTr("Description"); type: "outlined"; text: qsTr("Outlined multi-line input") }
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: qsTr("Notes"); text: qsTr("Too short"); isError: true; errorText: qsTr("Add more detail") }
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: qsTr("Bio"); text: qsTr("A concise profile"); maxLength: 40; showCounter: true }
            MeoTextArea { width: 272 * MeoTheme.globalScale; height: 124 * MeoTheme.globalScale; label: qsTr("Disabled"); text: qsTr("Unavailable"); enabled: false }
        }
    }
    Component {
        id: dropdownSample
        Grid {
            columns: 3
            spacing: MeoTheme.space12
            MeoExposedDropdown { width: 260 * MeoTheme.globalScale; label: qsTr("Environment"); model: [qsTr("Development"), qsTr("Staging"), qsTr("Production")]; currentIndex: 0 }
            MeoExposedDropdown { width: 260 * MeoTheme.globalScale; label: qsTr("Region"); type: "outlined"; model: [qsTr("Americas"), qsTr("Europe"), qsTr("Asia")]; currentIndex: 2 }
            MeoExposedDropdown { width: 260 * MeoTheme.globalScale; label: qsTr("Workspace"); model: [qsTr("Personal"), qsTr("Team")]; isError: true; errorText: qsTr("Choose a workspace") }
            MeoExposedDropdown {
                width: 260 * MeoTheme.globalScale
                label: qsTr("Open menu")
                model: [qsTr("Inbox"), qsTr("Later"), qsTr("Archived")]
                Timer {
                    interval: 300
                    running: true
                    repeat: false
                    onTriggered: parent.openMenu()
                }
            }
            MeoExposedDropdown { width: 260 * MeoTheme.globalScale; label: qsTr("Disabled"); model: [qsTr("Unavailable")]; currentIndex: 0; enabled: false }
        }
    }
    Component {
        id: dateInputSample
        Grid {
            columns: 2
            spacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("ISO value") }
                MeoDateInput { width: 220 * MeoTheme.globalScale; value: new Date(2026, 7, 31) }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Slash format") }
                MeoDateInput { width: 220 * MeoTheme.globalScale; format: "yyyy/MM/dd"; value: new Date(2024, 1, 29) }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Empty allowed") }
                MeoDateInput { width: 220 * MeoTheme.globalScale; allowEmpty: true; value: new Date(0) }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Clear affordance") }
                MeoDateInput { width: 220 * MeoTheme.globalScale; value: new Date(2025, 11, 24); showClearButton: true }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Validation error") }
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
                SampleLabel { label: qsTr("Disabled") }
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
                SampleLabel { label: qsTr("Morning") }
                MeoTimeInput { width: 220 * MeoTheme.globalScale; value: "09:30" }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Clear affordance") }
                MeoTimeInput { width: 220 * MeoTheme.globalScale; value: "18:45"; showClearButton: true }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Empty allowed") }
                MeoTimeInput { width: 220 * MeoTheme.globalScale; allowEmpty: true }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Validation error") }
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
                SampleLabel { label: qsTr("Disabled") }
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
                SampleLabel { label: qsTr("Step 2") }
                MeoSpinBox { from: 0; to: 100; value: 42; stepSize: 2 }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Minimum") }
                MeoSpinBox { from: 0; to: 10; value: 0 }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Maximum") }
                MeoSpinBox { from: 0; to: 10; value: 10 }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Read only") }
                MeoSpinBox { from: -5; to: 5; value: -2; editable: false }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Disabled") }
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

            MeoCheckbox { label: qsTr("Checked"); checked: true }
            MeoCheckbox { label: qsTr("Unchecked") }
            MeoCheckbox { label: qsTr("Indeterminate"); indeterminate: true }
            MeoCheckbox { label: qsTr("Error"); checked: true; isError: true; errorText: qsTr("Required") }
            MeoCheckbox { label: qsTr("Disabled"); checked: true; enabled: false }
        }
    }
    Component {
        id: radioSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space24

            MeoRadioButton { label: qsTr("Selected"); checked: true }
            MeoRadioButton { label: qsTr("Unselected") }
            MeoRadioButton { label: qsTr("Error"); checked: true; isError: true; errorText: qsTr("Choose an option") }
            MeoRadioButton { label: qsTr("Disabled selected"); checked: true; enabled: false }
            MeoRadioButton { label: qsTr("Disabled"); enabled: false }
        }
    }
    Component {
        id: switchSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space24

            MeoSwitch { label: qsTr("No icons"); checked: true }
            MeoSwitch { label: qsTr("Selected icon"); checked: true; showIcon: true; icon: "check" }
            MeoSwitch { label: qsTr("Both icons"); uncheckedIcon: "close" }
            MeoSwitch { label: qsTr("Error"); checked: true; showIcon: true; icon: "check"; isError: true; errorText: qsTr("Unavailable") }
            MeoSwitch { label: qsTr("Disabled on"); checked: true; showIcon: true; icon: "check"; enabled: false }
            MeoSwitch { label: qsTr("Disabled off"); uncheckedIcon: "close"; enabled: false }
        }
    }
    Component {
        id: sliderSample
        Column {
            width: 520 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            SampleLabel { label: qsTr("1. XS — 16 / 44 / R8") }
            MeoSlider {
                width: parent.width
                value: 50
                expressive: true
                size: "xs"
            }

            SampleLabel { label: qsTr("2. S — 24 / 44 / R8, discrete stops") }
            MeoSlider {
                width: parent.width
                value: 40
                expressive: true
                size: "s"
                stops: true
                stepSize: 10
            }

            SampleLabel { label: qsTr("3. M — 40 / 52 / R12, 24dp inset icon") }
            MeoSlider {
                width: parent.width
                value: 48
                expressive: true
                size: "m"
                insetIcon: "volume_up"
            }

            SampleLabel { label: qsTr("4. L — 56 / 68 / R16, 24dp inset icon") }
            MeoSlider {
                width: parent.width
                value: 56
                expressive: true
                size: "l"
                insetIcon: "volume_up"
            }

            SampleLabel { label: qsTr("5. XL — 96 / 108 / R28, 32dp inset icon") }
            MeoSlider {
                width: parent.width
                value: 64
                expressive: true
                size: "xl"
                insetIcon: "volume_up"
            }

            Row {
                spacing: MeoTheme.space24

                Column {
                    spacing: MeoTheme.space8
                    SampleLabel { label: qsTr("Value indicator") }
                    MeoSlider {
                        width: 320 * MeoTheme.globalScale
                        value: 50
                        expressive: true
                        valueLabelEnabled: true
                    }
                }

                Column {
                    spacing: MeoTheme.space8
                    SampleLabel { label: qsTr("Vertical") }
                    MeoSlider {
                        width: 52 * MeoTheme.globalScale
                        height: 180 * MeoTheme.globalScale
                        value: 60
                        expressive: true
                        size: "m"
                        orientation: Qt.Vertical
                    }
                }
            }
        }
    }
    Component {
        id: scrollBarSample
        Flow {
            spacing: MeoTheme.space16
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("1. Vertical always on") }
                MeoScrollBar { height: 120 * MeoTheme.globalScale; orientation: Qt.Vertical; policy: ScrollBar.AlwaysOn; position: 0.28; size: 0.35 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("2. Horizontal always on") }
                MeoScrollBar { width: 132 * MeoTheme.globalScale; orientation: Qt.Horizontal; policy: ScrollBar.AlwaysOn; position: 0.28; size: 0.35 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("3. Vertical auto") }
                MeoScrollBar { height: 120 * MeoTheme.globalScale; orientation: Qt.Vertical; policy: ScrollBar.AsNeeded; active: true; position: 0.52; size: 0.30 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("4. Horizontal auto") }
                MeoScrollBar { width: 132 * MeoTheme.globalScale; orientation: Qt.Horizontal; policy: ScrollBar.AsNeeded; active: true; position: 0.52; size: 0.30 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("5. Disabled") }
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

            SampleLabel { label: qsTr("1. Standard range") }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 24; secondValue: 78 }

            SampleLabel { label: qsTr("2. Expressive split") }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 24; secondValue: 78; expressive: true; trackStyle: "split" }

            SampleLabel { label: qsTr("3. Discrete stops") }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 20; secondValue: 80; discrete: true; stepSize: 20 }

            SampleLabel { label: qsTr("4. Narrow range") }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 46; secondValue: 54 }

            SampleLabel { label: qsTr("5. Disabled") }
            MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 24; secondValue: 78; enabled: false }
        }
    }
    Component {
        id: quickControlSliderSample
        Column {
            width: 360 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            SampleLabel { label: qsTr("1. Low") }
            MeoQuickControlSlider { width: parent.width; iconName: "light_mode"; label: qsTr("Brightness"); accessibleName: qsTr("Brightness"); iconAccessibleName: qsTr("Display options"); value: 24 }

            SampleLabel { label: qsTr("2. Mid") }
            MeoQuickControlSlider { width: parent.width; iconName: "volume_up"; label: qsTr("Output volume"); accessibleName: qsTr("Output volume"); iconAccessibleName: qsTr("Mute output"); value: 52 }

            SampleLabel { label: qsTr("3. High") }
            MeoQuickControlSlider { width: parent.width; iconName: "wifi"; label: qsTr("Wi-Fi strength"); accessibleName: qsTr("Wi-Fi strength"); iconAccessibleName: qsTr("Network options"); value: 88 }

            SampleLabel { label: qsTr("4. Details expanded") }
            MeoQuickControlSlider { width: parent.width; iconName: "volume_up"; label: qsTr("Output volume"); accessibleName: qsTr("Output volume"); iconAccessibleName: qsTr("Mute output"); value: 64; detailsAvailable: true; expanded: true }

            SampleLabel { label: qsTr("5. Disabled") }
            MeoQuickControlSlider { width: parent.width; iconName: "light_mode"; label: qsTr("Brightness"); accessibleName: qsTr("Brightness"); iconAccessibleName: qsTr("Display options"); value: 38; enabled: false }

            SampleLabel { label: qsTr("6. External value animation") }
            MeoQuickControlSlider { width: parent.width; iconName: "volume_up"; label: qsTr("Hardware volume"); accessibleName: qsTr("Hardware volume"); value: 76; animateExternalChanges: true; motionProfile: "pixel" }
        }
    }
    Component {
        id: quickSettingsTileSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space16

            SampleLabel { label: qsTr("1. Pixel wide active") }
            MeoQuickSettingsTile { title: qsTr("Wi-Fi"); supportingText: qsTr("Connected"); iconName: "wifi"; active: true; wide: true; visualStyle: "pixel"; detailsEnabled: true }

            SampleLabel { label: qsTr("2. Pixel wide inactive") }
            MeoQuickSettingsTile { title: qsTr("Bluetooth"); supportingText: qsTr("Off"); iconName: "bluetooth"; wide: true; visualStyle: "pixel" }

            SampleLabel { label: qsTr("3. Pixel compact active") }
            MeoQuickSettingsTile { title: qsTr("Flashlight"); iconName: "flashlight_on"; active: true; wide: false; visualStyle: "pixel" }

            SampleLabel { label: qsTr("4. Pixel compact inactive") }
            MeoQuickSettingsTile { title: qsTr("Airplane"); iconName: "flight"; wide: false; visualStyle: "pixel" }

            SampleLabel { label: qsTr("5. Edit state") }
            MeoQuickSettingsTile { title: qsTr("Quick Share"); supportingText: qsTr("Contacts"); iconName: "share"; active: true; wide: true; visualStyle: "pixel"; editMode: true; editSelected: true }

            SampleLabel { label: qsTr("6. Busy / unavailable") }
            MeoQuickSettingsTile { title: qsTr("Wi-Fi"); supportingText: qsTr("Waiting for NetworkManager"); iconName: "wifi"; wide: true; visualStyle: "pixel"; busy: true }
        }
    }
    Component {
        id: selectionGroupSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space24

            SampleLabel { label: qsTr("1. Checkbox mixed") }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "checkbox"; showSelectAll: true; model: [{ "label": qsTr("Design"), "checked": true }, { "label": qsTr("Code"), "checked": false }, { "label": qsTr("Research"), "checked": true }] }

            SampleLabel { label: qsTr("2. Checkbox all selected") }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "checkbox"; showSelectAll: true; model: [{ "label": qsTr("Alerts"), "checked": true }, { "label": qsTr("Updates"), "checked": true }] }

            SampleLabel { label: qsTr("3. Radio selection") }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "radio"; model: [{ "label": qsTr("Light"), "checked": false }, { "label": qsTr("System"), "checked": true }, { "label": qsTr("Dark"), "checked": false }] }

            SampleLabel { label: qsTr("4. Supporting text") }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "radio"; model: [{ "label": qsTr("Automatic"), "supportingText": qsTr("Follow the device"), "checked": true }, { "label": qsTr("Manual"), "supportingText": qsTr("Choose a fixed mode"), "checked": false }] }

            SampleLabel { label: qsTr("5. Disabled") }
            MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "checkbox"; showSelectAll: true; model: [{ "label": qsTr("Design"), "checked": true }, { "label": qsTr("Code"), "checked": false }]; enabled: false }
        }
    }
    Component {
        id: filterGroupSample
        Column {
            width: 520 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            SampleLabel { label: qsTr("1. Single selection") }
            MeoFilterGroup { width: parent.width; model: [qsTr("All"), qsTr("Open"), qsTr("Archived")]; currentIndex: 0 }

            SampleLabel { label: qsTr("2. Multiple selection") }
            MeoFilterGroup { width: parent.width; multiSelect: true; selectedIndices: [0, 2]; model: [qsTr("Updates"), qsTr("Assigned"), qsTr("Mentioned")] }

            SampleLabel { label: qsTr("3. With icons") }
            MeoFilterGroup { width: parent.width; model: [{ "label": qsTr("Design"), "icon": "palette" }, { "label": qsTr("Code"), "icon": "code" }, { "label": qsTr("Docs"), "icon": "article" }]; currentIndex: 1 }

            SampleLabel { label: qsTr("4. Required selection") }
            MeoFilterGroup { width: parent.width; allowEmptySelection: false; currentIndex: 1; model: [qsTr("List"), qsTr("Grid"), qsTr("Cards")] }

            SampleLabel { label: qsTr("5. Disabled") }
            MeoFilterGroup { width: parent.width; model: [{ "label": qsTr("Available") }, { "label": qsTr("Unavailable"), "enabled": false }, { "label": qsTr("Selected") }]; currentIndex: 2 }
        }
    }
    Component {
        id: stepperSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space24

            SampleLabel { label: qsTr("1. Horizontal current") }
            MeoStepper { width: 420 * MeoTheme.globalScale; model: [qsTr("Account"), qsTr("Profile"), qsTr("Review")]; currentIndex: 1 }

            SampleLabel { label: qsTr("2. Vertical completed") }
            MeoStepper { height: 220 * MeoTheme.globalScale; orientation: "vertical"; model: [qsTr("Draft"), qsTr("Check"), qsTr("Publish")]; currentIndex: 3 }

            SampleLabel { label: qsTr("3. First step") }
            MeoStepper { width: 420 * MeoTheme.globalScale; model: [qsTr("Choose"), qsTr("Configure"), qsTr("Finish")]; currentIndex: 0 }

            SampleLabel { label: qsTr("4. Interactive") }
            MeoStepper { height: 220 * MeoTheme.globalScale; orientation: "vertical"; model: [qsTr("Source"), qsTr("Preview"), qsTr("Save")]; currentIndex: 1; interactive: true }

            SampleLabel { label: qsTr("5. Disabled") }
            MeoStepper { width: 420 * MeoTheme.globalScale; model: [qsTr("Sign in"), qsTr("Verify"), qsTr("Done")]; currentIndex: 1; enabled: false }
        }
    }
    Component {
        id: navigationBarSample
        Column {
            width: 440 * MeoTheme.globalScale
            spacing: MeoTheme.space8

            SampleLabel { label: qsTr("1. Always labels · active indicator") }
            MeoNavigationBar {
                width: parent.width
                model: [
                    { "id": "home", "label": qsTr("Home"), "icon": "home" },
                    { "id": "explore", "label": qsTr("Explore"), "icon": "explore" },
                    { "id": "library", "label": qsTr("Library"), "icon": "folder" }
                ]
                currentId: "explore"
            }

            SampleLabel { label: qsTr("2. Selected label") }
            MeoNavigationBar {
                width: parent.width
                labelType: "selected"
                model: [
                    { "id": "home", "label": qsTr("Home"), "icon": "home" },
                    { "id": "browse", "label": qsTr("Browse"), "icon": "explore" },
                    { "id": "radio", "label": qsTr("Radio"), "icon": "radio" },
                    { "id": "library", "label": qsTr("Library"), "icon": "folder" }
                ]
                currentId: "home"
            }

            SampleLabel { label: qsTr("3. Icon-only with notification dot") }
            MeoNavigationBar {
                width: parent.width
                labelType: "none"
                model: [
                    { "id": "home", "label": qsTr("Home"), "icon": "home" },
                    { "id": "inbox", "label": qsTr("Inbox"), "icon": "inbox", "badgeDot": true },
                    { "id": "saved", "label": qsTr("Saved"), "icon": "favorite" }
                ]
                currentId: "inbox"
            }

            SampleLabel { label: qsTr("4. Numeric badge") }
            MeoNavigationBar {
                width: parent.width
                model: [
                    { "id": "home", "label": qsTr("Home"), "icon": "home" },
                    { "id": "updates", "label": qsTr("Updates"), "icon": "notifications", "badgeText": "24" },
                    { "id": "settings", "label": qsTr("Settings"), "icon": "settings" }
                ]
                currentId: "updates"
            }

            SampleLabel { label: qsTr("5. Disabled destination") }
            MeoNavigationBar {
                width: parent.width
                compact: true
                model: [
                    { "id": "home", "label": qsTr("Home"), "icon": "home" },
                    { "id": "locked", "label": qsTr("Locked"), "icon": "lock", "enabled": false },
                    { "id": "profile", "label": qsTr("Profile"), "icon": "person" }
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
                { "id": "inbox", "label": qsTr("Inbox"), "icon": "inbox", "badgeText": "24" },
                { "id": "outbox", "label": qsTr("Outbox"), "icon": "send" },
                { "id": "favorites", "label": qsTr("Favorites"), "icon": "favorite" },
                { "id": "trash", "label": qsTr("Trash"), "icon": "delete" },
                { "type": "header", "label": qsTr("Labels") },
                { "id": "label", "label": qsTr("Label"), "icon": "folder", "badgeDot": true }
            ]
            readonly property var compactRailItems: [
                { "id": "inbox", "label": qsTr("Inbox"), "icon": "inbox", "badgeText": "24" },
                { "id": "outbox", "label": qsTr("Outbox"), "icon": "send" },
                { "id": "favorites", "label": qsTr("Favorites"), "icon": "favorite" },
                { "id": "trash", "label": qsTr("Trash"), "icon": "delete" }
            ]

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Collapsed · 96dp") }
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
                SampleLabel { label: qsTr("Collapsed · selected label") }
                MeoNavigationRail {
                    height: 380 * MeoTheme.globalScale
                    model: railExamples.compactRailItems
                    currentIndex: 1
                    labelType: "selected"
                }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Expanded · 220dp") }
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
                SampleLabel { label: qsTr("Expanded · menu and FAB") }
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
                            MeoButton { text: qsTr("Compose"); type: "filled"; icon.name: "edit" }
                        }
                    }
                }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Expanded · 360dp groups") }
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
            SampleLabel { label: qsTr("Legacy compatibility · 360dp baseline; prefer expanded MeoNavigationRail") }
            MeoNavigationDrawer { width: 360 * MeoTheme.globalScale; height: 300 * MeoTheme.globalScale; model: control.navItems; currentIndex: 0; title: qsTr("MeoUI") }
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
                text: qsTr("Open modal navigation rail")
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
                        MeoButton { text: qsTr("Compose"); icon.name: "edit" }
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

            MeoButton { text: qsTr("Open modal navigation rail"); icon.name: "menu"; onClicked: drawer.open() }
            MeoNavigationDrawerModal { id: drawer; model: control.navItems }
        }
    }
    Component {
        id: drawerItemSample

        Column {
            width: 360 * MeoTheme.globalScale
            spacing: MeoTheme.space4

            MeoNavigationDrawerItem { width: parent.width; label: qsTr("Inbox"); icon: "inbox"; selected: true; badgeText: "8" }
            MeoNavigationDrawerItem { width: parent.width; label: qsTr("Archive"); icon: "archive" }
            MeoNavigationDrawerItem { width: parent.width; label: qsTr("Updates"); icon: "update"; mode: "group"; selected: true; supportingText: qsTr("Grouped row"); showDivider: true; roundedBottom: false }
            MeoNavigationDrawerItem { width: parent.width; label: qsTr("Advanced"); icon: "tune"; mode: "group"; supportingText: qsTr("Supporting text"); roundedTop: false }
            MeoNavigationDrawerItem { width: parent.width; label: qsTr("Settings"); icon: "settings"; selected: true; visualStyle: "settings" }
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
                    { "id": "home", "label": qsTr("Home"), "icon": "home" },
                    { "id": "explore", "label": qsTr("Explore"), "icon": "explore", "badgeText": "3" },
                    { "id": "profile", "label": qsTr("Profile"), "icon": "person" },
                    { "id": "library", "label": qsTr("Library"), "icon": "library_music" },
                    { "id": "settings", "label": qsTr("Settings"), "icon": "settings" },
                    { "id": "help", "label": qsTr("Help"), "icon": "help" }
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
                SampleLabel { label: qsTr("1. Icons") }
                MeoBreadcrumbs { model: [{ "label": qsTr("Home"), "icon": "home" }, { "label": qsTr("Library"), "icon": "folder" }, { "label": qsTr("Component") }] }
            }
            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("2. Text-only") }
                MeoBreadcrumbs { model: [{ "label": qsTr("Home") }, { "label": qsTr("Articles") }, { "label": qsTr("M3 navigation") }] }
            }
            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("3. Custom separator") }
                MeoBreadcrumbs { separator: "arrow_forward"; model: [{ "label": qsTr("Drive"), "icon": "folder" }, { "label": qsTr("Shared") }, { "label": qsTr("Preview") }] }
            }
            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("4. Explicit current item") }
                MeoBreadcrumbs { currentIndex: 1; model: [{ "label": qsTr("Projects"), "icon": "folder" }, { "label": qsTr("MeoUI") }, { "label": qsTr("Archive") }] }
            }
            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("5. Disabled link") }
                MeoBreadcrumbs { model: [{ "label": qsTr("Home"), "icon": "home" }, { "label": qsTr("Restricted"), "enabled": false }, { "label": qsTr("Current") }] }
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

                SampleLabel { label: qsTr("1. Primary with icons") }
                MeoTabs {
                    width: parent.width
                    model: [{ "label": qsTr("Video"), "icon": "videocam" }, { "label": qsTr("Photos"), "icon": "photo", "badgeDot": true }, { "label": qsTr("Audio"), "icon": "audiotrack" }]
                    currentIndex: 1
                }

                SampleLabel { label: qsTr("2. Primary text") }
                MeoTabs {
                    width: parent.width
                    model: [qsTr("Overview"), qsTr("Specs"), qsTr("Reviews")]
                    currentIndex: 0
                }

                SampleLabel { label: qsTr("3. Secondary") }
                MeoTabs {
                    width: parent.width
                    type: "secondary"
                    model: [qsTr("Explore"), qsTr("Flights"), qsTr("Trips")]
                    currentIndex: 2
                }
            }

            Column {
                width: 340 * MeoTheme.globalScale
                spacing: MeoTheme.space12

                SampleLabel { label: qsTr("4. Expressive pill") }
                MeoTabs {
                    width: parent.width
                    style: "expressive"
                    model: [{ "label": qsTr("For you"), "icon": "auto_awesome" }, { "label": qsTr("Following"), "icon": "groups" }, { "label": qsTr("Saved"), "icon": "bookmark" }]
                    currentIndex: 0
                }

                SampleLabel { label: qsTr("5. Scrollable") }
                MeoTabs {
                    width: parent.width
                    isScrollable: true
                    model: [qsTr("Overview"), qsTr("Specifications"), qsTr("Reviews"), qsTr("Support")]
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

                SampleLabel { label: qsTr("1. Small") }
                MeoTopAppBar {
                    width: parent.width
                    title: qsTr("Inbox")
                    type: "small"
                    navigationIcon: Component { MeoIconButton { icon.name: "menu"; type: "standard" } }
                    actions: [Component { MeoIconButton { icon.name: "search" } }, Component { MeoIconButton { icon.name: "more_vert" } }]
                }

                SampleLabel { label: qsTr("2. Center-aligned") }
                MeoTopAppBar {
                    width: parent.width
                    title: qsTr("Now playing")
                    type: "center"
                    navigationIcon: Component { MeoIconButton { icon.name: "arrow_back"; type: "standard" } }
                    actions: [Component { MeoIconButton { icon.name: "cast" } }]
                }

                SampleLabel { label: qsTr("3. Medium") }
                MeoTopAppBar {
                    width: parent.width
                    title: qsTr("Library")
                    type: "medium"
                    navigationIcon: Component { MeoIconButton { icon.name: "arrow_back"; type: "standard" } }
                    actions: [Component { MeoIconButton { icon.name: "search" } }, Component { MeoIconButton { icon.name: "favorite" } }]
                }
            }

            Column {
                width: 372 * MeoTheme.globalScale
                spacing: MeoTheme.space8

                SampleLabel { label: qsTr("4. Large flexible · collapsed pose") }
                MeoTopAppBar {
                    width: parent.width
                    title: qsTr("Discover")
                    type: "large"
                    flexible: true
                    scrollProgress: 0
                    navigationIcon: Component { MeoIconButton { icon.name: "menu"; type: "standard" } }
                    actions: [Component { MeoIconButton { icon.name: "search" } }]
                }

                SampleLabel { label: qsTr("5. Contextual selection") }
                MeoTopAppBar {
                    width: parent.width
                    title: qsTr("Ignored when contextual")
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
                    text: qsTr("M3 menus")
                    typeRole: "title"
                    typeSize: "small"
                }

                MeoText {
                    text: qsTr("Standard, vibrant, checked, keyboard, shortcuts, labels, dividers, and submenus.")
                    typeRole: "body"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                }

                Flow {
                    spacing: MeoTheme.space8
                    MeoButton { text: qsTr("Open standard"); icon.name: "more_vert"; onClicked: standardMenu.openFrom(this) }
                    MeoButton { text: qsTr("Open vibrant"); type: "tonal"; icon.name: "palette"; onClicked: vibrantMenu.openFrom(this) }
                    MeoButton { text: qsTr("Open submenu"); type: "outlined"; icon.name: "arrow_right"; onClicked: standardMenu.openSubmenu(4, standardMenu.model[4], standardMenu.menuItemAt(4)) }
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
                    { "type": "label", "label": qsTr("EDIT") },
                    { "label": qsTr("Copy"), "icon": "content_copy", "trailingText": "Ctrl+C" },
                    { "label": qsTr("Share"), "icon": "share", "selected": true },
                    { "label": qsTr("Offline mode"), "icon": "cloud_off", "checked": true, "supportingText": qsTr("Saved locally") },
                    { "label": qsTr("More tools"), "icon": "folder", "subItems": [{ "label": qsTr("Document"), "icon": "article" }, { "label": qsTr("Image"), "icon": "image", "selected": true }, { "label": qsTr("Slides"), "icon": "slideshow" }] },
                    { "type": "separator" },
                    { "label": qsTr("Paste"), "icon": "content_paste", "trailingText": "Ctrl+V", "enabled": false },
                    { "label": qsTr("Delete"), "icon": "delete", "trailingIcon": "keyboard_return" }
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
                    { "label": qsTr("Create"), "icon": "edit" },
                    { "label": qsTr("Offline mode"), "icon": "cloud_off", "checked": true },
                    { "label": qsTr("Settings"), "icon": "settings" },
                    { "label": qsTr("Help & feedback"), "icon": "help" }
                ]
            }
        }
    }
    Component {
        id: contextMenuSample
        Item {
            id: contextMenuRoot
            width: 520 * MeoTheme.globalScale
            height: 292 * MeoTheme.globalScale

            MeoCard {
                id: contextTarget
                anchors.centerIn: parent
                width: 312 * MeoTheme.globalScale
                height: 168 * MeoTheme.globalScale
                type: "filled"
                interactive: true

                Column {
                    anchors.centerIn: parent
                    width: parent.width - 2 * MeoTheme.space24
                    spacing: MeoTheme.space8
                    MeoIcon { anchors.horizontalCenter: parent.horizontalCenter; icon: "widgets"; size: 32; color: MeoTheme.primary }
                    MeoText { width: parent.width; text: qsTr("Widget card"); typeRole: "title"; typeSize: "small"; emphasized: true; horizontalAlignment: Text.AlignHCenter }
                    MeoText { width: parent.width; text: qsTr("Right-click or use the action"); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; horizontalAlignment: Text.AlignHCenter }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton)
                            contextMenu.openAtPoint(contextTarget, mouse.x, mouse.y)
                    }
                }
            }

            MeoButton {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: qsTr("Open context menu")
                icon.name: "more_vert"
                onClicked: contextMenu.openAtPoint(contextTarget,
                                                    contextTarget.width / 2,
                                                    contextTarget.height / 2)
            }

            MeoContextMenu {
                id: contextMenu
                parent: contextMenuRoot
                z: 10
                model: [
                    { "label": qsTr("Add to desktop"), "icon": "add" },
                    { "label": qsTr("Show alignment guides"), "icon": "grid_on", "selected": true },
                    { "type": "separator" },
                    { "label": qsTr("More options"), "icon": "more_horiz", "subItems": [{ "label": qsTr("Inspect"), "icon": "visibility" }] },
                    { "label": qsTr("Unavailable action"), "icon": "block", "enabled": false }
                ]
            }
        }
    }
    Component {
        id: meoWidgetSample
        Row {
            width: 620 * MeoTheme.globalScale
            height: 252 * MeoTheme.globalScale
            spacing: MeoTheme.space16

            MeoWidget {
                id: framedWidget
                width: 288 * MeoTheme.globalScale
                height: parent.height
                widgetId: "weather"
                preferredSize: MeoWidget.SizeMedium
                supportedSizes: [MeoWidget.SizeSmall, MeoWidget.SizeWide,
                                 MeoWidget.SizeMedium, MeoWidget.SizeLarge]
                privacy: MeoWidget.Location
                refreshPolicy: MeoWidget.Periodic
                supportedSurfaces: [MeoWidget.Desktop, MeoWidget.LockScreen]
                accessibleName: qsTr("Weather")

                Column {
                    anchors.centerIn: parent
                    width: parent.width - 2 * MeoTheme.space16
                    spacing: MeoTheme.space8
                    MeoIcon { anchors.horizontalCenter: parent.horizontalCenter; icon: "partly_cloudy_day"; size: 40; color: MeoTheme.primary }
                    MeoText { width: parent.width; text: "22°"; typeRole: "display"; typeSize: "small"; emphasized: true; horizontalAlignment: Text.AlignHCenter }
                    MeoText { width: parent.width; text: qsTr("Location privacy · periodic cache"); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap }
                }
            }

            MeoWidget {
                width: 288 * MeoTheme.globalScale
                height: parent.height
                widgetId: "media"
                preferredSize: MeoWidget.SizeLarge
                supportedSizes: [MeoWidget.SizeWide, MeoWidget.SizeMedium,
                                 MeoWidget.SizeLarge]
                privacy: MeoWidget.Media
                refreshPolicy: MeoWidget.EventDriven
                supportedSurfaces: [MeoWidget.Desktop, MeoWidget.LockScreen]
                frameMode: MeoWidget.Adaptive
                wantsOwnBackground: true
                accessibleName: qsTr("Media")

                MeoCard {
                    anchors.fill: parent
                    type: "filled"
                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 2 * MeoTheme.space16
                        spacing: MeoTheme.space8
                        MeoIcon { anchors.horizontalCenter: parent.horizontalCenter; icon: "music_note"; size: 36; color: MeoTheme.primary }
                        MeoText { width: parent.width; text: qsTr("Adaptive widget frame"); typeRole: "title"; typeSize: "small"; emphasized: true; horizontalAlignment: Text.AlignHCenter }
                        MeoText { width: parent.width; text: qsTr("The content keeps its own surface."); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap }
                    }
                }
            }
        }
    }
    Component {
        id: meoWidgetSheetSample
        MeoWidgetSheet {
            width: 1120 * MeoTheme.globalScale
            height: 660 * MeoTheme.globalScale
            // The full sheet uses desktop dimensions. Keep that layout legible
            // inside the narrower Showcase documentation page without changing
            // the product component's responsive contract.
            scale: 0.8
            transformOrigin: Item.TopLeft
            selectedWidgetKey: "meo:media"
            catalog: [
                {
                    "host": "meo", "id": "clock", "title": qsTr("Meo clock"),
                    "description": qsTr("Large date, time, and cached weather when available."),
                    "icon": "schedule", "defaultWidth": 320, "defaultHeight": 224,
                    "available": true
                },
                {
                    "host": "meo", "id": "media", "title": qsTr("Meo media"),
                    "description": qsTr("Playback controls for the current session."),
                    "icon": "music_note", "defaultWidth": 384, "defaultHeight": 176,
                    "available": true
                },
                {
                    "host": "plasma", "id": "org.kde.plasma.digitalclock",
                    "title": qsTr("Digital Clock"), "description": qsTr("Time and calendar."),
                    "icon": "schedule", "available": true
                },
                {
                    "host": "plasma", "id": "org.kde.plasma.systemmonitor",
                    "title": qsTr("System Monitor"), "description": qsTr("Sensors and resource use."),
                    "icon": "monitoring", "available": true
                }
            ]
        }
    }
    Component { id: dataTableSample; MeoDataTable { width: 520 * MeoTheme.globalScale; columns: control.tableColumns; model: control.tableRows; selectable: true; sortProperty: "calories" } }
    Component {
        id: listItemSample
        Column {
            width: 420 * MeoTheme.globalScale
            spacing: MeoTheme.space4

            SampleLabel { label: qsTr("1. One-line with badge") }
            MeoListItem { width: parent.width; headline: qsTr("Inbox"); leadingIcon: "inbox"; badgeText: "3" }

            SampleLabel { label: qsTr("2. Supporting text") }
            MeoListItem {
                width: parent.width
                headline: qsTr("Release notes")
                supportingText: qsTr("Updated 10 minutes ago")
                leadingComponentSize: 36
                leadingComponent: Component {
                    Rectangle {
                        width: 36 * MeoTheme.globalScale
                        height: width
                        radius: MeoTheme.shapeSmall
                        color: MeoTheme.tertiaryContainer
                        MeoIcon {
                            anchors.centerIn: parent
                            icon: "article"
                            size: 22
                            color: MeoTheme.contentOnTertiaryContainer
                        }
                    }
                }
            }

            SampleLabel { label: qsTr("3. Tonal selected") }
            MeoListItem { width: parent.width; headline: qsTr("Selected row"); supportingText: qsTr("Secondary container"); leadingIcon: "check_circle"; selected: true; isSegmented: true }

            SampleLabel { label: qsTr("4. Expressive vibrant") }
            MeoListItem { width: parent.width; headline: qsTr("Pinned item"); supportingText: qsTr("Primary in expressive mode"); leadingIcon: "push_pin"; selected: true; isSegmented: true; vibrant: true }

            SampleLabel { label: qsTr("5. Disabled") }
            MeoListItem { width: parent.width; headline: qsTr("Unavailable item"); supportingText: qsTr("This action is disabled"); leadingIcon: "block"; enabled: false }
        }
    }
    Component {
        id: listViewSample
        Item {
            id: listViewRoot
            width: 420 * MeoTheme.globalScale
            height: 228 * MeoTheme.globalScale

            readonly property var transitionRows: [
                { "title": qsTr("Connected network"), "detail": qsTr("Stable displacement") },
                { "title": qsTr("Media playback"), "detail": qsTr("Semantic insert transition") },
                { "title": qsTr("Background job"), "detail": qsTr("Reduced motion safe") }
            ]

            MeoListView {
                anchors.fill: parent
                clip: true
                model: listViewRoot.transitionRows
                spacing: MeoTheme.space4
                delegate: MeoListItem {
                    required property int index
                    readonly property int lastIndex: 2
                    required property string title
                    required property string detail
                    width: ListView.view.width
                    headline: title
                    supportingText: detail
                    leadingIcon: index === 0 ? "wifi" : index === 1 ? "music_note" : "download"
                    isSegmented: true
                    roundingStrategy: index === 0 ? "top" : index === lastIndex ? "bottom" : "none"
                }
            }
        }
    }
    Component {
        id: listTransitionsSample
        Flow {
            spacing: MeoTheme.space8
            MeoChip { label: qsTr("Insert") + " " + MeoTheme.motionDurationListInsert + " ms"; selected: true }
            MeoChip { label: qsTr("Remove") + " " + MeoTheme.motionDurationListRemove + " ms" }
            MeoChip { label: qsTr("Stagger") + " " + MeoListTransitions.staggerDelay + " ms × " + MeoListTransitions.staggerCap }
            MeoText {
                width: 360 * MeoTheme.globalScale
                text: MeoTheme.reduceMotion ? qsTr("Reduced motion: transitions are disabled.") : qsTr("Insert, displacement, and reorder share semantic motion.")
                typeRole: "body"
                typeSize: "small"
                wrapMode: Text.WordWrap
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }
    Component {
        id: listHeaderSample
        Row {
            spacing: MeoTheme.space16

            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: qsTr("1. Standard"); horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: qsTr("Recent") }
            }
            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: qsTr("2. Emphasized"); horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: qsTr("Pinned"); type: "emphasized" }
            }
            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: qsTr("3. Compact padding"); horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: qsTr("Today"); leftPadding: 8 * MeoTheme.globalScale; rightPadding: 8 * MeoTheme.globalScale }
            }
            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: qsTr("4. Long text"); horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: qsTr("Very long section title that truncates"); type: "emphasized" }
            }
            Column {
                width: 170 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: qsTr("5. Spacious"); horizontalAlignment: Text.AlignHCenter }
                MeoListHeader { width: parent.width; text: qsTr("Archives"); topPadding: 8 * MeoTheme.globalScale; bottomPadding: 8 * MeoTheme.globalScale }
            }
        }
    }
    Component {
        id: groupedListSample
        Flow {
            width: 760 * MeoTheme.globalScale
            spacing: MeoTheme.space24

            Column {
                width: 360 * MeoTheme.globalScale
                spacing: MeoTheme.space8

                SampleLabel { label: qsTr("Pixel connected surface — 28 / 1 / 2") }

                MeoGroupedList {
                    width: parent.width
                    title: qsTr("Recent files")
                    subtitle: qsTr("One outer silhouette; every row remains independently interactive.")
                    selectedIndex: 1
                    model: [
                        { "label": qsTr("Release notes"), "icon": "article", "trailingText": qsTr("Today") },
                        { "label": qsTr("Component audit"), "icon": "fact_check", "supportingText": qsTr("Updated 10 minutes ago"), "badgeText": "3" },
                        { "label": qsTr("Archived draft"), "icon": "archive", "enabled": false }
                    ]
                }
            }

            Column {
                width: 360 * MeoTheme.globalScale
                spacing: MeoTheme.space8

                SampleLabel { label: qsTr("1dp line separator") }

                MeoGroupedList {
                    width: parent.width
                    title: qsTr("Interaction states")
                    subtitle: qsTr("Hover darkens 8%; press expands from the exact click point.")
                    separatorStyle: "line"
                    dividerInset: 56 * MeoTheme.globalScale
                    showChevron: false
                    model: [
                        { "label": qsTr("Hover or press this row"), "icon": "touch_app" },
                        { "label": qsTr("Keyboard focus"), "icon": "keyboard", "supportingText": qsTr("Tab, then Enter or Space") },
                        { "label": qsTr("Unavailable"), "icon": "block", "enabled": false }
                    ]
                }
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
                SampleLabel { label: qsTr("1. Dot") }
                MeoBadge { isDot: true }
            }
            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: qsTr("2. Single digit") }
                MeoBadge { text: "8" }
            }
            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: qsTr("3. Two digits") }
                MeoBadge { text: "24" }
            }
            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: qsTr("4. Overflow") }
                MeoBadge { text: "120"; maxCount: 99 }
            }
            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: qsTr("5. Attached target") }
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
                SampleLabel { width: parent.width; label: qsTr("1. Circle"); horizontalAlignment: Text.AlignHCenter }
                MeoAvatar { anchors.horizontalCenter: parent.horizontalCenter; initials: "ME"; size: 32; variant: "circle" }
            }
            Column {
                width: 86 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: qsTr("2. Squircle"); horizontalAlignment: Text.AlignHCenter }
                MeoAvatar { anchors.horizontalCenter: parent.horizontalCenter; initials: "UI"; size: 40; variant: "squircle" }
            }
            Column {
                width: 86 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: qsTr("3. Hexagon"); horizontalAlignment: Text.AlignHCenter }
                MeoAvatar { anchors.horizontalCenter: parent.horizontalCenter; initials: "M3"; size: 48; variant: "hexagon" }
            }
            Column {
                width: 104 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: qsTr("4. Icon fallback"); horizontalAlignment: Text.AlignHCenter }
                MeoAvatar { anchors.horizontalCenter: parent.horizontalCenter; size: 40; variant: "circle" }
            }
            Column {
                width: 112 * MeoTheme.globalScale
                spacing: MeoTheme.space6
                SampleLabel { width: parent.width; label: qsTr("5. Large diamond"); horizontalAlignment: Text.AlignHCenter }
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
                SampleLabel { label: qsTr("1. Horizontal · 1dp") }
                MeoDivider { width: parent.width }
                SampleLabel { label: qsTr("2. Horizontal inset · 24dp") }
                MeoDivider { width: parent.width; leftInset: 24 * MeoTheme.globalScale; rightInset: 24 * MeoTheme.globalScale }
                SampleLabel { label: qsTr("3. Horizontal · 2dp") }
                MeoDivider { width: parent.width; thickness: 2 * MeoTheme.globalScale }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("4. Vertical · 1dp") }
                MeoDivider { anchors.horizontalCenter: parent.horizontalCenter; orientation: "vertical"; height: 52 * MeoTheme.globalScale }
            }

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("5. Vertical inset · 3dp") }
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
                SampleLabel { width: parent.width; label: qsTr("1. Text · animated"); horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "text"; width: 180 * MeoTheme.globalScale }
            }
            Column {
                width: 180 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: qsTr("2. Text · static"); horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "text"; width: 140 * MeoTheme.globalScale; active: false }
            }
            Column {
                width: 90 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: qsTr("3. Avatar"); horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "avatar" }
            }
            Column {
                width: 140 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: qsTr("4. Pill"); horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "pill" }
            }
            Column {
                width: 180 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { width: parent.width; label: qsTr("5. Card"); horizontalAlignment: Text.AlignHCenter }
                MeoSkeleton { type: "card"; width: 168 * MeoTheme.globalScale; height: 88 * MeoTheme.globalScale }
            }
        }
    }
    Component {
        id: cardSample
        Grid {
            columns: 3
            spacing: MeoTheme.space24
            SurfaceCard { title: qsTr("Elevated"); cardType: "elevated" }
            SurfaceCard { title: qsTr("Filled"); cardType: "filled" }
            SurfaceCard { title: qsTr("Outlined"); cardType: "outlined" }
            SurfaceCard { title: qsTr("Selected"); cardType: "filled"; selected: true }
            SurfaceCard { title: qsTr("Interactive"); cardType: "elevated"; interactive: true }
            SurfaceCard { title: qsTr("Disabled"); cardType: "filled"; enabledState: false }
        }
    }

    Component {
        id: authenticationSurfaceSample
        Row {
            spacing: MeoTheme.space24

            MeoAuthenticationSurface {
                width: 360 * MeoTheme.globalScale
                title: qsTr("Unlock Meo")
                supportingText: qsTr("Your password stays with the platform authenticator.")
                status: "fingerprint"
                statusText: qsTr("Or scan your fingerprint")
                MeoTextField {
                    Layout.fillWidth: true
                    label: qsTr("Password")
                    isPassword: true
                }
                MeoButton {
                    Layout.fillWidth: true
                    text: qsTr("Unlock")
                    icon.name: "lock_open"
                }
            }

            MeoAuthenticationSurface {
                width: 360 * MeoTheme.globalScale
                title: qsTr("Try again")
                status: "failed"
                errorText: qsTr("Unlocking failed")
                Component.onCompleted: triggerFailure()
                MeoTextField {
                    Layout.fillWidth: true
                    label: qsTr("Password")
                    isPassword: true
                    isError: true
                }
            }
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
                    text: qsTr("Basic dialog")
                    onClicked: basicDialog.open()
                }

                MeoButton {
                    text: qsTr("Dialog with icon")
                    type: "tonal"
                    onClicked: iconDialog.open()
                }

                MeoButton {
                    text: qsTr("Single select")
                    type: "outlined"
                    onClicked: singleSelectDialog.open()
                }

                MeoButton {
                    text: qsTr("Multi select")
                    type: "outlined"
                    onClicked: multiSelectDialog.open()
                }
            }

            MeoDialog {
                id: basicDialog
                title: qsTr("Basic dialog")
                message: qsTr("This dialog asks for a focused decision.")
                confirmText: qsTr("Accept")
                cancelText: qsTr("Cancel")
            }

            MeoDialog {
                id: iconDialog
                icon: "info"
                title: qsTr("Dialog with icon")
                message: qsTr("A hero icon reinforces the message.")
                confirmText: qsTr("Confirm")
                cancelText: qsTr("Dismiss")
            }

            MeoExpressiveDialog {
                id: singleSelectDialog
                title: qsTr("Choose density")
                message: qsTr("Selection dialogs keep choices in one focused surface.")
                confirmText: qsTr("Apply")
                cancelText: qsTr("Cancel")
                content: Component {
                    Column {
                        spacing: MeoTheme.space8
                        MeoRadioButton { label: qsTr("Comfortable"); checked: true }
                        MeoRadioButton { label: qsTr("Compact") }
                        MeoRadioButton { label: qsTr("Expanded") }
                    }
                }
            }

            MeoExpressiveDialog {
                id: multiSelectDialog
                title: qsTr("Visible columns")
                message: qsTr("Use checkboxes when multiple items can stay selected.")
                confirmText: qsTr("Save")
                cancelText: qsTr("Cancel")
                content: Component {
                    Column {
                        spacing: MeoTheme.space8
                        MeoCheckbox { label: qsTr("Name"); checked: true }
                        MeoCheckbox { label: qsTr("Status"); checked: true }
                        MeoCheckbox { label: qsTr("Owner") }
                    }
                }
            }
        }
    }
    Component {
        id: holdToConfirmSample
        Row {
            spacing: MeoTheme.space12

            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Session-ending") }
                MeoHoldToConfirm {
                    confirmationText: qsTr("Hold to sign out")
                    holdingText: qsTr("Keep holding to sign out…")
                    iconName: "logout"
                    tone: "neutral"
                }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Destructive") }
                MeoHoldToConfirm {
                    confirmationText: qsTr("Hold to shut down")
                    holdingText: qsTr("Keep holding to shut down…")
                    iconName: "power_settings_new"
                    tone: "error"
                }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Disabled") }
                MeoHoldToConfirm {
                    confirmationText: qsTr("Hold to restart")
                    iconName: "restart_alt"
                    tone: "primary"
                    enabled: false
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
                text: qsTr("Open full-screen dialog")
                icon.name: "edit"
                onClicked: full.open()
            }

            MeoFullScreenDialog {
                id: full
                title: qsTr("Edit event")
                showDivider: true
                actions: [{ "text": qsTr("Save") }]
                bottomActions: [{ "text": qsTr("Cancel") }, { "text": qsTr("Apply") }]
                content: Component {
                    Column {
                        width: parent ? parent.width : 0
                        spacing: MeoTheme.space16

                        MeoTextField {
                            width: parent.width
                            label: qsTr("Event name")
                            placeholder: qsTr("Design review")
                            type: "outlined"
                        }

                        MeoTextField {
                            width: parent.width
                            label: qsTr("Location")
                            placeholder: qsTr("Studio")
                            type: "outlined"
                            leadingIcon: "place"
                        }

                        MeoDivider { width: parent.width }

                        MeoText {
                            text: qsTr("Schedule")
                            typeRole: "title"
                            typeSize: "small"
                            color: MeoTheme.contentOnSurface
                        }

                        Row {
                            width: parent.width
                            spacing: MeoTheme.space12

                            MeoExposedDropdown {
                                width: (parent.width - MeoTheme.space12) / 2
                                label: qsTr("From")
                                model: ["09:00", "10:00", "11:00"]
                            }

                            MeoExposedDropdown {
                                width: (parent.width - MeoTheme.space12) / 2
                                label: qsTr("To")
                                model: ["10:00", "11:00", "12:00"]
                            }
                        }
                    }
                }
            }
        }
    }
    Component { id: expressiveDialogSample; Column { spacing: MeoTheme.space8; MeoButton { text: qsTr("Open expressive dialog"); onClicked: dialog.open() } MeoExpressiveDialog { id: dialog; title: qsTr("Expressive"); message: qsTr("Custom content and shape."); icon: "auto_awesome" } } }
    Component { id: bottomSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: qsTr("Open bottom sheet"); onClicked: sheet.open() } MeoBottomSheet { id: sheet; content: Component { MeoText { text: qsTr("Bottom sheet content"); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: standardSheetSample; Item { width: 420 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; MeoStandardBottomSheet { anchors.fill: parent; isOpen: true; content: Component { MeoText { text: qsTr("Standard sheet"); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: sideSheetSample; Item { width: 420 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; MeoSideSheet { anchors.right: parent.right; width: 240 * MeoTheme.globalScale; height: parent.height; isOpen: true; content: Component { MeoText { text: qsTr("Details"); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: modalSideSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: qsTr("Open side sheet"); onClicked: sheet.open() } MeoSideSheetModal { id: sheet; content: Component { MeoText { text: qsTr("Modal side sheet"); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: actionSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: qsTr("Open action sheet"); onClicked: sheet.open() } MeoActionSheet { id: sheet; title: qsTr("Share"); model: [{ "label": qsTr("Messages"), "icon": "chat" }, { "label": qsTr("Email"), "icon": "mail" }] } } }
    Component {
        id: bannerSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            MeoBanner { width: parent.width; title: qsTr("Information"); text: qsTr("This banner uses a tonal semantic container."); icon: "info" }
            MeoBanner { width: parent.width; title: qsTr("Network restored"); text: qsTr("Your work is syncing again."); icon: "cloud_done"; tone: "success" }
            MeoBanner { width: parent.width; title: qsTr("Storage almost full"); text: qsTr("Free space before creating a backup."); icon: "error"; tone: "error" }
            MeoBanner { width: parent.width; text: qsTr("This banner includes two actions."); icon: "info"; confirmText: qsTr("Action"); cancelText: qsTr("Dismiss") }
            MeoBanner { width: parent.width; title: qsTr("Title-only alert"); icon: "notifications" }
        }
    }
    Component {
        id: snackbarSample
        Column {
            spacing: MeoTheme.space8

            Flow {
                spacing: MeoTheme.space8

                MeoButton {
                    text: qsTr("Show snackbar")
                    type: "filled"
                    onClicked: {
                        snackbar.message = qsTr("Message sent")
                        snackbar.actionText = ""
                        snackbar.open()
                    }
                }

                MeoButton {
                    text: qsTr("With action")
                    type: "outlined"
                    onClicked: {
                        snackbar.message = qsTr("Photo deleted")
                        snackbar.actionText = qsTr("Undo")
                        snackbar.open()
                    }
                }
            }

            MeoSnackbar {
                id: snackbar
                message: qsTr("Saved")
                actionText: qsTr("Undo")
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
                text: qsTr("Hover target")
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
                text: qsTr("Tooltip on hover")
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
            MeoButton { text: qsTr("Open rich tooltip"); onClicked: tip.open() }
            MeoRichTooltip {
                id: tip
                title: qsTr("Rich tooltip")
                text: qsTr("Useful supporting detail with one focused action.")
                actions: [{ "text": qsTr("Learn more") }]
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
                SampleLabel { label: qsTr("1. Determinate linear") }
                MeoProgressBar { width: parent.width; value: 0.42 }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: qsTr("2. Indeterminate linear") }
                MeoProgressBar { width: parent.width; indeterminate: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: qsTr("3. 8dp linear") }
                MeoProgressBar { width: parent.width; value: 0.62; isThick: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: qsTr("4. Circle · 4dp") }
                MeoProgressBar { type: "circular"; value: 0.62 }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: qsTr("5. Circle · 8dp") }
                MeoProgressBar { type: "circular"; value: 0.62; isThick: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: qsTr("6. Wavy circle · 4dp") }
                MeoProgressBar { type: "circular"; value: 0.62; wavy: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: qsTr("7. Wavy circle · 8dp") }
                MeoProgressBar { type: "circular"; value: 0.62; wavy: true; isThick: true }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: qsTr("8. Linear wave · 10dp bounds") }
                MeoProgressBar { width: parent.width; wavy: true; value: 0.72 }
            }
            Column { width: 260 * MeoTheme.globalScale; spacing: MeoTheme.space8
                SampleLabel { label: qsTr("9. Linear wave · 14dp bounds") }
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
                SampleLabel { label: qsTr("1. Default · indeterminate") }
                MeoLoadingIndicator { running: true }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("2. Contained · indeterminate") }
                MeoLoadingIndicator { variant: "contained"; running: true }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("3. Default · 42%") }
                MeoLoadingIndicator { indeterminate: false; value: 0.42 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("4. Contained · 78%") }
                MeoLoadingIndicator { variant: "contained"; indeterminate: false; value: 0.78 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("5. Paused · stable pose") }
                MeoLoadingIndicator { running: false }
            }
        }
    }
    Component {
        id: loadingFeedbackSample
        Row {
            spacing: MeoTheme.space24

            Column {
                width: 180 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Unknown position · compact") }
                Item {
                    width: parent.width
                    height: 120 * MeoTheme.globalScale
                    MeoLoadingFeedback {
                        anchors.fill: parent
                        active: true
                        delay: 0
                        minimumVisibleDuration: 0
                    }
                }
            }

            Column {
                width: 360 * MeoTheme.globalScale
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Declared positions · detailed skeleton") }
                Item {
                    width: parent.width
                    height: 120 * MeoTheme.globalScale
                    MeoLoadingFeedback {
                        anchors.fill: parent
                        active: true
                        minimumVisibleDuration: 0
                        placeholder: Component {
                            Row {
                                anchors.fill: parent
                                spacing: MeoTheme.space12
                                MeoSkeleton { type: "avatar"; anchors.verticalCenter: parent.verticalCenter }
                                Column {
                                    width: parent.width - 52 * MeoTheme.globalScale
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: MeoTheme.space8
                                    MeoSkeleton { type: "text"; width: parent.width * 0.72 }
                                    MeoSkeleton { type: "text"; width: parent.width }
                                    MeoSkeleton { type: "pill"; width: 112 * MeoTheme.globalScale; height: 28 * MeoTheme.globalScale }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Component {
        id: pullRefreshSample
        Row {
            spacing: MeoTheme.space24

            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Idle (hidden)") }
                MeoPullToRefresh { pullDistance: 0 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Partial pull · 45%") }
                MeoPullToRefresh { pullDistance: 0.45 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Threshold ready") }
                MeoPullToRefresh { pullDistance: 1 }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Refreshing") }
                MeoPullToRefresh { refreshing: true }
            }
            Column {
                spacing: MeoTheme.space8
                SampleLabel { label: qsTr("Disabled") }
                MeoPullToRefresh { pullDistance: 1; pullEnabled: false }
            }
        }
    }
    Component { id: emptyStateSample; MeoEmptyState { width: 420 * MeoTheme.globalScale; icon: "inbox"; title: qsTr("No messages"); description: qsTr("Empty states explain what happened."); actionText: qsTr("Refresh") } }
    Component {
        id: searchBarSample
        Column {
            spacing: MeoTheme.space8
            SampleLabel { label: qsTr("Standard") }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: qsTr("Search components") }
            SampleLabel { label: qsTr("Active query") }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: qsTr("Search components"); active: true; text: "MeoTheme" }
            SampleLabel { label: qsTr("Pixel") }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: qsTr("Search apps"); visualStyle: "pixel" }
            SampleLabel { label: qsTr("Settings") }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: qsTr("Search settings"); visualStyle: "settings" }
            SampleLabel { label: qsTr("Launcher") }
            MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: qsTr("Search device"); visualStyle: "launcher" }
        }
    }
    Component {
        id: dockedSearchSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space16
            SampleLabel { label: qsTr("Contained (recommended)") }
            MeoDockedSearchBar {
                width: parent.width
                text: qsTr("meo")
                placeholder: qsTr("Search components")
                resultsTitle: qsTr("Results")
                isExpanded: true
                suggestions: [{ "label": qsTr("MeoTheme tokens"), "icon": "palette" }, { "label": qsTr("MeoButton usage"), "icon": "smart_button" }]
            }
            SampleLabel { label: qsTr("Divided (legacy compatibility)") }
            MeoDockedSearchBar {
                width: parent.width
                text: qsTr("meo")
                placeholder: qsTr("Search components")
                resultsTitle: qsTr("Results")
                style: "divided"
                isExpanded: true
                suggestions: [{ "label": qsTr("MeoSlider usage"), "icon": "tune" }, { "label": qsTr("MeoToolbar actions"), "icon": "toolbar" }]
            }
        }
    }
    Component {
        id: searchAppBarSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            SampleLabel { label: qsTr("Default") }
            MeoSearchAppBar { width: parent.width; placeholder: qsTr("Searchable page") }
            SampleLabel { label: qsTr("Active input") }
            MeoSearchAppBar { width: parent.width; placeholder: qsTr("Searchable page"); active: true; text: "MeoTheme" }
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
                text: qsTr("meo")
                placeholder: qsTr("Search components")
                resultsTitle: qsTr("Results")
                suggestions: [{ "label": qsTr("MeoTheme tokens"), "icon": "palette" }, { "label": qsTr("MeoButton usage"), "icon": "smart_button" }, { "label": qsTr("MeoSlider usage"), "icon": "tune" }]
                Component.onCompleted: open()
            }
        }
    }
    Component {
        id: searchSuggestionsSample
        Column {
            width: 420 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            SampleLabel { label: qsTr("Query highlight") }
            MeoSearchSuggestions { width: parent.width; highlightText: "meo"; model: [{ "label": qsTr("MeoTheme tokens"), "icon": "palette" }, { "label": qsTr("MeoButton usage"), "icon": "smart_button" }] }
            SampleLabel { label: qsTr("History removal") }
            MeoSearchSuggestions { width: parent.width; model: [{ "label": qsTr("Recent MeoTheme search"), "isHistory": true }] }
            SampleLabel { label: qsTr("Literal query") }
            MeoSearchSuggestions { width: parent.width; highlightText: "["; model: [{ "label": qsTr("Search [components]"), "icon": "search" }] }
        }
    }
    Component { id: searchHeaderSample; MeoSearchHeader { width: 520 * MeoTheme.globalScale; title: qsTr("Library"); placeholder: qsTr("Search"); actions: [Component { MeoIconButton { icon.name: "help" } }] } }
    Component { id: searchFilterSample; MeoSearchFilterBar { width: 520 * MeoTheme.globalScale; placeholder: qsTr("Search issues"); filterModel: control.chipItems; selectedFilterIndices: [0, 2] } }
    Component {
        id: carouselSample
        Column {
            width: 560 * MeoTheme.globalScale
            spacing: MeoTheme.space16

            SampleLabel { label: qsTr("Multi-browse") }
            MeoCarousel {
                width: parent.width
                itemHeight: 140 * MeoTheme.globalScale
                type: "multi-browse"
                model: control.carouselItems
                delegate: Component { CarouselTile {} }
            }

            SampleLabel { label: qsTr("Hero") }
            MeoCarousel {
                width: parent.width
                itemHeight: 170 * MeoTheme.globalScale
                type: "hero"
                model: control.carouselItems
                delegate: Component { CarouselTile { tileType: "hero" } }
            }

            SampleLabel { label: qsTr("Uncontained") }
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

            PageIndicatorColumn { label: qsTr("1. First"); count: 5; currentIndex: 0 }
            PageIndicatorColumn { label: qsTr("2. Middle"); count: 5; currentIndex: 2 }
            PageIndicatorColumn { label: qsTr("3. Last"); count: 5; currentIndex: 4 }
            PageIndicatorColumn { label: qsTr("4. Dense"); count: 8; currentIndex: 5; dotSize: 6 * MeoTheme.globalScale; activeDotWidth: 18 * MeoTheme.globalScale }
            PageIndicatorColumn { label: qsTr("5. Vertical click"); count: 4; currentIndex: 1; orientation: "vertical"; interactive: true }
        }
    }
    Component {
        id: mediaSample
        Grid {
            columns: 2
            columnSpacing: MeoTheme.space16
            rowSpacing: MeoTheme.space16
            width: 704 * MeoTheme.globalScale

            Item {
                width: 224 * MeoTheme.globalScale
                height: 150 * MeoTheme.globalScale
                MeoMediaController {
                    width: 328 * MeoTheme.globalScale
                    presentation: "compact"
                    title: qsTr("Soul Curve")
                    artist: qsTr("MeoUI Sessions")
                    isPlaying: true
                    duration: 180000
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
                    title: qsTr("Paused track")
                    artist: qsTr("MeoUI Sessions")
                    isPlaying: false
                    duration: 206000
                    position: 78000
                    liked: true
                    canRepeat: true
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
                    title: qsTr("Unavailable seek")
                    artist: qsTr("Downloaded episode")
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
                width: 464 * MeoTheme.globalScale
                height: 194 * MeoTheme.globalScale
                MeoMediaController {
                    width: 720 * MeoTheme.globalScale
                    height: 300 * MeoTheme.globalScale
                    presentation: "dashboard"
                    title: qsTr("Desktop now playing")
                    artist: qsTr("MeoUI Sessions")
                    album: qsTr("Expressive shell")
                    sourceName: qsTr("Browser")
                    isPlaying: true
                    duration: 242000
                    position: 93000
                    canSeek: true
                    canShuffle: true
                    canRepeat: true
                    shuffleEnabled: true
                    repeatMode: "all"
                    sourceCount: 3
                    scale: 0.64
                    transformOrigin: Item.TopLeft
                }
            }
            Item {
                width: 224 * MeoTheme.globalScale
                height: 112 * MeoTheme.globalScale
                MeoMediaController {
                    width: 440 * MeoTheme.globalScale
                    presentation: "lockScreen"
                    title: qsTr("Lock screen")
                    artist: qsTr("Ambient System")
                    isPlaying: true
                    duration: 260000
                    position: 118000
                    scale: 0.5
                    transformOrigin: Item.TopLeft
                }
            }
            Item {
                width: 224 * MeoTheme.globalScale
                height: 160 * MeoTheme.globalScale
                MeoMediaController {
                    width: 960 * MeoTheme.globalScale
                    presentation: "fullScreen"
                    title: qsTr("Full-screen player")
                    artist: qsTr("MeoUI Orchestra")
                    isPlaying: true
                    duration: 314000
                    position: 126000
                    canShuffle: true
                    canRepeat: true
                    volume: 0.42
                    scale: 0.23
                    transformOrigin: Item.TopLeft
                }
            }
        }
    }
    Component {
        id: weatherStatusSample
        Row {
            spacing: MeoTheme.space32

            MeoWeatherStatus {
                available: true
                temperatureText: "28 °C"
                condition: qsTr("Partly cloudy")
                location: qsTr("Singapore")
                showLocation: true
                iconName: "weather-partly-cloudy"
            }

            MeoWeatherStatus {
                available: true
                stale: true
                temperatureText: "28 °C"
                condition: qsTr("Weather data is out of date")
            }
        }
    }
    Component {
        id: privacyNotificationSample
        Column {
            width: 440 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            MeoPrivacyNotificationSummary {
                width: parent.width
                privacyLevel: "count"
                notificationCount: 3
            }
            MeoPrivacyNotificationSummary {
                width: parent.width
                privacyLevel: "app-name"
                notificationCount: 2
                applicationName: qsTr("Messages")
            }
            MeoPrivacyNotificationSummary {
                width: parent.width
                privacyLevel: "full-content"
                notificationCount: 1
                applicationName: qsTr("Calendar")
                summary: qsTr("Design review starts in 10 minutes")
                body: qsTr("Meeting room and invite details appear when content previews are enabled.")
            }
        }
    }
    Component {
        id: toolbarSample
        Column {
            width: 704 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            MeoToolbar { width: parent.width; title: qsTr("1. Regular toolbar") }
            MeoToolbar {
                width: parent.width
                title: qsTr("2. Search")
                actions: [Component { MeoIconButton { icon.name: "search"; Accessible.name: qsTr("Search") } }]
            }
            MeoToolbar {
                width: parent.width
                title: qsTr("3. Actions")
                actions: [
                    Component { MeoIconButton { icon.name: "edit"; Accessible.name: qsTr("Edit") } },
                    Component { MeoIconButton { icon.name: "more_vert"; Accessible.name: qsTr("More options") } }
                ]
            }
            MeoToolbar {
                width: parent.width
                title: qsTr("4. Compact toolbar")
                isCompact: true
                actions: [Component { MeoIconButton { icon.name: "close"; Accessible.name: qsTr("Close") } }]
            }
            MeoToolbar {
                width: parent.width
                title: qsTr("5. Long title elides before actions in a narrow region")
                actions: [
                    Component { MeoIconButton { icon.name: "share"; Accessible.name: qsTr("Share") } },
                    Component { MeoIconButton { icon.name: "more_vert"; Accessible.name: qsTr("More options") } }
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
                SampleLabel { label: qsTr("1. Standard selected action") }
                MeoDockedToolbar {
                    width: parent.width
                    actionIcons: ["arrow_back", "arrow_forward", "view_agenda", "more_vert"]
                    selectedActionIndex: 2
                }
            }

            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("2. Standard with primary action") }
                MeoDockedToolbar {
                    width: parent.width
                    actionIcons: ["archive", "delete", "more_vert"]
                    selectedActionIndex: 0
                    primaryAction: Component { MeoButton { text: qsTr("Create"); type: "filled"; icon.name: "add" } }
                }
            }

            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("3. Arbitrary action slot") }
                MeoDockedToolbar {
                    width: parent.width
                    actionIcons: ["format_bold", "format_italic"]
                    actions: [Component { MeoButton { text: qsTr("Back"); type: "text" } }]
                }
            }

            Column {
                width: 344 * MeoTheme.globalScale
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("4. Vibrant") }
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
                SampleLabel { label: qsTr("5. Disabled action") }
                MeoDockedToolbar {
                    width: parent.width
                    actionIcons: [
                        { "icon": "undo", "accessibleName": qsTr("Undo") },
                        { "icon": "redo", "accessibleName": qsTr("Redo"), "enabled": false },
                        { "icon": "more_vert", "accessibleName": qsTr("More") }
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
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: qsTr("1. Icon fallback"); email: "hello@meoarch.dev" }
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: qsTr("2. Initials"); email: "design@meoarch.dev"; avatarInitials: "MD" }
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: qsTr("3. No dropdown"); email: qsTr("local session"); avatarInitials: "LS"; showDropdown: false }
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: qsTr("4. A deliberately long account name that elides"); email: "very-long-address@meoarch.example"; avatarInitials: "LT" }
            MeoAccountHeader { width: 344 * MeoTheme.globalScale; name: qsTr("5. Disabled"); email: qsTr("Interaction unavailable"); avatarInitials: "DS"; enabled: false }
        }
    }
    Component {
        id: settingsAccountCardSample
        Grid {
            columns: 2
            spacing: MeoTheme.space12
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: qsTr("1. Settings account"); subtitle: qsTr("Local session · meo-laptop"); initials: "SH" }
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: qsTr("2. Initials fallback"); subtitle: qsTr("No avatar asset required"); initials: "IF"; avatarColor: MeoTheme.tertiaryContainer; avatarContentColor: MeoTheme.contentOnTertiaryContainer }
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: qsTr("3. Read-only identity"); subtitle: qsTr("No navigation affordance"); initials: "RO"; showChevron: false; interactive: false }
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: qsTr("4. A deliberately long account name that elides"); subtitle: qsTr("A deliberately long local session descriptor that also elides"); initials: "LT" }
            MeoSettingsAccountCard { width: 360 * MeoTheme.globalScale; title: qsTr("5. Disabled account"); subtitle: qsTr("Interaction unavailable"); initials: "DS"; enabled: false }
        }
    }
    Component {
        id: swipeToDismissSample
        Grid {
            columns: 2
            spacing: MeoTheme.space8
            Repeater {
                model: [
                    { "headline": qsTr("1. Archive or delete"), "supporting": qsTr("Both swipe directions"), "left": true, "right": true },
                    { "headline": qsTr("2. Archive only"), "supporting": qsTr("Swipe right only"), "left": true, "right": false },
                    { "headline": qsTr("3. Delete only"), "supporting": qsTr("Swipe left only"), "left": false, "right": true },
                    { "headline": qsTr("4. Long content label that elides"), "supporting": qsTr("Text stays within the row"), "left": true, "right": true },
                    { "headline": qsTr("5. Disabled"), "supporting": qsTr("Swipe unavailable"), "left": true, "right": true, "enabled": false }
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
            MeoChip { label: qsTr("1. Generic"); icon: "bolt" }
            MeoChip { label: qsTr("2. Selected"); selected: true }
            MeoChip { label: qsTr("3. Closable"); closable: true }
            MeoChip { label: qsTr("4. XL"); size: "xl"; selected: true }
            MeoChip { label: qsTr("5. Disabled"); icon: "block"; enabled: false }
        }
    }
    Component {
        id: assistChipSample
        Flow {
            spacing: MeoTheme.space8
            MeoAssistChip { label: qsTr("1. Directions"); icon: "directions" }
            MeoAssistChip { label: qsTr("2. Elevated"); icon: "star"; elevated: true }
            MeoAssistChip { label: qsTr("3. Outlined"); icon: "share"; visualStyle: "outlined" }
            MeoAssistChip { label: qsTr("4. No icon") }
            MeoAssistChip { label: qsTr("5. XL disabled"); icon: "block"; size: "xl"; enabled: false }
        }
    }
    Component {
        id: filterChipSample
        Flow {
            spacing: MeoTheme.space8
            MeoFilterChip { label: qsTr("1. Selected"); selected: true }
            MeoFilterChip { label: qsTr("2. Unselected") }
            MeoFilterChip { label: qsTr("3. Icon"); leadingIcon: "palette" }
            MeoFilterChip { label: qsTr("4. No icon") }
            MeoFilterChip { label: qsTr("5. Disabled"); leadingIcon: "code"; enabled: false }
        }
    }
    Component {
        id: inputChipSample
        Flow {
            spacing: MeoTheme.space8
            MeoInputChip { label: qsTr("1. Avery"); leadingIcon: "person" }
            MeoInputChip { label: qsTr("2. Selected"); leadingIcon: "task_alt"; selected: true }
            MeoInputChip { label: qsTr("3. Icon"); leadingIcon: "attach_file" }
            MeoInputChip { label: qsTr("4. Avatar"); avatarInitials: "AV" }
            MeoInputChip { label: qsTr("5. Disabled"); leadingIcon: "block"; enabled: false }
        }
    }
    Component {
        id: suggestionChipSample
        Flow {
            spacing: MeoTheme.space8
            MeoSuggestionChip { label: qsTr("1. Material") }
            MeoSuggestionChip { label: qsTr("2. Icon"); icon: "auto_awesome" }
            MeoSuggestionChip { label: qsTr("3. Outlined"); icon: "tips_and_updates"; visualStyle: "outlined" }
            MeoSuggestionChip { label: qsTr("4. No icon") }
            MeoSuggestionChip { label: qsTr("5. Disabled"); icon: "block"; enabled: false }
        }
    }
    Component { id: pageLayoutSample; Rectangle { width: 420 * MeoTheme.globalScale; height: 170 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.surfaceContainerLow; Column { anchors.fill: parent; anchors.margins: MeoTheme.space16; spacing: MeoTheme.space8; MeoText { text: qsTr("Page title"); typeRole: "title"; typeSize: "medium"; color: MeoTheme.contentOnSurface } MeoText { text: qsTr("Max width, padding and section spacing."); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap; width: parent.width } } } }
    Component { id: scaffoldSample; Rectangle { width: 420 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.surfaceContainer; MeoText { anchors.centerIn: parent; text: qsTr("Top bar + content + bottom bar + FAB slots"); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component { id: appLayoutSample; Rectangle { width: 420 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.surfaceContainerLow; Row { anchors.fill: parent; Rectangle { width: 90 * MeoTheme.globalScale; height: parent.height; color: MeoTheme.secondaryContainer; radius: MeoTheme.shapeLarge } MeoText { anchors.verticalCenter: parent.verticalCenter; text: qsTr("Drawer / rail / bottom navigation shell"); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; width: 260 * MeoTheme.globalScale; wrapMode: Text.WordWrap } } } }
    Component { id: dashboardSample; MeoDashboardLayout { width: 520 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; columns: 3; model: [{ "title": qsTr("Tokens") }, { "title": qsTr("Controls") }, { "title": qsTr("Patterns") }]; delegate: Component { Rectangle { property var modelData: ({ "title": "" }); radius: MeoTheme.shapeMedium; color: MeoTheme.surfaceContainerLow; MeoText { anchors.centerIn: parent; text: modelData.title; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: feedSample; MeoFeedLayout { width: 420 * MeoTheme.globalScale; height: 190 * MeoTheme.globalScale; model: [{ "title": qsTr("Release note") }, { "title": qsTr("Component update") }]; delegate: Component { MeoListItem { property var modelData: ({ "title": "" }); width: parent.width; headline: modelData.title; leadingIcon: "article" } } } }
    Component {
        id: listDetailSample
        MeoListDetailLayout {
            width: 520 * MeoTheme.globalScale
            height: 190 * MeoTheme.globalScale
            showDetail: true
            listComponent: Component {
                MeoGroupedList {
                    model: [{ "label": qsTr("Inbox") }, { "label": qsTr("Archive") }]
                    selectedIndex: 0
                }
            }
            detailComponent: Component {
                Rectangle {
                    color: MeoTheme.surfaceContainerLow
                    radius: MeoTheme.shapeLarge
                    MeoText {
                        anchors.centerIn: parent
                        text: qsTr("Detail pane")
                        typeRole: "title"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurface
                    }
                }
            }
        }
    }
    Component { id: settingsSample; MeoSettingsLayout { width: 420 * MeoTheme.globalScale; height: 220 * MeoTheme.globalScale; title: qsTr("Settings"); model: [{ "sectionTitle": qsTr("Appearance"), "items": [{ "title": qsTr("Dark theme"), "subtitle": qsTr("Use dark colors"), "icon": "dark_mode", "type": "switch", "checked": true }] }] } }
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
                    spacing: MeoTheme.space8

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
                SampleLabel { label: qsTr("Primary seed") }
                MeoColorField { width: 260 * MeoTheme.globalScale; label: qsTr("Theme seed"); color: MeoTheme.primary; helperText: qsTr("Valid #RRGGBB seed") }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Tonal seed") }
                MeoColorField { width: 260 * MeoTheme.globalScale; label: qsTr("Tonal seed"); color: MeoTheme.tertiary }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Prefilled text") }
                MeoColorField { width: 260 * MeoTheme.globalScale; label: qsTr("Accent"); text: "#FF8800" }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Validation error") }
                MeoColorField {
                    width: 260 * MeoTheme.globalScale
                    label: qsTr("Theme seed")
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
                SampleLabel { label: qsTr("Disabled") }
                MeoColorField { width: 260 * MeoTheme.globalScale; label: qsTr("Locked seed"); color: MeoTheme.secondary; enabled: false }
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
                SampleLabel { label: qsTr("Selected with counter") }
                MeoChipDropdown { width: 320 * MeoTheme.globalScale; label: qsTr("Included platforms"); placeholder: qsTr("Choose platforms"); model: [qsTr("Desktop"), qsTr("Mobile"), qsTr("Web")]; selectedIndices: [0, 2]; showCounter: true }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Empty placeholder") }
                MeoChipDropdown { width: 260 * MeoTheme.globalScale; label: qsTr("Categories"); placeholder: qsTr("Choose categories"); model: [qsTr("Design"), qsTr("Code"), qsTr("Research")] }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Outlined") }
                MeoChipDropdown { width: 260 * MeoTheme.globalScale; type: "outlined"; label: qsTr("Reviewers"); model: ["Avery", "Mika", "Rin"]; selectedIndices: [1] }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Validation error") }
                MeoChipDropdown { width: 260 * MeoTheme.globalScale; label: qsTr("Required tags"); placeholder: qsTr("Choose at least one"); model: [qsTr("Urgent")]; isError: true; errorText: qsTr("Select a tag") }
            }
            Column {
                spacing: MeoTheme.space4
                SampleLabel { label: qsTr("Disabled") }
                MeoChipDropdown { width: 260 * MeoTheme.globalScale; type: "outlined"; label: qsTr("Disabled"); model: [qsTr("Unavailable")]; selectedIndices: [0]; enabled: false }
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
            MeoMonthCalendar { width: 248 * MeoTheme.globalScale; height: 324 * MeoTheme.globalScale; selectedDate: new Date(2026, 0, 1); displayDate: new Date(2026, 0, 1); firstDayOfWeek: Qt.Monday; showWeekNumbers: true }
            MeoMonthCalendar { width: 220 * MeoTheme.globalScale; height: 324 * MeoTheme.globalScale; selectedDate: new Date(2026, 7, 31); displayDate: new Date(2026, 8, 1) }
            MeoMonthCalendar { width: 220 * MeoTheme.globalScale; height: 324 * MeoTheme.globalScale; selectedDate: new Date(2026, 10, 15); displayDate: new Date(2026, 10, 1); interactive: false }
        }
    }

    Component {
        id: steppedSliderSample
        Column {
            width: 360 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            SampleLabel { label: qsTr("1. Labelled value") }
            MeoSteppedSlider { width: parent.width; title: qsTr("Volume"); supportingText: qsTr("Room speaker"); value: 60; stepSize: 10; valueSuffix: "%"; showValueLabel: true }

            SampleLabel { label: qsTr("2. Compact steps") }
            MeoSteppedSlider { width: parent.width; title: qsTr("Brightness"); value: 4; from: 0; to: 5; stepSize: 1; showValueLabel: true }

            SampleLabel { label: qsTr("3. Minimum boundary") }
            MeoSteppedSlider { width: parent.width; title: qsTr("Text size"); value: 0; from: 0; to: 4; stepSize: 1; valueSuffix: "/4"; showValueLabel: true }

            SampleLabel { label: qsTr("4. Maximum boundary") }
            MeoSteppedSlider { width: parent.width; title: qsTr("Playback speed"); value: 2; from: 0.5; to: 2; stepSize: 0.25; valueSuffix: "×"; showValueLabel: true }

            SampleLabel { label: qsTr("5. Disabled") }
            MeoSteppedSlider { width: parent.width; title: qsTr("Contrast"); supportingText: qsTr("Unavailable for this display"); value: 50; stepSize: 10; valueSuffix: "%"; showValueLabel: true; enabled: false }
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
            MeoAppGridItem { title: qsTr("Settings"); iconName: "settings"; selected: true }
            MeoAppGridItem { title: qsTr("Files"); iconName: "folder" }
            MeoAppGridItem { title: qsTr("AI Studio"); iconName: "auto_awesome"; compact: true }
            MeoAppGridItem {
                title: qsTr("Custom")
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
            MeoAppGridItem { title: qsTr("Disabled"); iconName: "lock"; enabled: false }
        }
    }

    Component {
        id: expansionPanelSample
        Column {
            width: 440 * MeoTheme.globalScale
            spacing: MeoTheme.space8
            MeoExpansionPanel {
                width: parent.width
                title: qsTr("Release notes")
                subtitle: qsTr("What changed in this update")
                icon: "article"
                expanded: true
                contentItem: Component {
                    MeoText {
                        width: 408 * MeoTheme.globalScale
                        text: qsTr("Expanded content keeps secondary information available without overwhelming the primary screen.")
                        typeRole: "body"
                        typeSize: "medium"
                        color: MeoTheme.contentOnSurfaceVariant
                        wrapMode: Text.WordWrap
                    }
                }
            }
            MeoExpansionPanel { width: parent.width; title: qsTr("Earlier updates"); icon: "history" }
            MeoExpansionPanel { width: parent.width; title: qsTr("Unavailable section"); subtitle: qsTr("Disabled state"); icon: "block"; enabled: false }
        }
    }

    Component {
        id: settingsRowSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space4
            MeoSettingsRow { width: parent.width; title: qsTr("Wi-Fi"); subtitle: qsTr("Meo Network"); leadingIcon: "wifi"; trailingKind: "navigation"; selected: true }
            MeoSettingsRow { width: parent.width; title: qsTr("Dark theme"); subtitle: qsTr("Use dark colors"); leadingIcon: "dark_mode"; trailingKind: "switch"; checked: true }
            MeoSettingsRow { width: parent.width; title: qsTr("Storage"); leadingIcon: "storage"; trailingKind: "value"; valueText: qsTr("68% used") }
            MeoSettingsRow { width: parent.width; title: qsTr("System update"); leadingIcon: "system_update"; trailingKind: "status"; trailingText: qsTr("Up to date"); statusTone: "primary" }
            MeoSettingsRow { width: parent.width; title: qsTr("Reset settings"); leadingIcon: "restart_alt"; trailingKind: "action"; actionText: qsTr("Reset"); enabled: false }
        }
    }

    Component {
        id: segmentedListSample
        MeoSegmentedList {
            width: 420 * MeoTheme.globalScale
            title: qsTr("Recent components")
            subtitle: qsTr("A custom delegate receives its item data and rounded position.")
            selectedIndex: 1
            model: [
                { "label": qsTr("Buttons"), "icon": "smart_button", "supportingText": qsTr("Action surfaces") },
                { "label": qsTr("Navigation"), "icon": "explore", "supportingText": qsTr("Tabs and rails") },
                { "label": qsTr("Feedback"), "icon": "info", "supportingText": qsTr("Progress and messages"), "enabled": false }
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
            MeoListItem { width: parent.width; headline: qsTr("Selected expressive item"); supportingText: qsTr("Top rounding"); leadingIcon: "auto_awesome"; selected: true; isSegmented: true; roundingStrategy: "top"; vibrant: true }
            MeoListItem { width: parent.width; headline: qsTr("Adjacent item"); supportingText: qsTr("Bottom rounding"); leadingIcon: "palette"; isSegmented: true; roundingStrategy: "bottom" }
        }
    }

    Component {
        id: fallbackSample
        MeoText { text: qsTr("Sample registered in catalog"); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
    }

    Component {
        id: pageHostSample
        MeoPageHost {
            id: samplePageHost
            width: 440 * MeoTheme.globalScale
            height: 180 * MeoTheme.globalScale
            sourceComponent: Component {
                Rectangle {
                    color: MeoTheme.secondaryContainer
                    radius: MeoTheme.shapeLarge
                    MeoText {
                        anchors.centerIn: parent
                        text: qsTr("Hosted page component")
                        typeRole: "title"
                        typeSize: "medium"
                        color: MeoTheme.contentOnSecondaryContainer
                    }
                }
            }
            MeoText {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: MeoTheme.space8
                text: samplePageHost.enterDuration + qsTr("ms in · ") + samplePageHost.exitDuration + qsTr("ms out")
                typeRole: "label"
                typeSize: "small"
                color: MeoTheme.contentOnSecondaryContainer
            }
        }
    }

    Component {
        id: settingsGroupSample
        Column {
            width: 520 * MeoTheme.globalScale
            spacing: MeoTheme.space16

            SampleLabel { label: qsTr("Navigation and supporting text") }
            MeoSettingsGroup {
                width: parent.width
                title: qsTr("Connections")
                model: [
                    { "title": qsTr("Wi-Fi"), "subtitle": qsTr("Meo Network"), "leadingIcon": "wifi", "trailingKind": "navigation", "trailingText": qsTr("Connected") },
                    { "title": qsTr("Bluetooth"), "subtitle": qsTr("Headphones"), "leadingIcon": "bluetooth", "trailingKind": "navigation", "badgeText": "2" },
                    { "title": qsTr("Unavailable"), "leadingIcon": "block", "trailingKind": "none", "enabled": false }
                ]
            }

            SampleLabel { label: qsTr("Embedded current controls") }
            MeoSettingsGroup {
                width: parent.width
                model: [
                    { "title": qsTr("Internet sharing"), "leadingIcon": "wifi", "trailingKind": "switch", "checked": true },
                    { "title": qsTr("Device volume"), "leadingIcon": "volume_up", "trailingKind": "slider", "value": 62, "sliderSize": "m" },
                    { "title": qsTr("Refresh rate"), "leadingIcon": "speed", "trailingKind": "value", "valueText": "165 Hz" }
                ]
            }
        }
    }

    Component {
        id: settingsSidebarSample
        MeoSettingsSidebar {
            width: MeoTheme.settingsSidebarWidth
            height: 640 * MeoTheme.globalScale
            selectedRoute: "category:devices"
            groups: [
                {
                    "title": qsTr("Connections"),
                    "rows": [
                        { "title": qsTr("Network & Internet"), "subtitle": qsTr("Wi-Fi, VPN, and proxy"), "leadingIcon": "wifi", "leadingStyle": "tonal", "route": "category:network" },
                        { "title": qsTr("Connected devices"), "subtitle": qsTr("Bluetooth and input devices"), "leadingIcon": "devices", "leadingStyle": "tonal", "route": "category:devices" }
                    ]
                },
                {
                    "title": qsTr("Personal"),
                    "rows": [
                        { "title": qsTr("Wallpaper & style"), "subtitle": qsTr("Dynamic color, icons, and fonts"), "leadingIcon": "palette", "leadingStyle": "tonal", "route": "category:style" },
                        { "title": qsTr("Apps & notifications"), "subtitle": qsTr("Defaults, permissions, and alerts"), "leadingIcon": "apps", "leadingStyle": "tonal", "route": "category:apps" }
                    ]
                }
            ]
            searchResults: [
                { "title": qsTr("Wi-Fi"), "subtitle": qsTr("Network & Internet"), "leadingIcon": "wifi", "route": "wifi" }
            ]
        }
    }

    Component {
        id: settingsTaskSheetSample
        Column {
            spacing: MeoTheme.space8
            MeoButton { text: qsTr("Open settings task"); onClicked: taskSheet.open() }
            MeoSettingsTaskSheet {
                id: taskSheet
                title: qsTr("Choose display density")
                subtitle: qsTr("This preview changes nothing outside the Showcase.")
                acceptText: qsTr("Apply")
                rejectText: qsTr("Cancel")
                content: Component {
                    MeoSegmentedButtons {
                        width: 300 * MeoTheme.globalScale
                        model: [qsTr("Compact"), qsTr("Default"), qsTr("Comfortable")]
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
                { "title": qsTr("Wi-Fi"), "supportingText": qsTr("Meo Network"), "iconName": "wifi", "active": true, "span": 2 },
                { "title": qsTr("Bluetooth"), "supportingText": qsTr("Headphones"), "iconName": "bluetooth", "active": true, "span": 2 },
                { "title": qsTr("Flashlight"), "iconName": "flashlight_on", "span": 1 },
                { "title": qsTr("Do not disturb"), "iconName": "do_not_disturb_on", "span": 1 }
            ]
            availableTiles: [
                { "title": qsTr("Night light"), "iconName": "nightlight" },
                { "title": qsTr("Airplane mode"), "iconName": "flight" }
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
                    MeoText { anchors.centerIn: parent; text: qsTr("Main pane"); typeRole: "title"; typeSize: "medium"; color: MeoTheme.contentOnSurface }
                }
            }
            supportingPane: Component {
                Rectangle {
                    color: MeoTheme.secondaryContainer
                    radius: MeoTheme.shapeLarge
                    MeoText { anchors.centerIn: parent; text: qsTr("Supporting pane"); typeRole: "label"; typeSize: "large"; color: MeoTheme.contentOnSecondaryContainer }
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
                    { "label": qsTr("Circle → Square"), "from": "Circle", "to": "Square", "progress": 0.50 },
                    { "label": qsTr("Pill → Diamond"), "from": "Pill", "to": "Diamond", "progress": 0.45 },
                    { "label": qsTr("Soft burst → Cookie"), "from": "SoftBurst", "to": "Cookie9Sided", "progress": 0.55 },
                    { "label": qsTr("Triangle → Arrow"), "from": "Triangle", "to": "Arrow", "progress": 0.50 },
                    { "label": qsTr("Heart → Flower"), "from": "Heart", "to": "Flower", "progress": 0.60 }
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
                    MeoListItem { width: parent.width; headline: qsTr("Build complete"); supportingText: qsTr("Showcase is ready to inspect"); leadingIcon: "task_alt" }
                    MeoListItem { width: parent.width; headline: qsTr("No new warnings"); supportingText: qsTr("All checked samples are mapped"); leadingIcon: "info" }
                }
            }
        }
    }

    Component {
        id: statusStripSample
        MeoStatusStrip {
            statusModel: [
                { id: "network", iconName: "wifi", text: "MeoNet", available: true, active: true, accessibleName: qsTr("Connected to MeoNet") },
                { id: "audio", iconName: "volume_up", text: "64%", available: true, active: false, accessibleName: qsTr("Volume 64 percent") },
                { id: "battery", iconName: "battery_full", text: "82%", available: true, active: false, accessibleName: qsTr("Battery 82 percent") },
                { id: "warning", iconName: "priority_high", text: "", available: true, attention: true, accessibleName: qsTr("Attention required") },
                { id: "bluetooth", iconName: "bluetooth", available: false, active: true, accessibleName: qsTr("Bluetooth status is unavailable") }
            ]
        }
    }

    Component {
        id: ambientClockSample
        Row {
            spacing: MeoTheme.space32
            MeoAmbientClock {
                timeText: "14:30"
                dateText: qsTr("Monday, August 21")
            }
            MeoAmbientClock {
                timeText: "14:30:45"
                dateText: qsTr("Monday, August 21")
                showSeconds: true
            }
            MeoAmbientClock {
                timeText: "2:30 PM"
                showDate: false
            }
        }
    }

    Component {
        id: motionSurfaceSample
        MeoMotionSurface {
            width: 320 * MeoTheme.globalScale
            height: 132 * MeoTheme.globalScale
            surfaceStyle: "tonal"
            showOutline: false
            motionProfile: "pixel"
            entranceAxis: "y"
            entranceDistance: MeoMotion.popupOffset(motionProfile) * MeoTheme.globalScale
            animateOnCompleted: true
            MeoText {
                anchors.centerIn: parent
                text: qsTr("Pixel motion surface")
                typeRole: "title"
                typeSize: "medium"
                color: MeoTheme.contentOnTertiaryContainer
            }
        }
    }
    Component {
        id: springValueSample
        Item {
            width: 360 * MeoTheme.globalScale
            height: 120 * MeoTheme.globalScale
            property bool pressed: false
            MeoSpringValue {
                id: sampleSpring
                value: 1
                targetValue: parent.pressed ? 0.9 : 1
                spring: MeoMotion.fastSpatial
            }
            MeoButton {
                anchors.centerIn: parent
                text: parent.pressed ? qsTr("Release") : qsTr("Retarget spring")
                scale: sampleSpring.value
                onPressedChanged: parent.pressed = pressed
            }
        }
    }
    Component {
        id: launchSurfaceSample
        MeoLaunchSurface {
            width: 520 * MeoTheme.globalScale
            height: 300 * MeoTheme.globalScale
            appName: qsTr("Dolphin")
            supportingText: qsTr("Opening your files")
            fallbackIcon: "folder"
        }
    }

    Component {
        id: cachedImageSample
        Row {
            spacing: MeoTheme.space16

            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: qsTr("Constrained thumbnail") }
                MeoCachedImage {
                    width: 112 * MeoTheme.globalScale
                    height: 84 * MeoTheme.globalScale
                    source: "qrc:/qt/qml/MeoUI/assets/icons/meo-ai-f.svg"
                    requestedSourceWidth: 112
                    requestedSourceHeight: 84
                }
            }
            Column {
                spacing: MeoTheme.space6
                SampleLabel { label: qsTr("Inactive decode") }
                MeoCachedImage {
                    width: 112 * MeoTheme.globalScale
                    height: 84 * MeoTheme.globalScale
                    source: "qrc:/qt/qml/MeoUI/assets/icons/meo-ai-f.svg"
                    active: false
                    requestedSourceWidth: 112
                    requestedSourceHeight: 84
                }
                MeoText { text: qsTr("Paused"); typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
            }
        }
    }

    Component {
        id: motionPopupSample
        Column {
            spacing: MeoTheme.space8
            MeoButton { id: motionPopupTrigger; text: qsTr("Open motion popup"); onClicked: popup.openFrom(motionPopupTrigger) }
            MeoMotionPopup {
                id: popup
                width: 300 * MeoTheme.globalScale
                height: 132 * MeoTheme.globalScale
                presentation: MeoMotionPopup.Dialog
                motionProfile: "pixel"
                MeoText {
                    anchors.centerIn: parent
                    width: parent.width - 2 * MeoTheme.space24
                    text: qsTr("The same primitive can become a dialog, menu, or sheet.")
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
                headerTitle: qsTr("MeoUI")
                headerSubtitle: qsTr("Design system")
                avatarInitials: "M"
                title: qsTr("Showcase coverage")
                supportingText: qsTr("Top media")
                interactive: true
                actions: [{ "label": qsTr("Open"), "icon": "open_in_new", "type": "text" }]
            }
            MeoMediaCard {
                width: 224 * MeoTheme.globalScale
                height: 144 * MeoTheme.globalScale
                cardSize: "s"
                type: "outlined"
                mediaSource: parent.poster
                mediaPosition: "left"
                aspectRatio: 0.62
                title: qsTr("Media card")
                supportingText: qsTr("Side media layout")
            }
            MeoMediaCard {
                width: 224 * MeoTheme.globalScale
                height: 250 * MeoTheme.globalScale
                cardSize: "s"
                type: "filled"
                mediaSource: parent.poster
                mediaPosition: "bottom"
                title: qsTr("Selected")
                supportingText: qsTr("Bottom media")
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
                title: qsTr("Elevated")
                supportingText: qsTr("Right media")
                showOverflowButton: true
            }
            MeoMediaCard {
                width: 224 * MeoTheme.globalScale
                height: 144 * MeoTheme.globalScale
                cardSize: "s"
                type: "filled"
                title: qsTr("Disabled")
                supportingText: qsTr("No interaction")
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
            MeoAccountSwitcher { model: [{ "name": qsTr("Single account"), "email": "single@meoarch.dev" }] }
            MeoAccountSwitcher {
                model: [
                    { "name": qsTr("Meo User"), "email": "hello@meoarch.dev" },
                    { "name": qsTr("Design Review"), "email": "design@meoarch.dev" },
                    { "name": qsTr("Preview"), "email": "preview@meoarch.dev" }
                ]
                currentIndex: 0
            }
            MeoAccountSwitcher {
                model: [
                    { "name": qsTr("Meo User"), "email": "hello@meoarch.dev" },
                    { "name": qsTr("Design Review"), "email": "design@meoarch.dev" },
                    { "name": qsTr("Preview"), "email": "preview@meoarch.dev" }
                ]
                currentIndex: 8
            }
            MeoAccountSwitcher {
                model: [{ "name": qsTr("Disabled account"), "email": "unavailable@meoarch.dev" }]
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
