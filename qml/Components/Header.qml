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

    property int temperature: 0
    property var currentTime

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
                font.pixelSize: 26
                color: Theme.icon
            }
            Text {
                // This property can be updated from Main.qml
                text: headerRoot.temperature.toFixed(1) + " °C"
                color: Theme.primaryText
                font.pointSize: 20
                font.bold: true
            }
        }

        // Spacer to push time to the right
        Item {
            Layout.fillWidth: true
        }

        // Volume indicator in the center
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            // Icon changes based on volume level
            Text {
                font.family: materialFontFamily
                font.pixelSize: 26
                color: Theme.icon
                text: {
                    if (Theme.volumeLevel === 0) return "volume_off";
                    if (Theme.volumeLevel <= 2) return "volume_down";
                    return "volume_up";
                }
            }

            // Volume level bars
            Repeater {
                model: 5
                delegate: Rectangle {
                    width: 4
                    height: 8 + (index * 3) // Bars get taller
                    radius: 2
                    color: index < Theme.volumeLevel ? Theme.icon : Theme.tertiaryBg
                }
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
                // Bind text directly to currentTime and the format setting
                text: {
                    if (Theme.is24HourFormat) {
                        return Qt.formatDateTime(headerRoot.currentTime, "HH:mm");
                    } else {
                        // Manual 12-hour format
                        var hours = headerRoot.currentTime.getHours();
                        var minutes = headerRoot.currentTime.getMinutes();
                        var displayHours = hours % 12;
                        if (displayHours === 0) displayHours = 12; // 0 o'clock is 12 AM/PM
                        return (displayHours < 10 ? "0" : "") + displayHours + ":" + (minutes < 10 ? "0" : "") + minutes;
                    }
                }
                color: Theme.primaryText
                font.pointSize: 20
                font.bold: true
                font.letterSpacing: 2
            }
            Text {
                id: ampmText
                // Bind text directly to currentTime and the format setting
                text: {
                    if (Theme.is24HourFormat) {
                        return "";
                    } else {
                        return headerRoot.currentTime.getHours() >= 12 ? "PM" : "AM";
                    }
                }
                color: Theme.primaryText
                font.pointSize: 12 // Smaller font for AM/PM
                font.bold: true
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 2 // Align with bottom of time text
            }
        }
    }
}
