# MeoUI Showcase coverage

The maintained coverage gate is `../../tools/verify-showcase-coverage.py`.
It reads public exports from `qmldir`, requires every one to appear in
`ShowcaseCatalog.qml`, and requires every catalog entry to have a direct,
non-fallback sample in `ShowcaseSampleDelegate.qml`.

This is a strict 100% gate for the public **QML exports named by `qmldir`**.
It does not mechanically determine coverage of theme tokens, C++ runtime APIs,
assets, or behavior quality. Each Showcase refresh must therefore add a
reader-facing delivery checklist to its validation run for changed non-QML
items, stating how each is represented in the Showcase or separately evidenced
and why any item has no visual sample.

`../../tools/build-showcase.sh` runs that gate before configuring or building
`MeoShowcaseDemo`. Do not replace the check with a manually maintained total
or a generic fallback sample. Save build, runtime, visual, and manual-review
evidence under `/home/shekong/Projects/outputs/meo-ui/validation/<UTC-run-id>/`.

Historical reports with obsolete component counts were moved to the MeoUI
Obsidian archive so they cannot be mistaken for current coverage evidence.

## Build and runtime outputs

The maintained launchers put new material under
`/home/shekong/Projects/outputs/meo-ui/`: build products in `build/`, staged
installs in `install/`, and one evidence folder per invocation in
`validation/YYYY-MM-DDTHHMMSSZ-short-label/`. Command-line paths take priority,
then their matching environment variables; the Linux default is
`MEO_OUTPUT_ROOT` (or the workspace output root). The PowerShell default is the
cross-platform sibling `../outputs` directory and never hard-codes a Linux
path.

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
