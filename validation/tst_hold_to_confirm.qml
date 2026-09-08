import QtQuick
import QtTest
import MeoUI

TestCase {
    name: "MeoHoldToConfirm"
    when: windowShown

    Component {
        id: controlComponent
        MeoHoldToConfirm {
            holdDuration: 60
            confirmationText: "Hold to continue"
        }
    }

    function test_releaseCancels() {
        const control = createTemporaryObject(controlComponent, this)
        verify(control)
        let cancelled = 0
        control.cancelled.connect(function() { cancelled++ })
        control.beginHold()
        wait(20)
        verify(control.holding)
        control.cancelHold(true)
        compare(control.holding, false)
        compare(control.progress, 0)
        compare(cancelled, 1)
    }

    function test_holdConfirms() {
        const control = createTemporaryObject(controlComponent, this)
        verify(control)
        let confirmed = 0
        control.confirmed.connect(function() { confirmed++ })
        control.beginHold()
        wait(100)
        compare(confirmed, 1)
        compare(control.holding, false)
        compare(control.progress, 1)
    }

    function test_disabledCannotStart() {
        const control = createTemporaryObject(controlComponent, this)
        control.enabled = false
        control.beginHold()
        compare(control.holding, false)
    }
}
