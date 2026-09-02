import QtQuick
import MeoUI

// Compatibility export for compact callers that previously requested a modal
// navigation drawer. Material 3 Expressive replaces that surface with an
// expanded modal navigation rail; sharing the implementation prevents the two
// navigation patterns from drifting in color, selection, accessibility, focus,
// motion, and dynamic-theme behavior.
MeoNavigationRailModal {
    id: control

    // The old component defaulted to 360dp. Keep that source-compatible size
    // request while the shared rail remains responsible for the documented
    // 220–360dp clamp and overlay lifecycle.
    expandedWidth: 360 * MeoTheme.globalScale
    labelType: "always"
    closeOnDestination: false
}
