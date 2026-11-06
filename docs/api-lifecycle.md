> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# MeoUI API lifecycle

MeoUI is a shared UI library. Public QML may outlive the product surface that first introduced it, so new and old patterns must be classified explicitly instead of being left side-by-side with equal status.

## Status classes

### Current
Recommended for new product work. Current components are documented in Showcase/catalog coverage and follow current Material 3 Expressive guidance.

### Compatibility / deprecated
Kept to avoid breaking existing consumers. Deprecated APIs remain source-compatible for a transition window but must not be selected for new feature work when a Current replacement exists.

### Experimental
Public or semi-public work that is still being validated. Experimental components may change without the same migration guarantees as Current APIs and must be clearly labelled in docs/Showcase.

### Internal
Implementation details not intended as product-facing API.

## Initial classification

### Current
- `MeoDockedToolbar.qml`: current docked action-surface pattern for new work.
- `MeoWidget.qml`: current platform-neutral widget contract.
- `MeoWidgetSheet.qml`: current widget catalogue/browser pattern.
- established Material 3 Expressive controls, semantic tokens, motion and responsive layout primitives that are covered by the current Showcase.

### Deprecated compatibility
- None at present. `MeoBottomAppBar` was removed in the 2026-11 cleanup below.

## Deprecation rules

A deprecation must include:

1. the replacement or explicit statement that no direct replacement exists;
2. a reason based on product/API semantics, not only visual preference;
3. a migration note when properties/signals/behavior differ;
4. Showcase/catalog labelling;
5. no silent removal while known maintained consumers still depend on it.

Deprecated components may receive correctness, accessibility and compatibility fixes. They should not receive new product-specific features that belong in the replacement.

## Experimental rules

Experimental APIs must be clearly marked in their source documentation and Showcase metadata. A feature becomes Current only after its public contract, adaptive behavior, accessibility and validation path are stable enough for maintained consumers.

## Removal rules

Removal requires a dedicated cleanup change that verifies repository consumers and known first-party consumers have migrated. Do not remove a type as incidental work during unrelated UI changes.

## Removal record

### 2026-11 library cleanup

Removed after verifying that no first-party consumer imports them (OmniStore,
MeoSettings, meo-kde, MeoArch-os-workspace, meo-ai; meo-login-manager does not
import MeoUI) and that no other MeoUI component depends on them. Each one was
either deprecated or a thin duplicate of a Current component, so keeping both
made the catalog harder to choose from without adding capability.

| Removed | Use instead | Migration note |
| --- | --- | --- |
| `MeoBottomAppBar` | `MeoDockedToolbar` | Docked action surfaces. If the surface is navigation, use `MeoNavigationBar`. |
| `MeoExpressiveDialog` | `MeoDialog` | It was a wrapper: `content` becomes `supportingContent`; set `preferredDialogWidth: 400 * MeoTheme.globalScale` to keep the old width. |
| `MeoActionSheet` | `MeoMenu` / `MeoContextMenu` (pointer), `MeoBottomSheet` (touch) | Desktop contextual choices are anchored menus; a modal sheet stays available for compact/touch hosts. |
| `MeoSearchAppBar` | `MeoTopAppBar` + `MeoSearchBar`; results in `MeoSearchView` | Same `text`/`placeholder`/`leadingIcon`/`trailingIcon` on `MeoSearchBar`. |
| `MeoSearchHeader` | `MeoTopAppBar` + `MeoSearchBar` | Constrain the bar with `Layout.maximumWidth` instead of `maxSearchWidth`. |
| `MeoSearchFilterBar` | `MeoSearchBar` + `MeoFilterGroup` | `filterModel`/`selectedFilterIndices`/`multiSelectFilters` map to `MeoFilterGroup`'s model and selection. |
| `MeoFeedLayout` | `MeoListView` (or `GridView`) inside `MeoAppLayout` | It only forwarded a model to a list. |
| `MeoDashboardLayout` | `GridLayout` with `MeoWindowMetrics` columns | It only chose a column count. |

## Ownership

Reusable lifecycle/migration rules live here. Plasma/KWin or application-specific migration belongs in the owning repository; MeoUI must not keep a legacy component solely because an owning application refused to migrate without documenting that dependency.
