// Shared ListView foundation: all data and service behavior remain with callers.
import QtQuick
import MeoUI

ListView {
    id: control

    property bool useMeoTransitions: true
    property bool preserveScrollPosition: false
    property real savedContentY: originY

    add: useMeoTransitions ? MeoListTransitions.add : null
    remove: useMeoTransitions ? MeoListTransitions.remove : null
    displaced: useMeoTransitions ? MeoListTransitions.displaced : null
    move: useMeoTransitions ? MeoListTransitions.move : null

    onMovementStarted: if (preserveScrollPosition) savedContentY = contentY
    onContentYChanged: if (preserveScrollPosition && !moving) savedContentY = contentY
    onModelChanged: if (preserveScrollPosition)
                        contentY = Math.max(originY, savedContentY)
}
