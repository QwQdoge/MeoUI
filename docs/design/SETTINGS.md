# Settings Pattern

The Settings pattern takes the useful parts of modern system settings UI—fast
search, high-density grouped rows, tonal icon containers, and clear supporting
text—without copying another product's branding, wording, or layout.

## Building blocks

- `MeoSettingsRow` is a 72dp+ semantic row with a 40dp dynamic tonal icon
  container. Its trailing kind is explicit: `navigation`, `status`, `choice`,
  `toggle`, `action`, or `none`.
- `MeoSegmentedList` is the single connected-surface engine. `MeoGroupedList`
  and `MeoSettingsGroup` preserve their public APIs as adapters over it; they
  must not duplicate container, separator, or row-position geometry.
- `MeoSettingsGroup` maps semantic Settings roles onto that engine. Do not turn
  every row into a detached card.
- `MeoSettingsTaskSheet` is the only standard third-level Settings surface. It
  retracts on accept, reject, or navigation.
- `MeoSearchBar` is search-first. Set `trailingIcon: ""` when an account action
  is not a real Settings function.

## Visual rules

- Use semantic `MeoTheme` colors. Give a row's icon container one of the
  dynamic primary, secondary, tertiary, neutral, or error tones; never use a
  product-local pastel palette.
- Prefer one comfortable vertical list over dashboard grids for primary
  settings. Keep one primary action per row and keep supporting text to two
  lines maximum.
- Use 28dp group-end corners, 1dp internal member corners, and a 2dp gap that
  reveals the page `surface`. A 1dp `outlineVariant` line is an explicit compact
  alternative, not the Pixel-style default.
- Every interactive row uses `MeoStateLayer`: 8% hover darkening, 10% pressed
  darkening plus a click-point-origin soft-edge circular ripple, and a primary
  keyboard focus ring. Keyboard activation originates from the control center.
  Disabled rows do not render pointer feedback.
- Give grouped rows a shared rounded surface and 12–16dp space between groups.
  An index should fit a broad category scan before asking a user to navigate.
- Keep desktop Settings content around 720–760dp readable width. On compact
  windows, use an index/drawer category menu rather than a generic five-item
  bottom bar that hides categories behind “More”.
- A status row is not a disguised button. A KDE-owned action names KDE in its
  trailing label or supporting text.

## Safety boundary

A volume inspector may expose real mounted-volume facts in a task sheet. It
must not imply that mount, unmount, format, repair, encryption, partitioning,
or backup is implemented unless a verified backend, privilege model, and
recovery flow are present. When they are not, use a transparent external
handoff and say which system tool owns the action.
