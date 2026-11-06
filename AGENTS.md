## Workflow rules from the owner (override anything below)

- Commit directly on the repository's current/default branch (`main` unless the repo is deliberately on another working branch). Do not create feature branches or PR branches unless asked.
- After committing, push immediately. Do not ask for permission to commit or push, and do not leave finished work uncommitted or unpushed.
- Keep verification minimal: run only the quick check for the touched code (typecheck or the one relevant test). Do not run full suites or write extra tests unless asked.
- Do the whole task in one pass; do not stop to ask routine questions that have an obvious default.
- Never put secrets, tokens or credentials in code, logs or commits.

## MeoUI specification (read before UI work)

- People: https://meoarch.org/docs/ . Agents: https://meoarch.org/llms.txt , then the Markdown pages it lists; start with https://meoarch.org/docs/meoui/for-agents.md (decision tables and checklists).
- Window chrome and toolbar, where app settings live and their categories, About, and open-source credits: https://meoarch.org/docs/meoui/app-shell.md .
- The canonical source is this repository's `docs/design/` (plus `docs/api-lifecycle.md`, `docs/localization.md`). The site is generated from it: after changing these files, run `python3 scripts/build_docs.py` in meoarch-site and publish the site.

# MeoUI agent rules

## Start here

MeoUI is the shared, platform-neutral UI library. Before editing, inspect `git status`, the affected component/token, its nearest tests, and one comparable implementation when useful. Read only the docs/contracts needed for the change; do not perform a repository-wide audit by default.

Read `docs/api-lifecycle.md` before adding a replacement for an existing public control, reviving a legacy pattern, marking something experimental, or deleting/renaming public QML.

## Ownership

MeoUI owns reusable MD3 tokens, QML controls, patterns/layouts, motion primitives, accessibility/adaptive behavior, runtime tokens, and the Showcase.

Keep Plasma/KWin/DBus/system/package-manager behavior in meo-kde or the owning app. Consumers must import `MeoUI 1.0`; do not create private copies of shared controls.

Use `MeoTheme` semantic tokens, `MeoTheme.globalScale`, `MeoWindowMetrics`, existing motion primitives, and the established icon system. Do not hard-code a visual value when a suitable semantic token or shared primitive already exists.

Public components have a lifecycle classification. Deprecated compatibility APIs remain available for maintained consumers but are not preferred targets for new product work. Use `MeoDockedToolbar` for docked action-toolbar work (`MeoBottomAppBar` was removed; see the removal record in `docs/api-lifecycle.md`). Follow `docs/api-lifecycle.md` rather than deleting compatibility types opportunistically.

## Validation matrix

Run the narrowest relevant checks, then expand only when the public surface changed.

- Design-system/static usage:
  `python3 tools/verify-design-system-usage.py --mode library MeoTheme.qml MeoMotion.qml components widgets patterns`
- Normal Qt/QML change:
  `cmake --fresh -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_TESTING=ON -DMEOUI_BUILD_SHOWCASE=OFF`
  `cmake --build build --parallel 2`
  `QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure --timeout 60`
- Public QML export/catalog change: also run `python3 tools/verify-showcase-coverage.py`.
- Visible component/token/motion/layout behavior change: update the relevant Showcase sample and build/run the Showcase for visual inspection.
- Pure docs, test-only, packaging-only, or non-visible internal refactors do **not** require a full Showcase run unless they change a public/visible contract.

The Showcase coverage script proves catalog/sample coverage for public QML exports; it does not prove visual quality, C++ runtime behavior, assets, or real interaction.

## Cross-repository rule

If a requested change is generic and reusable, implement it here first. If it depends on Plasma, KWin, DBus, hardware, package management, or OS policy, keep that integration outside MeoUI and expose only the minimal generic UI/API needed here.

## Evidence and files

Distinguish static, offscreen, runtime, and manual visual acceptance. Never claim a level that was not run.

Keep maintained code contracts in `docs/`; project records belong under `$MEO_DOCS_ROOT/Projects/meo-ui/`. CI or direct CMake commands may use an ephemeral local build tree; retained build/install/validation/package output belongs under `$MEO_OUTPUT_ROOT/meo-ui/{build,install,validation,packages,tmp}/`. MeoUI's maintained tools may use their documented XDG-state fallback when `$MEO_OUTPUT_ROOT` is unset; otherwise do not invent machine-specific paths.

Preserve unrelated dirty work and avoid destructive cleanup.

## MeoArch documentation map

- Docs site: https://meoarch.org/docs/ (MeoUI specification: app shell, settings pattern, page types, dynamic color, API lifecycle, localization). Agent entry points: https://meoarch.org/llms.txt and https://meoarch.org/docs/meoui/for-agents.md. The canonical source is the MeoUI repository `docs/`; if they disagree, the repository wins.
- Packaging and releases: https://github.com/QwQdoge/meo-repo - read its `AGENTS.md`, `docs/MEOARCH_IMPLEMENTATION_RUNBOOK.md`, `manifests/{beta,stable}/` and the "MeoArch repository release" workflow (https://github.com/QwQdoge/meo-repo/actions/workflows/release.yml).
- Release approval: the `sign-and-publish` and AUR jobs wait on the protected `release` Environment. After the owner confirms in chat, agents approve with `gh api -X POST repos/QwQdoge/meo-repo/actions/runs/<run>/pending_deployments -F environment_ids[]=<id> -f state=approved` (details in meo-repo `AGENTS.md`); the owner can also use Actions -> "Review deployments" -> `release`.
- Before tagging a component for release: its source archive must extract cleanly (no tracked build output such as `target/`, no absolute symlinks) and its CI must be green; tag the newest green commit.
- Other repositories: MeoUI (design system), meo-kde (Plasma shell), meo-ai (Meo AI), meo-api (cloud API), MeoArch-account (account app), MeoSettings, MeoArch-os-workspace (ISO/installer/repair), OmniStore, meo-login-manager, meo-repo (packages), meoarch-site (meoarch.org).
