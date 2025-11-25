import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0

Rectangle {
    id: headerRoot
    Layout.fillWidth: true
    Layout.preferredHeight: 48
    color: Theme.secondaryBg
    border.color: Theme.separator
    border.width: 1

    property int fanSpeed: 0
    property real temperature: 0.0

    // Timer to update the clock every second
    Timer {
        id: clockTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            var now = new Date()
            if (Theme.is24HourFormat) {
                timeText.text = Qt.formatDateTime(now, "HH:mm")
                ampmText.text = ""
            } else {
                timeText.text = Qt.formatDateTime(now, "hh:mm")
                ampmText.text = Qt.formatDateTime(now, "AP")
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        // Temperature on the left
        RowLayout {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter
            Text {
                text: "thermostat" // Material icon for temperature
                font.family: materialFontFamily
                font.pixelSize: 22
                color: Theme.icon
            }
            Text {
                // This property can be updated from Main.qml
                text: headerRoot.temperature.toFixed(1) + " °C"
                color: Theme.secondaryText
                font.pointSize: 14
            }
        }

        // Spacer to push time to the right
        Item {
            Layout.fillWidth: true
        }

        // Time display on the right
        RowLayout {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            Text {
                id: timeText
                text: Qt.formatDateTime(new Date(), Theme.is24HourFormat ? "HH:mm" : "hh:mm")
                color: Theme.primaryText
                font.pointSize: 20
                font.bold: true
                font.letterSpacing: 2
            }
            Text {
                id: ampmText
                text: Theme.is24HourFormat ? "" : Qt.formatDateTime(new Date(), "AP")
                color: Theme.primaryText
                font.pointSize: 12 // Smaller font for AM/PM
                font.bold: true
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 2 // Align with bottom of time text
            }
        }
    }
}
