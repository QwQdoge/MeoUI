# MeoUI localization and accessibility contract

MeoUI owns reusable presentation strings and accessible labels. It does not
store a user, account, or desktop language preference: the application that
hosts MeoUI resolves that preference and loads the matching catalog before it
creates its first QML object.

## Language precedence

Use the system UI language by default. A signed-in account may carry a
language preference for synchronization, but it must be an explicit user
choice rather than a silent override of the current device. Hosts should offer
both choices and pass the resolved language consistently to their QML engine,
AI features, and account surfaces. A user can always return to system language.

The Showcase follows `QLocale::system()` by default and accepts
`--ui-language=<locale>` for validation. Its `zh_CN` catalog is loaded before
the QML root is created, so the first frame is already localized.

## Catalog workflow

- Source strings use `qsTr()` in their owning QML file. Do not use translated
  text as an identifier, configuration key, model ID, or persisted value.
- Put reviewed Chinese translations in `translations/meoui_zh_CN.ts`. The
  CMake `meoui_update_translations` target discovers newly added source
  strings; review its diff and translate every new user-facing entry before a
  catalog release.
- The build creates `meoui_zh_CN.qm` and installs it to
  `share/meoui-qml/translations`. A host loads that catalog with `QTranslator`,
  calls `QLocale::setDefault(...)` and `engine.setUiLanguage(...)`, and then
  `engine.retranslate()` when the user changes language. This first catalog is
  specifically `zh_CN`; an unavailable locale falls back to English instead
  of substituting a different Chinese script.
- English is the source-language fallback. Do not claim a locale is complete
  merely because a catalog file exists.

## Accessible language

Visible labels, placeholders, validation messages, and `Accessible.name` /
`Accessible.description` are all user-facing strings and must localize
together. Provide a concise action or state, not an implementation note. For
icon-only actions, name the outcome (for example, “Previous month”), and keep
keyboard activation and focus behavior available alongside pointer input.

Dates and times keep locale-neutral data values. Components expose a
`uiLocale` presentation property so month names, weekday order, date summaries,
spoken labels, and the default hour cycle can follow the resolved language
without changing stored data.
