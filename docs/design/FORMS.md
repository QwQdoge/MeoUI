> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Buttons, Inputs and Forms

## 1. Button hierarchy

`MeoButton.type`: `filled`, `tonal`, `outlined`, `elevated`, `text`. Sizes `xs`,
`s`, `m`, `l`, `xl`. Shape `round` (default) or `square`.

| Type | Emphasis | Use |
| --- | --- | --- |
| `filled` | highest | The single primary action of a page or dialog (Install, Save, Sign in) |
| `tonal` | high | Important secondary action (Update all, Open) |
| `elevated` | medium | Needs separation on a busy surface; avoid on a tinted page |
| `outlined` | medium | Equal alternative (Cancel in a form, Learn more) |
| `text` | lowest | Tertiary, inline, dialog actions (`MeoDialog` uses text buttons) |

Rules:

- **One filled button per view.** Two filled buttons compete; make one tonal.
- Order of actions in a row, left to right: dismissive (Cancel) then
  affirmative (Save). In a dialog the confirm action is on the right
  (`MeoDialog` already does this).
- Never disable the primary action to hide an error: show what is missing
  (inline field error) and keep the button enabled when the form can be
  submitted to show errors. Disable only while an operation is running.
- Loading: `loading: true` shows an in-button indicator and keeps the label and
  width; the button ignores clicks.
- Destructive actions use the same button type, the label names the effect
  ("Remove Firefox"), and they go through a confirmation (`DIALOGS.md`). There
  is no red filled button; use the error tone on the icon and message.
- Icon + label is preferred; icon-only buttons (`MeoIconButton`) need
  `toolTipText`.
- A `MeoSplitButton` combines a default action with alternatives (Install ▾
  with "Install without updates"). Do not use it when there is no clear
  default.
- Toggle buttons (`toggle: true`, `selected`) and `MeoIconToggleButton` show
  a state, not an action; label stays constant.

Sizing: use `m` in dialogs and forms, `s` in rows and cards, `l`/`xl` for
hero actions. Hit area ≥ `minimumTargetSize`.

## 2. Text fields

`MeoTextField`: `type` `filled` (default on tinted pages) or `outlined`;
`label`, `placeholder`, `supportingText`/`helperText`, `isError` +
`errorText`, `showClearButton`, `leadingIcon`, `trailingIcon`
(`trailingIconClicked`), `prefixText`, `suffixText`, `maxLength` +
`showCounter`, `isPassword` with `passwordVisible`.

Rules:

- A visible `label` always. A placeholder is an example, not a label.
- Helper text explains the format ("8–64 characters"); an error replaces it
  with what to fix ("Use at least 8 characters").
- Validate on blur and on submit, not on every keystroke, except for live
  constraints (counter, password strength).
- Keep the user's input on error. Never clear a field to show an error.
- `MeoTextArea` for multi-line, with a counter when limited.
- Number input: `MeoSpinBox`. Dates: `MeoDateInput`/`MeoDatePicker`; time:
  `MeoTimeInput`/`MeoTimePicker`; color: `MeoColorField`; choice from a long
  list: `MeoExposedDropdown`.
- Secrets use `isPassword`; never log or persist them (keyring only).

## 3. Choosing a selection control

| Choice | Control |
| --- | --- |
| On/off that takes effect immediately | `MeoSwitch` |
| On/off that is applied on Save, or one of several independent options | `MeoCheckbox` (supports `indeterminate` for "some") |
| One of 2–5 visible options | `MeoRadioButton` group or `MeoSegmentedButtons` |
| One of many | `MeoExposedDropdown` |
| A number in a range | `MeoSlider` (continuous), `MeoSteppedSlider` (steps), `MeoRangeSlider` |
| A rating the user gives | `MeoRatingBar` |
| Tags the user adds | input chips (`MeoInputChip`) |
| Filters | `MeoFilterChip` in a `MeoFilterGroup` |

Rules:

- A switch changes state **now**. If the user must press Save, use a checkbox.
- The label describes the **on** state ("Notify me about updates"), never
  "Enable/Disable …" ("Disable notifications" with a switch on is confusing).
- Toggle-like controls may preview the requested state immediately, but the
  backend stays authoritative and the control rolls back if it fails
  (`SETTINGS.md`).
- Group related options under a header; do not use more than 7 checkboxes in a
  row without grouping.

## 4. Form layout

- One column, labels above or inside fields, fields fill the column width up
  to `maximumContentWidth` (forms ≈ 560dp).
- Order by the user's thinking, required first. Mark optional fields "Optional"
  rather than starring required ones.
- Group with headers; separate groups by `sectionSpacing`.
- Primary and cancel actions at the bottom of the form (or in a docked toolbar
  for long forms), right-aligned on wide windows.
- Multi-step tasks use `MeoStepper`; each step validates before Next, Back
  never loses input.

## 5. Autosave versus explicit save

| Case | Behavior |
| --- | --- |
| Preferences (`SETTINGS.md`) | Apply immediately, no Save/Apply buttons |
| Creating or editing a record | Explicit Save; Cancel with a discard confirmation if edited |
| Privileged, destructive or restart-needed change | Explicit confirmation (`DIALOGS.md`) |
| Long form | Save draft locally; warn before leaving with unsaved changes |

## 6. Validation and errors

- Validate the data, not the user: "Enter a valid email address", not
  "Invalid input".
- Field error: red outline + error icon + text under the field; the form-level
  summary only for errors not tied to a field.
- Focus moves to the first invalid field on submit.
- Server failures keep the form filled and show a banner at the top of the form
  (`STATES.md`).

## 7. Example

```qml
import QtQuick
import QtQuick.Layouts
import MeoUI

ColumnLayout {
    spacing: MeoTheme.space16
    MeoListHeader { text: qsTr("Custom repository") }
    MeoTextField {
        id: name
        Layout.fillWidth: true
        label: qsTr("Name")
        isError: submitted && text === ""
        errorText: qsTr("Enter a name")
    }
    MeoTextField {
        id: url
        Layout.fillWidth: true
        label: qsTr("Address")
        placeholder: "https://example.org/repo"
        supportingText: qsTr("HTTPS only")
        isError: submitted && !valid(url.text)
        errorText: qsTr("Enter a valid HTTPS address")
        showClearButton: true
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight
        spacing: MeoTheme.space8
        MeoButton { type: "outlined"; text: qsTr("Cancel"); onClicked: close() }
        MeoButton { type: "filled"; text: qsTr("Add"); loading: adding; onClicked: submit() }
    }
}
```

Property names are those of `MeoTextField`/`MeoButton`/`MeoListHeader`; the
snippet has not been run in this pass (`submitted`, `valid`, `adding`, `submit`,
`close` belong to the host).

## 8. Checklist

- [ ] One filled button; labels name the effect.
- [ ] Every field has a visible label; errors say how to fix.
- [ ] Switch for instant, checkbox for deferred.
- [ ] Input is kept after an error; focus goes to the first error.
- [ ] Keyboard: Enter submits, Escape cancels, Tab order follows reading order.
- [ ] Secrets never logged or stored in plain text.
