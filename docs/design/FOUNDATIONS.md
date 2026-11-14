> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Visual Foundations and Page Style

What every MeoUI page is made of: surfaces, color, type, shape, space,
elevation, icons and motion. Components already apply these; this page tells
you which token to reach for when you compose a page, and why. Token values
below are read from `MeoTheme.qml` (a value changes with `MeoTheme.globalScale`,
density and corner scale, so always use the token, never the number).

## 1. Page style in one paragraph

A MeoUI page is a calm tonal surface with a few clear shapes on it. The page
is `MeoTheme.surface` (or `background`). Content sits in rounded containers one
tonal step above the page. One primary action per screen is filled; everything
else is tonal, outlined or text. Large shapes, generous radii and soft motion
are the identity; color comes only from the dynamic role table
(`DYNAMIC_COLOR.md`). Density is comfortable by default and never below the
touch-target floor.

Rules of thumb:

- **One focal point.** A page has one heading, one primary action, one thing the
  eye lands on first.
- **Group, don't box.** Related rows share one rounded surface
  (`MeoSegmentedList` / `MeoSettingsGroup`). Do not give every row its own card.
- **Tone is structure.** Use surface-container steps to show hierarchy before
  you reach for borders, shadows or dividers.
- **Expressive is opt-in.** `MeoTheme.isExpressive` turns on the bouncier shape
  and motion treatments. A page must be correct and readable with it off.

## 2. Surfaces and tonal hierarchy

From lowest to highest on a light page (the role names are the same in dark):

| Token | Use |
| --- | --- |
| `surface` / `background` | The page itself |
| `surfaceContainerLowest` | Grouped rows (`MeoSettingsRow` default), inputs on a tinted page |
| `surfaceContainerLow` | Elevated `MeoCard`, large content sections |
| `surfaceContainer` | Navigation rail/sidebar, standard sheets |
| `surfaceContainerHigh` | Menus, dialogs, search bars, filled fields |
| `surfaceContainerHighest` | Filled `MeoCard`, chips at rest, the strongest quiet surface |
| `primaryContainer` / `secondaryContainer` / `tertiaryContainer` | A single emphasized object: selected item, hero chip, key status |
| `errorContainer`, `warningContainer`, `successContainer` | Banners and inline status only |
| `inverseSurface` | Snackbars |

Rules:

- A container sits **one step above** what it is placed on. Do not place
  `surfaceContainerHighest` on `surfaceContainerHighest`.
- Never nest a card inside a card. Use a divider, a header or spacing.
- Text on a container uses the matching `contentOn…` role
  (`contentOnSurface`, `contentOnSurfaceVariant`, `contentOnPrimaryContainer`).
  Never `Qt.rgba` or a hex literal.
- Reduce Transparency is `MeoTheme.transparencyEnabled`; translucent surfaces
  take their alpha from `MeoTheme.surfaceAlpha(a)` and become opaque when off.
- Increase Contrast is `MeoTheme.highContrast`. Secondary text then uses
  on-surface and outlines strengthen. Check a page in high contrast.

## 3. Color roles by meaning

| Meaning | Role | Examples |
| --- | --- | --- |
| Brand, the main action, selection | `primary`, `primaryContainer` | Filled button, selected nav item, progress fill |
| Supporting action or object | `secondary`, `secondaryContainer` | Tonal button, filter chip selected |
| Accent, a different kind of thing | `tertiary`, `tertiaryContainer` | "Community" source badge, vibrant buttons |
| Problem or destructive | `error`, `errorContainer` | Error banner, destructive row icon |
| Needs attention, still works | `warningContainer` | Offline banner |
| Done, healthy | `successContainer` | Success banner (rare) |
| Neutral text | `contentOnSurface` (primary), `contentOnSurfaceVariant` (secondary) | Title / supporting text |
| Lines | `outline` (strong), `outlineVariant` (quiet) | Outlined card, divider |

Never convey meaning by color alone: pair it with an icon and words
(error = icon + text + tone).

## 4. Typography

Faces: Comfortaa Bold is the brand face (brand name, logo, English page
titles); Roboto is the UI face; Chinese falls back to Noto Sans SC.
`MeoText` applies the scale; set `typeRole` (`title`, `body`, `label`),
`typeSize` (`big`, `medium`, `small`) and `emphasized`.

Material type scale as defined in `MeoTheme` (size / line height, dp):

| Role | Large | Medium | Small |
| --- | --- | --- | --- |
| Display | 57 / 64 | 45 / 52 | 36 / 44 |
| Headline | 32 / 40 | 28 / 36 | 24 / 32 |
| Title | 22 / 28 | 16 / 24 (Medium) | 14 / 20 (Medium) |
| Body | 16 / 24 | 14 / 20 | 12 / 16 |
| Label | 14 / 20 (Medium) | 12 / 16 (Medium) | 11 / 16 (Medium) |

Each has an `…Emphasized` variant (Bold or DemiBold) for expressive emphasis.

Which style for what:

| Element | Style |
| --- | --- |
| Page title in a top app bar | `titleLarge` (or `headlineSmall` for large bars) |
| Section header | `titleMedium`, or `MeoListHeader` |
| Card title | `titleMedium` |
| Row headline | `bodyLarge` |
| Row supporting text, helper text | `bodyMedium` / `bodySmall`, `contentOnSurfaceVariant` |
| Button, chip, tab label | `labelLarge` |
| Caption, timestamp, badge | `labelMedium` / `labelSmall` |
| Large numbers (stats) | `displaySmall`…`headlineLarge` |

Rules:

- Component text uses `MeoTheme.textScale` (`globalScale × fontScale`), never
  `globalScale` alone. Icons and containers use `globalScale`.
- Design for `fontScale` up to 3: nothing may clip. Wrap, then truncate
  (`elide`) a single line only where the full text is available elsewhere
  (tooltip, detail page).
- One heading per level. Do not use bold body text as a heading.
- Line length 45–75 characters for reading text; cap prose at 560–680dp.

## 5. Shape

| Token | dp | Use |
| --- | ---: | --- |
| `shapeExtraSmall` | 4 | Tooltips, small badges |
| `shapeSmall` | 8 | Pressed control corners, small chips |
| `shapeMedium` | 12 | Controls (buttons in standard shape), inputs |
| `shapeLarge` | 16 | Compact cards |
| `shapeLargeIncreased` | 20 | `cardRadius` (cards) |
| `shapeExtraLarge` | 28 | Large surfaces, `dialogRadius`, group ends |
| `shapeExtraLargeIncreased` | 32 | Search bars, expressive large shapes |
| `shapeExtraExtraLarge` | 48 | Hero surfaces |
| `shapeFull` | pill | Buttons (round), chips, switches, nav pills |

Rules:

- Connected groups use 28dp outer corners and small inner corners with a 2dp gap
  (`connectedGroupOuterRadius` / `InnerRadius`).
- Corners scale with `cornerScale`; read `MeoTheme.cardRadius`,
  `dialogRadius`, never copy the dp.
- Pressed state shrinks the radius (controls 12 → 8dp). Do not fake it.
- Expressive shape catalog (squircle, hexagon, diamond…) is for icon
  containers, avatars and badges where it carries brand meaning. Not for
  every card.

## 6. Spacing

Scale (dp × `globalScale`): `space2`, `space4`, `space6`, `space8`, `space12`,
`space16`, `space24`, `space32`, `space40`, `space48`.

| Where | Token |
| --- | --- |
| Icon ↔ label inside a control | `space8` |
| Between related controls in a row | `space8`–`space12` |
| Card inner padding | 16dp (12dp compact) |
| Between cards in a grid | `space12`–`space16` |
| Between sections | `sectionSpacing` from `MeoWindowMetrics` (16dp compact, 24dp otherwise) |
| Page margin | `pageMargin` (16 / 24 / 32 / 40dp by width class) |
| Between a header and its content | `space8`–`space12` |

Always use `MeoWindowMetrics` (`pageMargin`, `sectionSpacing`,
`controlSpacing`) for layout rhythm; do not hand-pick margins per page.
Minimum touch target is `MeoTheme.minimumTargetSize` (48dp, reduced by
density). A visually smaller icon still gets that hit area.

## 7. Elevation

Elevation tokens (already scaled): `elevationLevel0…5` = 0, 1, 3, 6, 8, 12.

| Surface | Level |
| --- | --- |
| Flat group, filled/outlined card | 0 |
| Elevated card, button | 1 (hover 2) |
| Menu, rich tooltip, pull-to-refresh | 2 |
| Dialog, snackbar, floating toolbar, popover | 3 |
| FAB | its token |

Use `MeoElevationShadow` as a sibling behind a surface. Do not hand-write
shadow values, and prefer **tone** over shadow to separate surfaces: a shadow
is for something that floats above the page, not for ordinary grouping.

## 8. Icons and imagery

- Icons are `MeoIcon` (Material Symbols Rounded). One icon style per product;
  optical size follows the drawn size (20–48).
- Icon-only buttons set `toolTipText`; it is the accessible name.
- An icon in a tonal container (40dp) names a settings category or a
  source; the tone is one of primary, secondary, tertiary, neutral, error.
- App icons are real images from the backend. If missing, show a tonal
  placeholder with the first letter, never a stock illustration that implies
  the app.
- Screenshots keep their aspect ratio, use `MeoCachedImage`, and show a
  `MeoSkeleton` while loading.

## 9. Motion

Durations come from tokens (`motionDurationShort1…Long…`: 50, 100, 150, 200,
250, 300, 350, 400, 450, 500 ms and so on), scaled by the user's motion speed.

| Motion | Spec |
| --- | --- |
| Standard easing | `[0.2, 0, 0, 1]` |
| Page enter / exit | 350 ms emphasized-decelerate / 250 ms standard-accelerate |
| Popup enter / exit | `motionDurationMedium1` (250) / `motionDurationShort3` (150) |
| Press feedback | State layer, immediate |
| Loading indicator delay | 120 ms; minimum visible 300 ms |

Reduce Motion (`MeoTheme.reduceMotion`) sets spatial motion to zero without
changing state: the page still changes, it just doesn't travel. Never encode
information only in motion.

## 10. Accessibility floor

Every page must pass these before it ships:

- Keyboard: every action reachable with Tab/arrows; visible focus ring only in
  keyboard modality; Escape closes transient surfaces.
- Names: every control has `Accessible.name` (icon buttons via `toolTipText`);
  status changes are announced once (completion, failure), not every tick.
- Contrast: use role pairs; check high contrast.
- Targets: ≥ `minimumTargetSize`.
- Text scale 200%: nothing clips or overlaps.
- Reduced motion, reduced transparency tested.
- No information by color alone.

## 11. Known gaps

- There is no `MeoTheme` token for "success"/"warning" **solid** colors, only
  containers (`successContainer`, `warningContainer`). For a status dot use the
  container's content color.
- The expressive shape catalog has no documented rule for accessibility of
  non-circular touch areas; keep the hit area ≥ target size.
