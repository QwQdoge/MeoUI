> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Navigation

How a user moves around a MeoUI app. Window chrome, the overflow menu, Settings
and About are in `APP_SHELL.md`; the sidebar route contract is in
`SETTINGS.md`. This page covers the choices around them.

## 1. Choose the navigation surface

| Situation | Component |
| --- | --- |
| 2–5 top-level destinations on a phone-width window | `MeoNavigationBar` (bottom bar) |
| Same destinations, medium window | `MeoNavigationRail` |
| Same destinations, wide window | `MeoSidebar` (persistent, search, groups) |
| More than 5 destinations | Sidebar groups; bottom bar keeps the first few and an overflow that calls `openSidebar()` |
| Sections inside one destination | `MeoTabs` |
| A filter or sort of the same list | `MeoFilterGroup` / chips, `MeoSegmentedButtons` |
| A hierarchy deeper than two levels | `MeoBreadcrumbs` on wide windows, back arrow on compact |
| Steps of one task | `MeoStepper` |

`MeoAppLayout` and `MeoNavigationSuite` choose the right one of the first three
from the window class; use them instead of switching by hand.

## 2. Destinations

- **Few and stable.** Five or fewer primary destinations. Each is a place, not
  an action: Home, Explore, Installed, Updates are destinations; "Install" is
  not.
- **Same order everywhere.** The bottom bar, rail and sidebar show the same
  items in the same order; the sidebar may add groups.
- **Stable route ids.** Each destination has a unique `route` string. Selection
  is by route identity, never by row index, so filtering or reordering cannot
  select the wrong page.
- **Icon + label.** Bottom bar `labelType: "always"` unless space forces
  `"selected"`. A rail without labels needs tooltips and accessible names.
- **Badges** (`badgeText`, `badgeDot`) mean "needs attention" (Updates: 3). A
  count is real or absent.
- **Settings and About are not primary destinations** (`APP_SHELL.md`).
- Search is a toolbar capability (`MeoSearchBar`, `MeoSearchView`), not a
  permanent destination, unless search is the app's whole purpose.

## 3. Top app bar

| Type | Use |
| --- | --- |
| `small` | Default for pages and list/detail |
| `center` | A single-destination utility or a dialog-like page |
| `medium` / `large` | Landing pages that benefit from a headline; collapse on scroll |
| contextual (`isContextual`, `selectionCount`) | While items are selected: shows count and bulk actions, replaces the normal bar |

Rules: ≤3 trailing actions, the rest in the overflow (`more_vert`, last); the
leading control is exactly one of sidebar toggle, `menu`, or `arrow_back`
(only with a real parent).

## 4. Moving between pages

- A top-level switch replaces the content without a back stack.
- Opening an item pushes a route and shows `arrow_back`. Back returns to the
  same scroll position and selection (`preserveScrollPosition`).
- `MeoPageHost` animates by `direction` (1 forward, −1 back) with a 32dp
  travel; Reduce Motion makes the change instant.
- Deep content never needs more than **two levels** under a destination
  (`PAGE_TYPES.md`); a third level is a transient overlay (task sheet,
  dialog), not another page.
- Keyboard: `Ctrl+,` opens Settings, `Ctrl+?` shortcuts and `F1` help (`APP_SHELL.md`).
  Recommended, not yet enforced by a component: Escape or `Alt+Left` goes back
  where a back arrow is shown, and `Ctrl+F` focuses search where search exists.

## 5. Tabs, segmented buttons and chips

| Control | Switches | Remember on return |
| --- | --- | --- |
| `MeoTabs` | Parallel sections of one page (Overview, Reviews, Changes) | Recommended: restore the selected tab |
| `MeoSegmentedButtons` | 2–5 mutually exclusive views or modes of the same data (List/Grid) | Optional |
| `MeoFilterChip` / `MeoFilterGroup` | Filters that narrow the same list | Optional |

Do not use tabs for navigation between unrelated areas. Do not use more than
six tabs; use `isScrollable` only when localized labels need it.

## 6. Search

- `MeoSearchBar` sits in the top bar (wide) or opens a `MeoSearchView` (compact).
- Show recent and suggested queries (`MeoSearchSuggestions`) before typing.
- Results update while typing with a debounce; show `MeoLoadingFeedback` only
  after the 120 ms delay, and an empty state for no results (`STATES.md`).
- Search the **destination list** (`searchResults`) or the **content**, and say
  which in the placeholder ("Search navigation" vs "Search apps").

## 7. Checklist

- [ ] ≤5 primary destinations, same order on every size.
- [ ] Routes are unique stable strings; selection by route.
- [ ] Back returns to the previous scroll position.
- [ ] Contextual bar appears for multi-select and restores on exit.
- [ ] Keyboard and Escape behavior documented in the page.
- [ ] Every icon-only destination has a tooltip and accessible name.
