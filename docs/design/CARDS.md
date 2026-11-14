> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Cards

A card is one self-contained object the user can read, scan or open: an app, a
song, an article, an account. A card is **not** a generic box for every group of
controls: grouped settings use connected lists (`LISTS.md`), and page sections
use headers and spacing.

## 1. Decide: card, list row or group?

| Content | Use |
| --- | --- |
| A thing with an image, several facts and an action (app, album, post) | `MeoCard` / `MeoMediaCard` |
| A set of homogeneous items to scan quickly (installed apps, files) | `MeoListItem` in a `MeoListView` |
| A set of settings or related rows | `MeoSettingsGroup` / `MeoSegmentedList` |
| One status or note about the page | `MeoBanner` |
| A cluster of controls for one task | A plain section with a header, no card |

If you could replace the card with a row and lose nothing, use a row.

## 2. Types

`MeoCard.type`:

| Type | Surface | Edge | Use |
| --- | --- | --- | --- |
| `elevated` (default, level 1) | `surfaceContainerLow` | soft shadow | The default object card; sits on the page |
| `filled` (level 0) | `surfaceContainerHighest` | none | Cards that must separate from a tinted page without a shadow, dense grids |
| `outlined` (level 0) | page surface | 1dp `outlineVariant` | Cards in a list that already has many surfaces; selectable options |

Rules:

- One type per grid. Do not mix elevated and filled siblings.
- Radius is `MeoTheme.cardRadius` (20dp); `compact: true` caps it at 20dp and
  tightens padding to 12dp (default 16dp).
- Level is fixed by type; do not raise a card's `level` to "highlight" it.
  Use `selected`, a badge or a container color.

## 3. Anatomy

```text
┌──────────────────────────────┐
│ [media / icon]               │  optional, top or side, fixed aspect ratio
│ Overline (label)             │  optional category / source
│ Title                        │  titleMedium, 1–2 lines
│ Supporting text              │  bodyMedium, variant color, ≤3 lines
│ [Badge/Chip]   [Action ▸]    │  at most one primary action
└──────────────────────────────┘
```

| Part | Rule |
| --- | --- |
| Media | Fixed `aspectRatio` (16:9 default in `MeoMediaCard`); never stretched; `MeoSkeleton` while loading |
| Title | Required. One line preferred, two maximum, then elide |
| Supporting text | Optional, ≤3 lines |
| Actions | `actions` in `MeoMediaCard` (text or tonal buttons); the card as a whole may be `interactive` **or** have actions, rarely both. If both, the whole-card action is the primary one |
| Overflow | `showOverflowButton` for secondary actions (share, hide). Not for the main action |
| Badges | `MeoBadge` for count/state; `MeoChip` for source/category |

## 4. Sizes

`MeoMediaCard.cardSize`:

| Size | Width (media on top) | Width (media at side) | Use |
| --- | ---: | ---: | --- |
| `s` | 240dp | 300dp | Dense rows, carousels |
| `m` | 320dp | 380dp | Default |
| `l` | 400dp | 460dp | Hero / featured |

In a responsive grid the column decides the width; set the size only for
horizontally scrolled strips (`MeoCarousel`).

## 5. States

| State | Visual | Property |
| --- | --- | --- |
| Rest | by type | |
| Hover / focus | state layer 8% / 10% (color only, no lift on desktop) | `interactive: true` |
| Pressed | 10% layer, radius shrinks, slight scale | `interactive: true` |
| Selected | `secondaryContainer` tint (+ check or border) | `selected: true` |
| Disabled | content at `disabledContentOpacity`, no state layer | `enabled: false` |
| Loading | Skeleton with the final geometry | `MeoSkeleton { type: "card" }` |
| Error | Keep the card, show an inline message and Retry; do not replace it with a dialog | |

A selected card uses more than color (check mark, border or label) so it is
distinguishable in high contrast.

## 6. Grids and strips

- Grids use `GridLayout` with `columns: metrics.preferredColumns`; cards fill
  the cell width and share a height row by row.
- Keep card heights equal in a row: truncate text, not the image.
- A horizontal strip (`MeoCarousel`, scrolling `ListView`) is for ≤ 10
  suggestions, shows a peek of the next card, and is never the only way to reach
  the content ("See all").
- Gap between cards: `space12`–`space16`.

## 7. Content rules

- A card carries **one** idea. If you need tabs or sections inside, it is a
  page.
- No card inside a card. Use dividers and spacing inside.
- Do not put two filled buttons in a card.
- Missing data is omitted, never invented (no zero stars, no fake size).
- Text is localized and may be 40% longer; test a long translation.
- Accessible name = title + the most important state ("Firefox, installed,
  update available"); the whole interactive card is one accessible element with
  a button role; inner actions remain separately reachable.

## 8. Example

```qml
import QtQuick
import QtQuick.Layouts
import MeoUI

MeoCard {
    id: card
    type: "elevated"
    interactive: true
    onClicked: openDetails(model.id)
    Accessible.name: qsTr("%1, %2").arg(model.name).arg(model.stateText)

    ColumnLayout {
        spacing: MeoTheme.space8
        RowLayout {
            spacing: MeoTheme.space12
            MeoCachedImage { source: model.icon; Layout.preferredWidth: 48 * MeoTheme.globalScale; Layout.preferredHeight: 48 * MeoTheme.globalScale }
            ColumnLayout {
                Layout.fillWidth: true
                MeoText { text: model.name; typeRole: "title"; typeSize: "medium"; elide: Text.ElideRight; Layout.fillWidth: true }
                MeoText { text: model.developer; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; visible: model.developer !== "" }
            }
        }
        MeoText { text: model.summary; typeRole: "body"; typeSize: "medium"; maximumLineCount: 2; wrapMode: Text.Wrap; elide: Text.ElideRight; Layout.fillWidth: true }
        RowLayout {
            MeoChip { type: "assist"; label: model.sourceName; size: "xs" }
            Item { Layout.fillWidth: true }
            MeoButton { type: "tonal"; size: "s"; text: model.actionLabel; onClicked: model.run() }
        }
    }
}
```

The snippet follows the real property names of `MeoCard`, `MeoText`, `MeoChip`
and `MeoButton`; it has not been run in this documentation pass. Run the
Showcase to confirm layout.

## 9. Checklist

- [ ] A row or group would not do the job better.
- [ ] One card type per grid; no nested cards.
- [ ] Media has a fixed aspect ratio and a skeleton.
- [ ] One primary action; overflow for the rest.
- [ ] Selected state is not color-only.
- [ ] Tested with a long translation and 200% text.
