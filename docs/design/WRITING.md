> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Writing for the Interface

Words are part of the component. English is the source language; every string
goes through `qsTr()` and is translated (`../localization.md`; `zh_CN` is the
first reviewed catalog). Write sources so they translate well.

## 1. Voice

- Plain, calm, specific. Say what happened and what the user can do.
- Address the user as "you" only when needed; prefer imperative verbs on
  buttons.
- No jargon the user did not choose ("transaction", "daemon", "backend")
  unless the product is a developer tool.
- No humor in errors; light friendliness in empty/success states is fine.
- No blame, no exclamation marks, no ALL CAPS.

## 2. Casing and punctuation

| Element | Style |
| --- | --- |
| Buttons, tabs, menu items, titles, headers | Sentence case ("Check for updates") |
| Product and brand names | As written (MeoArch, OmniStore, Meo Account) |
| Button labels | No trailing period; ellipsis `…` only when the action needs more input |
| Dialog, banner, snackbar | Full sentences with a period, except one-word titles |
| Placeholders | Examples, no period ("name@example.org") |
| Numbers | Locale-formatted via the framework; units after a space ("12.4 MB") |

## 3. Buttons

- Verb + object when ambiguous ("Remove Firefox"), verb alone when clear
  ("Install").
- Pairs: Cancel / the specific action. Never OK / Cancel, Yes / No.
- State labels change with state: Install → Installing → Open. Reserve width
  for the longest.
- "Retry" for failed operations, "Try again" in sentences.

## 4. Titles and headers

| Surface | Pattern | Example |
| --- | --- | --- |
| Page | Noun | "Installed", "Updates" |
| Section header | Noun phrase, count in parentheses | "Updates (3)" |
| Dialog | Question or verb + object | "Remove Firefox?" |
| Empty state | What is empty | "No apps installed yet" |
| Error | What failed | "Couldn't install Firefox" |
| Banner | Situation | "You're offline" |

## 5. Messages by situation

| Situation | Message |
| --- | --- |
| Success | "Firefox installed." (past tense, short) |
| Offline | "You're offline. Showing what was saved." |
| Failure | "Couldn't install Firefox. Not enough disk space." + Retry |
| Cancelled by user | "Installation cancelled." (no error tone) |
| Waiting | "Waiting for another change to finish." |
| Needs account | "Sign in to Meo Account to use AI." |
| Needs authorization | "Updating system packages needs your password." |
| Unknown cause | "Something went wrong. Try again, or open the log." |
| Destructive | "The app and its cached data are removed. This can't be undone." |
| Empty search | "No results for “firefox”" |
| Rate limit (provider) | "Your AI provider is limiting requests. Try again later." |

## 6. Tooltips and accessible names

- Tooltip = the action ("Refresh"), not a sentence.
- Accessible name = what the control is or does; for an icon button it equals
  the tooltip. For an item, name + state ("Firefox, installed, update
  available").
- Progress: "Downloading Firefox, 40 percent" (updates announced on phase
  change, not each percent).
- Never rely on the visible icon, color or position in the name.

## 7. Localization-safe writing

- Whole sentences, never concatenated pieces; use `qsTr("Remove %1?").arg(name)`
  and plural forms via `qsTr("%n app(s)", "", count)`.
- Leave room: translations run up to ~40% longer (German, Russian) and Chinese
  is shorter but taller (line height).
- Don't embed formatting in strings (no bold fragments inside a sentence).
- Do not translate or alter identifiers: package names, command names, paths.
- Dates, sizes, numbers: format by locale, not by hand.
- A translated string is never a key or a stored value (`FOR_AGENTS.md`).

## 8. Do and don't

| Don't | Do |
| --- | --- |
| "Are you sure you want to proceed?" | "Remove Firefox?" |
| "Error 502" | "Couldn't reach the server. Try again." |
| "Operation failed." | "Couldn't update 2 apps. See details." |
| "Click here" | "View log" |
| "Invalid input" | "Use at least 8 characters" |
| "OK" | "Got it" (info) / the action verb |
| "Please wait…" with no context | "Downloading Firefox…" |
| "No data" | "Nothing here yet" + what to do |

## 9. Checklist

- [ ] All strings in `qsTr()`; no concatenated fragments.
- [ ] Buttons are verbs; dialogs ask the real question.
- [ ] Every error says what failed and what to do.
- [ ] Sentence case; no exclamation marks; no codes in headlines.
- [ ] Accessible names are specific and state-aware.
