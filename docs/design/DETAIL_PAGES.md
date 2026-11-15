> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Detail Pages

A detail page shows one object in full: an app, a package, a device, a
document, an account. It answers "what is this, is it right for me, what can I
do with it?". The reference case is a store's app details page; the structure
applies to any entity.

## 1. Page kind

A detail page is a `settings-detail`/`info-page`-style level-2 page
(`PAGE_TYPES.md`): reached from a list or card, has a back arrow, and does not
push another persistent page. Secondary views (all versions, permissions,
licenses) are transient overlays (`MeoSettingsTaskSheet`, side sheet, dialog).

## 2. Anatomy

```text
┌ Top app bar: ← back · title (collapses in) · overflow ┐
├ Header ────────────────────────────────────────────────┤
│ [Icon 96]  Name              [Primary action]          │
│            Developer · Source badge                     │
│            Facts strip: rating | size | version | age   │
├ Tabs or anchors (optional): Overview · Reviews · Changes┤
├ Media: screenshots carousel (if any)                    │
├ Description (collapsible after ~6 lines)                │
├ Details group: version, size, license, source, updated  │
├ Related: "More from developer", "Similar"               │
└─────────────────────────────────────────────────────────┘
```

| Part | Rule |
| --- | --- |
| Header | Identity first: icon (`MeoCachedImage`, 96dp, rounded `shapeExtraLarge`), name (`headlineSmall`/`titleLarge`), one subtitle line (developer, source). The **primary action sits in the header**, not at the bottom |
| Primary action | One `filled` `MeoButton`, state-driven (`STORE_FEEDBACK.md` §2); fixed width; progress shown in it or just under |
| Facts strip | 3–4 short facts, each with a label (`labelSmall`) and value; omit any that are unknown; never "0" or "N/A" as a fact |
| Tabs | Only if there are ≥3 substantial sections; otherwise one scrolling page with `MeoListHeader` sections |
| Media | `MeoCarousel`; keep aspect ratios; skeleton while loading; omit the section if none |
| Description | Plain text, `bodyLarge`, max 680dp wide; "Show more" after ~6 lines; no invented text |
| Details | `MeoSettingsGroup` of read-only rows (`trailingKind: "value"`), selectable text for IDs/hashes |
| Related | Strip of cards (`CARDS.md`), ≤10, "See all" |

## 3. Adaptive layout

| Class | Layout |
| --- | --- |
| compact | Single column; header stacks (icon over text, full-width action); facts scroll horizontally; tabs scrollable |
| medium | Single column up to `maximumContentWidth` (840); header is a row |
| expanded+ | Content column (≤ 840) + supporting pane (`MeoSupportingPaneLayout`): details/related on the side, or `MeoListDetailLayout` when opened from a list |

Rules:

- The same data and the same actions on every size; only arrangement changes.
- On wide windows keep the list visible on the left (`MeoListDetailLayout`) so
  the user can move between items without going back.
- Backend JSON shape does not dictate layout; map it to sections (`NATIVE_MEOUI_FRONTEND.md` in OmniStore).

## 4. States of a detail page

| State | Show |
| --- | --- |
| Loading | Header skeleton with the final geometry (icon, title, button, facts), then sections fill in as they arrive |
| Loaded, some data missing | Omit the missing sections and facts |
| Not found / removed | Full-page state: "This app is no longer available." + Back |
| Failed to load | Full-page error with Retry; keep the back arrow |
| Action in progress | Primary action shows the task (`PROGRESS.md`); the rest stays usable |
| Action failed | Inline message under the header with Retry and "View log" |
| Offline | Show cached data with a `warning` banner; disable network actions with a reason |

The header loads first and is never replaced by a spinner; content below may
fill in progressively.

## 5. Actions

- **Primary**: the one thing most users want here (Install, Open, Update).
- **Secondary**: tonal or text buttons in the header, ≤2 (Share, Website).
- **Overflow** (`more_vert`): everything else (Report, Copy link, Remove
  (destructive last, with confirmation)).
- Destructive actions confirm (`DIALOGS.md`); reversible ones show a snackbar
  with Undo.
- Keyboard: Enter activates the primary action when the header is focused;
  all actions reachable by Tab.

## 6. Trust, source and safety

- Show the **source** (Meo repo, Flatpak, AUR…) next to the name with a
  `MeoChip`/`MeoBadge`; community or unreviewed sources use the tertiary tone
  and words ("Community").
- Never show permissions, ratings, screenshots, sizes or developer data the
  backend did not provide.
- A security-relevant fact (needs review, untrusted source) is a `warning`
  banner under the header, not a footnote.

## 7. Example

```qml
import QtQuick
import QtQuick.Layouts
import MeoUI

MeoPageLayout {
    id: page
    title: details.name

    ColumnLayout {
        spacing: MeoTheme.space16

        RowLayout {
            spacing: MeoTheme.space16
            MeoCachedImage { source: details.icon; Layout.preferredWidth: 96 * MeoTheme.globalScale; Layout.preferredHeight: 96 * MeoTheme.globalScale }
            ColumnLayout {
                Layout.fillWidth: true
                MeoText { text: details.name; typeRole: "title"; typeSize: "big"; Layout.fillWidth: true; elide: Text.ElideRight }
                MeoText { text: details.developer; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; visible: details.developer !== "" }
                MeoChip { type: "assist"; label: details.sourceName; size: "xs" }
            }
            MeoButton { type: "filled"; size: "m"; text: details.actionLabel; loading: details.busy; onClicked: details.run() }
        }

        MeoBanner {
            visible: details.needsReview
            Layout.fillWidth: true
            tone: "warning"; icon: "warning"
            title: qsTr("This source needs review")
            text: qsTr("It is community maintained and not reviewed by MeoArch.")
        }

        MeoListHeader { text: qsTr("About") }
        MeoText { text: details.description; typeRole: "body"; typeSize: "big"; wrapMode: Text.Wrap; Layout.fillWidth: true; Layout.maximumWidth: 680 * MeoTheme.globalScale; visible: details.description !== "" }

        MeoListHeader { text: qsTr("Details") }
        MeoSettingsGroup { /* MeoSettingsRow items with trailingKind: "value" */ }
    }
}
```

Names come from `MeoPageLayout`, `MeoCachedImage`, `MeoText`, `MeoChip`,
`MeoButton`, `MeoBanner`, `MeoListHeader`, `MeoSettingsGroup`; the snippet has
not been run in this pass, and `details` is the host's data object.

## 8. Checklist

- [ ] Header with identity + primary action loads first, never a spinner.
- [ ] Unknown facts omitted; no invented media or ratings.
- [ ] One primary action; destructive actions confirm.
- [ ] Adaptive: list+detail on wide, route on compact.
- [ ] Source and trust visible; risky state is a banner.
- [ ] Back keeps list position; Escape/back are consistent.
- [ ] Verified compact, medium, expanded; 200% text.
