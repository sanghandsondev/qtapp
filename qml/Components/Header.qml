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

    // Function to process messages from the server
    function processServerMessage(message) {
        var msgStatus = message.status === "success" ? true : false
        var msgType = message.data.msg
        var serverData = message.data.data

        console.log("Header Component processing message:", msgType)

        if (msgType === "update_temperature_noti") {
            if (msgStatus) {
                headerRoot.temperature = serverData.temperature     
                //  qrc:/qml/Components/Header.qml:26: Error: Cannot assign [undefined] to int
                // console.log("Received temperature from server:", serverData.temperature)
                // console.log("Type of received temperature:", typeof serverData.temperature)
                // headerRoot.temperature = parseInt(serverData.temperature)

                console.log("Updated temperature to:", headerRoot.temperature)
            }
        } else {
            console.warn("Header Component received unknown message type:", msgType)
        }
    }

    // Temperature on the left
    RowLayout {
        id: temperatureLayout
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Text {
            text: "thermostat" // Material icon for temperature
            font.family: materialFontFamily
            font.pixelSize: 26
            color: {
                if (headerRoot.temperature < 20) return "#3b82f6"; // Blue for cold
                if (headerRoot.temperature > 26) return Theme.accent; // Red for hot
                return Theme.icon; // Default color for normal
            }
        }
        Text {
            // This property can be updated from Main.qml
            text: headerRoot.temperature + "°C"
            color: Theme.primaryText
            font.pointSize: 20
            font.bold: true
        }
    }

    // Volume indicator in the center
    RowLayout {
        id: volumeLayout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
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

    // Right-aligned items (Bluetooth and Time)
    RowLayout {
        id: rightAlignedLayout
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16 // Space between Bluetooth icon and time

        // Bluetooth Icon (visible when enabled)
        Text {
            text: "bluetooth"
            font.family: materialFontFamily
            font.pixelSize: 28
            color: Theme.primaryText
            opacity: Theme.bluetoothEnabled ? 1.0 : 0.0 // Control opacity instead of visibility
            visible: opacity > 0 // Keep it invisible when fully transparent to prevent interaction
            Layout.alignment: Qt.AlignVCenter
            Behavior on opacity { NumberAnimation { duration: 50 } } // Animate the opacity property
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
