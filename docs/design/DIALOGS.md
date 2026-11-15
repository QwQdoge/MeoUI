> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Dialogs, Alerts, Confirmations and Sheets

Interrupting the user is expensive. Use the lightest surface that does the job,
and use a dialog only when the user must decide before anything else can
happen.

## 1. Choose the surface

| Situation | Surface | Component | Blocks the page? |
| --- | --- | --- | --- |
| An action finished or failed; nothing else needed | Snackbar | `MeoSnackbar` | No |
| A condition affects the page and stays until fixed | Banner | `MeoBanner` | No |
| A hint that appears on hover/focus | Tooltip | `MeoTooltip`, `MeoRichTooltip` | No |
| A choice among actions for one item | Menu | `MeoMenu`, `MeoContextMenu` | Light (dismiss on outside click) |
| A yes/no decision or a short alert | Dialog | `MeoDialog` | Yes |
| A destructive or session-ending action | Dialog, or hold-to-confirm | `MeoDialog`, `MeoHoldToConfirm` | Yes |
| A short choice, credential or one setting edit inside Settings | Task sheet | `MeoSettingsTaskSheet` | Overlay |
| A longer task related to the current page (filters, a form, details) | Side sheet (wide) / bottom sheet (compact) | `MeoSideSheet`, `MeoBottomSheet`, `MeoStandardBottomSheet` | Optional |
| A task needing the whole screen (compose, multi-field edit, steps) | Full-screen dialog | `MeoFullScreenDialog` | Yes |
| Something requiring progress and recovery | A page (`PAGE_TYPES.md` `task-page`) | | n/a |

If the user can ignore it, it is not a dialog. If it can be undone, prefer a
snackbar with **Undo** over a confirmation.

## 2. `MeoDialog`

`MeoDialog` is the standard modal. Properties: `icon`, `title`, `message`,
`supportingContent` (a `Component` for custom body), `confirmText`,
`cancelText`, `showAcceptButton`, `showRejectButton`, `showDivider`,
`preferredDialogWidth` (default 400dp), `initialFocusTarget`; signals
`confirmed()`, `cancelled()`, `dismissed()`. Both actions are text buttons;
cancel is left of confirm. Radius is `dialogRadius` (28dp), elevation 3.

Anatomy:

```text
        [icon]            optional, centered when there is no body content
        Title             headline, ≤ 2 lines, a question or the action
        Message           what happens, consequences, ≤ 4 lines
        [supportingContent] optional: a list, a field, a checkbox
                [Cancel]  [Confirm]
```

Rules:

- **Title** names the decision ("Remove Firefox?"), not the surface
  ("Confirmation"). No "Are you sure?".
- **Message** states what will happen and what cannot be undone; not what the
  user already knows.
- **Buttons** are verbs. "Remove" / "Cancel", not "OK" / "Yes" / "No". The
  confirm label repeats the title's verb.
- At most two actions. A third choice ("Don't ask again") is a checkbox in
  `supportingContent`, not a button.
- Initial focus: the **safe** action (Cancel) for destructive dialogs; the
  field for input dialogs. Set `initialFocusTarget`.
- `MeoDialog` is modal with `closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside`.
  Escape or a click outside closes it and emits `dismissed()` (not
  `cancelled()`, which is only the Cancel button). The host must treat
  `dismissed()` as a cancel and never as a confirm.
- For an irreversible, in-flight or must-answer dialog set
  `closePolicy: Popup.NoAutoClose` on the dialog so only its buttons close it.
- Recommended: Enter confirms when focus is not in a text area.
- No dialog stacking. A dialog may open a menu, not another dialog; chain the
  decision into one.
- Do not open a dialog at startup or on a background event. Only the user's own
  action opens one; a background condition becomes a banner.
- Content never scrolls inside a dialog more than ~half the window. If it does,
  use a full-screen dialog or a sheet.

## 3. Variants by purpose

### 3.1 Informational alert

One action ("Got it"), `showRejectButton: false`. Use only when the user must
read something before continuing (a security notice). Otherwise a banner.

### 3.2 Confirmation (reversible)

```text
Title:   Replace the current theme?
Message: Your color settings change immediately. You can switch back in Appearance.
Actions: Cancel   Replace
```

### 3.3 Destructive confirmation

`MeoDialog` has no destructive tone property. Compose it:

- `icon: "warning"` (or `delete`),
- title names the object ("Remove Firefox?"),
- message says what is lost and that it cannot be undone,
- confirm label is the specific verb ("Remove"),
- initial focus on Cancel.

```text
Title:   Remove Firefox?
Message: The app and its cached data are removed from this device. Your profile in
         your home folder is kept.
Actions: Cancel   Remove
```

For **bulk** destructive actions say the count ("Remove 12 apps?"). For data
that cannot be recovered, ask the user to type the name or use hold-to-confirm.

### 3.4 Session-ending or high-impact action: hold to confirm

`MeoHoldToConfirm` requires a continuous press (default 5 s,
`holdDuration`). Releasing, losing focus, disabling or Escape cancels. Use for
shutdown, sign-out of all devices, wipe, factory reset. Properties:
`confirmationText`, `holdingText`, `iconName`, `tone` (`error`, `primary`,
`neutral`); signals `confirmed()`, `cancelled()`. It exposes progress to
assistive technology ("Confirmation in N percent"). Always provide a
keyboard-accessible equivalent (hold Space/Enter) and say it in the label.

### 3.5 Input dialog

Put one `MeoTextField` in `supportingContent`; confirm is disabled until the
value is valid; Enter confirms. More than two fields → a sheet or page.

### 3.6 Choice dialog

Radio list in `supportingContent`; confirm applies. For ≤5 options with an
immediate effect, a menu is lighter.

### 3.7 Progress dialog

Avoid. Progress belongs on the page or in a task sheet (`PROGRESS.md`). If an
operation blocks everything, show an indeterminate or determinate bar, a Cancel
button when it can be cancelled, and no Confirm.

### 3.8 Permission and authorization

System authorization (polkit, Meo Account) is shown by the system. The app
explains **why** before triggering it ("Updating system packages needs your
password") and never asks for the password itself.

## 4. Sheets

| Sheet | Use | Notes |
| --- | --- | --- |
| `MeoBottomSheet` (modal) | Touch/compact choices, share, filters | `dismissible`; max height ratio 0.72; max width 640dp |
| `MeoStandardBottomSheet` | A persistent secondary surface under content (player controls) | Does not block the page |
| `MeoSideSheet` (`isOpen`, `title`, `content`, `showCloseButton`) | Task list, filters, details beside the page on wide windows | Not modal; Escape closes |
| `MeoSideSheetModal` | Same on medium windows, with a scrim | |
| `MeoSettingsTaskSheet` | Third-level Settings overlay | Retracts on accept, reject or navigation (`SETTINGS.md`) |
| `MeoFullScreenDialog` | Compose or multi-field edit; `actions` in the header, `bottomActions` at the bottom | Close = discard; confirm if there are edits |

Sheet rules:

- Always a close affordance (button, drag handle, Escape).
- A sheet holds one task; do not push pages inside it.
- On compact windows a side sheet becomes a bottom sheet or a route.

## 5. Snackbars

`MeoSnackbar`: `message`, `actionText`, `icon`, `dismissible`, `duration`
(4000 ms default), signals `actionClicked()`, `dismissed()`.

- One short sentence, ≤2 lines. Past tense for results ("Firefox installed").
- At most one action (Undo, Retry, View). The action is a verb.
- Auto-dismisses; **never** the only place an important failure appears:
  also keep it in the row or page where the user can act later.
- Never stack; a new message replaces the old one (queue if each matters).
- Do not cover the primary action; place above the bottom bar or FAB.
- Do not use a snackbar for errors that need a decision: use a banner or dialog.

## 6. Banners

`MeoBanner`: `title`, `text`, `icon`, `tone` (`tonal`, `warning`, `success`,
`error`), `confirmText`, `cancelText`, `confirmed()`, `cancelled()`. It has
the `AlertMessage` role so assistive technology announces it.

- Sits at the top of the content it describes, pushes content down, never
  overlays.
- Persists until the cause is gone or the user dismisses it; not for
  transient results.
- Title says the situation, text says the effect, one action says the fix.
- At most one banner per page at a time; combine messages, most severe first.
- Error tone is for "the thing you asked for did not happen"; warning for
  "degraded but working".

## 7. Menus and tooltips

- Menus: ≤7 items, grouped with dividers; destructive item last, with the
  error tone icon. Anchor with `openFrom(button)` and `placement: "auto"`
  (`FOR_AGENTS.md`).
- Tooltips (`MeoTooltip`): label only, appear after `tooltipShowDelay`
  (500 ms), never on touch. Rich tooltips (`MeoRichTooltip`) carry a title,
  text and ≤2 actions; they are not for essential information.

## 8. Writing

- Title: verb + object, a question for decisions ("Delete 3 files?").
- Message: consequence first, then recovery ("Items in the trash are deleted
  after 30 days.").
- Confirm: the specific verb. Cancel: "Cancel".
- No technical codes in dialog text; offer "Details" for logs.
- See `WRITING.md` for tone and examples.

## 9. Example

```qml
import QtQuick
import MeoUI

MeoDialog {
    id: removeDialog
    property string appName
    property int appCount: 1

    icon: "warning"
    title: appCount === 1 ? qsTr("Remove %1?").arg(appName)
                          : qsTr("Remove %1 apps?").arg(appCount)
    message: qsTr("The app and its cached data are removed from this device. Your files in your home folder are kept.")
    confirmText: qsTr("Remove")
    cancelText: qsTr("Cancel")
    // Set initialFocusTarget to the safe action when your host exposes it.
    onConfirmed: transactions.submitRemove(appName)
    onDismissed: transactions.cancelPendingRemove(appName)
}
```

Open with `removeDialog.open()` (it is a `Popup`). Property and signal names
are from `MeoDialog`; the snippet has not been run in this pass.

## 10. Known gaps

- `MeoDialog` has no destructive tone or automatic safe-focus: compose as in
  3.3 and set `initialFocusTarget` yourself.
- There is no built-in "type to confirm" dialog; build it with a text field in
  `supportingContent`.
- A global dialog queue does not exist; the host must prevent stacking.

## 11. Checklist

- [ ] The lightest surface that works (snackbar → banner → menu → dialog).
- [ ] Title names the decision; buttons are verbs; max two actions.
- [ ] Destructive: names the object, states loss, safe action focused.
- [ ] No dialog from a background event; no stacking.
- [ ] Escape and focus return to the opener.
- [ ] Reduce Motion respected; text scale 200% fits.
