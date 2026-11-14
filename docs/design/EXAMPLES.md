> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# Worked Examples

Small, complete compositions that apply the other pages together. Property and
signal names are read from the component sources in this repository; **the
snippets were not run in this documentation pass** (no Qt toolchain in the
environment). Treat them as the intended structure and confirm in the Showcase
(`cmake … -DMEOUI_BUILD_SHOWCASE=ON`) before copying into a product. Data objects
(`model`, `details`, `task`, `transactions`) belong to the host app.

Each example lists the rules it demonstrates, so it can be reviewed against the
checklists.

## 1. An app shell with adaptive navigation

Rules: `LAYOUT.md` §1–2, `NAVIGATION.md` §1–2, `APP_SHELL.md`.

```qml
import QtQuick
import MeoUI

MeoAppLayout {
    id: app
    pageTitle: currentRoute === "settings" ? qsTr("Settings") : ""
    navigationModel: [
        { id: "home",      route: "home",      label: qsTr("Home"),      icon: "home" },
        { id: "explore",   route: "explore",   label: qsTr("Explore"),   icon: "explore" },
        { id: "installed", route: "installed", label: qsTr("Installed"), icon: "apps" },
        { id: "updates",   route: "updates",   label: qsTr("Updates"),   icon: "system_update", badgeText: updates.count > 0 ? String(updates.count) : "" }
    ]
    pages: [homePage, explorePage, installedPage, updatesPage]
}
```

(Entry keys: `label` or `text`, `icon`, `route` or `id`, `badgeText`,
`badgeCount`, `badgeDot`. `MeoAppLayout` appends Settings and About routes
itself.)

## 2. A store Home page

Rules: `LAYOUT.md` §3, `CARDS.md`, `PROGRESS.md` §4, `STATES.md` §1.

```qml
MeoPageLayout {
    title: qsTr("Home")

    MeoLoadingFeedback {
        Layout.fillWidth: true
        active: home.loading
        placeholder: Component { /* skeleton cards with final height */ }
    }

    MeoEmptyState {
        visible: home.failed
        icon: "cloud_off"
        title: qsTr("Couldn't load Home")
        description: qsTr("Check your connection, then try again.")
        actionText: qsTr("Try again")
        onActionClicked: home.reload()
    }

    MeoListHeader { text: qsTr("Recommended"); visible: home.recommended.count > 0 }
    GridLayout {
        columns: metrics.preferredColumns
        Repeater { model: home.recommended; delegate: AppCard { } } // CARDS.md §8
    }
}
```

Shows: loading → skeleton, failed → one full-page state with one action, empty
section → no header, grid columns from `MeoWindowMetrics`.

## 3. Install with progress, then done or failed

Rules: `FORMS.md` §1, `PROGRESS.md` §3/§5, `STORE_FEEDBACK.md` §2, `STATES.md` §3.

```qml
RowLayout {
    spacing: MeoTheme.space12

    MeoButton {
        type: task.state === "failed" ? "outlined" : "filled"
        text: task.actionLabel                // Install · Installing… · Open · Retry
        loading: task.state === "running" && task.fraction < 0
        enabled: task.state !== "queued"
        onClicked: task.primary()
    }

    ColumnLayout {
        visible: task.state === "running"
        Layout.fillWidth: true
        MeoText { text: task.phaseText; typeRole: "label"; typeSize: "medium" }
        MeoProgressBar { Layout.fillWidth: true; indeterminate: task.fraction < 0; value: Math.max(0, task.fraction) }
    }

    MeoIconButton {
        visible: task.canCancel
        type: "standard"; icon.name: "close"; toolTipText: qsTr("Cancel")
        onClicked: task.cancel()
    }
}

MeoSnackbar {
    id: done
    message: qsTr("%1 installed.").arg(task.name)
    actionText: qsTr("Open")
    onActionClicked: task.open()
}
```

Shows: one primary button with a fixed slot, determinate vs indeterminate
bar, cancel only when possible, one completion snackbar (not per percent).

## 4. Confirm removal (and undo for reversible actions)

Rules: `DIALOGS.md` §2–3, `WRITING.md` §3.

```qml
MeoDialog {
    id: remove
    icon: "warning"
    title: qsTr("Remove %1?").arg(target.name)
    message: qsTr("The app and its cached data are removed from this device. This can't be undone.")
    confirmText: qsTr("Remove")
    onConfirmed: transactions.remove(target.id)
    onDismissed: { /* Escape or outside click = cancel */ }
}
```

For a reversible action (hide an app, archive), skip the dialog and show a
`MeoSnackbar { message: qsTr("App hidden."); actionText: qsTr("Undo") }`.

## 5. Offline with cached data

Rules: `STATES.md` §4–5.

```qml
MeoBanner {
    visible: network.offline
    Layout.fillWidth: true
    tone: "warning"; icon: "cloud_off"
    title: qsTr("You're offline")
    text: qsTr("Showing what was saved on %1.").arg(cache.updatedText)
    confirmText: qsTr("Retry")
    onConfirmed: network.retry()
}
```

## 6. A Settings-style group

Rules: `SETTINGS.md`, `LISTS.md`, `FORMS.md` §3.

```qml
MeoSettingsGroup {
    MeoSettingsRow {
        title: qsTr("Notify me about updates")
        subtitle: qsTr("Checked every 6 hours.")
        leadingIcon: "notifications"
        trailingKind: "switch"
        checked: settings.notifyUpdates
        onToggled: settings.notifyUpdates = checked
    }
    MeoSettingsRow {
        title: qsTr("Update channel")
        leadingIcon: "alt_route"
        trailingKind: "value"
        trailingText: settings.channelName
        onActivated: channelSheet.open()   // MeoSettingsTaskSheet, level 3
    }
}
```

(`MeoSettingsRow` signals: `activated()`, `toggled(bool checked)`,
`actionTriggered()`, `sliderMoved(real)`, `optionSelected(int, var)`,
`dropdownSelected(int, string)`.)

## 7. How to review a page against these docs

1. Pick the page type (`PAGE_TYPES.md`) and layout (`LAYOUT.md`).
2. Walk the state matrix (`STATES.md` §1) and confirm every state exists.
3. Check each component against its page checklist (cards, lists, forms,
   dialogs, progress).
4. Check wording (`WRITING.md` §9) and accessibility (`FOUNDATIONS.md` §10).
5. Run the narrowest validation (`FOR_AGENTS.md` "Validation") and report the
   evidence level honestly.
