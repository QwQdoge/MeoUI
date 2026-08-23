# Dynamic Color Contract

Dynamic color is mandatory for every visible Meo/KDE product session. It is a
complete Material 3/HCT role table, not an accent swatch and not an optional
product skin.

## Ownership

- **MeoUI consumes and validates** semantic roles through `MeoTheme`. It does
  not read wallpaper files, KDE configuration, or derive colors with RGB/HSL.
- **The platform bridge generates and installs** the full role table. On KDE,
  `MeoShellTheme` consumes one native Material Color Utilities
  `SchemeTonalSpot` result sourced from the platform accent, a configured local
  wallpaper, or an explicitly selected manual seed. A `MeoColorField` is only
  a validated seed input; it must never generate a product-local palette.
- **Applications require the bridge** before their first visible product page.
  A Settings-like system application must expose failure rather than silently
  presenting the fixed preview palette.

## Required application behavior

1. Use `MeoTheme` semantic roles only (`surfaceContainer*`, `primaryContainer`,
   `contentOn*`, `outlineVariant`, inverse roles, and so on). Do not bake a
   wallpaper color, a seed color, or hand-blended tonal colors into product QML.
2. Install one complete role table atomically with
   `MeoTheme.applyDynamicColorScheme(scheme, sourceId)`. The method rejects a
   partial table and reports `colorSchemeMode: "invalid"`; a product must not
   treat `dynamicColorsAvailable` alone as proof.
3. In a real Meo/KDE session, require
   `colorSchemeMode === "dynamic"` and
   `hasCompleteColorScheme(dynamicColorScheme)` before the initial page is
   considered ready. The bridge must also synchronize dark mode, font scale,
   and reduced-motion preference.
4. A fixed `SchemeTonalSpot` fallback is allowed only for an installer,
   offscreen test, or non-Meo platform preview. It must be visible as
   `colorSchemeMode: "fallback"`, never labelled as dynamic color.
5. Do not call a host theme generator or `--apply` command from an application
   merely to obtain its palette. Applications consume the current session;
   changing the desktop's colors remains a user-controlled platform action.

## Acceptance checks

- Validate a complete scheme, including primary, containers, surfaces,
  outlines, inverse roles, and fixed roles.
- Inject two distinct complete HCT schemes and verify that a representative
  page updates primary, a container, a surface, outline, and content color
  together.
- In KDE, verify `MeoShellTheme.ready` and the application readiness property.
  A successful offscreen check is evidence of QML wiring only; changing an
  accent or wallpaper in a live Plasma session still needs manual acceptance.

## API surface

`MeoTheme` intentionally exposes these diagnostic fields for product tests:

```qml
MeoTheme.colorSchemeMode       // "dynamic" | "fallback" | "invalid"
MeoTheme.dynamicColorSourceId
MeoTheme.colorSchemeRevision
MeoTheme.hasCompleteColorScheme(MeoTheme.dynamicColorScheme)
```

The complete-role requirement prevents a visually dangerous mixed state where
some controls use the current desktop color while others retain a stale MeoUI
fallback.
