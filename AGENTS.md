# MeoUI Development Guidelines

MeoUI is a standalone Qt Quick / QML Material Design 3 component library.

- Keep the library independent from OS image, packaging, workflow, and release automation files.
- Use `MeoTheme.qml` tokens for color, spacing, shape, motion, and typography.
- Multiply pixel values by `MeoTheme.globalScale`.
- Keep showcase pages under `showcase/`; reusable controls belong in `components/`, `widgets/`, or `patterns/`.
- Prefer out-of-source builds under `out/`.
