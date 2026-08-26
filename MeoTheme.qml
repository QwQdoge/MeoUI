pragma Singleton
import QtQuick

QtObject {
    id: theme

    // 🌟 全局缩放因子（用于支持高分屏自适应与圆角/字体动态调整）
    property real globalScale: 1.0
    property real cornerScale: 1.0
    property real scrollSpeedScale: 1.0

    // 🌟 主题模式开关
    property bool isDarkMode: false
    property bool isExpressive: false
    property bool isBouncy: true
    property bool reduceMotion: false
    property bool transparencyEnabled: true

    // Material 3 adaptive window classes, expressed in effective pixels.
    readonly property real windowBreakpointMedium: 600
    readonly property real windowBreakpointExpanded: 840
    readonly property real windowBreakpointLarge: 1200
    readonly property real windowBreakpointExtraLarge: 1600
    readonly property real windowHeightBreakpointMedium: 480
    readonly property real windowHeightBreakpointExpanded: 900

    function windowWidthSizeClass(availableWidth) {
        const effectiveWidth = Math.max(0, availableWidth) / Math.max(0.1, globalScale)
        if (effectiveWidth < windowBreakpointMedium) return "compact"
        if (effectiveWidth < windowBreakpointExpanded) return "medium"
        if (effectiveWidth < windowBreakpointLarge) return "expanded"
        if (effectiveWidth < windowBreakpointExtraLarge) return "large"
        return "extraLarge"
    }

    function windowHeightSizeClass(availableHeight) {
        const effectiveHeight = Math.max(0, availableHeight) / Math.max(0.1, globalScale)
        if (effectiveHeight < windowHeightBreakpointMedium) return "compact"
        if (effectiveHeight < windowHeightBreakpointExpanded) return "medium"
        return "expanded"
    }

    function windowPageMargin(availableWidth) {
        const sizeClass = windowWidthSizeClass(availableWidth)
        if (sizeClass === "compact") return 16 * globalScale
        if (sizeClass === "medium" || sizeClass === "expanded") return 24 * globalScale
        if (sizeClass === "large") return 32 * globalScale
        return 40 * globalScale
    }

    // The C++ token singleton is the canonical metric source.  Plasma can keep
    // a QML engine alive while the module plugin is replaced during a desktop
    // update, though; during that narrow handoff a singleton member may be
    // temporarily unavailable.  Keep the fallback values here, at the design
    // system boundary, so no product has to invent raw spacing or shape values
    // and a panel never receives an undefined geometry value.
    function metricToken(name, fallback) {
        if (typeof MeoTokens !== "undefined"
                && typeof MeoTokens[name] === "number") {
            return MeoTokens[name]
        }
        return fallback
    }

    // 🎨 MeoArch MD3 fallback color schemes. These are the Material Color
    // Utilities SchemeTonalSpot roles for the default Meo seed (#6750A4), so
    // the installer and offscreen consumers follow the same specification as
    // the live KDE dynamic-color bridge.
    readonly property var fallbackLightColorScheme: ({
        "primary": "#65558F",
        "onPrimary": "#FFFFFF",
        "primaryContainer": "#E9DDFF",
        "onPrimaryContainer": "#4D3D75",
        "inversePrimary": "#CFBDFE",
        "secondary": "#625B71",
        "onSecondary": "#FFFFFF",
        "secondaryContainer": "#E8DEF8",
        "onSecondaryContainer": "#4A4458",
        "tertiary": "#7E5260",
        "onTertiary": "#FFFFFF",
        "tertiaryContainer": "#FFD9E3",
        "onTertiaryContainer": "#633B48",
        "error": "#BA1A1A",
        "onError": "#FFFFFF",
        "errorContainer": "#FFDAD6",
        "onErrorContainer": "#93000A",
        "background": "#FDF7FF",
        "onBackground": "#1D1B20",
        "surface": "#FDF7FF",
        "onSurface": "#1D1B20",
        "surfaceDim": "#DED8E0",
        "surfaceBright": "#FDF7FF",
        "surfaceVariant": "#E7E0EB",
        "onSurfaceVariant": "#49454E",
        "outline": "#7A757F",
        "outlineVariant": "#CAC4CF",
        "surfaceContainerLowest": "#FFFFFF",
        "surfaceContainerLow": "#F8F2FA",
        "surfaceContainer": "#F2ECF4",
        "surfaceContainerHigh": "#ECE6EE",
        "surfaceContainerHighest": "#E6E0E9",
        "inverseSurface": "#322F35",
        "onInverseSurface": "#F5EFF7",
        "shadow": "#000000",
        "scrim": "#000000",
        "surfaceTint": "#65558F",
        "primaryFixed": "#E9DDFF",
        "primaryFixedDim": "#CFBDFE",
        "onPrimaryFixed": "#201047",
        "onPrimaryFixedVariant": "#4D3D75",
        "secondaryFixed": "#E8DEF8",
        "secondaryFixedDim": "#CBC2DB",
        "onSecondaryFixed": "#1E192B",
        "onSecondaryFixedVariant": "#4A4458",
        "tertiaryFixed": "#FFD9E3",
        "tertiaryFixedDim": "#EFB8C8",
        "onTertiaryFixed": "#31101D",
        "onTertiaryFixedVariant": "#633B48"
    })

    readonly property var fallbackDarkColorScheme: ({
        "primary": "#CFBDFE",
        "onPrimary": "#36275D",
        "primaryContainer": "#4D3D75",
        "onPrimaryContainer": "#E9DDFF",
        "inversePrimary": "#65558F",
        "secondary": "#CBC2DB",
        "onSecondary": "#332D41",
        "secondaryContainer": "#4A4458",
        "onSecondaryContainer": "#E8DEF8",
        "tertiary": "#EFB8C8",
        "onTertiary": "#4A2532",
        "tertiaryContainer": "#633B48",
        "onTertiaryContainer": "#FFD9E3",
        "error": "#FFB4AB",
        "onError": "#690005",
        "errorContainer": "#93000A",
        "onErrorContainer": "#FFDAD6",
        "background": "#141218",
        "onBackground": "#E6E0E9",
        "surface": "#141218",
        "onSurface": "#E6E0E9",
        "surfaceDim": "#141218",
        "surfaceBright": "#3B383E",
        "surfaceVariant": "#49454E",
        "onSurfaceVariant": "#CAC4CF",
        "outline": "#948F99",
        "outlineVariant": "#49454E",
        "surfaceContainerLowest": "#0F0D13",
        "surfaceContainerLow": "#1D1B20",
        "surfaceContainer": "#211F24",
        "surfaceContainerHigh": "#2B292F",
        "surfaceContainerHighest": "#36343A",
        "inverseSurface": "#E6E0E9",
        "onInverseSurface": "#322F35",
        "shadow": "#000000",
        "scrim": "#000000",
        "surfaceTint": "#CFBDFE",
        "primaryFixed": "#E9DDFF",
        "primaryFixedDim": "#CFBDFE",
        "onPrimaryFixed": "#201047",
        "onPrimaryFixedVariant": "#4D3D75",
        "secondaryFixed": "#E8DEF8",
        "secondaryFixedDim": "#CBC2DB",
        "onSecondaryFixed": "#1E192B",
        "onSecondaryFixedVariant": "#4A4458",
        "tertiaryFixed": "#FFD9E3",
        "tertiaryFixedDim": "#EFB8C8",
        "onTertiaryFixed": "#31101D",
        "onTertiaryFixedVariant": "#633B48"
    })

    // 🎨 Dynamic color provider API
    //
    // A dynamic scheme is an atomic Material/HCT role table, never a seed
    // colour or a handful of hand-picked containers.  Accepting partial maps
    // used to make one product surface dynamic while another silently fell
    // back to the purple preview palette.  Keep the validation here, at the
    // shared design-system boundary, so applications cannot accidentally
    // ship a mixed theme.
    readonly property var requiredDynamicColorRoles: Object.keys(fallbackLightColorScheme)
    property bool dynamicColorsAvailable: false
    property var dynamicColorScheme: ({})
    property string colorSchemeMode: "fallback" // dynamic | fallback | invalid
    property string dynamicColorSourceId: ""
    property string dynamicColorError: ""
    property int colorSchemeRevision: 0

    function hasCompleteColorScheme(scheme) {
        if (!scheme || typeof scheme !== "object")
            return false
        for (let index = 0; index < requiredDynamicColorRoles.length; ++index) {
            const role = requiredDynamicColorRoles[index]
            const value = scheme[role]
            if (typeof value === "undefined" || value === null || value === "")
                return false
        }
        return true
    }

    // Returns true only when the entire MD3 role table has been installed.
    // `sourceId` is diagnostic metadata; MeoUI deliberately does not know how
    // a platform generated the table.
    function applyDynamicColorScheme(scheme, sourceId) {
        if (!hasCompleteColorScheme(scheme)) {
            dynamicColorScheme = ({})
            dynamicColorsAvailable = false
            colorSchemeMode = "invalid"
            dynamicColorSourceId = ""
            dynamicColorError = "A complete Material color-role table is required."
            colorSchemeRevision += 1
            return false
        }

        dynamicColorScheme = scheme
        dynamicColorsAvailable = true
        colorSchemeMode = "dynamic"
        dynamicColorSourceId = sourceId || "external"
        dynamicColorError = ""
        colorSchemeRevision += 1
        return true
    }

    function clearDynamicColorScheme() {
        dynamicColorsAvailable = false
        dynamicColorScheme = ({})
        colorSchemeMode = "fallback"
        dynamicColorSourceId = ""
        dynamicColorError = ""
        colorSchemeRevision += 1
    }

    function colorForRole(role, darkMode, dynamicAvailable, scheme) {
        const fallbackScheme = darkMode ? fallbackDarkColorScheme : fallbackLightColorScheme
        if (dynamicAvailable
                && scheme
                && typeof scheme[role] !== "undefined"
                && scheme[role] !== null
                && scheme[role] !== "") {
            return scheme[role]
        }
        return fallbackScheme[role]
    }

    function dynamicOrFallback(role) {
        if (dynamicColorsAvailable
                && dynamicColorScheme
                && typeof dynamicColorScheme[role] !== "undefined"
                && dynamicColorScheme[role] !== null
                && dynamicColorScheme[role] !== "") {
            return dynamicColorScheme[role]
        }
        return isDarkMode ? fallbackDarkColorScheme[role] : fallbackLightColorScheme[role]
    }

    // 🎨 Active MD3 roles. Content roles use a non-`onXxx` public name because
    // QML reserves that shape for signal handlers in several compiled paths.
    property color primary: dynamicOrFallback("primary")
    property color contentOnPrimary: dynamicOrFallback("onPrimary")
    property color primaryContainer: dynamicOrFallback("primaryContainer")
    property color contentOnPrimaryContainer: dynamicOrFallback("onPrimaryContainer")
    property color inversePrimary: dynamicOrFallback("inversePrimary")

    property color secondary: dynamicOrFallback("secondary")
    property color contentOnSecondary: dynamicOrFallback("onSecondary")
    property color secondaryContainer: dynamicOrFallback("secondaryContainer")
    property color contentOnSecondaryContainer: dynamicOrFallback("onSecondaryContainer")

    property color tertiary: dynamicOrFallback("tertiary")
    property color contentOnTertiary: dynamicOrFallback("onTertiary")
    property color tertiaryContainer: dynamicOrFallback("tertiaryContainer")
    property color contentOnTertiaryContainer: dynamicOrFallback("onTertiaryContainer")

    property color error: dynamicOrFallback("error")
    property color contentOnError: dynamicOrFallback("onError")
    property color errorContainer: dynamicOrFallback("errorContainer")
    property color contentOnErrorContainer: dynamicOrFallback("onErrorContainer")

    property color background: dynamicOrFallback("background")
    property color contentOnBackground: dynamicOrFallback("onBackground")
    property color surface: dynamicOrFallback("surface")
    property color contentOnSurface: dynamicOrFallback("onSurface")
    property color surfaceDim: dynamicOrFallback("surfaceDim")
    property color surfaceBright: dynamicOrFallback("surfaceBright")
    property color surfaceVariant: dynamicOrFallback("surfaceVariant")
    property color contentOnSurfaceVariant: dynamicOrFallback("onSurfaceVariant")
    property color outline: dynamicOrFallback("outline")

    // M3 Content color aliases
    property color onPrimary: contentOnPrimary
    // M3 Surface Containers
    property color surfaceContainerLowest: dynamicOrFallback("surfaceContainerLowest")
    property color surfaceContainerLow: dynamicOrFallback("surfaceContainerLow")
    property color surfaceContainer: dynamicOrFallback("surfaceContainer")
    property color surfaceContainerHigh: dynamicOrFallback("surfaceContainerHigh")
    property color surfaceContainerHighest: dynamicOrFallback("surfaceContainerHighest")
    property color onPrimaryContainer: contentOnPrimaryContainer
    property color onSecondary: contentOnSecondary
    property color onSecondaryContainer: contentOnSecondaryContainer
    property color onTertiary: contentOnTertiary
    property color onTertiaryContainer: contentOnTertiaryContainer
    property color onSurface: contentOnSurface
    property color onSurfaceVariant: contentOnSurfaceVariant
    property color onError: contentOnError
    property color onErrorContainer: contentOnErrorContainer

    // Motion duration aliases
    readonly property int durationShort: motionDurationFast
    readonly property int durationMedium: motionDurationMedium
    readonly property int durationLong: motionDurationSlow



    // 🌟 Surface Tint Helper (MD3 Elevation Overlay)
    function surfaceTint(level) {
        let opacities = [0, 0.05, 0.08, 0.11, 0.12, 0.14];
        let opacity = opacities[Math.min(Math.max(level, 0), 5)];
        return Qt.tint(surface, Qt.rgba(primary.r, primary.g, primary.b, opacity));
    }

    // 🌟 Motion Tokens (MD3 Standard). Keep one duration gateway so the
    // accessibility setting and the user-selected motion scale affect every
    // semantic token consistently.
    readonly property real effectiveMotionScale: Math.max(0, Math.min(4, motionScale))

    function motionDurationFor(milliseconds) {
        return reduceMotion ? 0 : Math.max(0, Math.round(milliseconds * effectiveMotionScale))
    }

    readonly property int motionDurationShort1: motionDurationFor(50)
    readonly property int motionDurationShort2: motionDurationFor(100)
    readonly property int motionDurationShort3: motionDurationFor(150)
    readonly property int motionDurationShort4: motionDurationFor(200)
    readonly property int motionDurationMedium1: motionDurationFor(250)
    readonly property int motionDurationMedium2: motionDurationFor(300)
    readonly property int motionDurationMedium3: motionDurationFor(350)
    readonly property int motionDurationMedium4: motionDurationFor(400)
    readonly property int motionDurationLong1: motionDurationFor(450)
    readonly property int motionDurationLong2: motionDurationFor(500)
    readonly property int motionDurationLong3: motionDurationFor(550)
    readonly property int motionDurationLong4: motionDurationFor(600)
    readonly property int motionDurationExtraLong1: motionDurationFor(700)
    readonly property int motionDurationExtraLong2: motionDurationFor(800)
    readonly property int motionDurationExtraLong3: motionDurationFor(900)
    readonly property int motionDurationExtraLong4: motionDurationFor(1000)

    // Material 3 semantic motion aliases for component code.
    readonly property var motionDurationInstant: motionDurationShort1
    // Interactive desktop feedback needs to acknowledge a pointer immediately.
    // Longer values stay reserved for spatial transitions rather than hover/press.
    readonly property var motionDurationFast: motionDurationFor(120)
    readonly property var motionDurationMedium: motionDurationFor(220)
    readonly property var motionDurationSlow: motionDurationFor(320)
    readonly property var motionDurationRippleExpand: motionDurationFor(280)
    readonly property var motionDurationRippleFade: motionDurationFor(160)
    readonly property int motionDurationState: motionDurationFor(100)
    readonly property int motionDurationSelection: motionDurationFor(220)
    readonly property int motionDurationShapeEnter: motionDurationFor(140)
    readonly property int motionDurationShapeSettle: motionDurationFor(220)
    readonly property int motionDurationDialogEnter: motionDurationFor(240)
    readonly property int motionDurationDialogExit: motionDurationFor(160)
    readonly property int motionDurationMenuEnter: motionDurationFor(160)
    readonly property int motionDurationMenuExit: motionDurationFor(120)
    readonly property int motionDurationSheetEnter: motionDurationFor(320)
    readonly property int motionDurationSheetExit: motionDurationFor(220)
    readonly property int motionDurationPage: motionDurationFor(320)
    readonly property int motionDurationTooltipExit: motionDurationFor(100)
    readonly property int motionStaggerDelay: motionDurationFor(25)

    readonly property list<real> motionEasingStandard: [0.2, 0, 0, 1]
    readonly property list<real> motionEasingStandardAccelerate: [0.3, 0, 1, 1]
    readonly property list<real> motionEasingStandardDecelerate: [0, 0, 0, 1]
    readonly property list<real> motionEasingEmphasized: [0.05, 0.7, 0.1, 1]
    readonly property list<real> motionEasingEmphasizedAccelerate: [0.3, 0, 0.8, 0.15]
    readonly property list<real> motionEasingEmphasizedDecelerate: [0.05, 0.7, 0.1, 1]
    readonly property list<real> motionEasingEnter: [0, 0, 0, 1]
    readonly property list<real> motionEasingExit: [1, 0, 1, 1]

    // 🌟 M3E Spring Physics Motion Curves (Spatial vs Effect)
    readonly property list<real> motionEasingSpringBouncy: isBouncy ? [0.34, 1.35, 0.64, 1.0] : motionEasingEmphasizedDecelerate // Controlled Settling Overshoot
    readonly property list<real> motionEasingSpringStiff: isBouncy ? [0.18, 0.89, 0.32, 1.25] : motionEasingStandardDecelerate // Instant Physical Press Response
    readonly property list<real> motionEasingSpringSubtle: isBouncy ? [0.22, 1.1, 0.36, 1.0] : motionEasingEmphasizedDecelerate // Smooth Release Settling

    // Compatibility & Primary M3E Curve
    readonly property list<real> motionEasingSoul: motionEasingEmphasized

    // 🌟 M3E Motion Scheme Categories
    // Spatial Motion (Position, Size, Bounds, Shape Morphing)
    readonly property int motionDurationSpatialFast: motionDurationFor(120)
    readonly property int motionDurationSpatialDefault: motionDurationFor(220)
    readonly property int motionDurationSpatialSlow: motionDurationFor(340)

    // Effect Motion (Opacity, Color, State Layer, Scrim - Monotonic without Overshoot)
    readonly property int motionDurationEffectFast: motionDurationFor(80)
    readonly property int motionDurationEffectDefault: motionDurationFor(150)
    readonly property int motionDurationEffectSlow: motionDurationFor(250)

    // 🌟 字体族 Token (Font Family Tokens)
    // Consumers may bind these to the platform font provider. Keep a concrete
    // family here: QFont's `family` property is a single family name, not a CSS
    // comma-separated fallback declaration.
    property string fontFamily: "Roboto"
    property string fontFamilyMonospace: "Roboto Mono"
    property string fontFamilyBrand: "Comfortaa"

    // 🌟 字体全局缩放 (Font Scale Token)
    property real fontScale: 1.0

    // 🌟 动画时间与曲线全局倍率 (Motion Duration & Speed Scale)
    property real motionScale: 1.0

    // 🌟 图标尺寸 Token (Icon Size Tokens)
    readonly property real iconSizeXS: metricToken("iconSizeXS", 16) * globalScale
    readonly property real iconSizeS: metricToken("iconSizeS", 18) * globalScale
    readonly property real iconSizeM: metricToken("iconSizeM", 24) * globalScale
    readonly property real iconSizeL: metricToken("iconSizeL", 32) * globalScale
    readonly property real iconSizeXL: metricToken("iconSizeXL", 48) * globalScale

    // 🌟 悬浮/阴影 Token (Elevation Tokens)
    readonly property real elevationLevel0: 0
    readonly property real elevationLevel1: 1 * globalScale
    readonly property real elevationLevel2: 3 * globalScale
    readonly property real elevationLevel3: 6 * globalScale
    readonly property real elevationLevel4: 8 * globalScale
    readonly property real elevationLevel5: 12 * globalScale

    // MD3 state-layer opacity tokens.
    readonly property real stateOpacityHover: metricToken("stateOpacityHover", 0.10)
    readonly property real stateOpacityFocus: metricToken("stateOpacityFocus", 0.12)
    readonly property real stateOpacityPressed: metricToken("stateOpacityPressed", 0.14)
    readonly property real stateOpacityDragged: metricToken("stateOpacityDragged", 0.16)

    // Semantic feedback and surface roles used by products consuming MeoUI.
    readonly property real disabledContainerOpacity: 0.12
    readonly property real disabledContentOpacity: 0.38
    readonly property color scrim: dynamicOrFallback("scrim")
    readonly property color shadow: dynamicOrFallback("shadow")
    readonly property color inverseSurface: dynamicOrFallback("inverseSurface")
    readonly property color contentOnInverseSurface: dynamicOrFallback("onInverseSurface")
    readonly property color success: isDarkMode ? "#8ED6A0" : "#256D3A"
    readonly property color successContainer: isDarkMode ? "#164A27" : "#D8F3DC"
    readonly property color contentOnSuccessContainer: isDarkMode ? "#C1F1CB" : "#123C20"

    property color outlineVariant: dynamicOrFallback("outlineVariant")

    // MD3 Fixed Colors remain stable across light/dark, but follow the active
    // HCT source when a dynamic scheme is installed.
    property color primaryFixed: dynamicOrFallback("primaryFixed")
    property color fixedOnPrimary: dynamicOrFallback("onPrimaryFixed")
    property color primaryFixedDim: dynamicOrFallback("primaryFixedDim")
    property color fixedOnPrimaryVariant: dynamicOrFallback("onPrimaryFixedVariant")

    property color secondaryFixed: dynamicOrFallback("secondaryFixed")
    property color fixedOnSecondary: dynamicOrFallback("onSecondaryFixed")
    property color secondaryFixedDim: dynamicOrFallback("secondaryFixedDim")
    property color fixedOnSecondaryVariant: dynamicOrFallback("onSecondaryFixedVariant")

    property color tertiaryFixed: dynamicOrFallback("tertiaryFixed")
    property color fixedOnTertiary: dynamicOrFallback("onTertiaryFixed")
    property color tertiaryFixedDim: dynamicOrFallback("tertiaryFixedDim")
    property color fixedOnTertiaryVariant: dynamicOrFallback("onTertiaryFixedVariant")

    // 🌟 辅助/窗口背景色
    property color windowBg: background

    // 🌟 M3 Shape Scale (MD3 Standard)
    readonly property real shapeNone: 0
    readonly property real shapeExtraSmall: metricToken("shapeExtraSmall", 4) * globalScale * cornerScale
    readonly property real shapeSmall: metricToken("shapeSmall", 8) * globalScale * cornerScale
    readonly property real shapeMedium: metricToken("shapeMedium", 12) * globalScale * cornerScale
    readonly property real shapeLarge: metricToken("shapeLarge", 16) * globalScale * cornerScale
    readonly property real shapeLargeIncreased: metricToken("shapeLargeIncreased", 20) * globalScale * cornerScale
    readonly property real shapeExtraLarge: metricToken("shapeExtraLarge", 28) * globalScale * cornerScale
    readonly property real shapeExtraLargeIncreased: metricToken("shapeExtraLargeIncreased", 32) * globalScale * cornerScale
    readonly property real expressiveShapeCornerRadius: metricToken("shapeExtraLargeIncreased", 32) * globalScale * cornerScale
    readonly property real shapeExtraExtraLarge: metricToken("shapeExtraExtraLarge", 48) * globalScale * cornerScale
    readonly property real shapeFull: 1000 * globalScale // Large value for full rounding

    // 🌟 MD3 Expressive Dimension Tokens
    readonly property real buttonHeightXS: metricToken("buttonHeightXS", 32) * globalScale
    readonly property real buttonHeightS: metricToken("buttonHeightS", 40) * globalScale
    readonly property real buttonHeightM: metricToken("buttonHeightM", 48) * globalScale
    readonly property real buttonHeightL: metricToken("buttonHeightL", 56) * globalScale
    readonly property real buttonHeightXL: metricToken("buttonHeightXL", 72) * globalScale

    readonly property real sliderTrackHeightXS: 4 * globalScale
    readonly property real sliderTrackHeightS: 16 * globalScale
    readonly property real sliderTrackHeightM: 28 * globalScale
    readonly property real sliderTrackHeightL: 36 * globalScale
    readonly property real sliderTrackHeightXL: 44 * globalScale

    readonly property real sliderThumbWidthExpressive: 4 * globalScale
    readonly property real sliderThumbHeightExpressive: 44 * globalScale
    readonly property real sliderThumbGapExpressive: 6 * globalScale

    readonly property real shapeSquareRadius: 4 * globalScale

    // 🌟 Semantic thickness tokens
    readonly property real strokeWidthThin: 1 * globalScale
    readonly property real strokeWidthMedium: 2 * globalScale
    readonly property real strokeWidthThick: 3 * globalScale

    // 🌟 MD3 Expressive Shape Library (Conceptual Tokens)
    readonly property string shapeSquircle: "squircle"
    readonly property string shapeHexagon: "hexagon"
    readonly property string shapeDiamond: "diamond"
    readonly property string shapePentagon: "pentagon"
    readonly property string shapeOctagon: "octagon"

    // 🌟 M3 间距网格系统 (Spacing Tokens)
    readonly property real space2: metricToken("space2", 2) * globalScale
    readonly property real space4: metricToken("space4", 4) * globalScale
    readonly property real space8: metricToken("space8", 8) * globalScale
    readonly property real space12: metricToken("space12", 12) * globalScale
    readonly property real space16: metricToken("space16", 16) * globalScale
    readonly property real space24: metricToken("space24", 24) * globalScale
    readonly property real space32: metricToken("space32", 32) * globalScale
    readonly property real space40: metricToken("space40", 40) * globalScale
    readonly property real space48: metricToken("space48", 48) * globalScale

    // 🌟 兼容老版组件的 Padding 定义
    readonly property real compactPadding: 8 * globalScale
    readonly property real standardPadding: 16 * globalScale
    readonly property real largePadding: 24 * globalScale

    // Settings composition tokens.  These keep the Pixel/Material 3 rhythm in
    // one reusable contract while allowing desktop pages to remain adaptive.
    readonly property real settingsContentMaxWidth: metricToken("settingsContentMaxWidth", 760) * globalScale
    readonly property real settingsSidebarWidth: metricToken("settingsSidebarWidth", 288) * globalScale
    readonly property real settingsSidebarHorizontalMargin: metricToken("settingsSidebarHorizontalMargin", 8) * globalScale
    readonly property real settingsSidebarItemHeight: metricToken("settingsSidebarItemHeight", 56) * globalScale
    readonly property real settingsRowHeight: metricToken("settingsRowHeight", 72) * globalScale
    readonly property real settingsRowHorizontalPadding: metricToken("settingsRowHorizontalPadding", 16) * globalScale
    readonly property real settingsLeadingContainerSize: metricToken("settingsLeadingContainerSize", 40) * globalScale
    readonly property real settingsLeadingIconSize: metricToken("settingsLeadingIconSize", 24)
    readonly property real settingsIconTextGap: metricToken("settingsIconTextGap", 16) * globalScale
    readonly property real settingsSearchHeight: metricToken("settingsSearchHeight", 64) * globalScale
    readonly property real settingsSearchRadius: shapeExtraLargeIncreased
    readonly property real settingsAccountHeight: metricToken("settingsAccountHeight", 92) * globalScale
    readonly property real settingsAccountRadius: shapeExtraLarge
    readonly property real settingsAvatarSize: metricToken("settingsAvatarSize", 48) * globalScale

    // 🌟 Material Design 3 Typography (Type Scale)
    // Format: { size, weight, lineHeight, letterSpacing }
    readonly property string typefacePlain: fontFamily
    readonly property string typefaceBrand: fontFamilyBrand
    readonly property string typefaceChineseFallback: "Noto Sans SC, Microsoft YaHei, Source Han Sans SC"

    // Display
    readonly property var displayLarge: { "size": 57, "weight": Font.Normal, "lineHeight": 64, "letterSpacing": -0.25 }
    readonly property var displayMedium: { "size": 45, "weight": Font.Normal, "lineHeight": 52, "letterSpacing": 0 }
    readonly property var displaySmall: { "size": 36, "weight": Font.Normal, "lineHeight": 44, "letterSpacing": 0 }

    // Headline
    readonly property var headlineLarge: { "size": 32, "weight": Font.Normal, "lineHeight": 40, "letterSpacing": 0 }
    readonly property var headlineMedium: { "size": 28, "weight": Font.Normal, "lineHeight": 36, "letterSpacing": 0 }
    readonly property var headlineSmall: { "size": 24, "weight": Font.Normal, "lineHeight": 32, "letterSpacing": 0 }

    // Title
    readonly property var titleLarge: { "size": 22, "weight": Font.Normal, "lineHeight": 28, "letterSpacing": 0 }
    readonly property var titleMedium: { "size": 16, "weight": Font.Medium, "lineHeight": 24, "letterSpacing": 0.15 }
    readonly property var titleSmall: { "size": 14, "weight": Font.Medium, "lineHeight": 20, "letterSpacing": 0.1 }

    // Body
    readonly property var bodyLarge: { "size": 16, "weight": Font.Normal, "lineHeight": 24, "letterSpacing": 0.5 }
    readonly property var bodyMedium: { "size": 14, "weight": Font.Normal, "lineHeight": 20, "letterSpacing": 0.25 }
    readonly property var bodySmall: { "size": 12, "weight": Font.Normal, "lineHeight": 16, "letterSpacing": 0.4 }

    // Label
    readonly property var labelLarge: { "size": 14, "weight": Font.Medium, "lineHeight": 20, "letterSpacing": 0.1 }
    readonly property var labelMedium: { "size": 12, "weight": Font.Medium, "lineHeight": 16, "letterSpacing": 0.5 }
    readonly property var labelSmall: { "size": 11, "weight": Font.Medium, "lineHeight": 16, "letterSpacing": 0.5 }

    // 🌟 MD3 Expressive Typography (Emphasized Type Scale)
    // Display Emphasized (Bold weight 700)
    readonly property var displayLargeEmphasized: { "size": 57, "weight": Font.Bold, "lineHeight": 64, "letterSpacing": -0.25 }
    readonly property var displayMediumEmphasized: { "size": 45, "weight": Font.Bold, "lineHeight": 52, "letterSpacing": 0 }
    readonly property var displaySmallEmphasized: { "size": 36, "weight": Font.Bold, "lineHeight": 44, "letterSpacing": 0 }

    // Headline Emphasized (Bold weight 700)
    readonly property var headlineLargeEmphasized: { "size": 32, "weight": Font.Bold, "lineHeight": 40, "letterSpacing": 0 }
    readonly property var headlineMediumEmphasized: { "size": 28, "weight": Font.Bold, "lineHeight": 36, "letterSpacing": 0 }
    readonly property var headlineSmallEmphasized: { "size": 24, "weight": Font.Bold, "lineHeight": 32, "letterSpacing": 0 }

    // Title Emphasized (DemiBold weight 600)
    readonly property var titleLargeEmphasized: { "size": 22, "weight": Font.DemiBold, "lineHeight": 28, "letterSpacing": 0 }
    readonly property var titleMediumEmphasized: { "size": 16, "weight": Font.DemiBold, "lineHeight": 24, "letterSpacing": 0.15 }
    readonly property var titleSmallEmphasized: { "size": 14, "weight": Font.DemiBold, "lineHeight": 20, "letterSpacing": 0.1 }

    // Body Emphasized (DemiBold weight 600)
    readonly property var bodyLargeEmphasized: { "size": 16, "weight": Font.DemiBold, "lineHeight": 24, "letterSpacing": 0.5 }
    readonly property var bodyMediumEmphasized: { "size": 14, "weight": Font.DemiBold, "lineHeight": 20, "letterSpacing": 0.25 }
    readonly property var bodySmallEmphasized: { "size": 12, "weight": Font.DemiBold, "lineHeight": 16, "letterSpacing": 0.4 }

    // Label Emphasized (DemiBold weight 600)
    readonly property var labelLargeEmphasized: { "size": 14, "weight": Font.DemiBold, "lineHeight": 20, "letterSpacing": 0.1 }
    readonly property var labelMediumEmphasized: { "size": 12, "weight": Font.DemiBold, "lineHeight": 16, "letterSpacing": 0.5 }
    readonly property var labelSmallEmphasized: { "size": 11, "weight": Font.DemiBold, "lineHeight": 16, "letterSpacing": 0.5 }

    // 🌟 Meo semantic typography tokens.
    // Use these in pages/components instead of raw pixel sizes.
    readonly property var titleBig: { "size": 40, "weight": Font.Bold, "lineHeight": 48, "letterSpacing": 0, "family": typefaceBrand }
    readonly property var titleMediumUi: { "size": 26, "weight": Font.Bold, "lineHeight": 34, "letterSpacing": 0, "family": typefacePlain }
    readonly property var titleSmallUi: { "size": 16, "weight": Font.Bold, "lineHeight": 24, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodyBig: { "size": 18, "weight": Font.Normal, "lineHeight": 28, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodyMediumUi: { "size": 15, "weight": Font.Normal, "lineHeight": 22, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodySmallUi: { "size": 14, "weight": Font.Normal, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelBig: { "size": 15, "weight": Font.Medium, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelMediumUi: { "size": 14, "weight": Font.Medium, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelSmallUi: { "size": 12, "weight": Font.Medium, "lineHeight": 16, "letterSpacing": 0, "family": typefacePlain }

    readonly property var titleBigEmphasized: titleBig
    readonly property var titleMediumUiEmphasized: titleMediumUi
    readonly property var titleSmallUiEmphasized: titleSmallUi
    readonly property var bodyBigEmphasized: { "size": 18, "weight": Font.Bold, "lineHeight": 28, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodyMediumUiEmphasized: { "size": 15, "weight": Font.Bold, "lineHeight": 22, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodySmallUiEmphasized: { "size": 14, "weight": Font.Bold, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelBigEmphasized: { "size": 15, "weight": Font.Bold, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelMediumUiEmphasized: { "size": 14, "weight": Font.Bold, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelSmallUiEmphasized: { "size": 12, "weight": Font.Bold, "lineHeight": 16, "letterSpacing": 0, "family": typefacePlain }

    function typeToken(role, size, emphasized) {
        const normalizedRole = role || "body"
        const normalizedSize = size || "medium"

        if (normalizedRole === "title") {
            if (normalizedSize === "big" || normalizedSize === "large") return emphasized ? titleBigEmphasized : titleBig
            if (normalizedSize === "small") return emphasized ? titleSmallUiEmphasized : titleSmallUi
            return emphasized ? titleMediumUiEmphasized : titleMediumUi
        }

        if (normalizedRole === "body") {
            if (normalizedSize === "big" || normalizedSize === "large") return emphasized ? bodyBigEmphasized : bodyBig
            if (normalizedSize === "small") return emphasized ? bodySmallUiEmphasized : bodySmallUi
            return emphasized ? bodyMediumUiEmphasized : bodyMediumUi
        }

        if (normalizedRole === "label") {
            if (normalizedSize === "big" || normalizedSize === "large") return emphasized ? labelBigEmphasized : labelBig
            if (normalizedSize === "small") return emphasized ? labelSmallUiEmphasized : labelSmallUi
            return emphasized ? labelMediumUiEmphasized : labelMediumUi
        }

        return bodyMediumUi
    }
}
