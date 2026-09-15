# Third-party notices

MeoUI's own code is MIT licensed. The items below retain their upstream
licenses; the corresponding full license texts are shipped in `assets/licenses`
or beside the font files in `assets/fonts`.

## AndroidX Graphics Shapes and Compose Material3

`components/MeoMaterialShapes.js`, `MeoMotion.qml`, and selected runtime token
values contain JavaScript/QML/C++ adaptations of algorithms, descriptors, and
tokens from AndroidX Graphics Shapes and Compose Material3.

- Source: https://android.googlesource.com/platform/frameworks/support/
- Referenced revisions: `9df4d001962d58aabca222967b8ceb1789acb960`,
  `27cf9a7d5788aa0f5f2d8b6699ce279560daf326`, and
  `64212d2a7941fd734599a75b73fc3750e8bb1cb3`
- License: Apache License 2.0 (`assets/licenses/Apache-2.0.txt`)
- Copyright 2024 The Android Open Source Project

## DankMaterialShell

The lifecycle ideas in `components/MeoMotionPopup.qml`,
`components/MeoListTransitions.qml`, and `components/MeoCachedImage.qml` were
adapted from small, identified portions of DankMaterialShell. The MeoUI code is
reimplemented for Qt Quick Controls and does not include Quickshell services,
theme data, or IPC code.

- Source: https://github.com/AvengeMedia/DankMaterialShell
- License: MIT (`assets/licenses/DankMaterialShell-MIT.txt`)
- Copyright 2025 Avenge Media LLC

## Material Symbols Rounded

`assets/fonts/MaterialSymbolsRounded.ttf` is the Material Symbols Rounded
variable font loaded by `components/MeoIcon.qml`.

- Source: https://github.com/google/material-design-icons
- Upstream reference revision: `84ccef280841abfac506afc4ad4a2782f6d0a1d0`
- Local asset SHA-256: `6bb7f46afab064c7d9ec6a865756b90dd68afb90bff85df209bdf03cfc0ecb17`
- License: Apache License 2.0 (`assets/licenses/Apache-2.0.txt`)
- Copyright 2022 Google LLC

## Roboto

`assets/fonts/Roboto-Regular.ttf`, `Roboto-Medium.ttf`, and `Roboto-Bold.ttf`
are redistributed font binaries.

- Source: https://github.com/googlefonts/roboto-classic
- Local asset SHA-256: `15256405ecb0d880678833a582760efad538ab2932318b52c8105b267d159459`
  (Regular), `79343dc641a2e8d48a703a4667b71fc8dc6565cc8ce47dfc34fc52c12aadbf38`
  (Medium), and `4aaf8c5b661a386998c2e70cf2b87e2440f5404e0b8fd81164f0413fb3435ec6`
  (Bold)
- License: SIL Open Font License 1.1 (`assets/fonts/OFL-Roboto.txt`)
- Copyright 2011 The Roboto Project Authors

## Comfortaa

`assets/fonts/Comfortaa-Bold.ttf` is redistributed font software.

- Source: https://github.com/googlefonts/comfortaa
- Local asset SHA-256: `492a6c62d53e4b0c8dbb1f4e53112b73a736537fb6a3a62eec26e0a6dbf92dee`
- License: SIL Open Font License 1.1 (`assets/fonts/OFL-Comfortaa.txt`)
- Copyright 2011 The Comfortaa Project Authors, with Reserved Font Name
  "Comfortaa"

## Impeccable authoring skill

The repository-local authoring support under `.agents/skills/impeccable` comes
from the Impeccable project. It is development tooling and is not installed by
the MeoUI runtime package.

- Source: https://github.com/pbakaus/impeccable
- License: Apache License 2.0 (`.agents/skills/impeccable/LICENSE`)
- Upstream notice: `.agents/skills/impeccable/NOTICE.md`; it also records the
  MIT-licensed `platform-design-skills` material distilled into the iOS and
  Android references.
- Copyright 2026 Paul Bakaus
