# MeoUI Agent Rules

## Ownership

MeoUI owns platform-neutral MD3 tokens, reusable QML controls/patterns/layouts, accessibility/adaptive behavior, motion primitives, and the Showcase. Plasma/DBus/ISO/package-manager integration belongs in `meo-kde` or the owning application. Do not create private copies of shared controls elsewhere.

Before editing, inspect the affected component, semantic tokens/motion primitives, its public contract, a comparable implementation, and `git status`. Use `MeoTheme`, `MeoMotion`, `MeoTheme.globalScale`, `MeoWindowMetrics`, and the established icon system instead of hard-coded visual tokens or one-off animation APIs.

## Validation ladder

Run the narrowest relevant checks first.

- Design-system audit: `python3 tools/verify-design-system-usage.py --mode library MeoTheme.qml MeoMotion.qml components widgets patterns`.
- Normal Qt change: configure/build/CTest using the commands in `.github/workflows/qt-validation.yml`.
- Public QML export change: also run `tools/verify-showcase-coverage.py`; its mechanical 100% gate covers public `qmldir` QML exports only.
- Public visual/runtime behavior, tokens, reusable controls, or user-visible assets: refresh the relevant Showcase sample, build and run `MeoShowcaseDemo`, and retain inspectable evidence. Non-QML public behavior needs checklist/manual evidence because the QML coverage script cannot prove it.
- Docs/CI-only changes do not require a Showcase refresh unless they alter delivered UI/runtime behavior.

Never describe compilation, offscreen checks, screenshots, or unrun commands as stronger acceptance than they actually provide.

## Files and safety

Use `$MEO_DOCS_ROOT/Projects/meo-ui/` for plans/audits/decisions and `$MEO_OUTPUT_ROOT/meo-ui/{build,install,validation,packages,tmp}/` for generated output. A validation run should contain a short README plus the evidence actually produced. Do not add new output to repository `out/` or `artifacts/`, and do not invent machine-specific paths when the environment roots are unset.

Preserve unrelated dirty work; avoid destructive cleanup.
