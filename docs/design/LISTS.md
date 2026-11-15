> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Lists, Rows and Sections

Lists are the workhorse of MeoUI pages. This page covers content lists (files,
apps, messages); settings rows follow `SETTINGS.md` and share the same
connected-surface engine.

## 1. Components

| Component | Role |
| --- | --- |
| `MeoListView` | The scrolling container (transitions, scroll position) |
| `MeoListItem` | A content row (headline, supporting text, leading/trailing parts) |
| `MeoSegmentedList` / `MeoGroupedList` | Connected rounded group of rows |
| `MeoSettingsRow` + `MeoSettingsGroup` | Settings rows with a typed trailing control |
| `MeoListHeader` | Section header above a group |
| `MeoDivider` | Quiet separator when a connected surface is not used |
| `MeoSwipeToDismiss` | Swipe actions on touch |
| `MeoDataTable` | Dense, sortable tabular data on wide windows |

## 2. Anatomy of a row

```text
[leading]  Overline                         [trailing]
           Headline
           Supporting text (1–3 lines)
```

`MeoListItem` properties: `overline`, `headline`, `supportingText`,
`supportingTextLines` (1, 2 or 3), `leadingIcon`, `leadingImage`
(`leadingImageVariant` `square` or `circle`, `leadingImageSize` 40 / 56 / 64),
`leadingComponent`, `trailingComponent`, `badgeText`, `actions`, `selected`,
`interactive`.

| Part | Rule |
| --- | --- |
| Leading | One of: icon, avatar (40), small image (56), large image (64). Same kind in a list |
| Headline | The identity of the row; one line, elided |
| Supporting | The one fact that helps decide (version, size, date). ≤3 lines |
| Trailing | One control or one status: a value, a switch, a chevron, an action. Not several |
| Badge | `badgeText` for count/new; a dot for unread |

Height follows content: 56dp one line, 72dp two lines, 88dp three lines;
`isDense` gives 48 / 64 / 72dp. A large leading image raises the height.

## 3. Choose the row style

| Need | Property |
| --- | --- |
| Separate rows with lines on a flat page | `showDivider: true`, `dividerInset` to align with text |
| Rounded connected group (default for ≤ ~15 rows) | `isSegmented: true`, set `roundingStrategy` (`top`, `middle`, `bottom`, `all`) per position, or use `MeoSegmentedList` |
| Dense list (file manager, logs) | `isDense: true` |
| Emphasize a key row | `isEmphasized: true` (bold) |
| Selected row | `selected: true`; vibrant selection with `vibrant: true` |

Do not mix segmented rows and divider rows in one list. A long, virtualized list
(hundreds of rows) uses divider rows; connected groups are for short sets.

## 4. Behavior

- A row is **either** interactive as a whole **or** contains controls. If it has a
  trailing switch, the whole row toggles it (as `MeoSettingsRow` does); if it
  has a trailing action button, the row body opens details.
- Selection: tap/click selects; in multi-select mode the leading element
  becomes a checkbox and the top app bar turns contextual (`NAVIGATION.md`).
- Swipe actions are a shortcut for touch; the same actions exist in a
  context menu (`MeoContextMenu`) and the row's detail.
- Reordering and removal animate with `MeoListTransitions`; Reduce Motion
  makes them instant.
- Right-click / long-press opens `MeoContextMenu` with the row's actions.

## 5. Sections and headers

- `MeoListHeader { text: ... }` names a group; `type: "emphasized"` for the
  first section on a page.
- A header describes **what** the rows are ("Updates (3)"), not what to do.
- A section with more rows than fit shows a "See all" text button in the header
  row, not a row at the end.
- Empty section: hide the header unless the empty state needs it
  (`STATES.md`).

## 6. Tables

Use `MeoDataTable` when the user compares columns or sorts (package list with
name, version, size, source). On compact windows a table becomes a list with
the most important column as the headline.

- Header row sticky; click sorts; arrow icon shows direction.
- Right-align numbers, left-align text.
- Never let the table scroll horizontally on expanded windows; hide the least
  important columns first.

## 7. Long lists and loading

- Virtualize: use `ListView` models; never create a row per item in a `Column`.
- First load: `MeoSkeleton` rows with the final row height
  (`MeoLoadingFeedback { placeholder }`).
- Loading more: a single row at the end with `MeoLoadingIndicator`, not a full
  skeleton.
- Refresh: keep old rows until new data arrives; update in place.
- Empty: `MeoEmptyState`. Error: inline message with Retry (`STATES.md`).

## 8. Example

```qml
import QtQuick
import MeoUI

MeoListView {
    id: updates
    model: updatesModel
    delegate: MeoListItem {
        required property var model
        width: ListView.view.width
        headline: model.name
        supportingText: qsTr("%1 → %2 · %3").arg(model.current).arg(model.next).arg(model.size)
        leadingImage: model.icon
        leadingImageSize: 40
        leadingImageVariant: "circle"
        badgeText: model.security ? qsTr("Security") : ""
        showDivider: true
        onClicked: openDetails(model.id)
    }
}
```

Property names come from `MeoListItem` and `MeoListView`; the snippet has not
been run in this pass.

## 9. Checklist

- [ ] Rows have one leading kind and ≤1 trailing element.
- [ ] Whole-row action and inner controls do not conflict.
- [ ] Virtualized; skeleton rows match final height.
- [ ] Headers describe content; "See all" in the header.
- [ ] Context menu and keyboard (Enter, Space, Delete) equal to swipe.
- [ ] Text scale 200% and long translations tested.
