> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Empty, Error and Status States

Every list, page and task has more than a happy path. Design these states
first; they are what users meet most when something is wrong or new.

## 1. The state matrix

| State | Meaning | Show |
| --- | --- | --- |
| Loading | First load, layout known/unknown | Skeleton / indicator (`PROGRESS.md`) |
| Empty (first use) | Nothing yet, user can add | `MeoEmptyState` with an action |
| Empty (filtered) | Nothing matches | `MeoEmptyState`, "Clear filters" |
| Empty (done) | Nothing left to do | `MeoEmptyState`, positive tone, no action |
| Partial | Some data failed | Content + inline error on the failed part |
| Stale | Showing saved data | Content + `tonal` banner "Last updated …" |
| Offline | No network | Content (cached) + `warning` banner |
| Error (recoverable) | Failed, retry may work | Inline message + Retry |
| Error (blocking) | Nothing can be shown | Full-page error state + action |
| No access | Needs sign-in / permission | Explain + the one action that fixes it |
| Unavailable | Not supported here | Explain why; hide the control, don't disable it silently |

Never leave a blank area, an endless spinner or a raw error.

## 2. Empty states

`MeoEmptyState`: `icon`, `title`, `description`, `actionText`, `customContent`,
signal `actionClicked()`. It centers a 64dp icon, a headline and body text in a
column up to 400dp wide.

| Case | Title | Description | Action |
| --- | --- | --- | --- |
| First use | "No apps installed yet" | "Browse Explore to find software." | "Explore" |
| No results | "No results for “firefox”" | "Check the spelling, or try another source." | "Clear search" |
| Filtered | "Nothing matches these filters" | | "Clear filters" |
| All done | "You're up to date" | "Last checked 2 minutes ago." | "Check again" |
| Category empty | "Nothing here yet" | | "Back" |

Rules:

- Say **what** is empty and **what to do**; one action only.
- Empty is not an error: no error color, no Retry.
- Icon is a quiet, generic symbol; never an illustration that implies content.
- Keep the page's header and search; replace only the content area.
- A positive "all done" state has no action unless re-checking is meaningful.

## 3. Errors

### 3.1 Choose the surface

| Situation | Surface |
| --- | --- |
| Action finished/failed, nothing blocked | `MeoSnackbar` (with action) |
| Affects the page, stays until fixed | `MeoBanner { tone: "error" }` |
| One item failed | Message in that row/card with Retry |
| A field is invalid | Field error (`FORMS.md`) |
| A decision is needed | `MeoDialog` (`DIALOGS.md`) |
| Page cannot load | Full-page error (below) |

One failure → one message. Do not stack a banner, a snackbar and a dialog.

### 3.2 Message structure

1. **What failed**, in the user's terms ("Couldn't install Firefox").
2. **Why**, only if known and useful ("Not enough disk space").
3. **What to do**, as an action ("Free 120 MB, then try again").
4. **Details** collapsed (code, log link) for support.

Never: raw exception, backend JSON, HTTP status alone, or a code without words.
When the cause is unknown say so: "Something went wrong. Try again, or open
the log."

### 3.3 Full-page error

Use `MeoEmptyState` with an error icon, a title ("Couldn't load Explore"), one
sentence, and **Retry**; add "Open log" for developer or support audiences. Keep
navigation and the top bar so the user can leave.

### 3.4 Inline error with retry

```qml
RowLayout {
    visible: item.failed
    spacing: MeoTheme.space8
    MeoIcon { icon: "error"; color: MeoTheme.error }
    MeoText { text: item.errorText; color: MeoTheme.error; Layout.fillWidth: true; wrapMode: Text.Wrap }
    MeoButton { type: "text"; size: "s"; text: qsTr("Retry"); onClicked: item.retry() }
}
```

## 4. Banners

`MeoBanner.tone`:

| Tone | Container | Use |
| --- | --- | --- |
| `tonal` | secondary-ish | Info, stale data, tips |
| `warning` | `warningContainer` | Degraded but working |
| `error` | `errorContainer` | The requested thing did not happen |
| `success` | `successContainer` | Rare; prefer a snackbar |

A banner has a title (the accessible name), text, an icon and optionally
`confirmText`/`cancelText`. The icon and title carry the meaning, color is
reinforcement. At most one banner per page.

## 5. Offline and stale data

- Cache the last good data and show it; mark it ("Last updated 10:42").
- Disable only actions that need the network, with a reason in the tooltip or
  supporting text, not silently.
- Return to normal automatically when the connection returns; update in place.
- Don't show a modal "No connection".

## 6. Permission, account and quota

- **Not signed in** (feature needs an account): inline in that feature only;
  never block unrelated features ("Sign in to Meo Account to use AI.", action
  "Open Meo Settings").
- **Not allowed** (policy): say who controls it; hide, not disable, controls
  the user can never use.
- **Quota or plan limit**: only if the service defines it. Do not show a limit
  or a remaining count the API does not provide (`MEO_API_FACTS.md` in OmniStore
  documents that Meo defines none today).

## 7. Status indicators

For persistent status (connected, updating, source trusted):

| Need | Use |
| --- | --- |
| Count or unread | `MeoBadge` (`maxCount` 99, `isDot`) |
| A category or state label | `MeoChip` / `MeoAssistChip` |
| A system-like status line | `MeoStatusStrip` |
| A row with status | `MeoSettingsRow { trailingKind: "status"; statusTone }` |

Status text + icon + tone together; a colored dot alone is never enough.

## 8. Writing states

- Sentence case, no exclamation marks, no blame ("Couldn't…", not "You
  failed to…").
- Specific nouns ("Firefox", "the source"), not "the item".
- One sentence for the cause, one for the fix.
- Keep error codes out of the headline; put them under Details.
- Examples in `WRITING.md`.

## 9. Checklist

- [ ] Every list/page defines loading, empty, error, offline.
- [ ] Empty states have one action or none; never an error color.
- [ ] Errors use the right surface; no stacking.
- [ ] Nothing renders a raw exception or JSON.
- [ ] State is not conveyed by color alone.
- [ ] Retry actually retries and shows progress.
