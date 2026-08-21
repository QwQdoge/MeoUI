# MeoUI Development Guidelines

MeoUI is a standalone Qt Quick / QML Material Design 3 component library.

- Keep the library independent from OS image, packaging, workflow, and release automation files.
- Use `MeoTheme.qml` tokens for color, spacing, shape, motion, and typography.
- Multiply pixel values by `MeoTheme.globalScale`.
- Keep showcase pages under `showcase/`; reusable controls belong in `components/`, `widgets/`, or `patterns/`.
- Prefer out-of-source builds under `out/`.
- Put screenshots and visual acceptance evidence under
  `artifacts/validation/<run-id>/`; do not place generated images in the source
  component directories.

## UI/UX workflow

For every non-trivial UI change, follow `Understand → Design → Implement → Run → Inspect → Critique → Polish → Verify`.

- Use `$meoui` for the project design-system router and `$impeccable` for design/critique principles. MeoUI source and verified system rules take priority over generic design guidance.
- Inspect the relevant QML component, `MeoTheme.qml`, and a comparable implementation before editing. Prefer an existing component, then extension, then a reusable new component; do not duplicate controls or hard-code visual tokens.
- Keep parent layout ownership separate from a control's hit target, visual container, glyph size, state, and intrinsic sizing contract.
- Use semantic tokens, `globalScale`, `MeoWindowMetrics`, existing motion primitives, and the icon system. Check the states and accessibility/adaptive cases that apply.
- Run the narrowest relevant QML target and inspect runtime visual evidence for visual changes. A build alone is not visual acceptance.
