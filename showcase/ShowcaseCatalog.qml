import QtQuick

QtObject {
    id: catalog

    readonly property var categories: [
        {
            "id": "foundations",
            "label": "Foundations",
            "icon": "palette",
            "subtitle": "Theme tokens, colors, typography, shape, motion, state layers, icons, and font resources.",
            "components": [
                component("MeoTheme", "MeoTheme.qml", "Color roles, type scale, motion, spacing, shape, state, density, and complete dynamic-scheme validation tokens.", qsTr("dynamic, fallback, invalid scheme, colors, typography, motion, shape, scale"), qsTr("Fallback light, Fallback dark, Dynamic light, Dynamic dark, Invalid input"), "colorSchemeMode, dynamicColorSourceId, hasCompleteColorScheme(), applyDynamicColorSchemes(), globalScale, isDarkMode, isExpressive", "Use semantic tokens and a complete platform role table instead of raw colors."),
                component("MeoMotion", "MeoMotion.qml", "AndroidX Material3 standard and expressive spring-token contract with analytic, unit-mass sampling for shared QML motion.", "standard and expressive; default, fast, slow; spatial and effects", "Twelve source-token values, standard selector, expressive selector, sampled settling", "defaultSpatial, fastSpatial, slowSpatial, defaultEffects, fastEffects, slowEffects, stateAt(), isAtRest()", "Use this semantic spring contract for new M3 motion; do not feed its stiffness directly to Qt SpringAnimation."),
                component("MeoWindowMetrics", "MeoWindowMetrics.qml", "Five effective-pixel breakpoints and adaptive page metrics.", "compact, medium, expanded, large, extra-large, navigation mode, columns", "Compact <600, Medium 600–839, Expanded 840–1199, Large 1200–1599, Extra-large ≥1600", "availableWidth, availableHeight, widthSizeClass, pageMargin, preferredColumns", "MeoWindowMetrics { availableWidth: page.width; availableHeight: page.height }"),
                component("MeoText", "components/MeoText.qml", "Semantic text wrapper for display, title, body, and label roles.", "title, body, label, emphasized, fallback fonts", "Role variants, sizes, emphasized variants, Chinese fallback", "text, typeRole, typeSize, emphasized, color", "MeoText { text: \"Page title\"; typeRole: \"title\"; typeSize: \"big\" }"),
                component("MeoIcon", "components/MeoIcon.qml", "Material Symbols icon renderer with M3 variable-font axes.", "regular, filled, bold weight, positive grade, 48 optical size", "Five visible axis configurations with semantic color and size tokens", "icon, size, color, fill, fillLevel, weight, grade, opticalSize", "MeoIcon { icon: \"favorite\"; fill: true; color: MeoTheme.primary }"),
                component("MeoAiMark", "components/MeoAiMark.qml", "Canonical Meo AI identity mark with a fixed lavender field and white monogram.", "five host treatments: default, primary, tertiary, inverse, compact", "Five configurations with container, mark-color, and corner-radius variations", "containerColor, markColor, cornerRadius", "MeoAiMark { width: 48; height: 48 }"),
                component("MeoStateLayer", "components/MeoStateLayer.qml", "Shared AndroidX Material3 interaction layer: 15ms hover, 45ms focus/drag entrance, and a shape-clipped soft-edge bounded ripple with exact click-point origin, 30% start radius, +10dp target radius, 75ms alpha entrance, 225ms FastOutSlowIn expansion and center convergence, hold persistence, and 150ms linear release fade. Rounded clipping, tint, ripple, and focus ring share one GPU shader pass; the software renderer uses a zero-effect geometry fallback.", "hovered, focused, pressed, dragged, click-point ripple, keyboard-center ripple, reduce motion", "Normal, hovered, focused, held, quick click, released, dragged", "hovered, focused, pressed, dragged, overlayColor, focusColor, rippleFeather, rippleStartRadius, rippleBoundedExtraRadius, rippleOriginMode, rippleActive, rippleOriginX, rippleOriginY, rippleCenterX, rippleCenterY, rippleOpacity, rippleRadius, rippleTargetRadius, radius, renderBackend", "Use inside interactive surfaces instead of hand-built hover fills; pointer activation starts at the exact click point and converges toward the bounded target center, keyboard activation starts centrally, a held ripple stays expanded until release, and Reduce Motion removes the ripple."),
                component("MeoShape", "components/MeoShape.qml", "Expressive shape primitive with the complete 35-shape Material 3 Expressive catalogue for containers, actions, rails, indicators, and avatars.", "35 M3E shapes (at least five), fill, stroke, rotation", "Thirty-five configurations, semantic aliases, filled, stroked, rotated", "type, radius, color, strokeColor, strokeWidth, rotationAngle", "MeoShape { type: \"Soft burst\"; color: MeoTheme.primaryContainer }"),
                component("MeoShapeMorph", "components/MeoShapeMorph.qml", "Shape primitive that interpolates between compatible expressive path topologies without moving its container.", "five morphs: circle-square, pill-diamond, soft-burst-cookie, triangle-arrow, heart-flower", "Five mid-morph configurations with clamped topology and optional spring scale", "fromShape, toShape, morphProgress, rawSpringProgress, color, rotationAngle", "MeoShapeMorph { fromShape: \"SoftBurst\"; toShape: \"Pill\"; morphProgress: 0.5 }")
            ]
        },
        {
            "id": "actions",
            "label": "Actions",
            "icon": "smart_button",
            "subtitle": "Buttons, icon buttons, FABs, grouped actions, split actions, and segmented controls.",
            "components": [
                component("MeoButton", "components/MeoButton.qml", "Primary action button with M3/M3 Expressive types, sizes, toggle colors, loading, and shape morph states.", "five primary types: filled, tonal, outlined, elevated, text; plus icon, disabled, loading", "Five type configurations, normal, disabled, icon, loading, selected, focused, xs/s/m/l/xl", "text, type, size, shape, loading, loadingWithContainer, toggle, selected, selectedIcon, vibrant", "MeoButton { text: \"Save\"; type: \"filled\"; size: \"s\" }"),
                component("MeoIconButton", "components/MeoIconButton.qml", "Icon-only M3 Expressive action with default/toggle color roles, selection shape morphs, badges, width options, and size variants.", "standard, filled, tonal, outlined, default, toggle, badge", "Normal, selected, disabled, badge, narrow/uniform/wide, xs/s/m/l/xl", "icon.name, type, size, widthOption, shape, toggle, selected, selectedIcon, badgeText, badgeDot", "MeoIconButton { icon.name: \"favorite\"; type: \"filled\"; widthOption: \"uniform\" }"),
                component("MeoIconToggleButton", "components/MeoIconToggleButton.qml", "M3 Expressive toggle action sharing Icon Button roles, widths, target sizing, and selection shape morphs.", "standard, filled, tonal, outlined, checked, badge", "Unchecked, checked, disabled, badge, narrow/uniform/wide, xs/s/m/l/xl", "icon.name, type, size, widthOption, shape, checked, checkedIcon, selectedIcon, badgeText, badgeDot", "MeoIconToggleButton { icon.name: \"favorite_border\"; checkedIcon: \"favorite\"; type: \"standard\" }"),
                component("MeoFAB", "components/MeoFAB.qml", "Floating action button for prominent primary actions with M3 Expressive color styles.", "small, regular, medium, large, extended, collapsed", "Small, regular, medium, large, extended, collapsed, primary/secondary/tertiary", "type, colorStyle, collapsed, icon.name, text", "MeoFAB { type: \"medium\"; colorStyle: \"primary\"; icon.name: \"add\" }"),
                component("MeoFABMenu", "components/MeoFABMenu.qml", "Material FAB menu with up to six unified action surfaces and an animated close trigger.", "small, regular, medium, large, primary/secondary/tertiary, opened", "Closed, opened, 56dp action surface, 4dp item gap, RTL", "model, icon, activeIcon, fabType, colorStyle, opened, enableScrim", "Use for two to six related primary actions; do not pair it with an extended FAB."),
                component("MeoSplitButton", "components/MeoSplitButton.qml", "Material split button with independent primary and trailing action surfaces.", "filled, tonal, outlined, elevated; xs/s/m/l/xl", "Normal, trailing selected, disabled, RTL, icon and label", "text, icon, size, type, menuModel", "MeoSplitButton { text: \"Create\"; type: \"filled\"; size: \"s\" }"),
                component("MeoButtonGroup", "components/MeoButtonGroup.qml", "Material standard group with proportional adjacent-button press motion, plus an explicit stable connected mode.", "standard, connected, filled, tonal, outlined, elevated", "Selected shape/width, 15% proportional adjacent press response, connected single or multi-select, selection-required, disabled, RTL", "model, type, variant, size, currentIndex, multiSelect, selectionRequired, selectedIndices, pressExpansionRatio, accessibleName, activateIndex(), baseShape, selectedShape", "MeoButtonGroup { variant: \"standard\"; model: actions }"),
                component("MeoSegmentedButtons", "components/MeoSegmentedButtons.qml", "M3 outlined segmented selection control with 40dp baseline geometry, secondary-container selection, and radio/checkbox semantics.", "single, icons, multi, disabled, compact", "Single, icons, multi-selected, disabled, xs", "model, currentIndex, multiSelect, selectedIndices, size, accessibleName, activateIndex()", "MeoSegmentedButtons { model: [\"List\", \"Grid\"] }")
            ]
        },
        {
            "id": "text-input",
            "label": "Text Input",
            "icon": "edit",
            "subtitle": "Text fields, text areas, dropdowns, date inputs, time inputs, and picker widgets.",
            "components": [
                component("MeoTextField", "components/MeoTextField.qml", "Filled and outlined single-line input with icons, helper text, error, clear, prefix, suffix, and counter.", "filled, outlined, icons, helper, error", "Normal, focused-ready, error, disabled, password-style, counter, xs/s/m/l/xl", "type, size, label, placeholder, helperText, isError, errorText, leadingIcon, trailingIcon, prefixText, suffixText, showCounter", "MeoTextField { label: \"Email\"; type: \"outlined\"; leadingIcon: \"mail\" }"),
                component("MeoColorField", "components/MeoColorField.qml", "Accessible #RRGGBB seed input with a validated dynamic swatch. It selects a seed only; platform code still owns Material/HCT generation.", "primary, tonal, prefilled text, validation error, disabled", "Five configurations, valid/invalid swatch, clear, disabled", "color, label, helperText, text, valid, normalizedText, commit()", "MeoColorField { label: \"Theme seed\"; text: \"#4285f4\" }"),
                component("MeoTextArea", "components/MeoTextArea.qml", "Multiline filled or outlined text input.", "filled, outlined, error, counter, disabled", "Normal, focused-ready, error, counter, RTL", "type, label, placeholder, helperText, isError, errorText, maxLength, showCounter", "MeoTextArea { label: \"Description\"; type: \"outlined\" }"),
                component("MeoExposedDropdown", "components/MeoExposedDropdown.qml", "Text-field based menu selector.", "filled, outlined, error, open menu, disabled", "Selection, keyboard, focus, error, RTL", "label, model, currentIndex, isError, errorText, type, enabled", "MeoExposedDropdown { label: \"Environment\"; model: [\"Dev\", \"Prod\"] }"),
                component("MeoChipDropdown", "components/MeoChipDropdown.qml", "MD3 Expressive multi-select exposed dropdown component with removable chips.", "selected counter, empty placeholder, outlined, validation error, disabled", "Five configurations, add/remove selection, error, disabled", "type, size, label, placeholder, helperText, isError, errorText, model, selectedIndices, showCounter", "MeoChipDropdown { label: \"Categories\"; model: [\"A\", \"B\", \"C\"]; selectedIndices: [0] }"),
                component("MeoDateInput", "components/MeoDateInput.qml", "M3 outlined date text field with strict yyyy-MM-dd or yyyy/MM/dd parsing and optional empty state.", "ISO value, slash format, empty allowed, validation error, clear affordance, disabled", "Six configurations, strict validation, visible invalid input, clear, disabled", "value, format, allowEmpty, hasValue, dateAccepted(date), cleared(), commit()", "MeoDateInput { format: \"yyyy-MM-dd\"; value: new Date(2026, 7, 31) }"),
                component("MeoTimeInput", "components/MeoTimeInput.qml", "Strict 24-hour HH:mm time field with explicit value, visible validation error, and optional empty-state contracts.", "morning, evening, empty allowed, validation error, disabled", "Five configurations, strict validation, visible invalid input, accept, clear, disabled", "value, allowEmpty, hasValue, timeAccepted(time), cleared(), commit()", "MeoTimeInput { value: \"09:30\" }"),
                component("MeoDatePicker", "widgets/MeoDatePicker.qml", "Material 3 docked date picker with an outlined date field and month/year menus.", "current month, leap February, leading date, year boundary, distant month", "Five configurations, date field, month/year selection, navigation, calendar states", "selectedDate, displayDate, interactive, headline, dateSelected(date), accepted(date), rejected()", "MeoDatePicker { selectedDate: new Date() }"),
                component("MeoDateRangePicker", "widgets/MeoDateRangePicker.qml", "Material 3 date-range picker with outlined inputs and month/year menus.", "complete range, same-day, start only, end only, non-interactive", "Five configurations, range bridge, reverse selection, month/year menus, disabled", "startDate, endDate, displayDate, interactive, headline, rangeSelected(start,end), accepted(start,end), rejected()", "Use when a flow needs a date interval."),
                component("MeoMonthCalendar", "components/MeoMonthCalendar.qml", "Keyboard-accessible month calendar primitive for a single selected date.", "August selected, leap day, Monday-first, adjacent selection, non-interactive", "Five configurations, selected/today, adjacent days, keyboard, disabled", "selectedDate, displayDate, focusedDate, interactive, firstDayOfWeek", "MeoMonthCalendar { selectedDate: new Date() }"),
                component("MeoSpinBox", "components/MeoSpinBox.qml", "MeoUI numeric-input primitive with native SpinBox range semantics and named increment actions.", "step 2, minimum, maximum, read-only, disabled", "Five configurations, min/max affordances, editable, disabled", "from, to, value, stepSize, editable, accessibleName, accessibleDescription", "MeoSpinBox { from: 0; to: 100; value: 42; stepSize: 2 }"),
                component("MeoTimePicker", "widgets/MeoTimePicker.qml", "Material 3 dial and input time picker.", "12-hour dial, PM, minute selection, 24-hour dial, input mode", "Five configurations, dial/input mode, AM/PM, 24-hour ring, validated bounds", "hours, minutes, isPM, use24Hour, inputMode, activeUnit", "MeoTimePicker { hours: 10; minutes: 30 }")
            ]
        },
        {
            "id": "selection",
            "label": "Selection",
            "icon": "check_box",
            "subtitle": "Checkboxes, radio buttons, switches, sliders, ranges, and selection groups.",
            "components": [
                component("MeoCheckbox", "components/MeoCheckbox.qml", "M3 checkbox with an 18dp visual indicator, 40dp state layer, 48dp target, and checked or indeterminate states.", "checked, unchecked, indeterminate, error, disabled", "Pointer, keyboard, focus, mixed state, error, RTL", "checked, indeterminate, label, isError, errorText, helperText", "MeoCheckbox { label: \"Receive updates\"; checked: true }"),
                component("MeoRadioButton", "components/MeoRadioButton.qml", "M3 single-choice radio control with a 20dp icon, 40dp state layer, and 48dp target.", "selected, unselected, error, disabled selected, disabled", "Pointer, keyboard, focus, error, RTL", "checked, label, isError, errorText, helperText", "MeoRadioButton { label: \"Option A\"; checked: true }"),
                component("MeoSwitch", "components/MeoSwitch.qml", "M3 switch with a 52x32dp track, 48dp target, 40dp state layer, and optional selected or unselected icons.", "no icons, selected icon, selected and unselected icons, error, disabled", "Pointer, keyboard, focus, pressed-handle growth, error, RTL", "checked, label, icon, uncheckedIcon, showIcon, isExpressive, isError", "MeoSwitch { label: \"Enabled\"; checked: true }"),
                component("MeoSlider", "components/MeoSlider.qml", "M3 Expressive slider matrix: XS/S/M/L/XL rails are 16/24/40/56/96dp, handles are 4x44/44/52/68/108dp, outer corners are 8/8/12/16/28dp, and split inner corners are 2dp. Discrete stops remain visible on split rails; every thumb uses the shared click-point ripple.", "five sizes, inset icon, split-rail discrete stops, value indicator, vertical, centered, range, disabled", "Click-point ripple, hold, drag threshold, keyboard, focus, external value, disabled, RTL, reduced motion", "from, to, value, variant, centerValue, orientation, expressive, trackStyle, insetIcon, endStopEnabled, stops, stepSize, valueLabelEnabled, size, accessibleName, accessibleDescription", "MeoSlider { expressive: true; size: \"m\"; insetIcon: \"volume_up\"; value: 40 }"),
                component("MeoScrollBar", "components/MeoScrollBar.qml", "Dynamic-color scrollbar with static geometry, semantic hover/pressed feedback, and policy-driven auto-hide.", "vertical always on, horizontal always on, vertical auto, horizontal auto, disabled", "Idle, active, hovered, pressed, disabled", "orientation, policy, position, size", "MeoScrollBar { orientation: Qt.Vertical; policy: ScrollBar.AlwaysOn; size: 0.35 }"),
                component("MeoSteppedSlider", "components/MeoSteppedSlider.qml", "MeoUI labelled composition over one M3 slider semantic, with explicit decrease and increase controls.", "labelled, compact, minimum, maximum, disabled", "Pointer, buttons, keyboard, boundaries, disabled", "title, supportingText, from, to, value, stepSize, discrete, showValueLabel", "MeoSteppedSlider { title: \"Volume\"; value: 60; stepSize: 10 }"),
                component("MeoQuickControlSlider", "components/MeoQuickControlSlider.qml", "System quick-control composition over the shared M-size MeoSlider: 40dp track, 4x52dp handle, 12dp outer and 2dp inner corners, and a 24dp inset icon. It owns no private rail or handle implementation.", "low, mid, high, details expanded, disabled", "Pointer, hold, drag, keyboard, tracking, icon action, disclosure, disabled, RTL", "iconName, label, accessibleName, from, to, value, tracking, detailsAvailable, expanded, slider", "MeoQuickControlSlider { iconName: \"light_mode\"; value: 70 }"),
                component("MeoQuickSettingsTile", "components/MeoQuickSettingsTile.qml", "SystemUI-inspired quick-settings tile with dynamic active roles, compact/wide geometry, Circle-to-Cookie4Sided icon morph, long-press details, and edit-ready drag behavior.", "Pixel wide active morph, Pixel wide inactive, Pixel compact active, Pixel compact inactive, edit state", "Pointer, keyboard, long press/details, edit, drag-ready, disabled, reduced motion", "title, supportingText, iconName, active, wide, visualStyle, inactiveIconShape, activeIconShape, iconShapeMorphEnabled, detailsEnabled, detailsOnLongPress, editMode, editSelected", "MeoQuickSettingsTile { title: \"Wi-Fi\"; iconName: \"wifi\"; active: true; wide: true; visualStyle: \"pixel\"; activeIconShape: \"Cookie4Sided\" }"),
                component("MeoRangeSlider", "components/MeoRangeSlider.qml", "M3 two-thumb range slider using the shared expressive geometry, visible split-rail stops, click-point thumb ripple, and a real drag threshold.", "standard range, expressive split, split-rail discrete stops, narrow range, disabled", "Click-point ripple, drag threshold, keyboard, focus, disabled, RTL, reduced motion", "from, to, firstValue, secondValue, discrete, stepSize, expressive, trackStyle, size, valueLabelEnabled", "MeoRangeSlider { firstValue: 20; secondValue: 80 }"),
                component("MeoRatingBar", "components/MeoRatingBar.qml", "MeoUI star-rating input with optional half-star selection, keyboard bounds, and a read-only presentation.", "empty small, partial, full large, read-only, disabled", "Pointer, keyboard, half-star selection, read-only, disabled", "maxRating, rating, readOnly, allowHalfRating, clearOnReselect, size, activeColor, inactiveColor", "MeoRatingBar { rating: 3.5; size: \"m\" }"),
                component("MeoSelectionGroup", "components/MeoSelectionGroup.qml", "MeoUI checkbox/radio list composition that preserves the M3 child-control tokens and radio-group navigation.", "checkbox mixed, checkbox all, radio, supporting text, disabled", "Pointer, keyboard, selected surface, indeterminate, disabled", "model, type, showSelectAll, selectedIndex, activateIndex(), setAllSelected()", "MeoSelectionGroup { type: \"radio\"; model: [{ label: \"System\", checked: true }] }"),
                component("MeoFilterGroup", "components/MeoFilterGroup.qml", "M3 Filter Chip selection group with single/multi selection, ListModel support, and semantic grouping.", "single, multi, icons, required selection, disabled", "Pointer, keyboard, selected, disabled, RTL", "model, currentIndex, selectedIndices, multiSelect, allowEmptySelection, accessibleName, activate()", "MeoFilterGroup { model: [{ label: \"All\" }, { label: \"Open\" }] }"),
                component("MeoStepper", "components/MeoStepper.qml", "MeoUI flow-progress primitive, non-interactive unless explicitly enabled.", "horizontal, vertical, first, completed, interactive, disabled", "Current, completed, upcoming, pointer, keyboard, disabled", "model, currentIndex, orientation, interactive, stepActivated(index)", "MeoStepper { model: [\"Account\", \"Review\"]; currentIndex: 1 }")
            ]
        },
        {
            "id": "navigation",
            "label": "Navigation",
            "icon": "explore",
            "subtitle": "Navigation bars, rails, drawers, tabs, breadcrumbs, app bars, and adaptive suites.",
            "components": [
                component("MeoNavigationBar", "widgets/MeoNavigationBar.qml", "Material 3 bottom navigation with stable pill indicators and semantic selection.", "five configurations: always labels, selected label, icon-only dot badge, numeric badge, disabled destination", "Five configurations, enabled, selected, hovered, focused, pressed, disabled", "model, currentIndex, currentId, labelType, compact", "MeoNavigationBar { model: navItems; currentId: \"home\" }"),
                component("MeoNavigationRail", "widgets/MeoNavigationRail.qml", "M3 Expressive navigation rail: 96dp collapsed or a 220–360dp expanded rail that replaces the default drawer, with an optional hide-when-collapsed layout mode.", "five configurations: collapsed labels, collapsed selected-label, expanded 220dp, expanded menu/FAB, expanded 360dp groups", "Five configurations, collapsed, expanded, selected, hover, focus, press, disabled, badge", "model, currentIndex, currentId, isExpanded, hideWhenCollapsed, expandedWidth, labelType, header, footer", "MeoNavigationRail { model: navItems; isExpanded: true }"),
                component("MeoNavigationRailModal", "widgets/MeoNavigationRailModal.qml", "M3 Expressive leading-edge modal expanded navigation rail with shared scrim, dismissal, and sheet motion.", "modal expanded rail, 220dp, 280dp, 360dp, optional menu/FAB header", "Closed, opened, outside press, escape, destination activation, reduced motion", "model, currentIndex, currentId, expandedWidth, header, footer, labelType, closeOnDestination", "MeoNavigationRailModal { model: navItems; expandedWidth: 280 }"),
                component("MeoNavigationDrawer", "widgets/MeoNavigationDrawer.qml", "Legacy navigation drawer retained only for compatibility; prefer an expanded MeoNavigationRail for new layouts.", "legacy drawer, headers, badges", "Selected, header, badge", "model, currentIndex, title, header, footer", "Use MeoNavigationRail { isExpanded: true } for new work."),
                component("MeoNavigationDrawerModal", "widgets/MeoNavigationDrawerModal.qml", "Compatibility modal-drawer export implemented by the M3 Expressive expanded modal navigation rail.", "220–360dp modal rail, scrim, open-close", "Closed, opened, selected, stable ID", "model, currentIndex, currentId, header, footer, expandedWidth", "Prefer MeoNavigationRailModal for new work; use this only for legacy callers."),
                component("MeoNavigationDrawerItem", "components/MeoNavigationDrawerItem.qml", "Legacy drawer row that stays in sync with M3 dynamic color and motion roles.", "selected badge, unselected, group, supporting text, settings", "Five visible compatibility configurations: selected, unselected, grouped, supporting, settings", "label, icon, badgeText, badgeDot, selected, mode, supportingText, showDivider, visualStyle", "MeoNavigationDrawerItem { label: \"Inbox\"; icon: \"inbox\"; selected: true }"),
                component("MeoAppGridItem", "components/MeoAppGridItem.qml", "Launcher-grid item with a stable touch target, icon slot, label, and selection state.", "regular, selected, compact, custom icon content, disabled", "Five configurations, pointer, keyboard, selected, disabled", "title, iconName, iconContent, selected, compact", "MeoAppGridItem { title: \"Settings\"; iconName: \"settings\" }"),
                component("MeoNavigationSuite", "patterns/MeoNavigationSuite.qml", "Five-class navigation that uses a 96dp collapsed rail at medium widths and an expanded rail by default at wider widths.", "compact, medium, expanded, large, extra-large", "Bottom bar with overflow, compact modal rail, collapsed rail, expanded rail, opt-in legacy drawer", "model, currentIndex, availableWidth, compactNavigationLimit, compactPresentation, preferPersistentDrawer, openOverflow()", "Use compactPresentation: \"drawer\" for Settings-like category indexes; it opens the M3 Expressive modal rail."),
                component("MeoBreadcrumbs", "components/MeoBreadcrumbs.qml", "Hierarchical navigation with a non-interactive current page and link semantics.", "icons, text-only, custom separator, explicit current, disabled link", "Five configurations, pointer, keyboard, current, disabled", "model, separator, currentIndex, clicked(index, data)", "MeoBreadcrumbs { model: [{ label: \"Home\" }, { label: \"Library\" }] }"),
                component("MeoTabs", "components/MeoTabs.qml", "Material primary and secondary tabs with an explicit expressive-pill option.", "primary icons, primary text, secondary, expressive pill, scrollable", "Selected, unselected, pointer, keyboard, disabled, RTL", "model, currentIndex, type, style, isScrollable, activate(), focusTab()", "MeoTabs { model: [\"Overview\", \"Usage\"] }"),
                component("MeoTopAppBar", "widgets/MeoTopAppBar.qml", "Material 3 top app bar with explicit small, center-aligned, medium, large/flexible, and contextual modes.", "small, center, medium, large flexible, contextual", "Five M3 layouts, actions, contextual selection", "type, flexible, scrollProgress, title, navigationIcon, actions, isContextual, selectionCount", "MeoTopAppBar { title: \"Inbox\"; type: \"small\" }"),
                component("MeoBottomAppBar", "widgets/MeoBottomAppBar.qml", "Legacy M3 bottom app bar retained for compatibility. Prefer MeoDockedToolbar for new action surfaces.", "legacy actions, fab slot", "Legacy default, with actions", "navigationIcons, fab", "Prefer MeoDockedToolbar for new work."),
                component("MeoMenu", "components/MeoMenu.qml", "M3 popup menu with compact menu rows, labels, dividers, shortcuts, selection, supporting text, and an operational submenu surface.", "standard, vibrant, checked, separator, label, shortcut, submenu", "Open, pointer, keyboard, focus, selected, disabled, RTL", "model, surfaceStyle, vibrant, itemSpacing, menuPadding, menuHorizontalInset, currentIndex, open(), openAt(), openSubmenu(), submenuRequested", "MeoMenu { model: [{ label: \"Copy\", icon: \"content_copy\", shortcut: \"Ctrl+C\" }] }"),
                component("MeoContextMenu", "components/MeoContextMenu.qml", "Pointer-positioned Pixel/MD3 context menu that shares the standard menu keyboard and submenu contract.", "context target, selection, disabled, submenu, vibrant", "Right-click position, pointer, keyboard, focus, selected, disabled, RTL", "model, openAtPoint(anchor, localX, localY), currentIndex, submenuRequested", "MeoContextMenu { model: [{ label: \"Add widget\", icon: \"widgets\" }] }"),
                component("MeoWidget", "components/MeoWidget.qml", "Platform-neutral Meo widget contract with a responsive cell grid, explicit privacy/refresh metadata, adaptive framing, and MD3 tokens.", "1x1, 2x1, 2x2, 4x2, 4x4; framed, adaptive", "dynamic colour, dynamic shape, spacing, typography, reduced motion", "widgetId, preferredSize, supportedSizes, privacy, refreshPolicy, supportedSurfaces, frameMode", "MeoWidget { widgetId: \"weather\"; preferredSize: MeoWidget.SizeMedium }"),
                component("MeoWidgetSheet", "components/MeoWidgetSheet.qml", "ChromeOS-style desktop widget catalogue: a light search rail, safe content-first previews, and an explicit selected-widget action surface. Hosts supply metadata and retain package loading and placement ownership.", "featured, Meo, Plasma compatibility, search, category counts, unavailable item", "Category selection, explicit add, contextual actions, refresh, close, keyboard escape, reduced motion", "catalog, searchText, selectedCategory, selectedWidgetKey, widgetActivated(), widgetContextRequested(), refreshRequested(), closeRequested()", "MeoWidgetSheet { catalog: widgetCatalog; onWidgetActivated: host.addWidget(widget) }")
            ]
        },
        {
            "id": "data-display",
            "label": "Data Display",
            "icon": "table_chart",
            "subtitle": "Tables, lists, headers, grouped rows, badges, avatars, dividers, and skeleton states.",
            "components": [
                component("MeoDataTable", "components/MeoDataTable.qml", "Sortable and selectable data table with one shared surface for header and rows.", "columns, rows, selection, sorting", "Normal, sorted header, selected row, keyboard focus", "columns, model, selectable, sortProperty, sortAscending, toggleRow(), toggleAll()", "MeoDataTable { columns: columns; model: rows; selectable: true }"),
                component("MeoListItem", "components/MeoListItem.qml", "Rich list row with icons, size-controlled custom leading content, supporting text, tonal selection, trailing content, and actions.", "one-line, supporting text, custom leading visual, tonal selected, expressive vibrant, disabled", "Pointer, keyboard, focus, selected, RTL, disabled", "headline, supportingText, leadingIcon, leadingComponent, leadingComponentSize, badgeText, selected, isSegmented, vibrant, trailingComponent", "MeoListItem { headline: \"Inbox\"; supportingText: \"12 unread\" }"),
                component("MeoListView", "components/MeoListView.qml", "ListView base with shared insert, remove, displacement, capped stagger, and reduced-motion-safe transitions.", "vertical lists, insert/remove/reorder, optional saved position", "Normal, insert, remove, displaced, reduced motion", "model, delegate, useMeoTransitions, preserveScrollPosition", "MeoListView { model: devices; delegate: deviceDelegate }"),
                component("MeoListTransitions", "components/MeoListTransitions.qml", "Singleton transition contract used by MeoListView and compatible ListView hosts.", "insert, remove, displaced, move, stagger", "Enabled, reduced motion", "add, remove, displaced, move, staggerDelay", "Use through MeoListView for new lists."),
                component("MeoExpansionPanel", "components/MeoExpansionPanel.qml", "Expandable surface with a stable header, semantic content reveal, and no press-scale distortion.", "expanded, collapsed, icon, subtitle, disabled", "Pointer, keyboard, focus, expanded, disabled, RTL", "title, subtitle, icon, expanded, interactive, contentItem, toggle()", "MeoExpansionPanel { title: \"Release notes\"; expanded: true }"),
                component("MeoSettingsRow", "components/MeoSettingsRow.qml", "Semantic high-density settings row with a 40dp dynamic tonal icon container.", "selected navigation, toggle, value, status, disabled action", "Five configurations, enabled, disabled, selected, semantic trailing controls", "title, subtitle, leadingIcon, leadingTone, trailingKind, trailingText, checked", "MeoSettingsRow { title: \"Wi-Fi\"; leadingIcon: \"wifi\"; trailingKind: \"navigation\" }"),
                component("MeoListHeader", "components/MeoListHeader.qml", "Measured, accessible section label for lists and grouped content.", "standard, emphasized, compact padding, long text, spacious", "Five configurations, text elision, accessible name", "text, type, topPadding, bottomPadding, leftPadding, rightPadding", "MeoListHeader { text: \"Today\"; type: \"emphasized\" }"),
                component("MeoGroupedList", "patterns/MeoGroupedList.qml", "Pixel-style connected rows over the shared MeoSegmentedList surface engine: one 28dp outer silhouette, 1dp inner corners, 2dp background gaps, and the shared click-point state layer.", "connected gap rows, tonal selected, optional line separators, supporting text, badges, disabled", "Rest, 8% hover, 10% click-point press ripple, keyboard focus, selected, disabled, RTL", "title, subtitle, model, selectedIndex, showDividers, separatorStyle, memberGap, dividerInset, showChevron, activate()", "MeoGroupedList { title: \"Recent files\"; model: rows }"),
                component("MeoSegmentedList", "patterns/MeoSegmentedList.qml", "Reusable connected-list container that gives a custom delegate its data and first/middle/last rounding.", "default rows, custom delegate, first, middle, last, disabled", "Pointer, selected, disabled, RTL", "title, subtitle, model, delegate, selectedIndex, isSegmented, itemSpacing, activate()", "MeoSegmentedList { title: \"Recent\"; model: rows; delegate: listItem }"),
                component("MeoStatusCenter", "widgets/MeoStatusCenter.qml", "Combined clock, month calendar, and notification surface for a desktop status center with a host-configurable compact breakpoint.", "wide with calendar, compact notifications, unread count", "Wide, compact, unread", "currentDateTime, unreadCount, compactBreakpoint, notificationsTitle, notificationContent", "MeoStatusCenter { unreadCount: 3; compactBreakpoint: 680 }"),
                component("MeoStatusStrip", "components/MeoStatusStrip.qml", "Backend-agnostic compact system-status row driven by semantic status maps.", "connected, active, tonal active color, attention, text-hidden, unavailable", "Connected, active with host-owned tonal content, attention, text hidden, unavailable", "statusModel, active, activeContentColor, showText, iconSize, textScale", "MeoStatusStrip { active: true; activeContentColor: MeoTheme.contentOnSecondaryContainer; statusModel: [{ id: \"wifi\", iconName: \"wifi\", active: true }] }"),
                component("MeoAmbientClock", "components/MeoAmbientClock.qml", "Backend-agnostic large ambient clock for quiet session-entry and glanceable views.", "24-hour, seconds, date hidden, localized host text, long date", "Five visible clock/date configurations, accessible summary", "dateTime, timeText, dateText, showDate, showSeconds, timeColor, dateColor", "MeoAmbientClock { timeText: \"14:30\"; dateText: \"Monday, August 21\" }"),
                component("MeoBadge", "components/MeoBadge.qml", "Material notification badge with count, overflow, dot, and target-attachment behavior.", "dot, single digit, two digits, 99+ overflow, attached target", "Five configurations, accessible count/dot", "text, maxCount, isDot, target, shape", "MeoBadge { text: \"12\" }"),
                component("MeoAvatar", "components/MeoAvatar.qml", "Image, initials, and icon-fallback avatar with measured expressive shapes.", "circle, squircle, hexagon, icon fallback, large diamond", "Five configurations, image-error fallback, accessible name", "source, initials, size, variant, color, textColor", "MeoAvatar { initials: \"ME\"; variant: \"squircle\" }"),
                component("MeoDivider", "components/MeoDivider.qml", "M3 outline-variant separator with full-target sizing and visible-line insets.", "horizontal 1dp, horizontal inset, horizontal 2dp, vertical, vertical inset 3dp", "Five configurations, accessible separator", "orientation, thickness, inset, leftInset, rightInset, topInset, bottomInset, color", "MeoDivider { leftInset: 24; rightInset: 24 }"),
                component("MeoSkeleton", "components/MeoSkeleton.qml", "Measured loading placeholder with low-GPU breathing by default and an explicit shimmer opt-in.", "breathing text, static text, avatar, pill, card, opt-in shimmer", "Active, inactive, reduced motion, accessible name", "type, active, animate, animationStyle, radius, width, height", "MeoSkeleton { type: \"card\"; animationStyle: \"breathing\" }")
            ]
        },
        {
            "id": "surfaces",
            "label": "Surfaces",
            "icon": "layers",
            "subtitle": "Cards, dialogs, sheets, action sheets, and temporary surfaces.",
            "components": [
                component("MeoCard", "components/MeoCard.qml", "M3 surface card with elevated, filled, outlined, selected, and interactive variants.", "elevated, filled, outlined, selected, interactive", "Elevated, filled, outlined, selected, interactive", "type, level, radius, shape, interactive, selected", "MeoCard { type: \"elevated\"; interactive: true }"),
                component("MeoAuthenticationSurface", "components/MeoAuthenticationSurface.qml", "Credential-free 28dp authentication presentation surface. Platform code supplies real fields and authenticators.", "idle, password, fingerprint, smartcard, submitting, failure", "Active, inactive, status, error, bounded 300ms failure feedback, reduced motion", "active, title, supportingText, status, statusText, errorText, content, triggerFailure()", "MeoAuthenticationSurface { title: \"Unlock\"; status: \"fingerprint\" }"),
                component("MeoCachedImage", "components/MeoCachedImage.qml", "Asynchronous image surface with constrained decode size, Qt in-memory cache, and visibility-driven lifecycle.", "static artwork, thumbnail, inactive, animation opt-in", "Loading, ready, failed, inactive", "source, active, requestedSourceWidth, requestedSourceHeight, allowAnimation", "MeoCachedImage { source: artwork; requestedSourceWidth: 256 }"),
                component("MeoMotionSurface", "components/MeoMotionSurface.qml", "Elevated surface primitive with dynamic color, shape, shadow, reusable entrance motion, and an explicit outline policy.", "outlined default, borderless tonal, elevated, translucent, dynamic color, entrance directions", "Resting, borderless tonal, palette transition, revealed", "type, interactive, bouncy, surfaceStyle, showOutline, color, radius, elevation, reveal()", "MeoMotionSurface { surfaceStyle: \"tonal\"; showOutline: false; animateOnCompleted: true }"),
                component("MeoSpringValue", "components/MeoSpringValue.qml", "Interruptible analytic spring value that preserves velocity when a gesture changes target.", "standard, expressive, retargeted, reduced motion", "Running, settled, retargeted in flight", "value, targetValue, velocity, spring, enabled, running, snapTo()", "MeoSpringValue { value: 1; targetValue: pressed ? 0.92 : 1 }"),
                component("MeoInteractionSpring", "components/MeoInteractionSpring.qml", "Reusable hover, press, and active-state spatial spring controller for buttons, cards, navigation rows, and anchored surfaces.", "rest, hover, pressed, active, disabled, reduced motion", "Resting, lifted hover, compressed press, active/open emphasis, retargeted in flight", "hovered, pressed, active, enabled, motionProfile, scale, offsetX, offsetY, snapToCurrentState()", "MeoInteractionSpring { hovered: pointer.containsMouse; pressed: pointer.pressed }"),
                component("MeoLaunchSurface", "components/MeoLaunchSurface.qml", "Bounded non-interactive launch feedback content for a shell-owned surface, with static cached imagery and low-GPU skeleton motion.", "application icon, fallback icon, static background, loading, reduced motion", "Launching, ready to crossfade, reduced motion", "appName, supportingText, backgroundSource, accentColor, active, iconContent", "MeoLaunchSurface { appName: \"Dolphin\"; fallbackIcon: \"folder\" }"),
                component("MeoDialog", "components/MeoDialog.qml", "M3 basic dialog for one focused decision, with scrim, optional icon/divider/supporting content, semantic text actions, deterministic initial focus, and a distinct dismissal callback.", "basic, icon, supporting content, divider, actions", "Closed, open, keyboard escape, outside press, accept, reject, RTL", "title, message, confirmText, cancelText, icon, supportingContent, showDivider, preferredDialogWidth, initialFocusTarget, confirmed(), cancelled(), dismissed()", "MeoDialog { title: \"Delete item?\"; message: \"This cannot be undone.\" }"),
                component("MeoHoldToConfirm", "components/MeoHoldToConfirm.qml", "Continuous five-second confirmation control for session-ending and destructive actions.", "error, primary, neutral", "idle, holding, confirmed, cancelled, reduced motion", "confirmationText, holdingText, holdDuration, iconName, tone, confirmed(), cancelled()", "MeoHoldToConfirm { confirmationText: \"Hold to shut down\"; tone: \"error\" }"),
                component("MeoFullScreenDialog", "components/MeoFullScreenDialog.qml", "M3 full-screen focused-task dialog with a 56dp header, close affordance, optional divider, and optional 56dp bottom action bar.", "full-screen, header action, bottom actions, content slot", "Closed, open, close, escape, header action, bottom action, RTL", "title, content, actions, bottomActions, showDivider", "Use for focused editing flows."),
                component("MeoExpressiveDialog", "patterns/MeoExpressiveDialog.qml", "Expressive dialog with custom content slot.", "icon, custom content, actions", "Closed, open-ready, content", "title, message, confirmText, cancelText, icon, content", "MeoExpressiveDialog { title: \"Ready\" }"),
                component("MeoBottomSheet", "widgets/MeoBottomSheet.qml", "Modal bottom sheet.", "modal sheet, content slot", "Closed, open-ready", "content", "Use for compact temporary tasks."),
                component("MeoStandardBottomSheet", "widgets/MeoStandardBottomSheet.qml", "Standard bottom sheet surface.", "standard sheet, drag handle, content", "Closed, open-ready", "content", "Use for persistent or standard sheets."),
                component("MeoSideSheet", "widgets/MeoSideSheet.qml", "Side sheet for supplementary content.", "side panel, content", "Closed, open-ready", "content", "Use for details alongside main content."),
                component("MeoSideSheetModal", "widgets/MeoSideSheetModal.qml", "Modal side sheet with scrim.", "modal side panel, content", "Closed, open-ready", "content", "Use when side content blocks the current task."),
                component("MeoActionSheet", "widgets/MeoActionSheet.qml", "Action sheet for contextual choices.", "actions, icons, destructive-ready", "Closed, open-ready", "model, title", "MeoActionSheet { title: \"Share\"; model: actions }"),
                component("MeoMotionPopup", "components/MeoMotionPopup.qml", "Animated Popup base with pre-open measurement, retained exit content, nested transient protection, and optional viewport-aware anchor placement.", "dialog, menu, bottom sheet, side sheet, full screen, anchored transient", "Closed, opening, open, closing, child transient", "presentation, surfaceRadius, surfaceColor, scrimOpacity, openFrom(), contentActive, placement, registerTransientSurface()", "MeoMotionPopup { presentation: MeoMotionPopup.Dialog }")
            ]
        },
        {
            "id": "feedback",
            "label": "Feedback",
            "icon": "info",
            "subtitle": "Banners, snackbars, tooltips, progress, loading, pull refresh, and empty states.",
            "components": [
                component("MeoBanner", "components/MeoBanner.qml", "MeoUI inline alert primitive with semantic message and actions.", "tonal, success, error, action, title", "Tonal, success, error, two actions, title-only", "title, text, icon, tone, confirmText, cancelText", "MeoBanner { text: \"Network restored\"; icon: \"info\" }"),
                component("MeoSnackbar", "components/MeoSnackbar.qml", "M3 inverse-surface message; a supplied action keeps it visible for user response.", "actionless timeout, action persistence, dismissible, icon, long message", "Closed, open with timeout, open with action", "message, actionText, dismissible, duration, icon", "MeoSnackbar { message: \"Saved\" }"),
                component("MeoTooltip", "components/MeoTooltip.qml", "Plain tooltip.", "message, anchor-ready", "Hidden, visible-ready", "text", "MeoTooltip { text: \"Copy\" }"),
                component("MeoRichTooltip", "components/MeoRichTooltip.qml", "M3 rich tooltip with title, supporting text, action and explicit MeoUI media extensions.", "title, text, action, icon extension, image extension", "Hidden, visible with action, visible without action", "title, text, actions, icon, image, shape", "Use for explanatory tooltips."),
                component("MeoProgressBar", "components/MeoProgressBar.qml", "M3 linear and circular progress with 4/8dp active indicators, 4dp tracks, end-stop contrast, and 40dp expressive waves.", "nine configurations (at least five): linear, circular, thick, indeterminate, waveform", "Nine configurations, determinate, indeterminate, track, end stop, thick, expressive", "value, indeterminate, type, isThick, wavy, showTrack, activeColor, trackColor", "MeoProgressBar { value: 0.4; type: \"linear\" }"),
                component("MeoLoadingIndicator", "components/MeoLoadingIndicator.qml", "M3 Expressive morphing loading indicator: a 38dp active shape in one fixed 48dp container.", "default/contained; determinate/indeterminate; paused", "Default, contained, determinate, paused stable pose", "variant, indeterminate, value, running", "MeoLoadingIndicator { variant: \"contained\" }"),
                component("MeoLoadingFeedback", "components/MeoLoadingFeedback.qml", "Latency-safe loading feedback: compact M3E indication for unknown geometry or an immediate detailed skeleton when target positions are declared.", "unknown compact, declared skeleton, anti-flash delay, minimum visibility", "Delayed compact indicator, immediate structured placeholder, reduced motion", "active, placeholder, delay, minimumVisibleDuration, accessibleName, indicatorVariant", "MeoLoadingFeedback { active: requestPending; placeholder: pageSkeleton }"),
                component("MeoPullToRefresh", "components/MeoPullToRefresh.qml", "AndroidX-aligned pull-to-refresh indicator; bind an owning scroll surface to its pull distance and release signal.", "idle, partial pull, threshold, refreshing, disabled", "Idle, partial pull, threshold-ready, refreshing, disabled", "pullDistance, refreshing, pullEnabled, positionalThreshold, refreshRequested(), release()", "MeoPullToRefresh { pullDistance: scrollPullFraction; onRefreshRequested: reload() }"),
                component("MeoEmptyState", "patterns/MeoEmptyState.qml", "Empty state layout with icon, title, description, and action.", "icon, copy, action", "No data, action", "icon, title, description, actionText, customContent", "MeoEmptyState { title: \"No items\"; actionText: \"Create\" }")
            ]
        },
        {
            "id": "search",
            "label": "Search",
            "icon": "search",
            "subtitle": "Search bars, docked search, app bar search, search views, suggestions, and filter headers.",
            "components": [
                component("MeoSearchBar", "widgets/MeoSearchBar.qml", "Standalone stable-pill search entry.", "standard, active query, pixel, settings, launcher", "Standard, active query, Pixel, Settings, Launcher", "text, placeholder, leadingIcon, trailingIcon, active, visualStyle", "MeoSearchBar { placeholder: \"Search components\" }"),
                component("MeoDockedSearchBar", "widgets/MeoDockedSearchBar.qml", "Embedded M3 Expressive docked search results.", "contained, divided", "Collapsed, contained results, divided results", "text, placeholder, style, isExpanded, suggestions, content", "MeoDockedSearchBar { style: \"contained\"; isExpanded: true }"),
                component("MeoSearchAppBar", "widgets/MeoSearchAppBar.qml", "Compact app-bar search affordance; use MeoSearchView for results.", "app bar, compact search", "Default, active input", "text, placeholder, active, actions", "Use at the top of searchable screens; hand results to MeoSearchView."),
                component("MeoSearchView", "widgets/MeoSearchView.qml", "M3 Expressive Search View with a search bar and results container.", "contained, divided, docked, full-screen", "Contained docked, contained full-screen, divided docked, divided full-screen", "placeholder, suggestions, content, resultsTitle, style, layout", "MeoSearchView { style: \"contained\"; layout: \"docked\" }"),
                component("MeoSearchSuggestions", "widgets/MeoSearchSuggestions.qml", "Search result and history list with semantic icons and safe literal highlighting.", "history, icons, highlight", "Query highlight, history removal, literal special-character query", "model, highlightText, selected(index, data), removed(index, data)", "MeoSearchSuggestions { highlightText: \"meo\" }"),
                component("MeoSearchHeader", "patterns/MeoSearchHeader.qml", "Page header with title, search box, and actions.", "title, search, actions", "Default, accepted, action-ready", "title, placeholder, text, leadingIcon, trailingIcon, actions", "MeoSearchHeader { title: \"Library\"; placeholder: \"Search\" }"),
                component("MeoSearchFilterBar", "patterns/MeoSearchFilterBar.qml", "Combined search and filter chip row.", "search, filters, multi-select", "No filters, selected filters", "text, placeholder, filterModel, selectedFilterIndices, multiSelectFilters", "MeoSearchFilterBar { filterModel: filters }")
            ]
        },
        {
            "id": "content-media",
            "label": "Content & Media",
            "icon": "perm_media",
            "subtitle": "Carousel, page indicators, media controller, toolbars, and account headers.",
            "components": [
                component("MeoCarousel", "components/MeoCarousel.qml", "Scrollable carousel with multi-browse, uncontained, hero, and full-screen strategies.", "multi-browse, uncontained, hero, full-screen", "Default, indicator, auto-scroll-ready", "model, delegate, type, itemWidth, itemHeight, showPageIndicator, autoScroll", "MeoCarousel { model: cards; type: \"hero\" }"),
                component("MeoPageIndicator", "components/MeoPageIndicator.qml", "Measured page indicator with clamped selection and optional interactive dots.", "first, middle, last, dense, vertical interactive", "Five configurations, current page, click activation, accessible page name", "count, currentIndex, orientation, interactive, dotSize, activeDotWidth", "MeoPageIndicator { count: 4; currentIndex: 1; interactive: true }"),
                component("MeoMediaCard", "components/MeoMediaCard.qml", "Content card with media placement, header identity, supporting copy, and action model.", "top, left, bottom, right, disabled", "Five configurations, filled, outlined, elevated, selected, disabled", "cardSize, mediaSource, mediaPosition, headerTitle, title, supportingText, actions", "MeoMediaCard { title: \"Release notes\"; mediaPosition: \"top\" }"),
                component("MeoMediaController", "widgets/MeoMediaController.qml", "Media playback control surface with compact, desktop-dashboard, lock-screen, and full-screen presentations.", "compact, control center, dashboard, unavailable seek, lock screen, full screen", "Six configurations, playing, paused, desktop dashboard, multi-player switching, disabled seek, volume", "presentation, title, artist, album, duration, position, volume, canSeek, canShuffle, canRepeat, repeatMode, sourceCount", "MeoMediaController { title: \"Track\"; presentation: \"dashboard\" }"),
                component("MeoWeatherStatus", "components/MeoWeatherStatus.qml", "Quiet, backend-neutral weather projection for session entry; hosts provide only fresh cached data.", "hidden, fresh, stale, city hidden, city shown", "Unavailable, fresh, stale-hidden, accessible summary", "available, stale, temperatureText, condition, location, showLocation", "MeoWeatherStatus { available: cache.available; temperatureText: cache.temperatureText }"),
                component("MeoPrivacyNotificationSummary", "components/MeoPrivacyNotificationSummary.qml", "Read-only notification summary with an explicit privacy level and no notification actions.", "hidden, count, app name, full content", "Four privacy levels, plural count, bounded text", "privacyLevel, notificationCount, applicationName, summary, body", "MeoPrivacyNotificationSummary { privacyLevel: \"count\"; notificationCount: 2 }"),
                component("MeoToolbar", "widgets/MeoToolbar.qml", "General toolbar with semantic intrinsic sizing, title elision, and action slots.", "regular, single action, two actions, compact, long title", "Five configurations, compact height, title elision, accessible toolbar", "title, actions, isCompact", "MeoToolbar { title: \"Tools\"; isCompact: true }"),
                component("MeoDockedToolbar", "components/MeoDockedToolbar.qml", "M3 Expressive 64dp docked action toolbar replacing the bottom app bar for new work.", "standard selected, primary action, arbitrary slot, vibrant, disabled action", "Five configurations, selected, pointer, keyboard, disabled", "actionIcons, actions, primaryAction, colorStyle, isVibrant, selectedActionIndex", "MeoDockedToolbar { actionIcons: [\"search\", \"delete\"]; colorStyle: \"vibrant\" }"),
                component("MeoFloatingToolbar", "components/MeoFloatingToolbar.qml", "M3 Expressive contextual toolbar with horizontal or vertical layout and optional paired FAB.", "floating, horizontal, vertical, standard, vibrant, paired FAB", "Horizontal, vertical, vibrant, selected action, paired FAB", "actionIcons, actions, fab, orientation, colorStyle, selectedActionIndex", "MeoFloatingToolbar { actionIcons: [\"edit\", \"share\"]; fab: addFab }"),
                component("MeoAccountHeader", "widgets/MeoAccountHeader.qml", "Accessible account identity header with shared avatar fallbacks.", "icon fallback, initials, no dropdown, long text, disabled", "Five configurations, pointer, keyboard, dropdown, text elision, disabled", "name, email, avatarSource, avatarInitials, showDropdown, interactive", "MeoAccountHeader { name: \"Meo User\"; avatarInitials: \"MU\" }"),
                component("MeoAccountSwitcher", "widgets/MeoAccountSwitcher.qml", "Expressive account switching widget with normalized model and selection state.", "empty model, single, multi-account, clamped index, disabled", "Five configurations, quick switch, overflow menu, disabled", "model, currentIndex, accountSelected(), addAccountRequested()", "MeoAccountSwitcher { model: accounts; currentIndex: 0 }"),
                component("MeoSettingsAccountCard", "widgets/MeoSettingsAccountCard.qml", "Settings identity card with an accessible 92 dp tonal surface and 48 dp avatar.", "default, initials, read-only, text elision, disabled", "Five configurations, pointer and keyboard activation, read-only and disabled", "title, subtitle, avatarSource, initials, showChevron, interactive", "MeoSettingsAccountCard { title: \"Meo User\"; subtitle: \"Local session\" }"),
                component("MeoSwipeToDismiss", "components/MeoSwipeToDismiss.qml", "AndroidX-style swipeable row with a fixed 56dp default positional threshold, logical-direction actions, and restoration.", "both directions, archive only, delete only, long label, disabled", "Five configurations, idle, direction-limited swipe, dismissed and restored", "content, startToEndAction, endToStartAction, leftAction, rightAction, positionalThreshold, swipeThreshold, gesturesEnabled, dismissed, dismissedInDirection(), restore()", "MeoSwipeToDismiss { content: listRow; startToEndAction: archiveAction; endToStartAction: deleteAction }")
            ]
        },
        {
            "id": "chips",
            "label": "Chips",
            "icon": "label",
            "subtitle": "Assist, filter, input, suggestion, generic, action, selected, avatar, icon, and closable chips.",
            "components": [
                component("MeoChip", "components/MeoChip.qml", "M3 32dp rounded chip with selection, a 48dp close target, and explicit expressive extensions.", "generic, selected, closable, XL, disabled", "Five configurations, keyboard activation, close action, disabled", "type, label, icon, size, selected, closable, selectedContainerColor, contentColor", "MeoChip { label: \"Closable\"; icon: \"bolt\"; closable: true }"),
                component("MeoAssistChip", "components/MeoAssistChip.qml", "Assist chip with the M3 32dp baseline and optional expressive surface/size extensions.", "standard, elevated, outlined, no icon, XL disabled", "Five configurations, keyboard activation, disabled", "label, icon, size, avatarSource, avatarInitials, elevated, visualStyle, shape", "MeoAssistChip { label: \"Directions\"; icon: \"directions\" }"),
                component("MeoFilterChip", "components/MeoFilterChip.qml", "Selectable filter chip with M3 selected/unselected roles and optional avatar fallback.", "selected, unselected, icon, no icon, disabled", "Five configurations, keyboard selection, disabled", "label, leadingIcon, size, selected, avatarSource, avatarInitials, shape", "MeoFilterChip { label: \"Design\"; selected: true }"),
                component("MeoInputChip", "components/MeoInputChip.qml", "Input chip for entered entities with removable action and image-or-initials avatars.", "normal, selected, icon, initials avatar, disabled", "Five configurations, close action, disabled", "label, leadingIcon, avatarSource, avatarInitials, selected, shape", "MeoInputChip { label: \"Avery\"; avatarInitials: \"AV\" }"),
                component("MeoSuggestionChip", "components/MeoSuggestionChip.qml", "Suggestion chip for lightweight prompts with M3 32dp rounded baseline.", "standard, icon, outlined, no icon, disabled", "Five configurations, keyboard activation, disabled", "label, icon, size, visualStyle, shape", "MeoSuggestionChip { label: \"Material\" }")
            ]
        },
        {
            "id": "layouts",
            "label": "Layouts",
            "icon": "dashboard_customize",
            "subtitle": "Page, scaffold, app, dashboard, feed, list-detail, and settings layouts.",
            "components": [
                component("MeoPageLayout", "patterns/MeoPageLayout.qml", "Standard page shell with title, subtitle, actions, max width, and spacing.", "compact, medium, expanded, large, extra-large", "Five window classes, wrapping actions", "title, subtitle, topBar, actions, metricsOverride, compactWidth, mediumWidth, expandedWidth", "Use as the default page container."),
                component("MeoScaffold", "patterns/MeoScaffold.qml", "Composable app scaffold with top, bottom, navigation, sheet, fab, content, and snackbar slots.", "slots, adaptive, side sheet", "Compact, medium, expanded, side sheet", "topBar, bottomBar, navigationBar, navigationRail, navigationDrawer, sideSheet, fab, content, snackbar", "Use for app screens with multiple layout slots."),
                component("MeoAppLayout", "patterns/MeoAppLayout.qml", "Application shell that adapts between drawer, rail, and bottom navigation.", "compact, rail, drawer", "Compact bottom nav, medium rail, expanded drawer", "navigationModel, pages, currentIndex, compactNavigationLimit, accountHeader, fab", "MeoAppLayout { navigationModel: pages }"),
                component("MeoDashboardLayout", "patterns/MeoDashboardLayout.qml", "Responsive dashboard grid.", "columns, cards, responsive", "Compact, medium, expanded columns", "model, delegate, padding, spacing, columns", "Use for metric dashboards."),
                component("MeoFeedLayout", "patterns/MeoFeedLayout.qml", "Responsive feed/list layout.", "single column, adaptive spacing", "Compact feed, expanded feed", "model, delegate, padding, spacing", "Use for repeatable content feeds."),
                component("MeoListDetailLayout", "patterns/MeoListDetailLayout.qml", "Master-detail layout that adapts by breakpoint.", "list, detail, split", "Compact list/detail, expanded split", "listComponent, detailComponent, showDetail", "Use for inbox/detail or settings/detail flows."),
                component("MeoPageHost", "components/MeoPageHost.qml", "Animated asynchronous page host that retains the previous frame, coalesces rapid navigation without snapping an active handoff, and exposes compact or position-declared loading feedback without delaying ready content.", "component source, URL source, forward, backward, rapid latest-wins navigation, compact loading, declared skeleton, reduce motion", "Initial page, loading, transitioning, queued replacement, settled route", "source, sourceComponent, sourceProperties, pageKey, currentPageKey, readyPageKey, direction, transitionDirection, asynchronous, loadingPlaceholder, loadingDelay, loadingMinimumVisibleDuration, loading, enterDuration, exitDuration, showComponent()", "MeoPageHost { sourceComponent: homePage; loadingPlaceholder: pageSkeleton }"),
                component("MeoSettingsLayout", "patterns/MeoSettingsLayout.qml", "Legacy basic settings page layout.", "sections, settings rows", "Default settings", "title, model, padding", "Prefer MeoSettingsGroup and semantic MeoSettingsRow for new Settings work."),
                component("MeoSettingsGroup", "patterns/MeoSettingsGroup.qml", "Semantic Settings adapter over the same connected-list engine as MeoGroupedList, with 28dp outer corners, 1dp member corners, 2dp page-colored gaps, and shared row feedback.", "navigation, supporting text, badge, switch, value, grouped M slider", "Rest, 8% hover, 10% press ripple, keyboard focus, embedded control, disabled", "title, subtitle, model, separatorStyle, memberGap, rowActivated, rowToggled, rowSliderMoved", "MeoSettingsGroup { title: \"Connections\"; model: rows }"),
                component("MeoSettingsSidebar", "patterns/MeoSettingsSidebar.qml", "Search-first desktop Settings index built from grouped MeoSettingsRow destinations with a persistent selected route.", "grouped routes, selected category, search results, empty search, scrolling", "Rest, hover, click-point ripple, keyboard focus, selected route", "title, searchText, searchPlaceholder, groups, searchResults, selectedRoute, footer, routeActivated", "MeoSettingsSidebar { groups: settingsGroups; selectedRoute: \"category:network\" }"),
                component("MeoSettingsTaskSheet", "patterns/MeoSettingsTaskSheet.qml", "Transient third-level settings sheet that retracts on accept, reject, or navigation.", "detail, choice, confirmation", "Closed, opened, accepted, rejected", "title, subtitle, content, acceptText, rejectText, dismissible, navigate()", "Use only for short non-route settings tasks; set dismissible false when a backend is waiting for an explicit security response."),
                component("MeoQuickSettingsEditor", "patterns/MeoQuickSettingsEditor.qml", "Touch-first editor for selecting, resizing, and reordering quick-settings tiles.", "four-column tile grid, selected tile, available tiles", "Editing, selected, wide tile, compact tile", "tiles, availableTiles, columns, selectedIndex, tileMoved, tileResizeRequested", "MeoQuickSettingsEditor { tiles: quickSettingTiles }"),
                component("MeoSupportingPaneLayout", "patterns/MeoSupportingPaneLayout.qml", "Adaptive two-pane layout that stacks its supporting pane on compact widths.", "adaptive, stacked, side-by-side", "Main only, supporting pane visible, compact stack", "mainPane, supportingPane, showSupportingPane, adaptiveMode", "MeoSupportingPaneLayout { showSupportingPane: true }")
            ]
        }
    ]

    // Keep the dynamically supplied catalog copy discoverable by lupdate. The
    // component() helper translates its string arguments at runtime, but Qt's
    // extractor only sees literal qsTr() calls. This marker function is never
    // evaluated by the UI; it preserves the reviewed catalog entries in the
    // generated .qm without turning API fields or code snippets into prose.
    function catalogTranslationMarkers() {
        return [
            qsTr("Color roles, type scale, motion, spacing, shape, state, density, and complete dynamic-scheme validation tokens."),
            qsTr("AndroidX Material3 standard and expressive spring-token contract with analytic, unit-mass sampling for shared QML motion."),
            qsTr("Five effective-pixel breakpoints and adaptive page metrics."),
            qsTr("Semantic text wrapper for display, title, body, and label roles."),
            qsTr("Material Symbols icon renderer with M3 variable-font axes."),
            qsTr("Canonical Meo AI identity mark with a fixed lavender field and white monogram."),
            qsTr("Shared AndroidX Material3 interaction layer: 15ms hover, 45ms focus/drag entrance, and a shape-clipped soft-edge bounded ripple with exact click-point origin, 30% start radius, +10dp target radius, 75ms alpha entrance, 225ms FastOutSlowIn expansion and center convergence, hold persistence, and 150ms linear release fade. Rounded clipping, tint, ripple, and focus ring share one GPU shader pass; the software renderer uses a zero-effect geometry fallback."),
            qsTr("Expressive shape primitive with the complete 35-shape Material 3 Expressive catalogue for containers, actions, rails, indicators, and avatars."),
            qsTr("Shape primitive that interpolates between compatible expressive path topologies without moving its container."),
            qsTr("Primary action button with M3/M3 Expressive types, sizes, toggle colors, loading, and shape morph states."),
            qsTr("Icon-only M3 Expressive action with default/toggle color roles, selection shape morphs, badges, width options, and size variants."),
            qsTr("M3 Expressive toggle action sharing Icon Button roles, widths, target sizing, and selection shape morphs."),
            qsTr("Floating action button for prominent primary actions with M3 Expressive color styles."),
            qsTr("Material FAB menu with up to six unified action surfaces and an animated close trigger."),
            qsTr("Material split button with independent primary and trailing action surfaces."),
            qsTr("Material standard group with proportional adjacent-button press motion, plus an explicit stable connected mode."),
            qsTr("M3 outlined segmented selection control with 40dp baseline geometry, secondary-container selection, and radio/checkbox semantics."),
            qsTr("Filled and outlined single-line input with icons, helper text, error, clear, prefix, suffix, and counter."),
            qsTr("Accessible #RRGGBB seed input with a validated dynamic swatch. It selects a seed only; platform code still owns Material/HCT generation."),
            qsTr("Multiline filled or outlined text input."),
            qsTr("Text-field based menu selector."),
            qsTr("MD3 Expressive multi-select exposed dropdown component with removable chips."),
            qsTr("M3 outlined date text field with strict yyyy-MM-dd or yyyy/MM/dd parsing and optional empty state."),
            qsTr("Strict 24-hour HH:mm time field with explicit value, visible validation error, and optional empty-state contracts."),
            qsTr("Material 3 docked date picker with an outlined date field and month/year menus."),
            qsTr("Material 3 date-range picker with outlined inputs and month/year menus."),
            qsTr("Keyboard-accessible month calendar primitive for a single selected date."),
            qsTr("MeoUI numeric-input primitive with native SpinBox range semantics and named increment actions."),
            qsTr("Material 3 dial and input time picker."),
            qsTr("M3 checkbox with an 18dp visual indicator, 40dp state layer, 48dp target, and checked or indeterminate states."),
            qsTr("M3 single-choice radio control with a 20dp icon, 40dp state layer, and 48dp target."),
            qsTr("M3 switch with a 52x32dp track, 48dp target, 40dp state layer, and optional selected or unselected icons."),
            qsTr("M3 Expressive slider matrix: XS/S/M/L/XL rails are 16/24/40/56/96dp, handles are 4x44/44/52/68/108dp, outer corners are 8/8/12/16/28dp, and split inner corners are 2dp. Discrete stops remain visible on split rails; every thumb uses the shared click-point ripple."),
            qsTr("Dynamic-color scrollbar with static geometry, semantic hover/pressed feedback, and policy-driven auto-hide."),
            qsTr("MeoUI labelled composition over one M3 slider semantic, with explicit decrease and increase controls."),
            qsTr("System quick-control composition over the shared M-size MeoSlider: 40dp track, 4x52dp handle, 12dp outer and 2dp inner corners, and a 24dp inset icon. It owns no private rail or handle implementation."),
            qsTr("SystemUI-inspired quick-settings tile with dynamic active roles, compact/wide geometry, Circle-to-Cookie4Sided icon morph, long-press details, and edit-ready drag behavior."),
            qsTr("M3 two-thumb range slider using the shared expressive geometry, visible split-rail stops, click-point thumb ripple, and a real drag threshold."),
            qsTr("MeoUI star-rating input with optional half-star selection, keyboard bounds, and a read-only presentation."),
            qsTr("MeoUI checkbox/radio list composition that preserves the M3 child-control tokens and radio-group navigation."),
            qsTr("M3 Filter Chip selection group with single/multi selection, ListModel support, and semantic grouping."),
            qsTr("MeoUI flow-progress primitive, non-interactive unless explicitly enabled."),
            qsTr("Material 3 bottom navigation with stable pill indicators and semantic selection."),
            qsTr("M3 Expressive navigation rail: 96dp collapsed or a 220–360dp expanded rail that replaces the default drawer, with an optional hide-when-collapsed layout mode."),
            qsTr("M3 Expressive leading-edge modal expanded navigation rail with shared scrim, dismissal, and sheet motion."),
            qsTr("Legacy navigation drawer retained only for compatibility; prefer an expanded MeoNavigationRail for new layouts."),
            qsTr("Compatibility modal-drawer export implemented by the M3 Expressive expanded modal navigation rail."),
            qsTr("Legacy drawer row that stays in sync with M3 dynamic color and motion roles."),
            qsTr("Launcher-grid item with a stable touch target, icon slot, label, and selection state."),
            qsTr("Five-class navigation that uses a 96dp collapsed rail at medium widths and an expanded rail by default at wider widths."),
            qsTr("Hierarchical navigation with a non-interactive current page and link semantics."),
            qsTr("Material primary and secondary tabs with an explicit expressive-pill option."),
            qsTr("Material 3 top app bar with explicit small, center-aligned, medium, large/flexible, and contextual modes."),
            qsTr("Legacy M3 bottom app bar retained for compatibility. Prefer MeoDockedToolbar for new action surfaces."),
            qsTr("M3 popup menu with compact menu rows, labels, dividers, shortcuts, selection, supporting text, and an operational submenu surface."),
            qsTr("Pointer-positioned Pixel/MD3 context menu that shares the standard menu keyboard and submenu contract."),
            qsTr("Platform-neutral Meo widget contract with a responsive cell grid, explicit privacy/refresh metadata, adaptive framing, and MD3 tokens."),
            qsTr("ChromeOS-style desktop widget catalogue: a light search rail, safe content-first previews, and an explicit selected-widget action surface. Hosts supply metadata and retain package loading and placement ownership."),
            qsTr("Sortable and selectable data table with one shared surface for header and rows."),
            qsTr("Rich list row with icons, size-controlled custom leading content, supporting text, tonal selection, trailing content, and actions."),
            qsTr("ListView base with shared insert, remove, displacement, capped stagger, and reduced-motion-safe transitions."),
            qsTr("Singleton transition contract used by MeoListView and compatible ListView hosts."),
            qsTr("Expandable surface with a stable header, semantic content reveal, and no press-scale distortion."),
            qsTr("Semantic high-density settings row with a 40dp dynamic tonal icon container."),
            qsTr("Measured, accessible section label for lists and grouped content."),
            qsTr("Pixel-style connected rows over the shared MeoSegmentedList surface engine: one 28dp outer silhouette, 1dp inner corners, 2dp background gaps, and the shared click-point state layer."),
            qsTr("Reusable connected-list container that gives a custom delegate its data and first/middle/last rounding."),
            qsTr("Combined clock, month calendar, and notification surface for a desktop status center with a host-configurable compact breakpoint."),
            qsTr("Backend-agnostic compact system-status row driven by semantic status maps."),
            qsTr("Backend-agnostic large ambient clock for quiet session-entry and glanceable views."),
            qsTr("Material notification badge with count, overflow, dot, and target-attachment behavior."),
            qsTr("Image, initials, and icon-fallback avatar with measured expressive shapes."),
            qsTr("M3 outline-variant separator with full-target sizing and visible-line insets."),
            qsTr("Measured loading placeholder with low-GPU breathing by default and an explicit shimmer opt-in."),
            qsTr("M3 surface card with elevated, filled, outlined, selected, and interactive variants."),
            qsTr("Credential-free 28dp authentication presentation surface. Platform code supplies real fields and authenticators."),
            qsTr("Asynchronous image surface with constrained decode size, Qt in-memory cache, and visibility-driven lifecycle."),
            qsTr("Elevated surface primitive with dynamic color, shape, shadow, reusable entrance motion, and an explicit outline policy."),
            qsTr("Interruptible analytic spring value that preserves velocity when a gesture changes target."),
            qsTr("Reusable hover, press, and active-state spatial spring controller for buttons, cards, navigation rows, and anchored surfaces."),
            qsTr("Bounded non-interactive launch feedback content for a shell-owned surface, with static cached imagery and low-GPU skeleton motion."),
            qsTr("M3 basic dialog for one focused decision, with scrim, optional icon/divider/supporting content, semantic text actions, deterministic initial focus, and a distinct dismissal callback."),
            qsTr("Continuous five-second confirmation control for session-ending and destructive actions."),
            qsTr("M3 full-screen focused-task dialog with a 56dp header, close affordance, optional divider, and optional 56dp bottom action bar."),
            qsTr("Expressive dialog with custom content slot."),
            qsTr("Modal bottom sheet."),
            qsTr("Standard bottom sheet surface."),
            qsTr("Side sheet for supplementary content."),
            qsTr("Modal side sheet with scrim."),
            qsTr("Action sheet for contextual choices."),
            qsTr("Animated Popup base with pre-open measurement, retained exit content, nested transient protection, and optional viewport-aware anchor placement."),
            qsTr("MeoUI inline alert primitive with semantic message and actions."),
            qsTr("M3 inverse-surface message; a supplied action keeps it visible for user response."),
            qsTr("Plain tooltip."),
            qsTr("M3 rich tooltip with title, supporting text, action and explicit MeoUI media extensions."),
            qsTr("M3 linear and circular progress with 4/8dp active indicators, 4dp tracks, end-stop contrast, and 40dp expressive waves."),
            qsTr("M3 Expressive morphing loading indicator: a 38dp active shape in one fixed 48dp container."),
            qsTr("Latency-safe loading feedback: compact M3E indication for unknown geometry or an immediate detailed skeleton when target positions are declared."),
            qsTr("AndroidX-aligned pull-to-refresh indicator; bind an owning scroll surface to its pull distance and release signal."),
            qsTr("Empty state layout with icon, title, description, and action."),
            qsTr("Standalone stable-pill search entry."),
            qsTr("Embedded M3 Expressive docked search results."),
            qsTr("Compact app-bar search affordance; use MeoSearchView for results."),
            qsTr("M3 Expressive Search View with a search bar and results container."),
            qsTr("Search result and history list with semantic icons and safe literal highlighting."),
            qsTr("Page header with title, search box, and actions."),
            qsTr("Combined search and filter chip row."),
            qsTr("Scrollable carousel with multi-browse, uncontained, hero, and full-screen strategies."),
            qsTr("Measured page indicator with clamped selection and optional interactive dots."),
            qsTr("Content card with media placement, header identity, supporting copy, and action model."),
            qsTr("Media playback control surface."),
            qsTr("Quiet, backend-neutral weather projection for session entry; hosts provide only fresh cached data."),
            qsTr("Read-only notification summary with an explicit privacy level and no notification actions."),
            qsTr("General toolbar with semantic intrinsic sizing, title elision, and action slots."),
            qsTr("M3 Expressive 64dp docked action toolbar replacing the bottom app bar for new work."),
            qsTr("M3 Expressive contextual toolbar with horizontal or vertical layout and optional paired FAB."),
            qsTr("Accessible account identity header with shared avatar fallbacks."),
            qsTr("Expressive account switching widget with normalized model and selection state."),
            qsTr("Settings identity card with an accessible 92 dp tonal surface and 48 dp avatar."),
            qsTr("AndroidX-style swipeable row with a fixed 56dp default positional threshold, logical-direction actions, and restoration."),
            qsTr("M3 32dp rounded chip with selection, a 48dp close target, and explicit expressive extensions."),
            qsTr("Assist chip with the M3 32dp baseline and optional expressive surface/size extensions."),
            qsTr("Selectable filter chip with M3 selected/unselected roles and optional avatar fallback."),
            qsTr("Input chip for entered entities with removable action and image-or-initials avatars."),
            qsTr("Suggestion chip for lightweight prompts with M3 32dp rounded baseline."),
            qsTr("Standard page shell with title, subtitle, actions, max width, and spacing."),
            qsTr("Composable app scaffold with top, bottom, navigation, sheet, fab, content, and snackbar slots."),
            qsTr("Application shell that adapts between drawer, rail, and bottom navigation."),
            qsTr("Responsive dashboard grid."),
            qsTr("Responsive feed/list layout."),
            qsTr("Master-detail layout that adapts by breakpoint."),
            qsTr("Animated asynchronous page host that retains the previous frame, coalesces rapid navigation without snapping an active handoff, and exposes compact or position-declared loading feedback without delaying ready content."),
            qsTr("Legacy basic settings page layout."),
            qsTr("Semantic Settings adapter over the same connected-list engine as MeoGroupedList, with 28dp outer corners, 1dp member corners, 2dp page-colored gaps, and shared row feedback."),
            qsTr("Search-first desktop Settings index built from grouped MeoSettingsRow destinations with a persistent selected route."),
            qsTr("Transient third-level settings sheet that retracts on accept, reject, or navigation."),
            qsTr("Touch-first editor for selecting, resizing, and reordering quick-settings tiles."),
            qsTr("Adaptive two-pane layout that stacks its supporting pane on compact widths."),
            qsTr("Theme tokens, colors, typography, shape, motion, state layers, icons, and font resources."),
            qsTr("Actions"),
            qsTr("Buttons, icon buttons, FABs, grouped actions, split actions, and segmented controls."),
            qsTr("Text Input"),
            qsTr("Text fields, text areas, dropdowns, date inputs, time inputs, and picker widgets."),
            qsTr("Selection"),
            qsTr("Checkboxes, radio buttons, switches, sliders, ranges, and selection groups."),
            qsTr("Navigation"),
            qsTr("Navigation bars, rails, drawers, tabs, breadcrumbs, app bars, and adaptive suites."),
            qsTr("Data Display"),
            qsTr("Tables, lists, headers, grouped rows, badges, avatars, dividers, and skeleton states."),
            qsTr("Surfaces"),
            qsTr("Cards, dialogs, sheets, action sheets, and temporary surfaces."),
            qsTr("Feedback"),
            qsTr("Banners, snackbars, tooltips, progress, loading, pull refresh, and empty states."),
            qsTr("Search"),
            qsTr("Search bars, docked search, app bar search, search views, suggestions, and filter headers."),
            qsTr("Content & Media"),
            qsTr("Carousel, page indicators, media controller, toolbars, and account headers."),
            qsTr("Chips"),
            qsTr("Assist, filter, input, suggestion, generic, action, selected, avatar, icon, and closable chips."),
            qsTr("Layouts"),
            qsTr("Page, scaffold, app, dashboard, feed, list-detail, and settings layouts."),
        ]
    }

    // The navigation hierarchy is intentionally separate from source folders.
    // A public export has exactly one canonical catalog entry in `categories`;
    // a top-level page simply gathers related canonical subcategories.
    readonly property var navigationGroups: [
        {
            "id": "foundations",
            "label": qsTr("Foundations"),
            "icon": "palette",
            "subtitle": qsTr("Theme, environment, identity, shape, motion, and shared interaction primitives."),
            "categoryIds": ["foundations"]
        },
        {
            "id": "controls",
            "label": qsTr("Controls"),
            "icon": "tune",
            "subtitle": qsTr("Standalone actions, fields, selection, ranges, and chips."),
            "categoryIds": ["actions", "text-input", "selection", "chips"]
        },
        {
            "id": "composites",
            "label": qsTr("Composites & Patterns"),
            "icon": "account_tree",
            "subtitle": qsTr("Content collections, overlays, navigation chrome, feedback surfaces, and layouts."),
            "categoryIds": ["navigation", "data-display", "surfaces", "feedback", "content-media", "layouts"]
        },
        {
            "id": "features",
            "label": qsTr("Feature Domains"),
            "icon": "category",
            "subtitle": qsTr("End-to-end UI vocabulary owned by a product domain, starting with Search."),
            "categoryIds": ["search"]
        }
    ]

    function component(name, source, summary, variants, states, api, usage) {
        return {
            "name": qsTr(name),
            "source": source,
            "sourceArea": source.indexOf("/") === -1 ? "root" : source.substring(0, source.indexOf("/")),
            "summary": qsTr(summary),
            "variants": variants,
            "states": states,
            "api": api,
            "usage": usage
        }
    }

    function categoryById(id) {
        for (var i = 0; i < categories.length; ++i) {
            if (categories[i].id === id) {
                return {
                    "id": categories[i].id,
                    "label": qsTr(categories[i].label),
                    "icon": categories[i].icon,
                    "subtitle": qsTr(categories[i].subtitle),
                    "components": categories[i].components
                }
            }
        }
        return {
            "id": categories[0].id,
            "label": qsTr(categories[0].label),
            "icon": categories[0].icon,
            "subtitle": qsTr(categories[0].subtitle),
            "components": categories[0].components
        }
    }

    function navigationGroupById(id) {
        for (var i = 0; i < navigationGroups.length; ++i) {
            if (navigationGroups[i].id === id)
                return navigationGroups[i]
        }
        return navigationGroups[0]
    }
}
