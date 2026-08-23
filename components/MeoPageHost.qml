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
    // A URL-loaded page is usually a lightweight Item with no implicit size.
    // The host owns the viewport, so make every loaded page fill it instead of
    // requiring each page root to repeat anchors.fill: parent.
    property bool fillLoadedItem: true
    readonly property var currentItem: activeSlot === 0 ? firstLoader.item : secondLoader.item
    readonly property bool transitioning: pageTransition.running

    signal pageLoaded(Item item)

    property int activeSlot: 0
    property int pendingSlot: 0
    property bool initialized: false
    property bool componentReady: false
    property bool requestQueued: false
    property var incomingLoader: firstLoader
    property var outgoingLoader: secondLoader

    clip: true

    function loaderForSlot(slot) {
        return slot === 0 ? firstLoader : secondLoader
    }

    function finishTransition() {
        if (!pageTransition.running)
            return
        pageTransition.complete()
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
        finishTransition()
        pendingSlot = initialized ? 1 - activeSlot : 0
        incomingLoader = loaderForSlot(pendingSlot)
        outgoingLoader = loaderForSlot(activeSlot)
        if (hasComponent) {
            incomingLoader.source = ""
            incomingLoader.sourceComponent = sourceComponent
        } else {
            incomingLoader.sourceComponent = null
            incomingLoader.setSource(source, sourceProperties)
        }
    }

    function beginTransition(loader) {
        sizeLoadedItem(loader)
        if (loader.sourceComponent)
            applyProperties(loader.item, componentProperties)
        pageLoaded(loader.item)
        if (!initialized) {
            activeSlot = pendingSlot
            initialized = true
            loader.opacity = 1
            loader.x = 0
            loader.scale = 1
            return
        }

        if (MeoTheme.reduceMotion) {
            incomingLoader.opacity = 1
            incomingLoader.x = 0
            incomingLoader.scale = 1
            activeSlot = pendingSlot
            if (outgoingLoader !== incomingLoader)
                outgoingLoader.source = ""
            outgoingLoader.opacity = 0
            outgoingLoader.x = 0
            outgoingLoader.scale = 1
            return
        }

        incomingLoader.opacity = 0
        incomingLoader.x = MeoTheme.reduceMotion ? 0 : transitionDistance * (direction < 0 ? -1 : 1)
        incomingLoader.scale = MeoTheme.reduceMotion ? 1 : 0.992
        outgoingLoader.opacity = 1
        outgoingLoader.x = 0
        outgoingLoader.scale = 1
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
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        onWidthChanged: control.sizeLoadedItem(firstLoader)
        onHeightChanged: control.sizeLoadedItem(firstLoader)
        onLoaded: {
            control.sizeLoadedItem(firstLoader)
            if (firstLoader === control.incomingLoader)
                Qt.callLater(function() { control.beginTransition(firstLoader) })
        }
    }

    Loader {
        id: secondLoader
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        opacity: 0
        onWidthChanged: control.sizeLoadedItem(secondLoader)
        onHeightChanged: control.sizeLoadedItem(secondLoader)
        onLoaded: {
            control.sizeLoadedItem(secondLoader)
            if (secondLoader === control.incomingLoader)
                Qt.callLater(function() { control.beginTransition(secondLoader) })
        }
    }

    ParallelAnimation {
        id: pageTransition

        NumberAnimation {
            target: control.incomingLoader
            property: "opacity"
            from: 0
            to: 1
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationPage
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
        NumberAnimation {
            target: control.incomingLoader
            property: "x"
            to: 0
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationPage
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
        NumberAnimation {
            target: control.incomingLoader
            property: "scale"
            to: 1
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationPage
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
        NumberAnimation {
            target: control.outgoingLoader
            property: "opacity"
            to: 0
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium2
            easing.bezierCurve: MeoTheme.motionEasingStandardAccelerate
        }
        NumberAnimation {
            target: control.outgoingLoader
            property: "x"
            to: MeoTheme.reduceMotion ? 0 : -control.transitionDistance * 0.35 * (control.direction < 0 ? -1 : 1)
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium2
            easing.bezierCurve: MeoTheme.motionEasingStandardAccelerate
        }

        onFinished: {
            control.activeSlot = control.pendingSlot
            control.outgoingLoader.source = ""
            control.outgoingLoader.opacity = 0
            control.outgoingLoader.x = 0
            control.outgoingLoader.scale = 1
        }
    }
}
