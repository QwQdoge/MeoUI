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
- `MeoSettingsSidebar` is the reusable desktop index. It owns the persistent
  search field, connected category groups, selected-route visibility, and
  empty search state; the application supplies route data and navigation.
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
- Every interactive row uses `MeoStateLayer`: 8% hover darkening enters and
  exits linearly in 15ms; focus and drag enter in 45ms, while drag exits in
  150ms. A press starts a 10% soft-edge circular ripple at the exact pointer
  position. Following AndroidX Material3 ripple, its start radius is 30% of the
  largest control dimension, its bounded target covers the control diagonal
  plus 10dp, alpha enters linearly in 75ms, and radius expands in 225ms with
  FastOutSlowIn while the center converges linearly toward the control center.
  It remains fully expanded for the complete hold and fades linearly in 150ms
  after release. Keyboard activation originates from the control center.
  Disabled rows do not render pointer feedback, and Reduce Motion removes
  spatial ripple animation immediately.
  The shared state layer renders the rounded mask, base state, soft ripple edge,
  and focus ring in one fragment pass. Do not reintroduce stacked blur/mask
  `MultiEffect` layers in individual controls.
- Settings detail navigation uses asymmetric semantic motion: a 350ms
  emphasized-decelerate entrance and a 250ms standard-accelerate exit. Reduce
  Motion resolves both durations to zero without changing navigation state.
- Give grouped rows a shared rounded surface and 12–16dp space between groups.
  An index should fit a broad category scan before asking a user to navigate.
- Keep desktop Settings content around 720–760dp readable width. On compact
  windows, use an index/drawer category menu rather than a generic five-item
  bottom bar that hides categories behind “More”.
- At expanded and larger widths, keep the 360dp search-first index stable while
  the detail pane changes. Do not repeat the complete category catalogue in
  the detail pane. Automatically reveal the selected route when it is below
  the visible portion of a long index.
- A status row is not a disguised button. A KDE-owned action names KDE in its
  trailing label or supporting text.

## Safety boundary

A volume inspector may expose real mounted-volume facts in a task sheet. It
must not imply that mount, unmount, format, repair, encryption, partitioning,
or backup is implemented unless a verified backend, privilege model, and
recovery flow are present. When they are not, use a transparent external
handoff and say which system tool owns the action.
# Loading and immediate action feedback

- A press/ripple is rendered from the pointer location in the same input turn; backend work must not delay that acknowledgement.
- Use `MeoLoadingFeedback` when an action may outlive the press. Unknown result geometry uses the fixed 48dp M3 Expressive indicator after the shared 120ms anti-flash delay.
- When the destination geometry is known, provide `placeholder`; the detailed `MeoSkeleton` layout appears immediately and preserves the final content positions.
- Feedback that becomes visible remains for at least 300ms to avoid a one-frame flash. `MeoLoadingIndicator`, `MeoSkeleton`, and the feedback fade all follow shared Reduce Motion policy.
- Toggle-like controls may preview the requested state immediately, but the owning backend remains authoritative and must confirm or cause a rollback.
