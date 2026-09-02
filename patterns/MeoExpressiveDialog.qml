import QtQuick
import MeoUI

// Compatibility pattern for applications that previously selected an
// "expressive" dialog. Material 3 supplies one source-backed basic-dialog
// contract; this wrapper preserves the custom-content entry point while
// delegating surface, semantics, focus, actions, and motion to MeoDialog.
MeoDialog {
    id: control

    property Component content: null

    supportingContent: content
    preferredDialogWidth: 400 * MeoTheme.globalScale
}
