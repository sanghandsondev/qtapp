import QtQuick 6.4
import QtQuick.Window 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtWebSockets 1.0
import com.company.style 1.0

Item {
    id: settingsRoot
    width: parent.width
    height: parent.height

    // Property to hold the WebSocket client instance from Main.qml
    property var wsClient

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // --- Fixed Header ---
        Text {
            text: "Settings"
            color: Theme.primaryText
            font.pointSize: 20
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.separator // Separator line
        }

        // --- Settings List (Scrollable) ---
        ScrollView {
            id: settingsScrollView // Add an id to the ScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: parent.width // Occupy available width inside ScrollView
                spacing: 16

                // Connection Status Setting - Replaced RowLayout with Item for better control
                Item {
                    Layout.fillWidth: true
                    // Automatically adjust height based on the text content
                    height: Math.max(statusTextColumn.implicitHeight, connectionToggle.implicitHeight)

                    ColumnLayout {
                        id: statusTextColumn
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "WebSocket Server Connection Status"
                            color: Theme.primaryText
                            font.pointSize: 16
                        }
                        Text {
                            // Detailed status text
                            text: {
                                if (!wsClient) return "WS: Not available";
                                switch(wsClient.status) {
                                    case WebSocket.Open: return "Connected";
                                    case WebSocket.Connecting: return "Connecting...";
                                    case WebSocket.Closing: return "Closing...";
                                    case WebSocket.Closed: return "Disconnected";
                                    case WebSocket.Error: return "Error";
                                    default: return "Unknown";
                                }
                            }
                            color: Theme.secondaryText // Lighter gray for description
                            font.pointSize: 12
                        }
                    }

                    // Custom Toggle Switch
                    Text {
                        id: connectionToggle
                        anchors.right: parent.right
                        anchors.rightMargin: 20 // Add margin to the right
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: materialFontFamily
                        font.pixelSize: 48

                        property bool isConnecting: wsClient && wsClient.status === WebSocket.Connecting
                        property bool isConnected: wsClient && wsClient.status === WebSocket.Open
                        property bool canConnect: wsClient ? (wsClient.status === WebSocket.Closed || wsClient.status === WebSocket.Error) : false

                        text: isConnected || isConnecting ? "toggle_on" : "toggle_off"
                        color: isConnected ? Theme.toggleOn : Theme.toggleOff // Green when connected, gray otherwise

                        opacity: isConnecting ? 0.2 : 1.0

                        MouseArea {
                            anchors.fill: parent
                            enabled: connectionToggle.canConnect
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (wsClient) {
                                    wsClient.open()
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.separator
                }

                // --- Time Format Setting ---
                Item {
                    Layout.fillWidth: true
                    height: Math.max(timeFormatTextColumn.implicitHeight, timeFormatToggle.implicitHeight)

                    ColumnLayout {
                        id: timeFormatTextColumn
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "Time Format"
                            color: Theme.primaryText
                            font.pointSize: 16
                        }
                        Text {
                            text: Theme.is24HourFormat ? "24:00" : "12:00 AM/PM"
                            color: Theme.secondaryText
                            font.pointSize: 12
                        }
                    }

                    Text {
                        id: timeFormatToggle
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: materialFontFamily
                        font.pixelSize: 48

                        text: Theme.is24HourFormat ? "toggle_on" : "toggle_off"
                        color: Theme.is24HourFormat ? Theme.toggleOn : Theme.toggleOff

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Theme.toggleTimeFormat()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.separator
                }

                // --- Dark Mode Setting ---
                Item {
                    Layout.fillWidth: true
                    height: Math.max(themeTextColumn.implicitHeight, themeToggle.implicitHeight)

                    ColumnLayout {
                        id: themeTextColumn
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "Graphical Dark Mode"
                            color: Theme.primaryText
                            font.pointSize: 16
                        }
                        Text {
                            text: Theme.isDark ? "Dark Theme" : "Light Theme"
                            color: Theme.secondaryText
                            font.pointSize: 12
                        }
                    }

                    Text {
                        id: themeToggle
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: materialFontFamily
                        font.pixelSize: 48

                        text: Theme.isDark ? "toggle_on" : "toggle_off"
                        color: Theme.isDark ? Theme.toggleOn : Theme.toggleOff

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Theme.toggle()
                        }
                    }
                }
            }
        }
    }
}
