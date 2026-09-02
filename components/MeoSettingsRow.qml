import QtQuick
import QtQuick.Controls
import MeoUI

// A semantic row for system settings. The row owns the shared surface,
// focus treatment, labels, and compatibility-facing trailingKind API; each
// interactive treatment is rendered by an existing MeoUI control.
Control {
    id: control

    // Content
    property string title: ""
    property string subtitle: ""
    property string leadingIcon: ""
    property string leadingTone: "primary" // primary | secondary | tertiary | error | neutral

    // Grouping is owned by MeoSettingsGroup. The values are public so the row
    // can also be used directly in a small one-off group.
    property string positionInGroup: "only" // only | first | middle | last
    property bool showDivider: false
    property real dividerInset: 0

    // Surface and state
    property color surfaceColor: MeoTheme.surfaceContainerLowest
    property color selectionColor: MeoTheme.secondaryContainer
    property color selectionContentColor: MeoTheme.contentOnSecondaryContainer
    property bool selected: false

    // Keep the old behavior for existing navigation/status/choice/toggle/action
    // rows. The new embedded controls own their pointer and keyboard input.
    property bool interactive: {
        switch (trailingKind) {
        case "none":
        case "value":
        case "slider":
        case "segmented":
        case "dropdown":
        case "progress":
            return false
        default:
            return true
        }
    }

    // Trailing semantics. Existing kinds stay intact. New aliases keep the
    // settings contract readable at call sites: switch -> toggle and
    // button -> action. A choice remains the compact, navigational treatment
    // unless it is given options, in which case it becomes a dropdown.
    property string trailingKind: "navigation" // navigation | switch | toggle | value | slider | segmented | dropdown | choice | radio | checkbox | button | action | status | progress | none
    property string trailingText: ""
    property bool statusShowsChevron: false
    property string statusTone: "neutral" // primary | secondary | tertiary | error | neutral
    property bool checked: false
    property bool indeterminate: false
    property string actionText: ""
    property string actionType: "text"
    property bool toggleOnRowClick: true

    // Value/slider data. `trailingText` remains the compatibility display
    // value; valueText is a clearer string API for a value row.
    property string valueText: ""
    property real from: 0.0
    property real to: 100.0
    property real value: 0.0
    property real stepSize: 1.0
    property bool discrete: false
    property bool snapMode: false
    property bool tickMarksEnabled: discrete
    property bool sliderValueLabelEnabled: false
    property bool sliderIsThick: false
    property bool sliderWavy: false
    property string sliderSize: "s"
    property string valueSuffix: ""
    property bool showValueLabel: true

    // Selection data. `options` is the canonical model. The alternate model
    // names are accepted so callers can use the names of the reused controls
    // without making settings-page-specific wrapper components.
    property var options: []
    property var model: []
    property var choiceModel: []
    property var dropdownModel: []
    property var segmentedModel: []
    property int currentIndex: -1
    property bool multiSelect: false
    property var selectedIndices: []
    property string dropdownLabel: ""
    property string dropdownType: "outlined"
    property string segmentedSize: "s"

    // Progress data. Progress follows MeoProgressBar's 0.0–1.0 convention.
    property real progress: 0.0
    property bool progressIndeterminate: false
    property bool progressIsThick: false
    property bool progressWavy: false
    property bool progressVibrant: false
    property bool progressShowTrack: true
    property string progressText: ""
    property bool showProgressLabel: true

    signal activated()
    signal toggled(bool checked)
    signal actionTriggered()
    signal sliderMoved(real value)
    signal optionSelected(int index, var option)
    signal dropdownSelected(int index, string value)

    readonly property string effectiveKind: {
        switch (trailingKind) {
        case "switch":
            return "toggle"
        case "button":
            return "action"
        default:
            return trailingKind
        }
    }
    readonly property bool isToggle: effectiveKind === "toggle"
    readonly property bool isAction: effectiveKind === "action"
    readonly property bool isChoice: effectiveKind === "choice"
    readonly property bool isNavigation: effectiveKind === "navigation"
    readonly property bool isStatus: effectiveKind === "status"
    readonly property bool isValue: effectiveKind === "value"
    readonly property bool isSlider: effectiveKind === "slider"
    readonly property bool isSegmented: effectiveKind === "segmented"
    readonly property bool isRadio: effectiveKind === "radio"
    readonly property bool isCheckbox: effectiveKind === "checkbox"
    readonly property bool isProgress: effectiveKind === "progress"
    readonly property int optionCount: effectiveOptions.length
    readonly property bool choiceUsesDropdown: isChoice && optionCount > 0
    readonly property bool isDropdown: effectiveKind === "dropdown" || choiceUsesDropdown
    readonly property bool isLegacyChoice: isChoice && !choiceUsesDropdown
    readonly property bool hasExpandedControl: isSlider || isSegmented || isDropdown || isProgress
    readonly property bool isInteractive: interactive && enabled && !hasExpandedControl
    readonly property real scale: MeoTheme.globalScale
    readonly property real rowRadius: MeoTheme.shapeExtraLarge
    readonly property bool pressed: rowHitArea.pressed
    readonly property bool focusVisible: activeFocus
    readonly property real inlineControlInset: leadingIcon !== "" ? 56 * scale : 0
    readonly property color currentSurfaceColor: selected ? selectionColor : surfaceColor
    readonly property color currentContentColor: selected ? selectionContentColor : MeoTheme.contentOnSurface
    readonly property color currentSupportingColor: selected
                                                  ? selectionContentColor
                                                  : MeoTheme.contentOnSurfaceVariant
    readonly property color trailingContentColor: {
        if (selected || !isStatus)
            return currentSupportingColor
        switch (statusTone) {
        case "primary":
            return MeoTheme.primary
        case "secondary":
            return MeoTheme.secondary
        case "tertiary":
            return MeoTheme.tertiary
        case "error":
            return MeoTheme.error
        default:
            return currentSupportingColor
        }
    }
    readonly property var effectiveOptions: {
        if (options && options.length !== undefined && options.length > 0)
            return options
        if (model && model.length !== undefined && model.length > 0)
            return model
        if (choiceModel && choiceModel.length !== undefined && choiceModel.length > 0)
            return choiceModel
        if (dropdownModel && dropdownModel.length !== undefined && dropdownModel.length > 0)
            return dropdownModel
        if (segmentedModel && segmentedModel.length !== undefined && segmentedModel.length > 0)
            return segmentedModel
        return []
    }
    readonly property var dropdownOptions: {
        const values = []
        for (let index = 0; index < effectiveOptions.length; ++index)
            values.push(optionText(effectiveOptions[index]))
        return values
    }
    readonly property real clampedProgress: Math.max(0.0, Math.min(1.0, progress))
    readonly property bool effectiveProgressIndeterminate: progressIndeterminate || indeterminate
    readonly property string selectedOptionText: currentIndex >= 0 && currentIndex < optionCount
                                                ? optionText(effectiveOptions[currentIndex])
                                                : trailingText
    readonly property string effectiveValueText: valueText !== "" ? valueText
                                               : (trailingText !== "" ? trailingText : formatNumber(value, ""))
    readonly property string effectiveSliderText: trailingText !== "" ? trailingText
                                                : (showValueLabel ? formatNumber(value, valueSuffix) : "")
    readonly property string effectiveProgressText: progressText !== "" ? progressText
                                                  : (trailingText !== "" ? trailingText
                                                     : (showProgressLabel && !effectiveProgressIndeterminate
                                                        ? Math.round(clampedProgress * 100) + "%" : ""))
    readonly property string headerTrailingText: {
        if (isValue)
            return effectiveValueText
        if (isSlider)
            return effectiveSliderText
        if (isProgress)
            return effectiveProgressText
        return trailingText
    }
    readonly property string effectiveActionText: actionText !== "" ? actionText : trailingText
    readonly property bool hasChevron: isNavigation || isLegacyChoice || (isStatus && statusShowsChevron)
    readonly property bool hasControlTrailing: isToggle || isCheckbox || isRadio || isAction
    readonly property bool hasMetadataTrailing: !hasControlTrailing
                                               && !isSegmented
                                               && !isDropdown
                                               && (headerTrailingText !== "" || hasChevron)
    readonly property bool hasHeaderTrailing: hasControlTrailing || hasMetadataTrailing

    // These defaults remain dynamic because they are bound to semantic roles.
    // Products may override them only for another semantic token.
    readonly property color toneContainerColor: {
        switch (leadingTone) {
        case "secondary": return MeoTheme.secondaryContainer
        case "tertiary": return MeoTheme.tertiaryContainer
        case "error": return MeoTheme.errorContainer
        case "neutral": return MeoTheme.surfaceContainerHighest
        default: return MeoTheme.primaryContainer
        }
    }
    readonly property color toneIconColor: {
        switch (leadingTone) {
        case "secondary": return MeoTheme.contentOnSecondaryContainer
        case "tertiary": return MeoTheme.contentOnTertiaryContainer
        case "error": return MeoTheme.contentOnErrorContainer
        case "neutral": return MeoTheme.contentOnSurfaceVariant
        default: return MeoTheme.contentOnPrimaryContainer
        }
    }
    property color iconContainerColor: toneContainerColor
    property color iconColor: toneIconColor

    implicitWidth: 360 * scale
    implicitHeight: Math.max(MeoTheme.settingsRowHeight,
                             rowContent.implicitHeight + 24 * scale)
    padding: 12 * scale
    leftPadding: MeoTheme.settingsRowHorizontalPadding
    rightPadding: MeoTheme.settingsRowHorizontalPadding
    activeFocusOnTab: isInteractive
    hoverEnabled: isInteractive

    Accessible.role: isRadio ? Accessible.RadioButton
                             : ((isToggle || isCheckbox) ? Accessible.CheckBox : Accessible.Button)
    Accessible.name: title
    Accessible.description: subtitle
    Accessible.checked: (isToggle || isCheckbox || isRadio) ? checked : false
    Accessible.checkable: isToggle || isCheckbox || isRadio
    Accessible.focusable: isInteractive
    Accessible.ignored: hasExpandedControl
    Accessible.onPressAction: activate()

    function optionText(option) {
        if (option === undefined || option === null)
            return ""
        if (typeof option === "object") {
            if (option.label !== undefined)
                return String(option.label)
            if (option.text !== undefined)
                return String(option.text)
            if (option.value !== undefined)
                return String(option.value)
        }
        return String(option)
    }

    function formatNumber(number, suffix) {
        const numeric = Number(number)
        if (!isFinite(numeric))
            return ""
        const rounded = Math.round(numeric)
        const text = (discrete || Math.abs(numeric - rounded) < 0.00001)
                   ? String(rounded) : numeric.toFixed(1)
        return text + suffix
    }

    function setChecked(nextChecked) {
        if (!enabled || checked === nextChecked)
            return
        checked = nextChecked
        if (indeterminate)
            indeterminate = false
        toggled(checked)
    }

    function normalizedSliderValue(rawValue) {
        const lower = Math.min(from, to)
        const upper = Math.max(from, to)
        let nextValue = Math.max(lower, Math.min(upper, Number(rawValue)))
        if ((discrete || snapMode || tickMarksEnabled) && stepSize > 0) {
            const steps = Math.round((nextValue - from) / stepSize)
            nextValue = from + steps * stepSize
        }
        return Math.max(lower, Math.min(upper, nextValue))
    }

    function setSliderValue(rawValue) {
        if (!enabled)
            return
        const nextValue = normalizedSliderValue(rawValue)
        if (value === nextValue)
            return
        value = nextValue
        sliderMoved(value)
    }

    function selectOption(index, option) {
        if (!enabled || index < 0 || index >= optionCount)
            return
        if (multiSelect) {
            const next = selectedIndices ? selectedIndices.slice(0) : []
            const selectedAt = next.indexOf(index)
            if (selectedAt === -1)
                next.push(index)
            else
                next.splice(selectedAt, 1)
            selectedIndices = next
        } else {
            currentIndex = index
        }
        optionSelected(index, option === undefined ? effectiveOptions[index] : option)
    }

    function activate() {
        if (!isInteractive)
            return

        forceActiveFocus(Qt.MouseFocusReason)
        if ((isToggle || isCheckbox) && toggleOnRowClick) {
            setChecked(!checked)
            return
        }
        if (isRadio) {
            setChecked(true)
            return
        }
        if (isAction) {
            actionTriggered()
            return
        }
        activated()
    }

    function syncEmbeddedControls() {
        if (settingSwitch.checked !== checked)
            settingSwitch.checked = checked
        if (settingCheckbox.checked !== checked)
            settingCheckbox.checked = checked
        if (settingCheckbox.indeterminate !== indeterminate)
            settingCheckbox.indeterminate = indeterminate
        if (settingRadio.checked !== checked)
            settingRadio.checked = checked
        if (settingSlider.value !== value)
            settingSlider.value = value
        if (settingSegmented.currentIndex !== currentIndex)
            settingSegmented.currentIndex = currentIndex
        if (settingSegmented.selectedIndices !== selectedIndices)
            settingSegmented.selectedIndices = selectedIndices
        if (settingDropdown.currentIndex !== currentIndex)
            settingDropdown.currentIndex = currentIndex
    }

    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()

    background: Item {
        Rectangle {
            id: surface
            anchors.fill: parent
            color: control.currentSurfaceColor
            radius: control.rowRadius
            topLeftRadius: (control.positionInGroup === "only" || control.positionInGroup === "first") ? radius : 0
            topRightRadius: (control.positionInGroup === "only" || control.positionInGroup === "first") ? radius : 0
            bottomLeftRadius: (control.positionInGroup === "only" || control.positionInGroup === "last") ? radius : 0
            bottomRightRadius: (control.positionInGroup === "only" || control.positionInGroup === "last") ? radius : 0

            Behavior on color {
                enabled: !MeoTheme.reduceMotion
                ColorAnimation {
                    duration: MeoTheme.motionDurationSelection
                    easing.bezierCurve: MeoTheme.motionEasingEmphasized
                }
            }
        }

        MeoStateLayer {
            anchors.fill: parent
            radius: control.rowRadius
            topLeftRadius: (control.positionInGroup === "only" || control.positionInGroup === "first") ? radius : 0
            topRightRadius: (control.positionInGroup === "only" || control.positionInGroup === "first") ? radius : 0
            bottomLeftRadius: (control.positionInGroup === "only" || control.positionInGroup === "last") ? radius : 0
            bottomRightRadius: (control.positionInGroup === "only" || control.positionInGroup === "last") ? radius : 0
            visible: control.isInteractive
            pressed: rowHitArea.pressed
            hovered: rowHitArea.containsMouse
            // The explicit primary focus ring below carries keyboard focus;
            // keep the state layer tonal so focus and hover can combine.
            focused: control.activeFocus
            focusRingEnabled: false
            pressX: rowHitArea.mouseX - x
            pressY: rowHitArea.mouseY - y
            color: control.selected ? control.selectionContentColor : MeoTheme.contentOnSurface
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: MeoTheme.strokeWidthThin
            color: "transparent"
            radius: Math.max(0, control.rowRadius - MeoTheme.strokeWidthThin)
            topLeftRadius: (control.positionInGroup === "only" || control.positionInGroup === "first") ? radius : 0
            topRightRadius: (control.positionInGroup === "only" || control.positionInGroup === "first") ? radius : 0
            bottomLeftRadius: (control.positionInGroup === "only" || control.positionInGroup === "last") ? radius : 0
            bottomRightRadius: (control.positionInGroup === "only" || control.positionInGroup === "last") ? radius : 0
            border.width: control.activeFocus ? MeoTheme.strokeWidthMedium : 0
            border.color: MeoTheme.primary
            opacity: control.activeFocus ? 1 : 0

            Behavior on opacity {
                enabled: !MeoTheme.reduceMotion
                NumberAnimation {
                    duration: MeoTheme.motionDurationEffectDefault
                    easing.bezierCurve: MeoTheme.motionEasingStandard
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: control.dividerInset
            anchors.bottom: parent.bottom
            height: Math.max(1, 1 * control.scale)
            visible: control.showDivider
            color: MeoTheme.outlineVariant
            opacity: 0.28
        }

        MouseArea {
            id: rowHitArea
            anchors.fill: parent
            enabled: control.isInteractive
            hoverEnabled: true
            cursorShape: control.isInteractive ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: control.activate()
        }
    }

    contentItem: Column {
        id: rowContent
        width: control.availableWidth
        spacing: control.hasExpandedControl ? 8 * control.scale : 0

        Row {
            id: headerRow
            width: parent.width
            height: Math.max(48 * control.scale,
                             textColumn.implicitHeight,
                             trailingSlot.implicitHeight)
            spacing: MeoTheme.settingsIconTextGap

            Item {
                width: visible ? MeoTheme.settingsLeadingContainerSize : 0
                height: visible ? MeoTheme.settingsLeadingContainerSize : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: control.leadingIcon !== ""

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: control.iconContainerColor
                }

                MeoIcon {
                    anchors.centerIn: parent
                    icon: control.leadingIcon
                    size: MeoTheme.settingsLeadingIconSize
                    color: control.iconColor
                }
            }

            Column {
                id: textColumn
                width: Math.max(0, headerRow.width
                                - (control.leadingIcon !== "" ? MeoTheme.settingsLeadingContainerSize + headerRow.spacing : 0)
                                - (trailingSlot.visible ? trailingSlot.width + headerRow.spacing : 0))
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2 * control.scale

                Text {
                    width: parent.width
                    text: control.title
                    font.family: MeoTheme.typefacePlain
                    font.pixelSize: MeoTheme.titleMedium.size * control.scale
                    font.weight: MeoTheme.titleMedium.weight
                    font.letterSpacing: (MeoTheme.titleMedium.letterSpacing || 0) * control.scale
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 20 * control.scale
                    color: control.currentContentColor
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }

                Text {
                    width: parent.width
                    text: control.subtitle
                    visible: text !== ""
                    font.family: MeoTheme.typefacePlain
                    font.pixelSize: MeoTheme.bodyMedium.size * control.scale
                    font.weight: MeoTheme.bodyMedium.weight
                    font.letterSpacing: (MeoTheme.bodyMedium.letterSpacing || 0) * control.scale
                    color: control.currentSupportingColor
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }
            }

            Item {
                id: trailingSlot
                readonly property real textLimit: Math.max(0, headerRow.width * 0.42)
                visible: control.hasHeaderTrailing
                width: {
                    if (control.isToggle)
                        return settingSwitch.implicitWidth
                    if (control.isCheckbox)
                        return settingCheckbox.implicitWidth
                    if (control.isRadio)
                        return settingRadio.implicitWidth
                    if (control.isAction)
                        return actionButton.implicitWidth
                    return trailingMetadata.implicitWidth
                }
                height: Math.max(40 * control.scale,
                                 control.isToggle ? settingSwitch.implicitHeight : 0,
                                 control.isCheckbox ? settingCheckbox.implicitHeight : 0,
                                 control.isRadio ? settingRadio.implicitHeight : 0,
                                 control.isAction ? actionButton.implicitHeight : 0)
                implicitHeight: height
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: trailingMetadata
                    anchors.centerIn: parent
                    spacing: 8 * control.scale
                    visible: control.hasMetadataTrailing
                    width: implicitWidth
                    height: implicitHeight

                    Text {
                        id: trailingTextItem
                        text: control.headerTrailingText
                        visible: text !== ""
                        width: Math.min(implicitWidth, trailingSlot.textLimit)
                        font.family: MeoTheme.typefacePlain
                        font.pixelSize: MeoTheme.bodyMedium.size * control.scale
                        font.weight: MeoTheme.bodyMedium.weight
                        color: control.trailingContentColor
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignRight
                        textFormat: Text.PlainText
                    }

                    MeoIcon {
                        id: trailingChevron
                        icon: "chevron_right"
                        size: 20 * control.scale
                        color: control.trailingContentColor
                        visible: control.hasChevron
                    }
                }

                MeoSwitch {
                    id: settingSwitch
                    anchors.centerIn: parent
                    visible: control.isToggle
                    checked: control.checked
                    size: "s"
                    enabled: control.enabled
                    onToggled: (nextChecked) => control.setChecked(nextChecked)
                }

                MeoCheckbox {
                    id: settingCheckbox
                    anchors.centerIn: parent
                    visible: control.isCheckbox
                    checked: control.checked
                    indeterminate: control.indeterminate
                    label: ""
                    size: "s"
                    enabled: control.enabled
                    onToggled: (nextChecked) => control.setChecked(nextChecked)
                }

                MeoRadioButton {
                    id: settingRadio
                    anchors.centerIn: parent
                    visible: control.isRadio
                    checked: control.checked
                    label: ""
                    size: "s"
                    enabled: control.enabled
                    onToggled: (nextChecked) => control.setChecked(nextChecked)
                }

                MeoButton {
                    id: actionButton
                    anchors.centerIn: parent
                    visible: control.isAction
                    text: control.effectiveActionText
                    type: control.actionType
                    size: "s"
                    enabled: control.enabled
                    onClicked: control.actionTriggered()
                }
            }
        }

        Item {
            id: inlineControlSlot
            visible: control.hasExpandedControl
            x: control.inlineControlInset
            width: Math.max(0, parent.width - x)
            height: !visible ? 0
                    : (control.isSlider ? settingSlider.implicitHeight
                       : (control.isSegmented ? settingSegmented.implicitHeight
                          : (control.isDropdown ? settingDropdown.implicitHeight
                             : settingProgress.implicitHeight)))
            implicitHeight: height

            MeoSlider {
                id: settingSlider
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: control.isSlider
                from: control.from
                to: control.to
                value: control.value
                discrete: control.discrete
                stepSize: control.stepSize
                snapMode: control.snapMode
                tickMarksEnabled: control.tickMarksEnabled
                valueLabelEnabled: control.sliderValueLabelEnabled
                isThick: control.sliderIsThick
                wavy: control.sliderWavy
                size: control.sliderSize
                enabled: control.enabled
                onMoved: (nextValue) => control.setSliderValue(nextValue)
            }

            MeoSegmentedButtons {
                id: settingSegmented
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: control.isSegmented
                model: control.effectiveOptions
                currentIndex: control.currentIndex
                multiSelect: control.multiSelect
                selectedIndices: control.selectedIndices
                size: control.segmentedSize
                enabled: control.enabled
                onSelected: (index, option) => control.selectOption(index, option)
            }

            MeoExposedDropdown {
                id: settingDropdown
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: control.isDropdown
                label: control.dropdownLabel
                model: control.dropdownOptions
                text: control.selectedOptionText
                type: control.dropdownType
                enabled: control.enabled
                onSelected: (index, selectedValue) => {
                    control.selectOption(index, control.effectiveOptions[index])
                    control.dropdownSelected(index, selectedValue)
                }
            }

            MeoProgressBar {
                id: settingProgress
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: control.isProgress
                value: control.progress
                indeterminate: control.effectiveProgressIndeterminate
                isThick: control.progressIsThick
                wavy: control.progressWavy
                vibrant: control.progressVibrant
                showTrack: control.progressShowTrack
            }
        }
    }

    Connections {
        target: control

        function onCheckedChanged() {
            control.syncEmbeddedControls()
        }
        function onIndeterminateChanged() {
            control.syncEmbeddedControls()
        }
        function onValueChanged() {
            control.syncEmbeddedControls()
        }
        function onCurrentIndexChanged() {
            control.syncEmbeddedControls()
        }
        function onSelectedIndicesChanged() {
            control.syncEmbeddedControls()
        }
    }

    Component.onCompleted: syncEmbeddedControls()
}
