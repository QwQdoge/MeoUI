import QtQuick
import MeoUI

Item {
    id: control

    // Set active synchronously with the user's action. If a detailed
    // placeholder is supplied, its geometry is already known and can appear
    // immediately without moving surrounding content. Otherwise the compact
    // current M3 Expressive loading indicator appears after a short anti-flash
    // delay.
    property bool active: false
    property Component placeholder: null
    property int delay: placeholder !== null ? 0 : MeoTheme.loadingFeedbackDelay
    property int minimumVisibleDuration: MeoTheme.loadingFeedbackMinimumVisible
    property string accessibleName: qsTr("Loading")
    property string indicatorVariant: "contained"
    property color indicatorColor: MeoTheme.primary
    readonly property bool usesDetailedPlaceholder: placeholder !== null
    readonly property bool feedbackVisible: _feedbackHeld

    property bool _feedbackHeld: false
    property double _shownAt: 0

    enabled: false
    visible: _feedbackHeld || opacity > 0.001
    opacity: _feedbackHeld ? 1 : 0

    Accessible.role: Accessible.ProgressBar
    Accessible.name: accessibleName

    function showFeedback() {
        hideTimer.stop()
        if (_feedbackHeld)
            return
        _shownAt = Date.now()
        _feedbackHeld = true
    }

    function hideFeedback() {
        delayTimer.stop()
        if (!_feedbackHeld)
            return
        const elapsed = Date.now() - _shownAt
        const remaining = Math.max(0, minimumVisibleDuration - elapsed)
        if (remaining > 0) {
            hideTimer.interval = remaining
            hideTimer.restart()
        } else {
            _feedbackHeld = false
        }
    }

    function syncActiveState() {
        if (active) {
            hideTimer.stop()
            if (delay <= 0)
                showFeedback()
            else if (!_feedbackHeld) {
                delayTimer.interval = delay
                delayTimer.restart()
            }
        } else {
            hideFeedback()
        }
    }

    onActiveChanged: syncActiveState()
    onDelayChanged: {
        if (active && !_feedbackHeld)
            syncActiveState()
    }
    onPlaceholderChanged: {
        if (active && !_feedbackHeld)
            syncActiveState()
    }
    Component.onCompleted: syncActiveState()

    Behavior on opacity {
        NumberAnimation {
            duration: MeoTheme.motionDurationLoadingFeedbackFade
            easing.type: Easing.BezierSpline
            easing.bezierCurve: MeoTheme.motionEasingStandard
        }
    }

    Timer {
        id: delayTimer
        repeat: false
        onTriggered: {
            if (control.active)
                control.showFeedback()
        }
    }

    Timer {
        id: hideTimer
        repeat: false
        onTriggered: control._feedbackHeld = false
    }

    Loader {
        id: detailedLoader
        objectName: "meoLoadingDetailedPlaceholder"
        anchors.fill: parent
        active: control.feedbackVisible && control.usesDetailedPlaceholder
        visible: active
        sourceComponent: control.placeholder
    }

    MeoLoadingIndicator {
        id: compactIndicator
        objectName: "meoLoadingCompactIndicator"
        anchors.centerIn: parent
        visible: control.feedbackVisible && !control.usesDetailedPlaceholder
        running: visible
        variant: control.indicatorVariant
        color: control.indicatorColor
    }
}
