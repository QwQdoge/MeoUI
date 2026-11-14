> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Layout and Adaptive Behavior

Every MeoUI page adapts to the window it is given. Layout decisions are made
from the **window size class**, never from the platform, the device name or a
literal pixel width.

## 1. Window size classes

`MeoWindowMetrics` (width) reads `MeoTheme.windowWidthSizeClass()`. Widths are
in dp before `globalScale`.

| Class | Width | Page margin | Navigation | Panes | Typical |
| --- | --- | ---: | --- | --- | --- |
| `compact` | < 600 | 16 | bottom bar (`MeoNavigationBar`) | one | phone, narrow window |
| `medium` | 600–839 | 24 | rail (`MeoNavigationRail`) | one, overlay secondary | small tablet, half window |
| `expanded` | 840–1199 | 24 | sidebar | two | laptop window |
| `large` | 1200–1599 | 32 | sidebar | two or three | desktop |
| `extraLarge` | ≥ 1600 | 40 | sidebar | two or three | wide monitor |

Height classes: `compact` < 480, `medium` < 900, `expanded` ≥ 900. A short
window (landscape phone, split screen) hides secondary chrome first: large
top bars collapse, hero areas shrink, bottom bars may become a rail.

Derived values from `MeoWindowMetrics` (instantiate it with `availableWidth` /
`availableHeight`):

| Property | Meaning |
| --- | --- |
| `pageMargin` | outer margin |
| `sectionSpacing` | gap between sections (16 compact, 24 otherwise) |
| `controlSpacing` | gap between controls (8 compact, 12 otherwise) |
| `maximumContentWidth` | readable width cap: 840 medium, 1040 expanded, 1200 large, 1440 extraLarge |
| `navigationMode` | `bottomBar`, `rail` or `sidebar` |
| `usesOverlayPane` / `supportsTwoPane` | whether a second pane overlays or sits beside |
| `preferredColumns` | card grid columns (1 compact, up to 2 medium, up to `maxColumns` otherwise; `minimumColumnWidth` 280) |

Do not test `width > 800`. Test `metrics.isCompactWidth`,
`metrics.supportsTwoPane`, `metrics.preferredColumns`.

## 2. Page skeletons

| Pattern | Use | Adaptive behavior |
| --- | --- | --- |
| `MeoAppLayout` | An app with a few top-level destinations | Bottom bar / rail / sidebar from the class; Settings and About appended as routes (`APP_SHELL.md`) |
| `MeoScaffold` | A custom page host that needs explicit slots (`topBar`, `navigationBar`, `navigationRail`, `sideSheet`, `fab`, `snackbar`) | Same navigation switch; you supply the parts |
| `MeoPageLayout` | A scrolling content page with a title | Applies `pageMargin`, section spacing, a single readable column; breakpoints `compactWidth` 680 / `mediumWidth` 920 / `expandedWidth` 1180 |
| `MeoListDetailLayout` | A list and the detail of the selected item | Two panes at `supportsTwoPane`; otherwise detail replaces the list (`showDetail`) |
| `MeoSupportingPaneLayout` | Main content plus a secondary pane (filters, inspector, task sheet) | `adaptiveMode`: side-by-side when expanded, stacked when compact |
| `MeoSettingsLayout` | Settings with many categories | Category sidebar + detail; see `SETTINGS.md` |

Choose by task, not by looks:

| Task | Pattern |
| --- | --- |
| Browse a catalog, open an item | `MeoListDetailLayout` (wide) / `MeoPageHost` route (compact) |
| Read or edit one long page | `MeoPageLayout` |
| Show something about the current page without leaving it | `MeoSupportingPaneLayout`, `MeoSideSheet` |
| A short choice or confirmation | Dialog (`DIALOGS.md`), never a pane |

## 3. Content width and columns

- Reading and form pages: one column, centered, up to
  `maximumContentWidth` (and prose up to 560–680dp). Do not stretch a form
  across a 1600dp window.
- Grids of cards: `GridLayout` with `columns: metrics.preferredColumns`. Columns
  are equal width; a card never has a fixed pixel width inside a grid.
- Lists are full width of their column; a row is never narrower than its
  content needs.
- Settings content ≈ 720–760dp wide (`SETTINGS.md`).

## 4. Regions of a page

```text
┌───────────────────────────────────────────────┐
│ Top app bar  (title, ≤3 actions, overflow)     │  chrome
├────────┬──────────────────────────────┬───────┤
│ Nav    │ Header (title, subtitle,     │ Side  │
│ rail / │ primary action, tabs/chips)  │ sheet │
│ sidebar├──────────────────────────────┤ (opt) │
│        │ Content sections             │       │
│        │  section header              │       │
│        │  group / grid / list         │       │
├────────┴──────────────────────────────┴───────┤
│ Bottom bar (compact) · Snackbar above it       │
└───────────────────────────────────────────────┘
```

Rules:

- The top app bar is chrome, not content. Page title lives in it (or the large
  bar's headline), not repeated in the body.
- A **section** has a header (`MeoListHeader`), then one group, grid or list.
  Sections are separated by `sectionSpacing`, not by dividers.
- A sticky action (Install, Save) lives in the header or a docked toolbar
  (`MeoDockedToolbar`), not floating over the text.
- A FAB is for the single most common creation action of the page. A store has
  none.
- Snackbars appear above the bottom bar, never over a primary action.

## 5. Scrolling

- One scroll region per pane. Never nest vertical scroll areas.
- Top bars may collapse on scroll (`scrollProgress`); a `large` bar collapses
  to `small`.
- A long list uses `MeoListView` (keeps `useMeoTransitions`, scroll position
  with `preserveScrollPosition`).
- Pull to refresh (`MeoPullToRefresh`) is for touch lists backed by remote data.
  On desktop provide a Refresh action as well.

## 6. Compact specifics

- Bottom bar holds up to 5 destinations (`compactNavigationLimit`); more go to
  the sidebar modal via the overflow (`openSidebar()`).
- Dialogs become bottom sheets or full-screen dialogs when content is tall.
- A two-pane page becomes list → detail routes with a back arrow
  (`MeoPageHost` transitions).
- Hover-only affordances do not exist; every action reachable by touch.

## 7. Checklist

- [ ] Uses `MeoWindowMetrics` for margins, spacing and columns.
- [ ] Verified at compact (360), medium (700), expanded (1000), large (1400).
- [ ] No fixed widths on cards in a grid; no horizontal page scroll.
- [ ] Content capped at `maximumContentWidth`.
- [ ] One scroll region per pane.
- [ ] Navigation switches by class, not by platform.
- [ ] Safe-area margins honoured (`SafeArea.margins`, `safeAreaTop/Bottom/Left/Right` in `MeoAppLayout`).
