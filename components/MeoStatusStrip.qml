import QtQuick
import QtQuick.Layouts
import MeoUI

// A deliberately backend-agnostic compact status presentation.  Its model
// uses plain maps so a desktop shell, a preview, or an application can adapt
// platform state without importing another product's services.
Item {
    id: control

    // Every entry may provide id, iconName, text, available, active,
    // attention, and accessibleName.  `available: false` removes the entry;
    // callers decide which optional text is elided when space is constrained.
    property var statusModel: []
    property bool active: false
    property bool showText: true
    property real iconSize: 18 * MeoTheme.globalScale
    property real spacing: MeoTheme.space4
    // Hosts pass their per-instance typography preference here.  Keep it at
    // the shared primitive so a panel adapter never needs a visual text copy.
    property real textScale: 1.0

    implicitWidth: content.implicitWidth
    implicitHeight: Math.max(28 * MeoTheme.globalScale, content.implicitHeight)
    Accessible.name: statusDescription()

    function statusDescription() {
        const descriptions = []
        for (let index = 0; index < statusModel.length; ++index) {
            const entry = statusModel[index]
            if (!entry || entry.available === false)
                continue
            const description = entry.accessibleName || entry.text || entry.id
            if (description)
                descriptions.push(description)
        }
        return descriptions.join(", ")
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: control.spacing

        Repeater {
            model: control.statusModel

            delegate: RowLayout {
                required property var modelData
                visible: modelData && modelData.available !== false
                spacing: MeoTheme.space2

                readonly property color contentColor: control.active
                                                     ? MeoTheme.onPrimaryContainer
                                                     : (modelData.attention
                                                        ? MeoTheme.error
                                                        : modelData.active
                                                          ? MeoTheme.primary
                                                          : MeoTheme.onSurfaceVariant)

                MeoIcon {
                    icon: parent.modelData.iconName || "info"
                    size: control.iconSize
                    fill: parent.modelData.active === true
                    color: parent.contentColor
                }

                MeoText {
                    visible: control.showText && parent.modelData.text !== undefined
                    text: parent.modelData.text || ""
                    typeRole: "label"
                    typeSize: "small"
                    emphasized: parent.modelData.active === true
                    fontScaleOverride: control.textScale
                    color: parent.contentColor
                    Accessible.name: parent.modelData.accessibleName || text
                }
            }
        }
    }
}
