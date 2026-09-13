import QtQuick
import MeoUI

Item {
    id: control

    property url source
    property Component sourceComponent
    // URL pages can receive their required construction properties before
    // Component.onCompleted runs. This keeps deep links from briefly rendering
    // with defaults.
    property var sourceProperties: ({})
    property var componentProperties: ({})
    // A changing key can intentionally reload the same URL with different
    // properties, such as two KCM routes sharing one page component.
    property string pageKey: ""
    property int direction: 1
    property real transitionDistance: 32 * MeoTheme.globalScale
    // URL-backed pages are compiled and instantiated across frames so route
    // changes do not monopolize the GUI thread. Component-backed routes keep
    // their normal synchronous construction semantics in Qt.
    property bool asynchronous: true
    // A URL-loaded page is usually a lightweight Item with no implicit size.
    // The host owns the viewport, so make every loaded page fill it instead of
    // requiring each page root to repeat anchors.fill: parent.
    property bool fillLoadedItem: true
    // A host that knows the target page geometry can provide a detailed
    // skeleton. Without one, MeoLoadingFeedback falls back to the compact M3E
    // indicator after its anti-flash delay.
    property Component loadingPlaceholder: null
    property int loadingDelay: loadingPlaceholder !== null ? 0 : MeoTheme.loadingFeedbackDelay
    // A page that has finished constructing must never be held behind a
    // cosmetic minimum display time. Callers can opt into a longer hold for a
    // special transition, but the latency-safe default reveals content on the
    // same turn that Loader reports it ready.
    property int loadingMinimumVisibleDuration: 0
    property string loadingAccessibleName: qsTr("Loading page")
    readonly property var currentItem: activeSlot === 0 ? firstLoader.item : secondLoader.item
    // Route identity follows the page that has completed its visual handoff.
    // readyPageKey identifies the most recently constructed page and is useful
    // to hosts that need to acknowledge an asynchronous load before the
    // transition settles.
    readonly property string currentPageKey: committedPageKey
    readonly property string readyPageKey: loadedPageKey
    readonly property bool transitioning: pageTransition.running
    readonly property bool loading: requestInFlight
    readonly property bool loadingFeedbackVisible: loadingFeedback.feedbackVisible
    readonly property int enterDuration: MeoTheme.motionDurationPageEnter
    readonly property int exitDuration: MeoTheme.motionDurationPageExit

    signal pageLoaded(Item item)

    property int activeSlot: 0
    property int pendingSlot: 0
    property bool initialized: false
    property bool componentReady: false
    property bool requestQueued: false
    property bool transitionRequestPending: false
    property bool requestInFlight: false
    property int requestSerial: 0
    property int pendingDirection: 1
    property int transitionDirection: 1
    property string pendingPageKey: ""
    property string committedPageKey: ""
    property string loadedPageKey: ""
    property var pendingComponentProperties: ({})
    property var incomingLoader: firstLoader
    property var outgoingLoader: secondLoader

    clip: true

    function loaderForSlot(slot) {
        return slot === 0 ? firstLoader : secondLoader
    }

    function applyProperties(item, properties) {
        if (!item || !properties)
            return
        for (const propertyName in properties)
            item[propertyName] = properties[propertyName]
    }

    function sizeLoadedItem(loader) {
        if (!fillLoadedItem || !loader || !loader.item)
            return
        loader.item.x = 0
        loader.item.y = 0
        loader.item.width = loader.width
        loader.item.height = loader.height
    }

    function clearLoader(loader) {
        if (!loader)
            return
        loader.sourceComponent = null
        loader.source = ""
        loader.opacity = 0
        loader.x = 0
        loader.scale = 1
        loader.enabled = false
    }

    function schedulePageRequest() {
        if (!componentReady || requestQueued)
            return
        requestQueued = true
        Qt.callLater(function() {
            requestQueued = false
            requestPage()
        })
    }

    function showPage(nextSource, properties, nextDirection, key) {
        sourceProperties = properties || ({})
        direction = nextDirection === undefined ? 1 : nextDirection
        sourceComponent = null
        source = nextSource
        pageKey = key === undefined ? String(nextSource) : key
        schedulePageRequest()
    }

    function showComponent(nextComponent, properties, nextDirection, key) {
        componentProperties = properties || ({})
        direction = nextDirection === undefined ? 1 : nextDirection
        source = ""
        sourceComponent = nextComponent
        pageKey = key === undefined ? "" : key
        schedulePageRequest()
    }

    function requestPage() {
        const hasUrl = source && String(source).length > 0
        // A QML Component property can be represented as either null or
        // undefined while it is cleared. Treat only a real component as a
        // component route; otherwise URL pages would silently never load.
        const hasComponent = !!sourceComponent
        if (!hasUrl && !hasComponent)
            return

        // A new destination must never complete the active animation by
        // jumping it to its final frame. Keep the current handoff continuous,
        // coalesce repeated navigation to the latest public source/key, and
        // load that destination as soon as the two-slot handoff is complete.
        if (pageTransition.running) {
            transitionRequestPending = true
            return
        }

        transitionRequestPending = false
        requestInFlight = true
        requestSerial += 1
        pendingDirection = direction < 0 ? -1 : 1
        pendingPageKey = pageKey
        pendingComponentProperties = componentProperties || ({})
        pendingSlot = initialized ? 1 - activeSlot : 0
        incomingLoader = loaderForSlot(pendingSlot)
        outgoingLoader = loaderForSlot(activeSlot)
        incomingLoader.requestId = requestSerial
        if (hasComponent) {
            incomingLoader.source = ""
            // Clearing first also makes a changed pageKey reload the same
            // Component with a fresh construction-property snapshot.
            incomingLoader.sourceComponent = null
            incomingLoader.sourceComponent = sourceComponent
        } else {
            incomingLoader.sourceComponent = null
            incomingLoader.setSource(source, sourceProperties)
        }
    }

    function beginTransition(loader, loadedRequestId) {
        if (loader !== incomingLoader || loadedRequestId !== requestSerial)
            return
        requestInFlight = false
        sizeLoadedItem(loader)
        if (loader.sourceComponent)
            applyProperties(loader.item, pendingComponentProperties)
        loadedPageKey = pendingPageKey
        pageLoaded(loader.item)
        if (!initialized) {
            activeSlot = pendingSlot
            initialized = true
            committedPageKey = pendingPageKey
            loader.opacity = 1
            loader.x = 0
            loader.scale = 1
            loader.enabled = true
            return
        }

        if (MeoTheme.reduceMotion) {
            incomingLoader.opacity = 1
            incomingLoader.x = 0
            incomingLoader.scale = 1
            activeSlot = pendingSlot
            committedPageKey = pendingPageKey
            if (outgoingLoader !== incomingLoader)
                clearLoader(outgoingLoader)
            incomingLoader.enabled = true
            if (transitionRequestPending)
                schedulePageRequest()
            return
        }

        transitionDirection = pendingDirection
        incomingLoader.opacity = 0
        incomingLoader.x = transitionDistance * transitionDirection
        incomingLoader.scale = 0.992
        incomingLoader.enabled = true
        outgoingLoader.opacity = 1
        outgoingLoader.x = 0
        outgoingLoader.scale = 1
        outgoingLoader.enabled = false
        pageTransition.restart()
    }

    // Coalesce property notifications. A `showPage()` call updates source,
    // properties, and key together; loading once on the next event-loop turn
    // prevents those notifications from successively replacing and clearing
    // the two Loader slots.
    onSourceChanged: schedulePageRequest()
    onSourceComponentChanged: schedulePageRequest()
    onPageKeyChanged: schedulePageRequest()
    Component.onCompleted: {
        componentReady = true
        schedulePageRequest()
    }

    Loader {
        id: firstLoader
        property int requestId: 0
        asynchronous: control.asynchronous
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        onWidthChanged: control.sizeLoadedItem(firstLoader)
        onHeightChanged: control.sizeLoadedItem(firstLoader)
        onLoaded: {
            control.sizeLoadedItem(firstLoader)
            const loadedRequestId = firstLoader.requestId
            if (firstLoader === control.incomingLoader)
                Qt.callLater(function() { control.beginTransition(firstLoader, loadedRequestId) })
        }
        onStatusChanged: {
            if (status === Loader.Error && firstLoader === control.incomingLoader)
                control.requestInFlight = false
        }
    }

    Loader {
        id: secondLoader
        property int requestId: 0
        asynchronous: control.asynchronous
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        opacity: 0
        onWidthChanged: control.sizeLoadedItem(secondLoader)
        onHeightChanged: control.sizeLoadedItem(secondLoader)
        onLoaded: {
            control.sizeLoadedItem(secondLoader)
            const loadedRequestId = secondLoader.requestId
            if (secondLoader === control.incomingLoader)
                Qt.callLater(function() { control.beginTransition(secondLoader, loadedRequestId) })
        }
        onStatusChanged: {
            if (status === Loader.Error && secondLoader === control.incomingLoader)
                control.requestInFlight = false
        }
    }

    MeoLoadingFeedback {
        id: loadingFeedback
        objectName: "meoPageHostLoadingFeedback"
        anchors.fill: parent
        z: 100
        active: control.requestInFlight
        delay: control.loadingDelay
        minimumVisibleDuration: control.loadingMinimumVisibleDuration
        placeholder: control.loadingPlaceholder
        accessibleName: control.loadingAccessibleName
    }

    ParallelAnimation {
        id: pageTransition

        NumberAnimation {
            target: control.incomingLoader
            property: "opacity"
            to: 1
            duration: control.enterDuration
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
        NumberAnimation {
            target: control.incomingLoader
            property: "x"
            to: 0
            duration: control.enterDuration
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
        NumberAnimation {
            target: control.incomingLoader
            property: "scale"
            to: 1
            duration: control.enterDuration
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
        NumberAnimation {
            target: control.outgoingLoader
            property: "opacity"
            to: 0
            duration: control.exitDuration
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandardAccelerate
        }
        NumberAnimation {
            target: control.outgoingLoader
            property: "x"
            to: -control.transitionDistance * 0.35 * control.transitionDirection
            duration: control.exitDuration
            easing.type: Easing.BezierSpline; easing.bezierCurve: MeoTheme.motionEasingStandardAccelerate
        }

        onFinished: {
            control.activeSlot = control.pendingSlot
            control.committedPageKey = control.pendingPageKey
            control.clearLoader(control.outgoingLoader)
            control.incomingLoader.enabled = true
            if (control.transitionRequestPending)
                control.schedulePageRequest()
        }
    }
}
