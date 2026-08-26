# MeoUI Agent Rules

## Ownership

- MeoUI owns platform-neutral MD3 tokens, reusable QML controls, patterns, layouts, accessibility/adaptive behavior, and the Showcase.
- Keep Plasma, DBus, ISO, package-manager, and other OS-specific integration in `meo-kde` or the owning application. Do not create private copies of shared MeoUI controls elsewhere.
- Inspect the relevant component, tokens, comparable implementation, Git status, and public contract before editing. Preserve unrelated dirty work.

## Repository hygiene

- New root-level content is limited to entry documentation, source directories, and necessary build/release configuration. Never add loose plans, architecture drafts, audits, journals, screenshots, or generated logs to the repository root.
- `docs/` is only for maintained public contracts tied to code. Put plans, audits, decisions, agent journals, and historical reports in `/home/shekong/Documents/Obsidian Vault/MeoArch/Projects/meo-ui/`, using the numbered `00-inbox/`, `01-overview/`, `02-decisions/`, `03-work/`, `04-validation/`, and `99-archive/` folders described by that project's reader-facing `README.md`.
- Put generated material only in `/home/shekong/Projects/outputs/meo-ui/{build,install,validation,packages,tmp}/`: compiler results, staged installs, evidence, releasable packages, and disposable work respectively. Every validation run is `validation/<UTC-run-id>/` and includes a `README.md` plus evidence. Do not write new results to repository `out/` or `artifacts/`; leave existing legacy content untouched unless a separately approved migration says otherwise.

## Implementation and Showcase gate

- Use `MeoTheme` semantic tokens, `MeoTheme.globalScale`, `MeoWindowMetrics`, existing motion primitives, and the established icon system. Do not hard-code visual tokens or duplicate existing controls.
- Keep a control's layout ownership, hit target, visual container, state, and intrinsic sizing contract explicit.
- Any MeoUI delivery change—tokens, QML, C++, assets, public contracts, build, or packaging—requires a Showcase refresh. `tools/verify-showcase-coverage.py` provides a 100% mechanical gate only for public QML exports in `qmldir`: every export must be catalogued and have a direct, non-fallback sample. It does not mechanically prove token use, C++ runtime APIs, assets, or behavioral quality.
- For every refresh, keep a reader-facing delivery checklist in the validation run that identifies how each changed non-QML delivery item is represented in the Showcase or separately evidenced, including explicit reasons for any non-visual item. Build **and run** `MeoShowcaseDemo`; save that checklist, QML coverage result, build/run logs, and inspectable visual evidence under `/home/shekong/Projects/outputs/meo-ui/validation/<UTC-run-id>/`. A successful build or offscreen check is not a substitute for the evidence it does not produce.

## Validation and claims

- Run the narrowest relevant checks first, then the required broader checks. Record commands and outcomes only after they actually ran.
- State the boundary between static, offscreen, runtime, and manual acceptance. Never describe unsupported commands or unperformed checks as verified.
