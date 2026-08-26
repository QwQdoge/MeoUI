cmake_minimum_required(VERSION 3.16)
project(MeoUI VERSION 0.3.1 LANGUAGES CXX)
set(CMAKE_AUTOMOC ON)
include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(MEOUI_BUILD_SHOWCASE "Build the MeoUI showcase application" ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2 Gui Qml)

# The token runtime is the single metric/state source for both the QML module
# and native renderers such as Meo QStyle.  It intentionally contains no
# widget painter code or desktop-specific policy.
add_library(meoui_tokens STATIC
    runtime/meotokens.cpp
    runtime/meotokens.h
)
add_library(MeoUI::Tokens ALIAS meoui_tokens)
set_target_properties(meoui_tokens PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_link_libraries(meoui_tokens PUBLIC Qt6::Core Qt6::Gui Qt6::Qml)
target_include_directories(meoui_tokens
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/runtime>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/MeoUI>
)

# Use Qt 6's standard :/qt/qml resource prefix for QML modules.
if(COMMAND qt_policy)
    qt_policy(SET QTP0001 NEW)
    if(QT_KNOWN_POLICY_QTP0004)
        qt_policy(SET QTP0004 NEW)
    endif()
endif()

set_source_files_properties(MeoTheme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

# MeoUI is a separately loadable runtime module.  Applications must import it
# through the QML import path instead of embedding a private static copy.  This
# keeps installer/Desktop UI fixes in one authoritative library.
qt_add_qml_module(meoui_module
    SHARED
    URI "MeoUI"
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/MeoUI"
    SOURCES
        runtime/meotokens.h
    QML_FILES
                widgets/MeoNavigationBar.qml
        widgets/MeoNavigationDrawerModal.qml
        patterns/MeoAppLayout.qml
        patterns/MeoFeedLayout.qml
        patterns/MeoDashboardLayout.qml
        showcase/pages/ButtonsPage.qml
        showcase/pages/InputsPage.qml
        showcase/pages/NavigationPage.qml
        showcase/pages/SelectionPage.qml
        showcase/pages/DisplayPage.qml
        showcase/pages/FeedbackPage.qml
        showcase/pages/PatternsPage.qml
        showcase/pages/ExpressivePage.qml
        showcase/pages/DataTablePage.qml
        showcase/pages/ThemePage.qml
        showcase/pages/SettingsPage.qml
        showcase/pages/ComponentsLabPage.qml
        showcase/pages/WidgetsLabPage.qml
        showcase/pages/LayoutsLabPage.qml
        showcase/ShowcaseApiTable.qml
        showcase/ShowcaseCatalog.qml
        showcase/ShowcaseCategoryPage.qml
        showcase/ShowcaseComponentHeader.qml
        showcase/ShowcaseSampleDelegate.qml
        showcase/ShowcaseSection.qml
        showcase/ShowcaseSnippet.qml
        showcase/ShowcaseStateGrid.qml
        showcase/ShowcaseVariantRow.qml
        showcase/SettingsPreviewSchemes.js
MeoTheme.qml
        MeoWindowMetrics.qml
        components/MeoButton.qml
        components/MeoIconToggleButton.qml
        components/MeoChipDropdown.qml
        components/MeoText.qml
        components/MeoSplitButton.qml
        components/MeoButtonGroup.qml
        components/MeoLoadingIndicator.qml
        components/MeoFABMenu.qml
        components/MeoDockedToolbar.qml
        components/MeoFloatingToolbar.qml
        components/MeoStepper.qml
        components/MeoSwipeToDismiss.qml
        components/MeoSegmentedButtons.qml
        components/MeoTextField.qml
        components/MeoColorField.qml
        components/MeoTextArea.qml
        components/MeoBanner.qml
        components/MeoBreadcrumbs.qml
        components/MeoRangeSlider.qml
        components/MeoCarousel.qml
        components/MeoFullScreenDialog.qml
        components/MeoPageIndicator.qml
        components/MeoCheckbox.qml
        components/MeoSwitch.qml
        components/MeoSlider.qml
        components/MeoRadioButton.qml
        components/MeoFAB.qml
        components/MeoCard.qml
        components/MeoMediaCard.qml
        components/MeoChip.qml
        components/MeoProgressBar.qml
        components/MeoDialog.qml
        components/MeoBadge.qml
        components/MeoDivider.qml
        components/MeoListItem.qml
        components/MeoSettingsRow.qml
        components/MeoMenu.qml
        components/MeoTabs.qml
        components/MeoTooltip.qml
        components/MeoSnackbar.qml
        components/MeoStateLayer.qml
        components/MeoMotionPopup.qml
        components/MeoMotionSurface.qml
        components/MeoPageHost.qml
        components/MeoFilterChip.qml
        components/MeoInputChip.qml
        components/MeoPullToRefresh.qml
        components/MeoRatingBar.qml
        components/MeoQuickControlSlider.qml
        components/MeoQuickSettingsTile.qml
        components/MeoAppGridItem.qml
        components/MeoSteppedSlider.qml
        components/MeoFilterGroup.qml
        components/MeoListHeader.qml
        components/MeoSelectionGroup.qml
        components/MeoNavigationDrawerItem.qml
        components/MeoDateInput.qml
        components/MeoTimeInput.qml
        components/MeoMonthCalendar.qml
        components/MeoIcon.qml
        components/MeoAiMark.qml
        components/MeoIconButton.qml
        components/MeoDataTable.qml
        components/MeoExposedDropdown.qml
        components/MeoExpansionPanel.qml
        components/MeoRichTooltip.qml
        widgets/MeoMediaController.qml
        widgets/MeoDatePicker.qml
        widgets/MeoDateRangePicker.qml
        widgets/MeoTimePicker.qml
        widgets/MeoNavigationRail.qml
        widgets/MeoNavigationDrawer.qml
        widgets/MeoBottomSheet.qml
        widgets/MeoActionSheet.qml
        widgets/MeoToolbar.qml
        widgets/MeoAccountHeader.qml
        widgets/MeoAccountSwitcher.qml
        widgets/MeoSettingsAccountCard.qml
        widgets/MeoSearchBar.qml
        widgets/MeoSearchAppBar.qml
        widgets/MeoDockedSearchBar.qml
        widgets/MeoBottomAppBar.qml
        widgets/MeoSearchView.qml
        widgets/MeoTopAppBar.qml
        widgets/MeoSearchSuggestions.qml
        components/MeoAssistChip.qml
        components/MeoAvatar.qml
        components/MeoSuggestionChip.qml
        components/MeoSkeleton.qml
        widgets/MeoSideSheetModal.qml
        widgets/MeoSideSheet.qml
        widgets/MeoStandardBottomSheet.qml
        widgets/MeoStatusCenter.qml
        patterns/MeoEmptyState.qml
        patterns/MeoScaffold.qml
        patterns/MeoListDetailLayout.qml
        patterns/MeoSettingsLayout.qml
        patterns/MeoSettingsGroup.qml
        patterns/MeoSettingsTaskSheet.qml
        patterns/MeoQuickSettingsEditor.qml
        patterns/MeoSearchFilterBar.qml
        patterns/MeoPageLayout.qml
        patterns/MeoGroupedList.qml
        patterns/MeoNavigationSuite.qml
        patterns/MeoSearchHeader.qml
        patterns/MeoExpressiveDialog.qml
        patterns/MeoSegmentedList.qml
        patterns/MeoSupportingPaneLayout.qml
        components/MeoShape.qml
        components/MeoShapeMorph.qml
        components/MeoMaterialShapes.js
        showcase/MeoShowcase.qml
    RESOURCES
        assets/fonts/MaterialSymbolsRounded.ttf
        assets/fonts/Comfortaa-Bold.ttf
        assets/fonts/Roboto-Regular.ttf
        assets/fonts/Roboto-Medium.ttf
        assets/fonts/Roboto-Bold.ttf
        assets/icons/meo-ai-f.svg
)

target_link_libraries(meoui_module PUBLIC MeoUI::Tokens Qt6::Core Qt6::Quick Qt6::QuickControls2)
set_target_properties(meoui_module PROPERTIES
    OUTPUT_NAME meoui
    VERSION ${PROJECT_VERSION}
    SOVERSION 0
)

install(TARGETS meoui_module
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
install(TARGETS meoui_tokens
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(FILES runtime/meotokens.h
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/MeoUI"
)
install(TARGETS meoui_moduleplugin
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/MeoUI"
    RUNTIME DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/MeoUI"
)
set_target_properties(meoui_moduleplugin PROPERTIES
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN;$ORIGIN/../../..;${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}"
)
set_target_properties(meoui_module PROPERTIES
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN;$ORIGIN/../../..;${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}"
)

install(TARGETS meoui_module
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/MeoUI"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/MeoUI"
    RUNTIME DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/MeoUI"
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/MeoUI/qmldir"
    "${CMAKE_CURRENT_BINARY_DIR}/MeoUI/meoui_module.qmltypes"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/MeoUI"
)
# Keep source QML beside the plugin for qmllint, IDE tooling, and transparent
# debugging.  The generated qmldir prefers the compiled qrc payload, so runtime
# applications still load the versioned shared module.
install(FILES MeoTheme.qml MeoWindowMetrics.qml
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/MeoUI"
)
install(DIRECTORY components patterns widgets showcase
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/qt6/qml/MeoUI"
    FILES_MATCHING PATTERN "*.qml"
)
install(FILES assets/icons/meo-ai-f.svg
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps"
    RENAME meo-ai.svg
)

# 新增 Demo 展示程序可执行目标
if(MEOUI_BUILD_SHOWCASE)
    qt_add_executable(MeoShowcaseDemo
        main.cpp
    )

    # Showcase evidence belongs beside the workspace-wide outputs tree rather
    # than beside whichever binary CMake happened to produce.  A caller may
    # choose another root at configure time with MEO_OUTPUT_ROOT; the process
    # environment still takes precedence when the executable is launched.
    set(MEOUI_DEFAULT_OUTPUT_ROOT "$ENV{MEO_OUTPUT_ROOT}")
    if(MEOUI_DEFAULT_OUTPUT_ROOT STREQUAL "")
        get_filename_component(MEOUI_DEFAULT_OUTPUT_ROOT
            "${CMAKE_CURRENT_SOURCE_DIR}/../outputs" ABSOLUTE)
    endif()
    file(TO_CMAKE_PATH "${MEOUI_DEFAULT_OUTPUT_ROOT}" MEOUI_DEFAULT_OUTPUT_ROOT)

    target_link_libraries(MeoShowcaseDemo PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        meoui_module
    )
    target_compile_definitions(MeoShowcaseDemo PRIVATE
        MEOUI_DEFAULT_OUTPUT_ROOT="${MEOUI_DEFAULT_OUTPUT_ROOT}"
    )

    # 移除不支持的 qt_import_qml_modules，改用设置 target 属性
    set_target_properties(MeoShowcaseDemo PROPERTIES
        QT_QML_IMPORT_PATH "${CMAKE_BINARY_DIR}"
        WIN32_EXECUTABLE TRUE
    )

    install(TARGETS MeoShowcaseDemo
        BUNDLE DESTINATION .
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    if(COMMAND qt_generate_deploy_qml_app_script)
        # Some versions of CMake/Qt6 error on OUTPUT_SCRIPT; omit it here for fallback
        #qt_generate_deploy_qml_app_script(
        #    TARGET MeoShowcaseDemo
        #    OUTPUT_SCRIPT deploy_script
        #    NO_UNSUPPORTED_PLATFORM_ERROR
        #)
        #install(SCRIPT ${deploy_script})
    endif()
endif()
