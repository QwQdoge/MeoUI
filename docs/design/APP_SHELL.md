# App Shell Contract

How a MeoUI application window is put together: window chrome and the
toolbar, where the app's own settings live and how they are grouped, where
About goes, and how open-source components and tools are credited. It
complements `SETTINGS.md` (the Settings building blocks) and `PAGE_TYPES.md`
(page hierarchy). It applies to every Meo application that imports
`MeoUI 1.0` (Meo Settings, OmniStore, Meo AI desktop, Installer, Repair and
future apps). Plasma shell surfaces in meo-kde (panels, plasmoids, lock
screen) are not application windows and are out of scope.

## 1. Window chrome and the toolbar

Qt can draw application content under the title bar, as macOS unified
toolbars do: Qt 6.9+ exposes `Qt.ExpandedClientAreaHint` and
`Qt.NoTitleBarBackgroundHint`, with the `SafeArea` attached property
reporting the space still owned by system window controls. MeoArch's primary
platform is KWin, which draws server-side decorations, so MeoUI defines the
same visual result without depending on that hint.

Rules:

- Keep the system window decoration. Application windows must not use
  `Qt.FramelessWindowHint`; KWin owns window controls, snapping, move/resize,
  accessibility and the close button. Frameless windows are reserved for
  shell surfaces owned by meo-kde (dock, panels, OSDs, authentication).
- Title bar color matching is owned by meo-kde's color scheme and decoration,
  driven by the same `MeoTheme` roles. An application must not try to repaint
  the title bar itself.
- Where the platform honours `Qt.ExpandedClientAreaHint` (macOS and other
  client-decorated platforms), an application may opt in. It must then pad
  its toolbar by `SafeArea.margins` so nothing sits under the window controls,
  and fall back to the normal layout when the hint is not honoured. Never
  assume the hint took effect.
- The toolbar is flush with the title bar: same `surface` color, no divider,
  no elevation at rest. A 1dp `outlineVariant` divider or tonal elevation
  appears only once content scrolls under it.

### Toolbar layout

Use `MeoTopAppBar` (`type: "small"`, 64dp) for the window toolbar, or
`MeoToolbar` (56dp, 48dp compact) for dense tool windows. `MeoBottomAppBar`
is deprecated; docked action surfaces use `MeoDockedToolbar` (see
`../api-lifecycle.md`). No traditional menu bar: Meo apps do not ship a
File/Edit/View menu bar or a global menu.

Slots, left to right:

| Slot | Content | Rule |
| --- | --- | --- |
| Leading | Sidebar toggle (wide), `menu` (compact index), or `arrow_back` (detail) | At most one control. Back is shown only when there is a real parent route. |
| Title | Current page or app name | `titleLarge` from `MeoTheme`, one line, elided. Omit it when the page shows its own large title directly below. |
| Center (optional) | `MeoSearchBar` for search-first apps | Only one search entry per window. |
| Trailing actions | Up to 3 `MeoIconButton` controls | Each has a tooltip and `Accessible.name`. More than 3 move into overflow. |
| Overflow | `more_vert` `MeoMenu` | Always the last item; contents below. |

On wide windows with a persistent `MeoSidebar`, the sidebar runs the full
window height with its own header (app name, search) and the toolbar spans
only the content pane. This is the MeoUI equivalent of a unified toolbar.

### Overflow menu

Order, top to bottom; omit entries the app does not have:

1. App-specific actions (sorted by frequency).
2. Divider.
3. **Settings** — shortcut `Ctrl+,`.
4. **Keyboard shortcuts** — shortcut `Ctrl+?` (only if the app has shortcuts beyond the platform defaults).
5. **Help** — shortcut `F1` (only if there is real help content).
6. **About _App name_**.

Keyboard: `Ctrl+,` opens Settings, `Ctrl+Q` quits, `Ctrl+W` closes the window,
`Ctrl+F` focuses search when the toolbar has one, `Esc` closes the topmost
transient surface. Do not rebind these to anything else.

## 2. Where settings live

| Kind of setting | Owner | Example |
| --- | --- | --- |
| System-wide, device or desktop | **Meo Settings** only | Wi-Fi, theme mode, dynamic color, language, default apps, notifications per app |
| App-specific preference | **The app itself** | OmniStore sources, Meo AI model choice, editor font size |
| Per-app system policy | **Meo Settings → Applications** | Permissions, autostart, default handlers |

- An app never duplicates a system control. If a preference also exists
  system-wide (theme, accent, language, notifications), the app offers
  **Follow system** as the default and only an explicit override; it never
  edits the system value.
- An app may deep-link to a Meo Settings route (for example `notifications`)
  when the user needs a system control; it names Meo Settings in the label
  ("Open notification settings in Meo Settings").
- Settings are part of the app window, not a second window. Open them as the
  route `settings` inside the existing `MeoPageHost`, so history, back and
  Reduce Motion behave like any other page. Apps without a page host may use
  `MeoFullScreenDialog` on compact windows.

### Entry points

- Apps with a persistent `MeoSidebar`: a **Settings** row pinned in the
  sidebar `footer` slot (icon `settings`), plus the overflow item.
- All other apps: the overflow item.
- Both entries and `Ctrl+,` open the same route.

### Presentation

- Up to two groups of preferences: one scrolling `settings-category` page
  built from `MeoSettingsGroup` rows.
- Three or more categories: `MeoSettingsLayout` with a category sidebar,
  following the two-level rule in `PAGE_TYPES.md`. Level three is always a
  `MeoSettingsTaskSheet`.
- Changes apply immediately. No Save/Apply/OK buttons for ordinary
  preferences. Privileged, destructive or restart-requiring changes confirm
  first and say what will happen.

### Categories

Use this order and these names; omit categories with nothing in them and
never create a category for a single row that fits elsewhere.

1. **General** — startup behavior, default view, language override.
2. **Appearance** — app-local overrides only (density, font size, layout). Theme mode and color default to *Follow system*.
3. _Feature domains_ — one category per real product domain, named by the task (for example "Sources", "Models", "Downloads"), not by implementation.
4. **Notifications** — what the app notifies about; delivery rules stay in Meo Settings.
5. **Privacy & data** — history, caches, telemetry (off by default), clear data.
6. **Accounts & sync** — Meo Account and third-party sign-ins, only when the app has them.
7. **Advanced** — diagnostics, logs, experimental flags, **Reset to defaults** (last row, confirmation required).
8. **About** — always last; see section 3.

Meo Settings itself uses the system category registry described in
MeoSettings `docs/SETTINGS_COVERAGE.md`; its sidebar ends with **About**.

### Storage

- Persist with `QSettings` after setting `organizationName` to `MeoArch` and
  the application name, which resolves to
  `$XDG_CONFIG_HOME/MeoArch/<Application name>.conf`.
- Keys are stable lowercase `group/key` strings. Never use translated text,
  row positions or display names as keys or values.
- Caches go to `QStandardPaths::CacheLocation`, data to
  `AppDataLocation`. Secrets go to the system keyring (KWallet / Secret
  Service), never to `QSettings`.

## 3. About

There are two different Abouts:

- **System About** (device, OS, hardware facts) exists only in Meo Settings →
  About, backed by `SystemInfoBackend`. Apps never show machine facts there or
  elsewhere, except inside an explicit "Copy diagnostic information" action.
- **App About** describes the application. It is the route `about`, reached
  from the overflow item **About _App name_** and, in apps with a settings
  sidebar, from the last **About** category. Both open the same page.

The App About page is an `info-page` with this content, in order:

1. Header: app icon (96dp), app name in the brand typeface, version and
   channel badge (Stable/Beta). The version is the compile-time version of the
   running binary (for example the CMake `PROJECT_VERSION`), never a typed
   string in QML.
2. One-sentence description.
3. Group **Links**: Website, Source code, Report a problem, Privacy policy
   (only when one exists). Each opens externally and says so.
4. Group **Legal**: License (opens the full license text in a
   `MeoSettingsTaskSheet`), **Open-source licenses** (level-2 info page, see
   section 4), Acknowledgements (optional).
5. Footer: copyright line in `bodySmall`, `contentOnSurfaceVariant`.

Do not put update checks, settings toggles or system facts on the About page.

## 4. Open-source components and tools

Every repository keeps its third-party record in the same place:

- `THIRD_PARTY_NOTICES.md` at the repository root: one section per component
  with what it is used for, which files, source URL, revision when vendored or
  adapted, SPDX license and copyright.
- Full license texts in `assets/licenses/` (or the repository's existing
  `LICENSES/` directory). Font licenses may sit beside the font files.
- Packaging installs both to `/usr/share/licenses/<package>/`.

What must be listed, and where it is shown:

| Kind | Example | `THIRD_PARTY_NOTICES.md` | In-app Open-source licenses | README "Built with" |
| --- | --- | --- | --- | --- |
| Vendored or adapted code, shaders, algorithms | AndroidX shapes, DankMaterialShell ideas | Yes | Yes | — |
| Bundled assets | Comfortaa, Roboto, Material Symbols, Papirus | Yes | Yes | — |
| Runtime platform libraries (dynamically linked) | Qt 6, KDE Frameworks, MeoUI | Optional | Yes, under "Platform" | — |
| Build and development tools (not shipped) | CMake, Node tools, agent skills | No | No | Yes |

The in-app **Open-source licenses** page reads the installed
`THIRD_PARTY_NOTICES.md` (for example with `Text.MarkdownText`) and the
license files at runtime. It never hard-codes a credit list in QML. If the
installed file is missing, say "License information is not available in this
build" and link to the source repository. MeoUI is listed by every consumer
(MIT) together with the assets it ships.

## 5. Where these rules live

| Content | Location | Notes |
| --- | --- | --- |
| Shared UI contracts (this file, Settings, page types, color, lifecycle, localization) | `MeoUI/docs/` | Canonical. Edit here. |
| Product-specific contracts | Owning repository `docs/` (for example MeoSettings `docs/SETTINGS_COVERAGE.md`) | Must not contradict MeoUI. |
| Published copy for people and agents | `https://meoarch.org/docs/` | Generated by `meoarch-site/scripts/build_docs.py`; never edited by hand. |
| Agent entry point | `https://meoarch.org/llms.txt`, Markdown at `https://meoarch.org/docs/meoui/*.md` | Same text as the human pages. |
| Plans, audits, decision logs | `$MEO_DOCS_ROOT/Projects/<project>/` | Not in repositories, not on the site. |

When a rule changes, change it in `MeoUI/docs/`, then regenerate and publish
the site. Every Meo repository's `AGENTS.md` points to the site.

## Checklist

- [ ] System window decoration kept; no frameless application window.
- [ ] Toolbar: one leading control, ≤3 trailing actions, overflow last.
- [ ] Overflow ends with Settings, (Shortcuts), (Help), About _App_.
- [ ] `Ctrl+,` opens the `settings` route; settings are in-window.
- [ ] No system control duplicated; overrides default to *Follow system*.
- [ ] Categories follow the fixed order; About is last.
- [ ] Preferences apply immediately; keys are stable, not translated.
- [ ] App About shows the compile-time version and no device facts.
- [ ] `THIRD_PARTY_NOTICES.md` and license texts exist and are installed; the in-app list is read from them.
