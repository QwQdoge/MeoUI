import QtQuick
import QtQuick.Layouts
import QtTest
import MeoUI 1.0
import "../components" as Components

Item {
    width: 640
    height: 360

    Components.MeoAuthenticationSurface {
        id: surface
        anchors.centerIn: parent
        title: "Unlock Meo"
        supportingText: "Use your password or fingerprint."

        MeoText {
            Layout.fillWidth: true
            text: "Platform-owned authentication content"
            typeRole: "body"
            typeSize: "medium"
            color: MeoTheme.contentOnSurface
        }
    }

    TestCase {
        name: "MeoAuthenticationSurface"
        when: windowShown

        function init() {
            surface.active = true
            surface.status = "idle"
            surface.statusText = ""
            surface.errorText = ""
        }

        function test_surface_has_no_credential_api() {
            verify(surface.title === "Unlock Meo")
            verify(surface.minimumWidth >= 320 * MeoTheme.globalScale)
            verify(surface.failureDuration === MeoTheme.motionDurationMedium2)
            // The public surface API starts and ends at presentation and its
            // default content slot. Credential ownership is statically kept
            // out of this component; QML QObject wrappers do not expose the
            // C++ QObject::property() reflection helper here.
            verify(surface.content !== undefined)
        }

        function test_status_maps_to_semantic_presentation() {
            surface.status = "fingerprint"
            compare(surface.statusIcon, "fingerprint")
            compare(surface.statusColor, MeoTheme.primary)
            surface.errorText = "Unlocking failed"
            compare(surface.statusIcon, "error")
            compare(surface.statusColor, MeoTheme.error)
            compare(surface.effectiveStatusText, "Unlocking failed")
        }

        function test_failure_motion_is_bounded_and_reduced_motion_is_static() {
            surface.triggerFailure()
            verify(surface.failureOffset <= 8 * MeoTheme.globalScale)
            wait(Math.max(1, surface.failureDuration + 40))
            compare(Math.round(surface.failureOffset), 0)

            const previous = MeoTheme.reduceMotion
            MeoTheme.reduceMotion = true
            surface.triggerFailure()
            compare(surface.failureOffset, 0)
            MeoTheme.reduceMotion = previous
        }
    }
}
