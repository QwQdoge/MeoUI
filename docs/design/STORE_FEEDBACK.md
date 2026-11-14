> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Store Pages, Progress and Error States

How an app-store style product (OmniStore is the reference) presents catalog
pages, long-running work, and failures. These are rules for composing existing
MeoUI components; they do not add new components. Generic controls stay in
MeoUI, store-specific cards stay in the product.

## 1. Store page structure

| Page | Role | Content rule |
| --- | --- | --- |
| Home | Storefront | Featured, recommended, recently updated. Not a package table |
| Explore | Categories and results | Categories come from backend/source data, never a hard-coded list |
| Installed | What is on this machine | Facts read from the package authority; sort by name, filter by source |
| Updates | What can change | Count, per-item version change, "Update all" |
| App details | One item | Adaptive: content + detail pane on wide windows, side sheet or full page on compact |
| Settings | App preferences | `APP_SHELL.md` and `SETTINGS.md` apply; never a primary tab beside the five above |

Primary navigation stays at these five or fewer. Search is a toolbar action, and
task progress opens from a toolbar action into a side sheet; neither takes a
permanent navigation slot.

### Missing data

A store must not invent data. For every field the backend did not supply:

| Field | When absent |
| --- | --- |
| Icon | Neutral tonal placeholder with the first letter of the name |
| Screenshots | Omit the section |
| Rating, review count | Omit; never show 0 stars |
| Size, version, license, developer | Omit the row, or show "Unknown" in a facts list where the row's absence would mislead |
| Description | Omit the section |

### Source and trust

Each item shows its source (Meo repo, Flatpak, AUR, ...). A community or
unreviewed source uses `MeoBadge` with the tertiary tone, text included, never
color alone. A source that is `available: false` is not shown as an enabled
source; it appears under advanced source management with its reason.

## 2. Install button states

One primary action per item, always the same slot and width, so the layout does
not shift between states.

| State | Label (English source) | Control | Notes |
| --- | --- | --- | --- |
| Not installed | Install | `MeoButton` filled | |
| Queued | Queued | Tonal, disabled | Show queue position if known |
| Working | Installing 42% / Installing… | Button hosts a determinate or indeterminate circular `MeoProgressBar` | Cancel as a separate icon button with tooltip, only if the backend can cancel |
| Installed | Open | Tonal | Secondary menu: Remove |
| Update available | Update | Filled | |
| Failed | Retry | Outlined, error-tone message beside it | Keep the reason visible, see section 4 |
| Needs auth | Authorize… | Filled | Opens the system privilege prompt; the app never collects the password |

Label length changes with translation, so reserve the width of the longest label.

## 3. Progress

The general rules are in `PROGRESS.md`; `STATES.md` and `DIALOGS.md` cover errors and
surfaces. This section only adds what is specific to a store.

### Choose the indicator

| Situation | Component |
| --- | --- |
| Work with a known fraction (download bytes, file count) | `MeoProgressBar { indeterminate: false; value: 0..1 }` |
| Work with no known fraction (resolving, waiting for a lock) | `MeoProgressBar { indeterminate: true }` |
| A page or list is loading and the layout is known | `MeoLoadingFeedback { placeholder: <MeoSkeleton layout> }` |
| A page or list is loading and the layout is unknown | `MeoLoadingFeedback` with the default compact indicator |
| Pull to reload a list | `MeoPullToRefresh` |
| Short work inside a button | Circular `MeoProgressBar` in the button, label stays |

Rules:

- `value` is clamped to 0–1. Never drive it past 1 and never reuse one bar for
  two phases; when the phase changes (download → verify → install), show the
  phase name and reset or switch to indeterminate for a phase with no fraction.
- Go indeterminate rather than showing a stalled or guessed percentage. A bar
  that sits at 99% for a minute is a lie.
- A progress value only decreases when work restarts; say so in the text
  ("Retrying…").
- Linear for a row or sheet with width, circular inside a button or a small
  slot. `wavy` and `vibrant` are optional expressive treatments, not meaning.
- Do not show loading feedback for work that finishes within
  `MeoTheme.loadingFeedbackDelay` (120 ms). `MeoLoadingFeedback` applies this
  delay and keeps the indicator at least `loadingFeedbackMinimumVisible`
  (300 ms) to avoid flashing. A skeleton placeholder shows immediately because
  its geometry is known.
- Reduced motion freezes the wave and spinner pose but not the value; text
  progress must still update.

### What a task row shows

Used in the task side sheet and an app's details page:

```text
[icon]  App name                     [Cancel]
        Phase: Downloading · 12.4 MB of 31 MB
        [=========>---------]  40%
```

| Part | Rule |
| --- | --- |
| Phase text | A short verb phrase from the transaction state, localized. Never a raw backend string |
| Numbers | Only when the backend provides them; otherwise omit rather than "0 B of 0 B" |
| Remaining time | Omit unless it is stable; never an estimate that jumps |
| Completion | Replace the bar with a done state and an Open action; remove after the user dismisses or the sheet closes |
| Persistence | Closing the window does not cancel the task. On reopen, restore the row from the service |

### Accessibility of progress

`MeoProgressBar` exposes role `ProgressBar` with a name of "Progress N%" or
"Loading progress". A task row needs a more specific name: set
`Accessible.name` to the item and phase ("Firefox, downloading"), and let the
value come from the bar. Announce completion and failure once through the
snackbar or banner (section 4), not on every percentage change.

## 4. Errors and empty states

### Choose the surface

| Situation | Surface | Component |
| --- | --- | --- |
| An action finished or failed and nothing is blocked | Transient notice | `MeoSnackbar` (4 s, with action) |
| An error affects the current page and stays until fixed | Inline banner at the top of the content | `MeoBanner { tone: "error" }` |
| A single item failed | Message in that item's row or details, beside Retry | text with error tone |
| A choice or confirmation is required | Dialog | `MeoDialog` |
| Page cannot load at all | Full-page empty/error state | Icon, title, one sentence, one action |
| No results, nothing installed, no updates | Empty state | Icon, title, one sentence, optional action |

Do not stack surfaces: one failure produces one message. A snackbar is not the
only place a failure appears if the user must act on it later; also keep it in
the task row or page.

### Writing an error message

An error has four parts; use as many as the user needs and no more:

1. **What failed**, in the user's terms ("Couldn't install Firefox").
2. **Why**, if known and meaningful ("Not enough disk space").
3. **What to do**, as an action ("Free 120 MB, then retry").
4. **Detail**, collapsed, for diagnostics (error code, log link).

Do not show a raw exception, a backend JSON blob, an HTTP status as the only
text, or an error code without words. Never show a made-up reason. When the
reason is unknown, say so: "Something went wrong. Try again, or open the log."

### Standard error states

The code names are the contract; the English wording is the source string and
is localized with `qsTr()`.

| Condition | Surface | Wording | Action |
| --- | --- | --- | --- |
| Offline / source unreachable | Banner, tone `warning` | "You're offline. Showing what was saved." | Retry |
| Search or load failed | Full-page error | "Couldn't load this page." | Retry |
| Install / update / remove failed | Item row + snackbar | "Couldn't install _App_." plus reason | Retry, View log |
| Not enough disk space | Item row | "Not enough space. _App_ needs _X_." | Open Storage (if available) |
| Authorization denied or cancelled | Snackbar | "Installation was cancelled." | Try again |
| Another transaction running | Item row, state Queued | "Waiting for another change to finish." | None |
| Source requires review / untrusted | Dialog | Names the source and the risk | Review, Cancel |
| Source unavailable | Source row, source page | Reason from backend `error` | Settings |
| Backend not running | Full-page error | "The store service isn't running." | Start service |
| Account / AI sign-in needed | Inline, in the AI view only | "Sign in to Meo Account to use AI." | Open Meo Settings |
| AI failure (provider limit, key, model, consent) | Inline, in the AI view only | See "AI error codes" below | Per code |
| Stale data shown | Banner, tone `tonal` | "Last updated _time_." | Refresh |

Account and AI failures stay in the AI view. They must not block browsing,
installing or updating, which do not depend on the account.

### AI error codes

The Meo API reports AI failures by code (`{"error":{"code":"…"}}`); show the wording,
never the code or the provider's text. Codes are from the `meo-api` source
(OmniStore `docs/MEO_API_FACTS.md` §2.3).

| Code | Wording (English source) | Action |
| --- | --- | --- |
| `unauthenticated` | "Sign in to Meo Account to use AI." | Open Meo Settings |
| `insufficient_scope`, `oauth_client_mismatch` | "This app isn't allowed to use AI on your account." | Open Meo Settings |
| `ai_credential_unavailable`, `invalid_credential` | "That AI connection is no longer available." | Choose another |
| `ai_provider_authentication_failed` | "Your AI provider rejected the saved key." | Open Meo Settings |
| `ai_model_or_endpoint_not_found` | "That model isn't available from your provider." | Choose another model |
| `ai_provider_rate_limited` | "Your AI provider is limiting requests. Try again later." | Retry later |
| `ai_provider_unavailable`, `ai_provider_unreachable`, `ai_provider_timeout` | "Your AI provider isn't responding." | Retry |
| `ai_provider_request_cancelled` | none (the user cancelled) | none |
| `consent_invalid_or_used`, `fresh_explicit_consent_required`, `too_many_consent_requests` | "Please confirm again." | Show the consent prompt |
| stream `truncated` event | "The answer was cut off." | Continue |
| stream `error` event | "The answer stopped early." | Retry |
| anything else | "Something went wrong. Try again." | Retry |

`ai_provider_rate_limited` is the user's own provider, not a Meo quota: Meo enforces no
plan quota today (all plans have empty entitlements). Do not show a remaining-quota number
or a plan limit; omit them until the API defines them.

### Banner tones

`MeoBanner.tone` is `tonal`, `warning`, `success` or `error`. Use the tone that
matches severity; the icon and title must say the same thing so color is never
the only signal.

| Tone | Use |
| --- | --- |
| `tonal` | Information, stale data, tips |
| `warning` | Degraded but working (offline, source unavailable) |
| `error` | The thing the user asked for did not happen |
| `success` | A completed action the user should see persisted (rare; prefer a snackbar) |

`MeoBanner` exposes role `AlertMessage`. Its `title` is the accessible name and
`text` the description, so always set a title for an error.

### Empty states

| Case | Title | Action |
| --- | --- | --- |
| No search results | "No results for _query_" | Clear search; suggest checking sources |
| Nothing installed | "Nothing installed yet" | Explore |
| Everything up to date | "You're up to date" | Check again |
| Category empty | "Nothing here yet" | Back |

Empty is not an error: no error tone, no Retry.

## 5. Checklist

- [ ] No fabricated metadata, rating, size, version or quota.
- [ ] Install button keeps a fixed slot across all states.
- [ ] Progress is determinate only when the fraction is known; phases are named.
- [ ] Loading feedback respects the 120 ms delay; skeletons used when layout is known.
- [ ] Every failure shows what failed, why if known, and one action.
- [ ] No raw backend text or error code is the only message.
- [ ] Status is never conveyed by color alone; error and warning have icon and text.
- [ ] Reduced motion tested; text progress still updates.
- [ ] Long labels (translations) do not resize the install button or push layout.
- [ ] Strings and accessible names use `qsTr()`.
- [ ] Showcase has a sample for any visible change.
