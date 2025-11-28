import QtQuick 6.4
import QtQuick.Window 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtWebSockets 1.0
import com.company.style 1.0
import com.company.sound 1.0

import "qrc:/qml/PageView/Settings/" as SettingsPages

Item {
    id: settingsRoot
    width: parent.width
    height: parent.height

    // Reset to main settings view when the page becomes visible again.
    // This ensures that when the user navigates away and comes back,
    // they always see the main settings list, not a sub-page.
    onVisibleChanged: {
        if (visible) {
            goBack()
        }
    }

    // Property to hold the WebSocket client instance from Main.qml
    property var wsClient

    // --- State Management for Sub-Pages ---
    property string currentSubPage: "" // e.g., "bluetooth"
    property string subPageTitle: ""   // e.g., "Bluetooth & devices"

    function goBack() {
        currentSubPage = ""
        subPageTitle = ""
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // --- Dynamic Header with Back Button ---
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            // Breadcrumb Text: "Settings > Sub-page"
            RowLayout {
                spacing: 8
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "Settings"
                    color: Theme.primaryText
                    font.pointSize: 20
                    font.bold: true
                }

                // Show "> Sub-page" only when on a sub-page
                RowLayout {
                    visible: currentSubPage !== ""
                    spacing: 8
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "chevron_right" // Icon for ">"
                        font.family: materialFontFamily
                        font.pixelSize: 28
                        font.bold: true
                        color: Theme.secondaryText
                    }

                    Text {
                        text: subPageTitle
                        color: Theme.secondaryText // Smaller and not bold
                        font.pointSize: 18
                        font.bold: false
                    }
                }
            }

            Item { Layout.fillWidth: true } // Spacer to push back button to the right

            // Back button - visible only on sub-pages, now at the end
            Text {
                id: backButton
                text: "arrow_back"
                font.family: materialFontFamily
                font.pixelSize: 28
                font.bold: true // Make icon bolder
                Layout.rightMargin: 10 // Move the icon 10 units from the right edge

                color: Theme.primaryText
                visible: currentSubPage !== ""

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -10
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        SoundManager.playTouch()
                        settingsRoot.goBack()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.separator // Separator line
        }

        // --- Content Area: Switches between settings list and sub-pages ---
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: currentSubPage === "" ? 0 : 1 // Switch between children

            // --- Settings List (Scrollable) ---
            ScrollView {
                id: settingsScrollView // Add an id to the ScrollView
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
                            color: {
                                if (isConnected) return Theme.success; // Green when connected
                                if (isConnecting) return Theme.toggleOn; // Default "on" color when connecting
                                return Theme.toggleOff; // Gray otherwise
                            }

                            opacity: isConnecting ? 0.2 : 1.0

                            MouseArea {
                                anchors.fill: parent
                                enabled: connectionToggle.canConnect
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    SoundManager.playTouch()
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

                    // --- Bluetooth & Devices Setting ---
                    Item {
                        Layout.fillWidth: true
                        height: 48 // Fixed height for simplicity

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 4 // Align with text in other items
                            spacing: 12

                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    text: "Bluetooth & devices"
                                    color: Theme.primaryText
                                    font.pointSize: 16
                                }
                            }

                            Item { Layout.fillWidth: true } // Spacer

                            // Navigation Arrow
                            Text {
                                text: "chevron_right" // > icon
                                font.family: materialFontFamily
                                font.pixelSize: 32
                                color: Theme.secondaryText
                                Layout.alignment: Qt.AlignVCenter
                                Layout.rightMargin: 20
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SoundManager.playTouch()
                                currentSubPage = "bluetooth"
                                subPageTitle = "Bluetooth & devices"
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
                                onClicked: {
                                    SoundManager.playTouch()
                                    Theme.toggleTimeFormat()
                                }
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
                                onClicked: {
                                    SoundManager.playTouch()
                                    Theme.toggle()
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.separator
                    }

                    // --- Sound Touch Setting ---
                    Item {
                        Layout.fillWidth: true
                        height: Math.max(soundTouchTextColumn.implicitHeight, soundTouchToggle.implicitHeight)

                        ColumnLayout {
                            id: soundTouchTextColumn
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "Sound Touch"
                                color: Theme.primaryText
                                font.pointSize: 16
                            }
                            Text {
                                text: Theme.soundTouchEnabled ? "Enabled" : "Disabled"
                                color: Theme.secondaryText
                                font.pointSize: 12
                            }
                        }

                        Text {
                            id: soundTouchToggle
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: materialFontFamily
                            font.pixelSize: 48

                            text: Theme.soundTouchEnabled ? "toggle_on" : "toggle_off"
                            color: Theme.soundTouchEnabled ? Theme.toggleOn : Theme.toggleOff

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SoundManager.playTouch()
                                    Theme.toggleSoundTouch()
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.separator
                    }

                    // --- Volume Setting ---
                    Item {
                        Layout.fillWidth: true
                        height: Math.max(volumeTextColumn.implicitHeight, volumeControl.implicitHeight)

                        ColumnLayout {
                            id: volumeTextColumn
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "System Volume"
                                color: Theme.primaryText
                                font.pointSize: 16
                            }
                            Text {
                                text: "Volume: " + Theme.volumeLevel*20 + " %"
                                color: Theme.secondaryText
                                font.pointSize: 12
                            }
                        }

                        RowLayout {
                            id: volumeControl
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 16 // Khoảng cách lớn giữa các nút và cụm volume

                            // Decrease Volume Button
                            Text {
                                text: "remove"
                                font.family: materialFontFamily
                                font.pixelSize: 32
                                color: Theme.volumeLevel > 0 ? Theme.icon : Theme.tertiaryBg
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -10        // Increase clickable area
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: Theme.volumeLevel > 0
                                    onClicked: {
                                        SoundManager.playTouch()
                                        Theme.setVolumeLevel(Theme.volumeLevel - 1)
                                    }
                                }
                            }

                            // Volume level indicator (grouped in its own layout)
                            RowLayout {
                                spacing: 4 // Khoảng cách nhỏ giữa các thanh volume
                                Repeater {
                                    model: 5
                                    delegate: Rectangle {
                                        width: 24
                                        height: 14
                                        radius: 2
                                        color: index < Theme.volumeLevel ? Theme.toggleOn : Theme.tertiaryBg
                                        border.color: Theme.separator
                                        border.width: 1
                                    }
                                }
                            }

                            // Increase Volume Button
                            Text {
                                text: "add"
                                font.family: materialFontFamily
                                font.pixelSize: 32
                                color: Theme.volumeLevel < 5 ? Theme.icon : Theme.tertiaryBg
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -10        // Increase clickable area
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: Theme.volumeLevel < 5
                                    onClicked: {
                                        SoundManager.playTouch()
                                        Theme.setVolumeLevel(Theme.volumeLevel + 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // --- Sub-Page Content Area ---
            SettingsPages.BluetoothDevices {
                onBackRequested: settingsRoot.goBack()
            }

            // Add other sub-pages here in the future, but StackLayout only shows one at a time.
            // For more pages, a different logic for currentIndex would be needed.
        }
    }
}
