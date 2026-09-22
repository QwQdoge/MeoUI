# MeoUI Showcase coverage

The maintained coverage gate is `../../tools/verify-showcase-coverage.py`.
It reads public exports from `qmldir`, requires every one to appear in
`ShowcaseCatalog.qml`, and requires every catalog entry to have a direct,
non-fallback sample in `ShowcaseSampleDelegate.qml`.

This is a strict one-to-one gate for the public **QML exports named by
`qmldir`**: every export has exactly one canonical `ShowcaseCatalog.qml`
entry, and every catalog entry is a public export with a direct sample. Labs
and visual-mode studies must reference canonical exports instead of adding
aliases such as a second “Expressive button” entry. It does not mechanically
determine coverage of theme tokens, C++ runtime APIs, assets, or behavior
quality. Each Showcase refresh must therefore add a
reader-facing delivery checklist to its validation run for changed non-QML
items, stating how each is represented in the Showcase or separately evidenced
and why any item has no visual sample.

`../../tools/build-showcase.sh` runs that gate before configuring or building
`MeoShowcaseDemo`. Do not replace the check with a manually maintained total
or a generic fallback sample. Save build, runtime, visual, and manual-review
evidence under `$MEO_OUTPUT_ROOT/meo-ui/validation/<UTC-run-id>/`.

Historical reports with obsolete component counts belong in the external MeoUI
project archive and must not be mistaken for current coverage evidence.

## Build and runtime outputs

The maintained launchers put new material under the configured output root:
build products in `meo-ui/build/`, staged installs in `meo-ui/install/`, and
one evidence folder per invocation in
`meo-ui/validation/YYYY-MM-DDTHHMMSSZ-short-label/`. Command-line paths take
priority, then their matching environment variables. On Linux the default is
`MEO_OUTPUT_ROOT`; when it is unset, the launchers use the platform XDG state
directory instead of any developer-specific absolute path. The PowerShell
default remains a cross-platform relative output location.

- Linux build/run: `tools/build-showcase.sh --run --run-id <UTC-id>`.
- Linux launcher: `tools/run-showcase-linux.sh --run-id <UTC-id> --` followed
  by optional application arguments such as `--screenshot=showcase.png`.
- Windows: `tools/build-showcase.ps1 -Run -RunId <UTC-id>`.

All three write coverage, configure, build, install (when requested), and
runtime logs to the same validation run where applicable. `MeoShowcaseDemo`
also accepts `--validation-dir`, `--output-root`, and `--run-id`; its runtime
log defaults to the validation folder rather than the executable directory.
Relative screenshot paths are resolved inside that validation folder. The
standard MinGW CMake presets use the sibling output tree; use the matching
`*-output-root` preset after setting `MEO_OUTPUT_ROOT` to choose a different
root.
