---
name: meoui
description: Use when creating, changing, reviewing, or validating any Qt Quick/QML UI that imports MeoUI, or when working on MeoUI itself. Routes to the verified shared MeoUI design-system reference.
---

# MeoUI Design System

## Authority and scope

Use this skill for non-trivial QML UI work in MeoUI or in a consuming Meo project.

Priority order:

1. Explicit user request.
2. The current project's live MeoUI implementation and its local architecture.
3. The verified shared reference at `/home/shekong/Documents/Obsidian Vault/Meo UI/design system/`.
4. Existing reference screenshots and accepted visual evidence.
5. `$impeccable` principles.
6. Agent preference.

The source code is authoritative if this reference differs from it. Do not copy tokens or components privately, substitute web/CSS patterns for QML, or use hard-coded visual values when a Meo token or component exists.

## Load only what the task needs

- Tokens, themes, scaling, typography, shape, or motion: read `references/tokens.md`.
- Picking or changing a reusable component: read `references/components.md`.
- Imports, ownership, adaptive layout, runtime, or verification: read `references/architecture.md`.
- A workflow/review task: read `references/workflow.md`.

These files are lightweight project-local pointers to the shared Obsidian reference. Read the linked source files before changing a disputed fact.

## Required UI workflow

For every non-trivial UI change:

`Understand → Design → Implement → Run → Inspect → Critique → Polish → Verify`

Before implementation, inspect the relevant component, `MeoTheme.qml`, and one comparable in-project use. Prefer an existing component, then extending it, then a reusable new component, and only then a one-off implementation.

Keep layout geometry, hit target, visual container, and glyph size independent. Parent layouts own placement; child controls own their intrinsic visual, state, and interaction contracts.

Check only relevant states, but include theme, scaling, long/localized text, disabled/loading/error, and motion-reduction behavior when applicable. Run the available QML target or test harness and inspect visual evidence for visual changes. Use `$impeccable` for critique principles, never for HTML/CSS/React implementation advice in QML.
