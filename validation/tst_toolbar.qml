import QtQuick
import QtTest
import MeoUI 1.0
import "../components" as Components

Item {
    width: 800
    height: 480

    Components.MeoDockedToolbar {
        id: dockedToolbar
        width: 480
        actionIcons: ["archive", "delete", "more_vert"]
        selectedActionIndex: 1
    }

    Components.MeoDockedToolbar {
        id: vibrantDockedToolbar
        y: 80
        width: 480
        colorStyle: "vibrant"
        actionIcons: ["archive", "delete"]
    }

    Components.MeoDockedToolbar {
        id: disabledDockedToolbar
        y: 250
        width: 480
        actionIcons: [
            { "icon": "undo", "accessibleName": "Undo" },
            { "icon": "redo", "accessibleName": "Redo", "enabled": false }
        ]
    }

    Components.MeoFloatingToolbar {
        id: floatingToolbar
        y: 170
        actionIcons: ["format_bold", "format_italic", "more_vert"]
        selectedActionIndex: 0
    }

    Components.MeoFloatingToolbar {
        id: verticalFloatingToolbar
        x: 360
        y: 170
        orientation: "vertical"
        colorStyle: "vibrant"
        actionIcons: ["format_bold", "format_italic", "format_underlined"]
    }

    TestCase {
        name: "MeoExpressiveToolbar"
        when: windowShown

        function test_dockedToolbarContract() {
            compare(dockedToolbar.implicitHeight, 64 * MeoTheme.globalScale)
            compare(dockedToolbar.vibrant, false)
            compare(vibrantDockedToolbar.vibrant, true)
            compare(vibrantDockedToolbar.containerColor, MeoTheme.primary)
            compare(dockedToolbar.contentColor, MeoTheme.contentOnSurfaceVariant)
        }

        function test_objectActionsExposeDisabledState() {
            const undo = findChild(disabledDockedToolbar, "meoDockedToolbarAction_0")
            const redo = findChild(disabledDockedToolbar, "meoDockedToolbarAction_1")
            verify(undo !== null)
            verify(redo !== null)
            verify(undo.enabled)
            verify(!redo.enabled)
        }

        function test_floatingToolbarOrientationAndColor() {
            compare(floatingToolbar.horizontal, true)
            compare(verticalFloatingToolbar.horizontal, false)
            verify(verticalFloatingToolbar.implicitHeight > verticalFloatingToolbar.implicitWidth)
            compare(verticalFloatingToolbar.containerColor, MeoTheme.primary)
            verify(floatingToolbar.surfaceWidth >= 64 * MeoTheme.globalScale)
        }
    }
}
