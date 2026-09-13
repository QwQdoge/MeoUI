import QtQuick
import QtQuick.Layouts
import MeoUI

// Backend-neutral weather status for quiet session-entry and desktop surfaces.
// The host is responsible for providing a bounded, cached projection; this
// component never performs network access or derives a location itself.
Item {
    id: control

    property bool available: false
    property bool stale: false
    property bool showLocation: false
    property string location: ""
    property string temperatureText: ""
    property string condition: ""
    property string iconName: "weather-clear"

    readonly property string safeLocation: boundedText(location, 64)
    readonly property string safeTemperature: boundedText(temperatureText, 24)
    readonly property string safeCondition: boundedText(condition, 96)
    readonly property string safeIconName: /^[A-Za-z0-9][A-Za-z0-9._+\-]*$/.test(iconName)
                                        ? iconName.slice(0, 128) : "weather-clear"
    readonly property string materialIconName: materialSymbolFor(safeIconName)
    readonly property bool hasPrimaryText: safeTemperature !== "" || safeCondition !== ""
    readonly property bool locationVisible: showLocation && safeLocation !== ""

    implicitWidth: weatherContent.implicitWidth
    implicitHeight: weatherContent.implicitHeight
    visible: available && !stale && hasPrimaryText
    opacity: visible ? 1 : 0

    Accessible.role: Accessible.StaticText
    Accessible.name: {
        const parts = []
        if (locationVisible)
            parts.push(safeLocation)
        if (safeTemperature !== "")
            parts.push(safeTemperature)
        if (safeCondition !== "")
            parts.push(safeCondition)
        return parts.join(", ")
    }

    function boundedText(value, maximumLength) {
        return String(value || "")
                .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "")
                .replace(/[\u202A-\u202E\u2066-\u2069]/g, "")
                .slice(0, maximumLength)
                .trim()
    }

    function materialSymbolFor(kdeIconName) {
        if (kdeIconName === "weather-clear" || kdeIconName === "weather-clear-night")
            return kdeIconName === "weather-clear-night" ? "clear_night" : "clear_day"
        if (kdeIconName === "weather-few-clouds" || kdeIconName === "weather-partly-cloudy")
            return "partly_cloudy_day"
        if (kdeIconName === "weather-overcast")
            return "cloudy"
        if (kdeIconName === "weather-showers" || kdeIconName === "weather-rain")
            return "rainy"
        if (kdeIconName === "weather-storm")
            return "thunderstorm"
        if (kdeIconName === "weather-snow")
            return "weather_snowy"
        return "cloud"
    }

    Behavior on opacity {
        NumberAnimation {
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationState
            easing.type: Easing.BezierSpline
            easing.bezierCurve: MeoTheme.motionEasingStandard
        }
    }

    RowLayout {
        id: weatherContent
        spacing: MeoTheme.space8

        MeoIcon {
            icon: control.materialIconName
            size: 24
            color: MeoTheme.primary
            Accessible.ignored: true
        }

        ColumnLayout {
            spacing: 0

            MeoText {
                Layout.fillWidth: true
                visible: control.safeTemperature !== "" || control.safeCondition !== ""
                text: [control.safeTemperature, control.safeCondition]
                      .filter(part => part !== "").join(" · ")
                typeRole: "title"
                typeSize: "small"
                emphasized: true
                color: MeoTheme.contentOnSurface
            }

            MeoText {
                Layout.fillWidth: true
                visible: control.locationVisible
                text: control.safeLocation
                typeRole: "body"
                typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }
}
