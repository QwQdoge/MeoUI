# MeoUI Specification

MeoUI is the shared Qt Quick / QML Material Design 3 design system of
MeoArch. **MEO = Modern · Expressive · Open**: modern interaction and
presentation, expressive motion and visual language, and an open Linux
foundation that leaves control with the user.

This directory is the canonical source of the MeoUI specification. It is
published at `https://meoarch.org/docs/meoui/` for people and as Markdown for
agents (`https://meoarch.org/llms.txt`). Edit the rules here, never on the
site.

## Documents

| Document | Covers |
| --- | --- |
| [APP_SHELL.md](APP_SHELL.md) | Window chrome and toolbar, where app settings live and how they are grouped, About, open-source credits, where specs live |
| [SETTINGS.md](SETTINGS.md) | Settings building blocks: rows, groups, sidebar, task sheet, state layer and motion |
| [PAGE_TYPES.md](PAGE_TYPES.md) | Page kinds, the two-level rule, registry metadata |
| [DYNAMIC_COLOR.md](DYNAMIC_COLOR.md) | The mandatory dynamic color role table and who generates it |
| [../api-lifecycle.md](../api-lifecycle.md) | Current, deprecated, experimental and internal components |
| [../localization.md](../localization.md) | Language precedence, translation catalogs, accessible names |
| [FOR_AGENTS.md](FOR_AGENTS.md) | The same rules as an operational checklist for coding agents |

## Core rules

### Ownership

- MeoUI owns reusable tokens, QML controls, patterns and layouts, motion,
  accessibility and adaptive behavior, runtime tokens and the Showcase.
- Plasma, KWin, D-Bus, hardware, package manager and OS policy belong in
  meo-kde or the owning app. MeoUI exposes only the minimal generic UI or API.
- A generic, reusable change is implemented in MeoUI first, then consumed.
- Consumers `import MeoUI 1.0`. They never copy a shared control into their
  own repository.

### Tokens

- Use `MeoTheme` semantic tokens, `MeoTheme.globalScale`,
  `MeoWindowMetrics`, `MeoMotion` primitives and the shared icon system. Do
  not hard-code a color, size, radius, duration or easing when a semantic token
  exists.
- Colors come only from the dynamic role table (`DYNAMIC_COLOR.md`). No
  product-local palette.
- Typography: Comfortaa Bold is the brand face (brand name, logo, English page
  titles); Roboto is the UI face; Chinese falls back to Noto Sans SC / Source
  Han Sans SC.
- Shape: controls 12dp (8dp pressed), large surfaces 28dp, pills full.
- Motion: standard easing `[0.2, 0, 0, 1]`; 350ms emphasized entrance and
  250ms accelerate exit for page navigation; Reduce Motion resolves spatial
  motion to zero without changing state.
- State layer opacities: hover 8%, focus 10%, pressed 10%, dragged 16%.

### Components

- Every public component has a lifecycle class (`../api-lifecycle.md`). New
  work uses Current components; docked actions use `MeoDockedToolbar`.
  Removed types and their replacements are listed in `../api-lifecycle.md`.
- Every public QML export has a Showcase sample; visible changes update it.

### Localization and accessibility

- All visible strings and `Accessible.name` / `Accessible.description` use
  `qsTr()`. Translated text is never a key or persisted value.
- English is the source language; `zh_CN` is the first reviewed catalog.
- The host app resolves the language before creating its first QML object.

### Runtime facts

Machine, session, hardware, account and configuration facts are runtime state
read from their authoritative owner. Never ship a placeholder value that looks
like a detected fact; show unavailable/unknown instead.

### Evidence

Static checks, offscreen tests, Showcase runs and manual visual review prove
different things. Report only the level that was actually run.

### Files

- Code-bound contracts live in `docs/` of the owning repository.
- Plans, audits and work logs live in `$MEO_DOCS_ROOT/Projects/<project>/`.
- Build, install, validation and package output lives in
  `$MEO_OUTPUT_ROOT/<project>/{build,install,validation,packages,tmp}/`.
- Third-party credits live in `THIRD_PARTY_NOTICES.md` plus license texts
  (`APP_SHELL.md` section 4).
