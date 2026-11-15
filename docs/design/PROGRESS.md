> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Progress and Loading

How MeoUI shows that something is happening. This is the canonical page;
`STORE_FEEDBACK.md` applies it to a store.

## 1. Three questions

1. **Will the user wait, or can they leave?** Waiting: show progress where the
   result will appear. Can leave: use a task row + a completion notice.
2. **Do you know how far along it is?** Yes → determinate. No → indeterminate.
3. **Do you know the shape of the result?** Yes → skeleton. No → indicator.

## 2. Choose the indicator

| Situation | Component |
| --- | --- |
| Known fraction (bytes, items) | `MeoProgressBar` determinate (`indeterminate: false`, `value` 0–1) |
| Unknown fraction (resolving, waiting for a lock) | `MeoProgressBar { indeterminate: true }` |
| Content area loading, layout known | `MeoLoadingFeedback { placeholder }` + `MeoSkeleton` |
| Content area loading, layout unknown | `MeoLoadingFeedback` (default 48dp `MeoLoadingIndicator`) |
| A page route loading | `MeoPageHost { loadingPlaceholder }` |
| An action in a button | `MeoButton { loading: true }` |
| Pull to reload | `MeoPullToRefresh` |
| Stepwise task | `MeoStepper` + a bar for the current step |
| Streaming text | Append text as it arrives; no bar |

## 3. `MeoProgressBar`

| Property | Meaning |
| --- | --- |
| `value` | 0–1 (clamped) |
| `indeterminate` | unknown amount |
| `type` | `linear` or `circular` |
| `linearStyle` | `standard` or `pill` |
| `isThick`, `showTrack` | geometry |
| `wavy` | expressive wavy active segment |
| `vibrant` | tertiary container tones |
| `leadingIcon` | icon at the start of a pill bar |
| `activeColor`, `trackColor` | override only with role tokens |

Role and name for assistive technology: `ProgressBar`, "Progress N%" or
"Loading progress". Give the host item a more specific `Accessible.name`.

Rules:

- **Linear** when there is width (row, sheet, page top); **circular** in a
  button or a small slot.
- **Top-of-page** thin linear bar for page-level loading; **inline** bar for an
  item's own task.
- Never move backwards on the same phase. Restarting work resets and says so
  ("Retrying…").
- Do not show a percentage you made up. If you only know "between phases", go
  indeterminate for the unknown phase.
- Do not stall at 100%: show "Finishing…" (indeterminate) while verifying.
- Reduce Motion freezes wave and spinner pose but the value still updates, so
  show progress as text too.
- Keep colors default (`primary` on `secondaryContainer`); error tone only on
  failure, replacing the bar.

## 4. Skeletons and delayed feedback

`MeoLoadingFeedback`:

| Property | Default | Meaning |
| --- | --- | --- |
| `active` | false | set in the same turn as the user's action |
| `placeholder` | none | a `Component` with the final geometry; shows with `delay: 0` |
| `delay` | 120 ms (`loadingFeedbackDelay`); 0 with a placeholder | anti-flash |
| `minimumVisibleDuration` | 300 ms | once shown, stays at least this long |
| `accessibleName` | "Loading" | announced |

Rules:

- Set `active` in the same input turn as the press; the press ripple is never
  delayed by backend work.
- If the result arrives inside 120 ms, show nothing.
- A placeholder has the same size and position as the final content so nothing
  jumps. `MeoSkeleton` types: `text`, `avatar`, `card`, `pill`, `block`;
  `animationStyle` `breathing`, `shimmer`, `none`.
- A skeleton may not appear longer than ~10 s without a fallback: after that
  show a message ("This is taking longer than expected") with Retry/Cancel.
- Never replace already shown content with a skeleton on refresh; keep the old
  content and update.

## 5. Long-running work

A task that outlives the page (install, download, backup, sync):

- It belongs to a **service**, not the window (`NATIVE_MEOUI_FRONTEND.md` in
  OmniStore). Closing the window does not cancel it; reopening restores it.
- Show it in a task list (side sheet from a toolbar action) with one row per
  task (below). The toolbar action carries a badge with the active count.
- Notify **once** on completion or failure (system notification and/or snackbar),
  not on each percent.
- Cancel is available only if the backend can cancel; otherwise do not render a
  disabled Cancel, say "Can't be cancelled now".
- Queue: tasks wait in order; show "Queued" and position.

Task row:

```text
[icon]  Name                         [Cancel]
        Phase · detail
        [========>---------]  40%
```

| Part | Rule |
| --- | --- |
| Phase | Short localized verb phrase from the service state ("Downloading", "Verifying", "Installing"); never a raw backend string |
| Detail | Numbers only when known ("12.4 of 31 MB"); omit otherwise |
| Time left | Omit unless stable; never an estimate that jumps |
| Done | Replace the bar with a done icon and **Open**; remove on dismiss |
| Failed | Error tone, one-sentence reason, **Retry**, **View log** (`STATES.md`) |

## 6. Timing guide

| Duration | Feedback |
| --- | --- |
| < 120 ms | None |
| 120 ms – 1 s | Compact indicator or in-button loading |
| 1 – 10 s | Skeleton/indicator + (if known) bar |
| > 10 s | Determinate bar if possible, phase text, Cancel if possible |
| Minutes | Task row + completion notification; user may leave |

## 7. Accessibility

- Every indicator has a name; changes of phase are announced, percent changes
  are not.
- Respect Reduce Motion: no spinning or travelling; show static state + text.
- Do not rely on color; the bar has a track and the text.
- Provide the same information in text for screen readers ("Downloading,
  40 percent, 12.4 of 31 MB").

## 8. Examples

Determinate task:

```qml
MeoProgressBar {
    Layout.fillWidth: true
    indeterminate: task.fraction < 0
    value: Math.max(0, task.fraction)
    Accessible.name: qsTr("%1, %2").arg(task.name).arg(task.phaseText)
}
```

Page loading with a skeleton:

```qml
MeoLoadingFeedback {
    anchors.fill: parent
    active: model.loading
    placeholder: Component {
        Column {
            spacing: MeoTheme.space12
            MeoSkeleton { type: "block"; width: parent.width; height: 160 * MeoTheme.globalScale }
            MeoSkeleton { type: "text"; width: parent.width * 0.6 }
            MeoSkeleton { type: "text"; width: parent.width * 0.9 }
        }
    }
}
```

Names come from the component sources; the snippets have not been run in this
pass.

## 9. Checklist

- [ ] No indicator for work under 120 ms; no flashing.
- [ ] Determinate only when the fraction is real; phase named.
- [ ] Skeleton matches final geometry; old content kept on refresh.
- [ ] Long tasks survive closing the window; one completion notice.
- [ ] Reduce Motion and screen reader text verified.
