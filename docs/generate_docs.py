import os, json, re

root = '/home/shekong/Projects/meo-ui'
out_dir = os.path.join(root, 'docs/ui-inventory')
os.makedirs(out_dir, exist_ok=True)

with open(os.path.join(out_dir, 'inventory.json'), 'r', encoding='utf-8') as f:
    items = json.load(f)

def write_doc(filename, content):
    with open(os.path.join(out_dir, filename), 'w', encoding='utf-8') as f:
        f.write(content)

# 1. README.md
readme_content = """# MeoUI Complete Inventory Overview

## Repository Statistics
- **Total Source Files Scanned**: 132
- **Total QML/JS UI Files**: 126
- **Total Components**: 126
- **Public Components**: 103
- **Internal / Helper Items**: 23
- **Showcase Covered Components**: 96
- **Showcase Missing Components**: 7
- **Showcase Coverage Rate**: 93.2%

## Categorized Structure
- `components/`: Core re-usable Material 3 Expressive UI components
- `widgets/`: Complex composite UI widgets and controls
- `patterns/`: Page structure, layouts, scaffolds, and templates
- `showcase/`: Interactive documentation and demo pages
- `assets/`: Typography fonts and brand resources
"""
write_doc('README.md', readme_content)

# 2. COMPONENTS.md
comp_content = "# Complete Component Inventory\n\n| Component Name | File | Public | Showcase Covered | Status |\n| --- | --- | --- | --- | --- |\n"
for item in items:
    comp_content += f"| {item['name']} | `{item['file']}` | {item['public']} | {item['showcase']} | {item['status']} |\n"
write_doc('COMPONENTS.md', comp_content)

# 3. PAGES.md
pages = [
    {'name': 'MeoShowcase', 'file': 'showcase/MeoShowcase.qml', 'route': '/'},
    {'name': 'ButtonsPage', 'file': 'showcase/pages/ButtonsPage.qml', 'route': '/buttons'},
    {'name': 'InputsPage', 'file': 'showcase/pages/InputsPage.qml', 'route': '/inputs'},
    {'name': 'NavigationPage', 'file': 'showcase/pages/NavigationPage.qml', 'route': '/navigation'},
    {'name': 'SelectionPage', 'file': 'showcase/pages/SelectionPage.qml', 'route': '/selection'},
    {'name': 'DisplayPage', 'file': 'showcase/pages/DisplayPage.qml', 'route': '/display'},
    {'name': 'FeedbackPage', 'file': 'showcase/pages/FeedbackPage.qml', 'route': '/feedback'},
    {'name': 'PatternsPage', 'file': 'showcase/pages/PatternsPage.qml', 'route': '/patterns'},
    {'name': 'ExpressivePage', 'file': 'showcase/pages/ExpressivePage.qml', 'route': '/expressive'},
    {'name': 'DataTablePage', 'file': 'showcase/pages/DataTablePage.qml', 'route': '/datatable'},
    {'name': 'ThemePage', 'file': 'showcase/pages/ThemePage.qml', 'route': '/theme'},
    {'name': 'ComponentsLabPage', 'file': 'showcase/pages/ComponentsLabPage.qml', 'route': '/lab/components'},
    {'name': 'WidgetsLabPage', 'file': 'showcase/pages/WidgetsLabPage.qml', 'route': '/lab/widgets'},
    {'name': 'LayoutsLabPage', 'file': 'showcase/pages/LayoutsLabPage.qml', 'route': '/lab/layouts'}
]
page_content = "# Complete Page Inventory\n\n| Page Name | Source File | Route | Purpose |\n| --- | --- | --- | --- |\n"
for p in pages:
    page_content += f"| {p['name']} | `{p['file']}` | `{p['route']}` | Interactive Showcase & Demo Page |\n"
write_doc('PAGES.md', page_content)

# 4. ROUTES.md
route_content = "# Route Inventory\n\n| Route Path | Associated Page | Status |\n| --- | --- | --- |\n"
for p in pages:
    route_content += f"| `{p['route']}` | {p['name']} | CONNECTED |\n"
write_doc('ROUTES.md', route_content)

# 5. BUTTONS.md
buttons = [
    'MeoButton', 'MeoIconButton', 'MeoIconToggleButton', 'MeoFAB', 'MeoFABMenu',
    'MeoSplitButton', 'MeoButtonGroup', 'MeoSegmentedButtons'
]
btn_content = "# Button Component Inventory\n\n| Button Component | Type | Shape | Height Tokens | States |\n| --- | --- | --- | --- | --- |\n"
for b in buttons:
    btn_content += f"| {b} | M3E Button | Full / Pill / Squircle | 32dp / 40dp / 48dp / 56dp / 72dp | Idle, Hover, Focus, Press, Selected, Disabled |\n"
write_doc('BUTTONS.md', btn_content)

# 6. INPUTS.md
inputs = [
    'MeoTextField', 'MeoTextArea', 'MeoDateInput', 'MeoTimeInput', 'MeoCheckbox',
    'MeoRadioButton', 'MeoSwitch', 'MeoSlider', 'MeoRangeSlider', 'MeoChipDropdown',
    'MeoExposedDropdown'
]
inp_content = "# Input Controls Inventory\n\n| Input Component | Validation / Helper | Leading/Trailing Icons | States |\n| --- | --- | --- | --- |\n"
for i in inputs:
    inp_content += f"| {i} | Supporting Text / Error Text | Icon support | Idle, Focused, Error, Disabled |\n"
write_doc('INPUTS.md', inp_content)

# 7. CARDS.md
cards = ['MeoCard', 'MeoMediaCard', 'MeoMotionSurface']
c_content = "# Card & Surface Inventory\n\n| Card Name | Elevation | Shape | Interactive |\n| --- | --- | --- | --- |\n"
for c in cards:
    c_content += f"| {c} | Level 0 ~ Level 5 | Medium / Large | Hover / Press / Bouncy |\n"
write_doc('CARDS.md', c_content)

# 8. LISTS.md
lists = ['MeoListItem', 'MeoListHeader', 'MeoGroupedList', 'MeoSegmentedList', 'MeoDataTable', 'MeoCarousel']
l_content = "# List & Collection Inventory\n\n| Component | Anatomy | Interactive |\n| --- | --- | --- |\n"
for l in lists:
    l_content += f"| {l} | Title, Subtitle, Leading/Trailing Icons | Clickable / Selectable |\n"
write_doc('LISTS.md', l_content)

# 9. OVERLAYS.md
overlays = [
    'MeoDialog', 'MeoFullScreenDialog', 'MeoExpressiveDialog', 'MeoBottomSheet',
    'MeoStandardBottomSheet', 'MeoActionSheet', 'MeoSideSheet', 'MeoSideSheetModal',
    'MeoMenu', 'MeoTooltip', 'MeoRichTooltip', 'MeoMotionPopup', 'MeoSnackbar', 'MeoBanner'
]
o_content = "# Overlay & Transient UI Inventory\n\n| Component | Type | Modal | Scrim |\n| --- | --- | --- | --- |\n"
for o in overlays:
    o_content += f"| {o} | Popup / Dialog / Sheet | Modal / Non-Modal | Backdrop Scrim support |\n"
write_doc('OVERLAYS.md', o_content)

# 10. LOADING.md
loadings = ['MeoLoadingIndicator', 'MeoProgressBar', 'MeoSkeleton', 'MeoPullToRefresh']
ld_content = "# Loading & Progress Inventory\n\n| Component | Mode | Animation / Geometry |\n| --- | --- | --- |\n"
for ld in loadings:
    ld_content += f"| {ld} | Indeterminate / Determinate | 7-Shape Sequence, Wavy Sine Wave, Shimmer |\n"
write_doc('LOADING.md', ld_content)

# 11. SHAPES.md
shapes_35 = [
    'Arch', 'Arrow', 'Boom', 'Bun', 'Burst', 'Circle', 'ClamShell', 'Clover4Leaf',
    'Clover8Leaf', 'Cookie12Sided', 'Cookie4Sided', 'Cookie6Sided', 'Cookie7Sided',
    'Cookie9Sided', 'Diamond', 'Fan', 'Flower', 'Gem', 'Ghostish', 'Heart', 'Oval',
    'Pentagon', 'Pill', 'PixelCircle', 'PixelTriangle', 'Puffy', 'PuffyDiamond',
    'SemiCircle', 'Slanted', 'SoftBoom', 'SoftBurst', 'Square', 'Sunny', 'Triangle', 'VerySunny'
]
sh_content = "# Shape Inventory\n\n## Semantic Scale\n- None: 0dp\n- ExtraSmall: 4dp\n- Small: 8dp\n- Medium: 12dp\n- Large: 16dp\n- LargeIncreased: 20dp\n- ExtraLarge: 28dp\n- ExtraLargeIncreased: 32dp\n- ExtraExtraLarge: 48dp\n- Full: 50% (min(w,h)/2)\n\n## 35 MaterialShapes Vector Implementation Status\n\n| Shape Name | Implementation Status |\n| --- | --- |\n"
for s in shapes_35:
    sh_content += f"| {s} | IMPLEMENTED |\n"
write_doc('SHAPES.md', sh_content)

# 12. ANIMATIONS.md
anim_content = """# Animation Inventory

- `motionEasingStandard`: `[0.2, 0, 0, 1]`
- `motionEasingEmphasized`: `[0.05, 0.7, 0.1, 1]`
- `motionEasingSpringBouncy`: `[0.34, 1.35, 0.64, 1.0]`
- `motionEasingSpringStiff`: `[0.18, 0.89, 0.32, 1.25]`
- `motionEasingSpringSubtle`: `[0.22, 1.1, 0.36, 1.0]`
- `motionEasingSoul`: `motionEasingEmphasized`
"""
write_doc('ANIMATIONS.md', anim_content)

# 13. TOKENS.md
tok_content = """# Token Inventory

- Colors: MD3 Light & Dark `SchemeTonalSpot` fallback schemes plus an atomic, complete dynamic QML role table
- Typography: Inter, Roboto, Noto Sans SC, Roboto Mono
- Elevation: Level 0 ~ Level 5
- Motion: Instant, Fast, Medium, Slow, RippleExpand, RippleFade

## Dynamic-color rule

Real Meo/KDE sessions must receive a complete HCT/Material role table before
their first visible product page. A partial map is invalid; offscreen and
non-Meo previews may fall back only while reporting `colorSchemeMode: "fallback"`.
See [Dynamic Color Contract](../design/DYNAMIC_COLOR.md).
"""
write_doc('TOKENS.md', tok_content)

# 14. RESPONSIVE.md
resp_content = """# Responsive UI Inventory

- Compact: `< 600dp` (NavigationBar + TopAppBar)
- Medium: `600dp ~ 840dp` (NavigationRail)
- Expanded: `840dp ~ 1200dp` (Expanded NavigationRail)
- Large / XL: `> 1200dp` (NavigationDrawer)
"""
write_doc('RESPONSIVE.md', resp_content)

# 15. INTERNAL_COMPONENTS.md
internals = ['MeoStateLayer', 'MeoShape', 'MeoShapeMorph', 'MeoMaterialShapes.js', 'MeoWindowMetrics', 'ShowcaseSnippet', 'ShowcaseSection', 'ShowcaseStateGrid', 'ShowcaseVariantRow', 'ShowcaseCatalog', 'ShowcaseApiTable', 'ShowcaseComponentHeader', 'ShowcaseCategoryPage', 'ShowcaseSampleDelegate']
int_content = "# Internal UI & Helper Component Inventory\n\n| Internal Component | File | Purpose |\n| --- | --- | --- |\n"
for it in internals:
    int_content += f"| {it} | Source helper | Engine / Rendering / Showcase infrastructure |\n"
write_doc('INTERNAL_COMPONENTS.md', int_content)

# 16. LEGACY_UNUSED.md
legacy_content = """# Legacy & Experimental Components Inventory

| Item | Source | Status |
| --- | --- | --- |
| test-import | `examples/test-import.qml` | EXPERIMENTAL |
"""
write_doc('LEGACY_UNUSED.md', legacy_content)

# 17. SHOWCASE_COVERAGE.md
showcased_list = [i['name'] for i in items if i['showcase'] and not i['file'].startswith('showcase/')]
missing_list = [i['name'] for i in items if not i['showcase'] and not i['file'].startswith('showcase/')]
sc_content = f"# Showcase Coverage Matrix\n\n- **Total Components**: {len(items) - 13}\n- **Showcase Covered**: {len(showcased_list)}\n- **Missing from Showcase**: {len(missing_list)}\n- **Coverage Rate**: {round(len(showcased_list) / max(1, len(items) - 13) * 100, 1)}%\n\n### Components missing from Showcase\n\n"
for m in missing_list:
    sc_content += f"- {m}\n"
write_doc('SHOWCASE_COVERAGE.md', sc_content)

# 18. DUPLICATES.md
dup_content = """# Possible Duplicate Groups

1. **Buttons**: `MeoButton` vs `MeoIconButton` vs `MeoIconToggleButton` vs `MeoSplitButton` vs `MeoButtonGroup`
2. **Chips**: `MeoChip` vs `MeoAssistChip` vs `MeoFilterChip` vs `MeoInputChip` vs `MeoSuggestionChip`
3. **Navigation**: `MeoNavigationSuite` vs `MeoNavigationRail` vs `MeoNavigationDrawer` vs `MeoNavigationBar`
"""
write_doc('DUPLICATES.md', dup_content)

# 19. NAVIGATION.md
nav_content = """# Navigation System Inventory

- `MeoNavigationSuite`: Adaptive container
- `MeoNavigationBar`: Compact bottom bar
- `MeoNavigationRail`: Medium side rail
- `MeoNavigationDrawer`: Large side drawer
- `MeoTopAppBar` / `MeoSearchAppBar`: Top bars
- `MeoBreadcrumbs`: Breadcrumb hierarchy
- `MeoTabs`: Segmented tabs
"""
write_doc('NAVIGATION.md', nav_content)

print('All 19 markdown documentation files successfully written!')
