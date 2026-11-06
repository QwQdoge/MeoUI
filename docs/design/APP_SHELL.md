> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

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
`MeoToolbar` (56dp, 48dp compact) for dense tool windows. Docked action
surfaces use `MeoDockedToolbar` (`MeoBottomAppBar` was removed; see
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

Declare the overflow `MeoMenu` with `parent: <window>.contentItem` and
`placement: "auto"`, and open it with `openFrom(button)`. `placement`
defaults to `"manual"`, which ignores the anchor and opens the menu at the
parent's top-left corner; a menu parented to the button itself is not clamped
to the window.

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
  route `settings` inside the existing page host, so history, back and
  Reduce Motion behave like any other page. Apps without a page host may use
  `MeoFullScreenDialog` on compact windows.

### Entry points

- Apps with a persistent `MeoSidebar`: a **Settings** row pinned in the
  sidebar `footer` slot (icon `settings`), plus the overflow item.
- All other apps: the overflow item.
- Both entries and `Ctrl+,` open the same route.
- Settings is never a primary navigation destination (a sidebar row or a
  bottom-navigation tab next to the product's own pages).

With `MeoAppLayout`, append the `settings` and `about` pages to `pages` after
the entries of `navigationModel`, set `sidebarFooter` to the Settings row and
`pageTitle` to the page's name. Pages after the navigation model select no
navigation row.

### Presentation

- An app whose settings fit one screenful or a few (up to about five
  categories): one scrolling page. Each category is a `MeoListHeader`
  followed by its `MeoSettingsGroup`s, in the order below.
- Larger settings: `MeoSettingsLayout` with a category sidebar, following the
  two-level rule in `PAGE_TYPES.md`.
- Level three is always a `MeoSettingsTaskSheet`.
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
4. Group **Legal**: License and **Open-source licenses** (section 4). Both
   open their full text as a read-only drill-in `MeoSettingsTaskSheet`
   (`PAGE_TYPES.md` level 3). Acknowledgements are optional.
5. Footer: copyright line in `bodySmall`, `contentOnSurfaceVariant`.

Do not put update checks, settings toggles or system facts on the About page.

Use the `MeoAboutPage` pattern instead of building this page by hand. The host
passes `version: Qt.application.version` (set from the build) and reads the
installed license files in C++, because QML cannot read local files:

```qml
MeoAboutPage {
    appName: qsTr("OmniStore")
    appIcon: "storefront"
    version: Qt.application.version
    links: [{ "title": qsTr("Source code"), "url": "https://github.com/QwQdoge/OmniStore", "icon": "code" }]
    licenseName: "GPL-3.0-only"
    licenseText: appLicenseText        // share/licenses/<package>/LICENSE
    noticesText: appNoticesText        // share/licenses/<package>/THIRD_PARTY_NOTICES.md
}
```

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

The in-app **Open-source licenses** sheet reads the installed
`THIRD_PARTY_NOTICES.md` (for example with `Text.MarkdownText`) and the
license files at runtime. It never hard-codes a credit list in QML. If the
installed file is missing, say "License information is not available in this
build" and link to the source repository. MeoUI is listed by every consumer
(MIT) together with the assets it ships.

## 5. Scope exceptions

- **Installer** is a full-screen, single-task wizard: no overflow menu, no
  Settings or About route. Its language and accessibility choices are wizard
  steps.
- **Quick Repair** is a recovery tool that may run in a minimal or live
  session. It keeps its sidebar of problem categories; Settings/About apply
  only when it runs as a normal desktop app, and never block recovery.
- **Meo AI** renders the view produced by its shared core
  (`meo/core-rs`). App Shell structure (overflow, Settings, About) is added in
  the core view, not in one renderer.
- **Shell surfaces** in meo-kde (panels, dock, lock screen, OSDs) are not
  application windows.

## 6. KDE and other Qt applications

MeoArch also ships upstream KDE and Qt applications. They cannot all be
rebuilt on MeoUI, so the hierarchy is matched in layers, following meo-kde
`docs/meo-application-chrome-roadmap.md`:

| Layer | Owner | Gives KDE/Qt apps |
| --- | --- | --- |
| Colors | meo-kde dynamic colors (`MeoLight`/`MeoDark` color schemes, including `[Colors:Header]`) | Same roles as `MeoTheme`; title bar and toolbar share the header surface |
| Title bar | meo-kde KWin decoration (`org.meo.decoration`) | Meo caption buttons, title bar flush with the toolbar |
| Controls | meo-kde `MeoStyle` (Qt Widgets `QStyle`, reads `Meo::DesignTokens`) | MeoUI shapes, sizes and state layers for buttons, menus, fields, lists |
| Chrome | Small per-app patches (Dolphin pilot) | Top bar composition, sidebar width, overflow placement |

What maps directly, without patches:

- **No menu bar, overflow menu last.** KXmlGui applications (Dolphin, Kate,
  Okular, Ark) hide the menu bar and show their hamburger menu when
  `[MainWindow] MenuBar=Disabled` is set; Konsole uses
  `[KonsoleWindow] ShowMenuBarByDefault=false`. meo-kde ships these in
  `defaults/applications/` and the Meo session seeds them once into its
  private profile (`~/.config/meo-desktop`), so the ordinary Plasma session and
  `/etc/xdg` are untouched and users can turn the menu bar back on
  (`Ctrl+M`, Konsole `Ctrl+Shift+M`). Kirigami applications (System Settings,
  Discover, Elisa) already have no menu bar.
- **About and open-source licenses.** KDE's `KAboutData` About dialog already
  lists the version, license, authors and the libraries used; this matches
  section 3 and needs no change.
- **Unified toolbar look.** The `Header` color group gives the title bar and
  the toolbar one surface, which is the KDE equivalent of section 1.

What does not map, and is accepted:

- KDE applications open settings as a separate `KConfigDialog` window
  ("Configure _App_…") instead of an in-window route.
- Kirigami's column-based page stack and global drawer are not rebuilt.
- Toolbar contents differ per application. Only the Tier 2 applications in the
  roadmap get chrome patches; others stay upstream with MeoStyle only.

Do not change KDE application layout through runtime widget-tree rewriting
or full forks; that is rejected in the roadmap.

## 7. Where these rules live

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
- [ ] `Ctrl+,` opens the `settings` route; settings are in-window and not a primary navigation item.
- [ ] No system control duplicated; overrides default to *Follow system*.
- [ ] Categories follow the fixed order; About is last.
- [ ] Preferences apply immediately; keys are stable, not translated.
- [ ] App About shows the compile-time version and no device facts.
- [ ] `THIRD_PARTY_NOTICES.md` and license texts exist and are installed; the in-app list is read from them.
