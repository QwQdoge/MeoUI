# Verified MeoUI components

Shared reference: `$MEOUI_DESIGN_SYSTEM_DIR/05-component-reference/README.md` when configured; otherwise use the repository-local generated `docs/design-system/05-component-reference/README.md` (with a paired English index and bilingual page for every exported component).

Primary sources:

- `CMakeLists.txt` QML module manifest
- `components/`, `widgets/`, and `patterns/`

Never assume a developer-specific documentation path. The CMake manifest determines what is exported by `import MeoUI 1.0`; component source determines its API and state behavior.
