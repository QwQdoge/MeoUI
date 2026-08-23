# Page and Hierarchy Contract

MeoUI page names describe the user's task and hierarchy; they are not generic
aliases for a large column of cards. Product registries should declare each
setting's `pageKind`, `depth`, `risk`, `presentation`, and `authority`.

| Type | Depth | Use | Must not do |
| --- | ---: | --- | --- |
| `settings-index` | Entry | Search, recent/frequent items, and first-level categories | Become a permanent third-level route |
| `settings-category` | 1 | One unambiguous domain such as Network or Storage | Mix unrelated system tools |
| `settings-detail` | 2 | A complete focused control or live inspector | Push another persistent settings page |
| `task-page` | 2 | A long-running, privileged, destructive, or recovery-sensitive task | Be reduced to a short drawer |
| `info-page` | 1 or 2 | Facts, diagnostics, and About views | Pretend stale or sampled data is live |
| `settings-task-sheet` | transient level 3 | A small choice, credential field, read-only drill-in, confirmation, or one setting edit | Enter history, nest, or become level 4 |
| `external-handoff` | 2 | A maintained KDE/system tool with explicit ownership | Claim Meo implements that tool |

## Two-level rule

Settings normally uses a Mac-like two-pane mental model:

1. The sidebar, index, or compact category drawer selects a first-level domain.
2. The content area presents the complete second-level setting or its clear
   category list.

Level three is always an overlay. It must close on completion, cancellation,
or navigation, and it is not pushed into `MeoPageHost` or browser history.
`MeoSettingsTaskSheet` is the supplied transient pattern; the persistent
`MeoSideSheet` is not a replacement for it.

Long-running backup/restore work, a destructive disk action, partitioning,
formatting, encryption, or a system reset are deliberate exceptions: they are
second-level task pages or a maintained external handoff because they need
progress, confirmation, error handling, and recovery information.

## Registry metadata

Each Settings entry should declare:

```text
pageKind: settings-category | detail | task | info | handoff
depth: 1 | 2
risk: read-only | reversible | system | privileged | recovery-sensitive
presentation: page | external
authority: meo | kde | external-system
iconTone: primary | secondary | tertiary | neutral | error
```

An overlay is intentionally absent from the registry: it belongs to a specific
second-level page and closes before another route can take over.

## Dynamic-color prerequisite

Every visible Meo/KDE product page, including category indexes, must consume a
complete `MeoTheme` dynamic role table before it is treated as ready. A source
picker (KDE accent, wallpaper, or manual seed) is a transient level-three
`settings-task-sheet` owned by the Appearance detail page; it is not a global
route and it cannot introduce a second palette. The platform generator applies
the selected source atomically, then all MeoUI consumers receive the same HCT
roles through `MeoTheme`.
