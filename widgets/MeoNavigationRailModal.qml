import QtQuick
import QtQuick.Controls
import MeoUI

// M3 Expressive's modal expanded navigation rail. This is intentionally a
// distinct popup rather than a `modal` flag on MeoNavigationRail: a docked
// Rectangle cannot provide the overlay, dismissal, focus, or lifecycle
// contract of a modal surface.
MeoMotionPopup {
    id: control
    presentation: MeoMotionPopup.SideSheet
    parent: Overlay.overlay

    property var model: []
    property int currentIndex: 0
    property string currentId: ""
    property real expandedWidth: 280 * themeGlobalScale
    property Component header: null
    property Component footer: null
    property string labelType: "always"
    property bool closeOnDestination: false

    signal clicked(int index)
    signal activated(var item, int index)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property real minimumWidth: 220 * themeGlobalScale
    readonly property real maximumWidth: 360 * themeGlobalScale
    readonly property real resolvedWidth: Math.max(minimumWidth,
                                                  Math.min(maximumWidth, expandedWidth))
    readonly property int destinationCount: {
        if (!model)
            return 0
        if (typeof model.count === "number")
            return model.count
        return typeof model.length === "number" ? model.length : 0
    }

    x: 0
    y: 0
    width: parent ? Math.min(parent.width, resolvedWidth) : resolvedWidth
    height: parent ? parent.height : 600 * themeGlobalScale
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    // NavigationRailExpandedTokens specifies CornerLarge for the modal
    // expanded rail (the docked rail remains square).  Do not inherit the
    // fullscreen side-sheet shape merely because this popup occupies the
    // leading edge.
    surfaceRadius: MeoTheme.shapeLarge
    surfaceColor: MeoTheme.surfaceContainer

    function destinationAt(index) {
        if (!model || index < 0 || index >= destinationCount)
            return null
        return typeof model.get === "function" ? model.get(index) : model[index]
    }

    function syncCurrentId() {
        const item = destinationAt(currentIndex)
        if (!item || item.type === "header" || item.id === undefined || item.id === null)
            return
        currentId = String(item.id)
    }

    function syncCurrentIndex() {
        if (currentId === "")
            return
        for (let index = 0; index < destinationCount; ++index) {
            const item = destinationAt(index)
            if (item && item.type !== "header" && item.id !== undefined
                    && String(item.id) === currentId) {
                if (currentIndex !== index)
                    currentIndex = index
                return
            }
        }
    }

    onCurrentIndexChanged: syncCurrentId()
    onCurrentIdChanged: syncCurrentIndex()
    onModelChanged: {
        if (currentId === "")
            syncCurrentId()
        else
            syncCurrentIndex()
    }

    // MeoMotionPopup's generic side sheet enters from the right. Navigation
    // rails occupy the leading edge, so their modal configuration enters from
    // the left while retaining the shared M3 sheet motion token.
    enter: Transition {
        NumberAnimation {
            property: "x"
            from: MeoTheme.reduceMotion ? 0 : -control.width
            to: 0
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSheetEnter
            easing.bezierCurve: MeoTheme.motionEasingEnter
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "x"
            from: 0
            to: MeoTheme.reduceMotion ? 0 : -control.width
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationSheetExit
            easing.bezierCurve: MeoTheme.motionEasingExit
        }
    }

    contentItem: Item {
        objectName: "meoNavigationRailModalSurface"
        Accessible.role: Accessible.Dialog
        Accessible.name: "Navigation"

        MeoNavigationRail {
            id: rail
            anchors.fill: parent
            model: control.model
            currentIndex: control.currentIndex
            currentId: control.currentId
            isExpanded: true
            expandedWidth: control.resolvedWidth
            header: control.header
            footer: control.footer
            labelType: control.labelType
            resizeInstantly: MeoTheme.reduceMotion

            onClicked: function(index) {
                control.currentIndex = index
                control.clicked(index)
                if (control.closeOnDestination)
                    control.close()
            }
            onActivated: function(item, index) {
                control.currentId = item && item.id !== undefined && item.id !== null
                                  ? String(item.id) : rail.currentId
                control.activated(item, index)
            }
        }
    }
}
