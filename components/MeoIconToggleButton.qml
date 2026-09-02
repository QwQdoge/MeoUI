import QtQuick
import QtQuick.Controls
import MeoUI

// Compatibility export for callers that prefer an explicitly toggle-named
// control. Visual and semantic behavior lives in MeoIconButton so both public
// exports share the current M3/M3 Expressive roles, geometry, state layers,
// badge placement, and 48dp minimum interactive target.
MeoIconButton {
    id: control

    // `checkedIcon` is retained for source compatibility. `selectedIcon` is
    // inherited and remains available for callers using the newer name.
    property string checkedIcon: ""

    type: "standard"
    size: "s"
    checkable: true
    selectedIcon: checkedIcon
    Accessible.role: Accessible.CheckBox
    Accessible.checked: checked
}
