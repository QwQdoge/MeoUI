> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# MeoUI Rules for Coding Agents

This is the agent-oriented version of the MeoUI specification. It says the
same things as the human pages, in decision tables and checklists. When this
file and another MeoUI document disagree, the other document wins and this
file is a bug.

Source: `MeoUI/docs/design/`. Published: `https://meoarch.org/docs/meoui/`.
Index for agents: `https://meoarch.org/llms.txt`.

## Before you edit

1. Read the target repository's `AGENTS.md`; its owner workflow rules come first.
2. Identify which repository owns the change:

| The change is about | Implement it in |
| --- | --- |
| A reusable control, token, motion, layout or pattern | MeoUI |
| Plasma, KWin, D-Bus, panels, lock screen, title bar colors | meo-kde |
| A system setting and its backend | MeoSettings |
| One application's own flow or preference | That application's repository |
| ISO composition, installer, repair, AI router | MeoArch-os-workspace |

3. Read only the documents you need:

| Task | Read |
| --- | --- |
| Window, toolbar, overflow menu, app settings, About, credits | `APP_SHELL.md` |
| Any Settings-style page or row | `SETTINGS.md`, `PAGE_TYPES.md` |
| Store pages, install buttons, progress bars, error/empty states | `STORE_FEEDBACK.md` |
| Colors, theming | `DYNAMIC_COLOR.md` |
| Adding, replacing, deprecating or deleting public QML | `../api-lifecycle.md` |
| Strings, translations, accessible names | `../localization.md` |

## Hard rules (MUST / MUST NOT)

- MUST `import MeoUI 1.0`; MUST NOT copy a MeoUI control into an app.
- MUST use `MeoTheme` tokens and `MeoTheme.globalScale`; MUST NOT hard-code a
  color, dp size, radius, duration or easing that has a token.
- MUST NOT create a product-local color palette.
- MUST NOT use `Qt.FramelessWindowHint` on an application window.
- MUST wrap every visible string and accessible name in `qsTr()`; MUST NOT use
  translated text as a key or stored value.
- MUST NOT ship placeholder system facts; read the authoritative backend or
  show unknown.
- MUST NOT put a system-wide control inside an app; link to Meo Settings.
- MUST NOT hard-code an open-source credit list in QML; read the installed
  `THIRD_PARTY_NOTICES.md`.
- MUST NOT select a deprecated component for new work; MUST NOT reintroduce a
  type listed in the `docs/api-lifecycle.md` removal record.
- MUST NOT claim a validation level you did not run.

## Decision table: app window

| Question | Answer |
| --- | --- |
| Toolbar component | `MeoTopAppBar { type: "small" }`; `MeoToolbar` for dense tool windows |
| Leading control | One of: sidebar toggle, `menu`, `arrow_back` (only with a real parent route) |
| Trailing actions | ≤3 `MeoIconButton`, each with tooltip and `Accessible.name`; extra go to overflow |
| Overflow icon | `more_vert`, last item in the toolbar |
| Overflow menu | `MeoMenu { parent: window.contentItem; placement: "auto" }` + `openFrom(button)`; default `placement: "manual"` ignores the anchor |
| Overflow tail order | app actions, divider, Settings (`Ctrl+,`), Keyboard shortcuts (`Ctrl+?`), Help (`F1`), About _App_ |
| Menu bar | None |
| Content under title bar | Only via `Qt.ExpandedClientAreaHint` where honoured, padded by `SafeArea.margins`, with fallback |
| Sidebar apps | Sidebar full height with its own header; toolbar spans the content pane only |

## Decision table: app settings

| Question | Answer |
| --- | --- |
| Separate window? | No. Route `settings` in the existing page host (compact apps without a host: `MeoFullScreenDialog`) |
| Entry points | Overflow "Settings", `Ctrl+,`, and in sidebar apps a footer row `settings`; never a primary nav item |
| With `MeoAppLayout` | Append `settings`/`about` pages after `navigationModel` entries; set `sidebarFooter` and `pageTitle` |
| Up to ~5 categories | One scrolling page: `MeoListHeader` per category + `MeoSettingsGroup`s |
| Larger | `MeoSettingsLayout` with category sidebar; level 3 = `MeoSettingsTaskSheet` |
| Category order | General, Appearance, feature domains, Notifications, Privacy & data, Accounts & sync, Advanced, About |
| Apply/Save buttons | None for ordinary preferences; confirm only privileged/destructive/restart changes |
| Theme, accent, language | Default "Follow system"; override only, never edit the system value |
| Storage | `QSettings`, organization `MeoArch`, keys `group/key` lowercase; secrets in the keyring |
| Reset | "Reset to defaults" as the last row of Advanced, with confirmation |

## Decision table: About and credits

| Question | Answer |
| --- | --- |
| Device / OS facts | Meo Settings → About only (`SystemInfoBackend`) |
| App About route | `about`, from overflow "About _App_" and the last settings category |
| Version source | Compile-time version of the binary (e.g. CMake `PROJECT_VERSION`) |
| About content order | Header (icon, name, version, channel) → description → Links → Legal → copyright |
| Component | `MeoAboutPage`; host passes `Qt.application.version` and license texts read in C++ |
| License / notices view | Read-only `MeoSettingsTaskSheet` drill-in (built into `MeoAboutPage`) |
| Third-party record | `THIRD_PARTY_NOTICES.md` at repo root + `assets/licenses/` (or `LICENSES/`), installed to `/usr/share/licenses/<pkg>/` |
| In-app list includes | Vendored/adapted code, bundled assets, runtime platform libraries (Qt, KDE Frameworks, MeoUI) |
| Build/dev tools | README "Built with" only, not in the app |

## Decision table: progress and errors

| Question | Answer |
| --- | --- |
| Known fraction | `MeoProgressBar { indeterminate: false; value }`; unknown: `indeterminate: true`; never a guessed percentage |
| Page loading, layout known | `MeoLoadingFeedback { placeholder }` with `MeoSkeleton`; unknown layout: default indicator (120 ms delay, 300 ms minimum) |
| Failure, nothing blocked | `MeoSnackbar` with action |
| Failure affecting the page | `MeoBanner { tone: "error"; title }` |
| Failure of one item | Message in its row with Retry |
| Empty result | Empty state, no error tone, no Retry |
| Error text | What failed, why if known, one action; never raw backend text |
| Missing store metadata | Omit the field; never invent rating, size, version or quota |

Details and the standard error table: `STORE_FEEDBACK.md`.

## Decision table: KDE and Qt applications

| Question | Answer |
| --- | --- |
| Restyle controls | meo-kde `MeoStyle`; never per-app redraws |
| Title bar / toolbar surface | meo-kde color scheme `[Colors:Header]` + `org.meo.decoration` |
| Hide menu bar | meo-kde `defaults/applications/<app>rc` (`[MainWindow] MenuBar=Disabled`; Konsole `[KonsoleWindow] ShowMenuBarByDefault=false`), seeded by `startmeo-wayland` into the Meo session profile; never `/etc/xdg` |
| Change layout | Only small chrome patches for roadmap Tier 2 apps (Dolphin first) |
| Rejected | Runtime widget-tree rewriting, full forks, literal tablet dimensions |
| Exempt from App Shell | Installer (wizard), Quick Repair in recovery, shell surfaces; Meo AI changes go in its core view |

## Decision table: desktop input (pointer and keyboard)

MeoUI keeps the Pixel / Material 3 Expressive look on every device; on
desktop it adopts the input conventions shared by WinUI 3 and macOS.

| Question | Answer |
| --- | --- |
| When does a focus ring show | Only in keyboard modality (`MeoTheme.focusVisible`, driven by `MeoInputModality`): Tab/arrow navigation shows it, a mouse/touch press that moves focus does not. Pass `focused: <item>.activeFocus` to `MeoStateLayer`; it applies the gate. Do not add a second focus ring |
| Hover feedback | Color only, through the state layer. No hover scale or lift (only the opt-in `"playful"` motion profile keeps one); press scale and active lift remain |
| Icon-only button label | Set `MeoIconButton.toolTipText`; it becomes the accessible name and a hover tooltip after `MeoTheme.tooltipShowDelay` (500 ms), never on touch |
| Tooltip timing | `MeoTooltip` defaults to `MeoTheme.tooltipShowDelay`; do not hard-code a delay |
| Scrollbar | `MeoScrollBar`: thin overlay pill while scrolling, full 8dp thumb plus faint track on hover/drag |
| Touch-specific behavior | Branch on `MeoTheme.touchInput` / `MeoTheme.pointerType`, never on `Qt.platform.os` |

## Decision table: accessibility and density

| Setting | Contract |
| --- | --- |
| Text size | `MeoTheme.fontScale` (0.5-3). Component text uses `MeoTheme.textScale` (`globalScale * fontScale`), never `globalScale` alone; icons and containers use `globalScale` |
| Reduce motion / motion speed | `MeoTheme.reduceMotion`, `MeoTheme.motionScale`; all durations come from motion tokens, springs check `reduceMotion` |
| Reduce transparency | `MeoTheme.transparencyEnabled`; translucent surfaces take their alpha from `MeoTheme.surfaceAlpha(a)` (opaque when off). Shell blur-behind follows the same flag |
| Increase contrast | `MeoTheme.highContrast`: secondary text uses on-surface, outlines/dividers strengthen, state layers +4%, focus ring +1dp |
| Density | `MeoTheme.density` 0/-1/-2/-3 (M3 density scale, 4dp per step, per-component floors); resolves to 0 on touch input. Heights come from `MeoTheme.buttonHeightForSize()`, `densityAdjusted()` and `minimumTargetSize` |
| Icons | `MeoIcon` (Material Symbols Rounded, one shared font loader via `MeoTheme.iconFontFamily`). Optical size follows the drawn size (20-48); grade follows `MeoTheme.iconGrade` (-25 dark, 200 high contrast). Override axes only for a deliberate emphasis |
| Who sets them | The host (meo-kde, apps) binds them to the platform settings; components only read MeoTheme |

## Decision table: rendering and motion performance

| Question | Answer |
| --- | --- |
| Drive a per-frame sampled motion (spring, morph) | `FrameAnimation` (vsync-aligned) via `MeoSpringValue`; never a 16 ms `Timer`, which drops/doubles frames at 60 Hz and caps high-refresh panels at ~60 Hz |
| Draw a rect / pill / circle surface | `MeoShape` (scene-graph `Rectangle` for `rect`, `round`, `squircle`, `circle`); `Canvas` only for the expressive shape catalog |
| Draw an animated arc, spinner or morphing path | `QtQuick.Shapes` (`Shape.CurveRenderer`); never an animated `Canvas`, which re-rasterizes on the CPU and re-uploads a texture every frame |
| Rotate a drawn shape | An item `rotation` transform, not a repaint |
| Elevation shadow | `MeoElevationShadow { target: surface; elevation: MeoTheme.elevationLevelN }` as a sibling behind the surface; never hand-write `MultiEffect` shadow values, and never put `layer.enabled` on an item that contains a state layer, ripple, spinner or other animated content |
| Which level | M3 component levels: buttons/cards 1 (hover 2), menus/rich tooltips/pull-to-refresh 2, dialogs/snackbars/floating toolbars/popovers 3, FAB by its token; values between levels interpolate. Elevation tokens are already scaled, so do not multiply by `globalScale` again |
| Fade an overlay out | Gate `visible` on the animated `opacity` (`visible: opacity > 0`), not on the condition that drives it; otherwise the exit transition never renders. Items inside a Row/Layout may hide immediately instead |
| Infinite or decorative animation | `running` includes `visible` (and `!MeoTheme.reduceMotion` when it moves) |
| Shape-pair results (topology alignment, interpolation tables) | Compute once per pair and cache; never per frame |

## Validation (MeoUI repository)

Run the narrowest check that covers the change:

```sh
# static design-system usage
python3 tools/verify-design-system-usage.py --mode library MeoTheme.qml MeoMotion.qml components widgets patterns
# normal QML/C++ change
cmake --fresh -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_TESTING=ON -DMEOUI_BUILD_SHOWCASE=OFF
cmake --build build --parallel 2
QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure --timeout 60
# public QML export or catalog change
python3 tools/verify-showcase-coverage.py
```

Docs-only changes need no build. After changing anything in `docs/design/`,
regenerate the site with `python3 scripts/build_docs.py` in `meoarch-site`.

## Reporting

State which evidence level you reached: static, offscreen, Showcase runtime,
or manual visual. Name what was not verified.
