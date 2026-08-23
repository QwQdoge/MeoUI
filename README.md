# MeoUI

MeoUI is the Material Design 3 / M3 Expressive QML component library used by the MeoArch workspace. The `MeoShowcaseDemo` target launches a finished showcase with token, component, widget, pattern, and layout pages.

The CMake target is a versioned shared runtime (`libmeoui.so.0`) with a
dynamically loaded QML plugin. Applications import `MeoUI 1.0`; they must not
embed or maintain private component copies.

The shared, verified MeoUI design-system reference lives at
`/home/shekong/Documents/Obsidian Vault/Meo UI/design system/`; the project-level
`$meoui` skill routes Codex there while keeping source code authoritative.

## Dynamic color and page contracts

Dynamic color is required for every visible Meo/KDE product session. MeoUI is
the platform-neutral consumer and validator of a complete Material/HCT role
table; the KDE bridge is its generator. An application must not derive a
palette from wallpaper or raw RGB/HSL, and it must not silently call a fixed
preview palette “dynamic.” See [the dynamic-color contract](docs/design/DYNAMIC_COLOR.md).

Settings-like applications use a declared page hierarchy: category/index,
complete second-level detail or task page, then only transient third-level
sheets. The full [page contract](docs/design/PAGE_TYPES.md) and
[Settings pattern](docs/design/SETTINGS.md) define ownership, safety, and
responsive navigation requirements.

## GitHub Pages Specification Site

The repository contains an interactive Material Design 3 component specification website in [`docs/`](docs/index.html). It displays all 89+ QML components, token tables, interactive search, code examples, and visual component image previews.

To host on GitHub Pages:
1. Enable GitHub Pages in repository settings.
2. Select `main` branch and `/docs` folder as the source.

## Requirements

- Qt 6 with `Core`, `Gui`, `Qml`, `Quick`, and `QuickControls2`
- CMake 3.16 or newer
- A C++17 compiler

Use an out-of-source build. The helper scripts below place generated files under `out/build/showcase` so source QML stays clean.

## Windows

From this directory:

```powershell
.\tools\build-showcase.ps1 -Config Release -Run
```

If Qt is not on `PATH`, pass the Qt prefix:

```powershell
.\tools\build-showcase.ps1 -QtPrefixPath "C:\Qt\6.7.3\msvc2019_64" -Config Release -Run
```

## Linux

From this directory:

```bash
./tools/build-showcase.sh --config Release --run
```

If Qt is installed in a custom prefix:

```bash
./tools/build-showcase.sh --qt-prefix "$HOME/Qt/6.7.3/gcc_64" --config Release --run
```

The Linux showcase release source package also includes `run-showcase-linux.sh`
at the package root:

```bash
tar -xzf meo-ui-showcase-linux-x64-source-0.3.1.tar.gz
cd meo-ui-showcase-linux-x64-source-0.3.1
./run-showcase-linux.sh
```

For a custom Qt install, set `MEO_UI_QT_PREFIX`:

```bash
MEO_UI_QT_PREFIX="$HOME/Qt/6.7.3/gcc_64" ./run-showcase-linux.sh
```

## Runtime Install

The release runtime package includes installer scripts for Linux and Windows.
They support `install`, `update`, `upgrade`, `verify`, and `uninstall`.

On Linux the default install root is `/opt/meo-ui`; bundled fonts are installed
under `/usr/local/share/fonts/meo-ui`. The script creates the compatibility
import path `/opt/meo-ui/qml/MeoUI` for existing `import MeoUI` applications.

```bash
tar -xzf meo-ui-runtime-0.3.1.tar.gz
cd meo-ui-runtime-0.3.1
./install-runtime.sh install
./install-runtime.sh verify
./install-runtime.sh update --yes
./install-runtime.sh upgrade --version 0.3.1
./install-runtime.sh uninstall
```

On Windows the default install root is `%LOCALAPPDATA%\MeoUI`, so a user-level
install does not require administrator privileges:

```powershell
.\tools\install-runtime.ps1 -Action install
.\tools\install-runtime.ps1 -Action verify
.\tools\install-runtime.ps1 -Action update -Yes
.\tools\install-runtime.ps1 -Action upgrade -Version 0.3.1
.\tools\install-runtime.ps1 -Action uninstall
```

Both scripts accept custom install locations. Use the reported `qml` directory
as the Qt import path.

```bash
./install-runtime.sh install --prefix "$HOME/.local/share/meo-ui" --font-dir "$HOME/.local/share/fonts/meo-ui"
```

```powershell
.\tools\install-runtime.ps1 -Action install -Prefix "$env:LOCALAPPDATA\MeoUI" -FontDir "$env:LOCALAPPDATA\MeoUI\fonts"
```

## Manual CMake

```bash
cmake -S . -B out/build/showcase -DCMAKE_BUILD_TYPE=Release
cmake --build out/build/showcase --target MeoShowcaseDemo
cmake --install out/build/showcase --prefix out/install/showcase
```

The install tree places the shared library under `lib` and the QML plugin,
type information, and inspectable QML sources under `lib/qt6/qml/MeoUI`.

On multi-config generators such as Visual Studio, add `--config Release` to the build and install commands.

## Showcase Coverage

The showcase entry point is `showcase/MeoShowcase.qml`. It includes pages for theme tokens, buttons, inputs, navigation, selection, display, feedback, patterns, data tables, expressive controls, component lab, widget lab, and layout lab.

`MeoWindowMetrics` uses five effective-pixel size classes: compact below 600 px, medium from 600–839 px, expanded from 840–1199 px, large from 1200–1599 px, and extra-large from 1600 px. Applications should consume its navigation mode, page margins, pane width, maximum content width, and adaptive column count rather than defining local breakpoints.
