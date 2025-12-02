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
    property var confirmationDialog // Add property for the dialog

    // Signal to forward to Main.qml
    signal openPairingDialog()
    signal closePairingDialog()
    signal addNewScanBTDevice(variant deviceData)

    // --- State Management for Sub-Pages ---
    property string currentSubPage: "" // e.g., "bluetooth", "display"
    property string subPageTitle: ""   // e.g., "Bluetooth & devices"

    function goBack() {
        currentSubPage = ""
        subPageTitle = ""
    }

    // Function to process messages from the server
    function processServerMessage(message) {
        var msgStatus = message.status === "success" ? true : false
        var msgType = message.data.msg
        var serverData = message.data.data

        console.log("Settings Page processing message:", msgType)

        if (msgType === "start_scan_btdevice_noti") {
            if (!msgStatus) {
                // If scanning fails to start, close the pairing dialog.
                console.log("Failed to start Bluetooth scan, closing pairing dialog.")
                settingsRoot.closePairingDialog()
            }
        }
        else if (msgType === "paired_btdevice_found_noti") {
            if (msgStatus) {
                // TODO: Forward the paired device info to Setting bluetooth
            }
        }
        else if (msgType === "scanning_btdevice_found_noti") {
            if (msgStatus) {
                // TODO: Forward the new device info to the pairing dialog
                settingsRoot.addNewScanBTDevice(serverData)
            }
            
        } else {
            console.warn("Header Component received unknown message type:", msgType)
        }
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

                    // Allow clicking "Settings" to go back when on a sub-page
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10
                        enabled: currentSubPage !== ""
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            SoundManager.playTouch()
                            settingsRoot.goBack()
                        }
                    }
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
            currentIndex: {
                if (currentSubPage === "") return 0;
                if (currentSubPage === "bluetooth") return 1;
                if (currentSubPage === "display") return 2;
                if (currentSubPage === "sound") return 3;
                return 0; // Default to main list
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
                        height: Math.max(bluetoothTextColumn.implicitHeight, bluetoothToggle.implicitHeight)

                        // This MouseArea will handle navigation. It's placed here
                        // so it acts as a background click handler for the row,
                        // but other MouseAreas on top (like the toggle's) will
                        // catch the click first.
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SoundManager.playTouch()
                                currentSubPage = "bluetooth"
                                subPageTitle = "Bluetooth & devices"
                            }
                        }

                        ColumnLayout {
                            id: bluetoothTextColumn
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "Bluetooth & devices"
                                color: Theme.primaryText
                                font.pointSize: 16
                            }
                            Text {
                                text: Theme.bluetoothEnabled ? "Discoverable as \"RaspberryPi\"" : "Bluetooth is turned off"
                                color: Theme.secondaryText
                                font.pointSize: 12
                            }
                        }

                        // Right side: On/Off text, toggle, and navigation arrow
                        RowLayout {
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: Theme.bluetoothEnabled ? "On" : "Off"
                                color: Theme.secondaryText
                                font.pointSize: 14
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                id: bluetoothToggle
                                font.family: materialFontFamily
                                font.pixelSize: 48
                                Layout.alignment: Qt.AlignVCenter

                                text: Theme.bluetoothEnabled ? "toggle_on" : "toggle_off"
                                color: Theme.bluetoothEnabled ? Theme.toggleOn : Theme.toggleOff

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // This click is handled here and won't pass to the parent MouseArea
                                        SoundManager.playTouch()
                                        Theme.toggleBluetooth()
                                    }
                                }
                            }

                            // Navigation Arrow
                            Text {
                                text: "chevron_right" // > icon
                                font.family: materialFontFamily
                                font.pixelSize: 32
                                color: Theme.secondaryText
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.separator
                    }

                    // --- Display Setting ---
                    Item {
                        Layout.fillWidth: true
                        height: Math.max(displayTextColumn.implicitHeight, 48) // Use fixed height for consistency

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SoundManager.playTouch()
                                currentSubPage = "display"
                                subPageTitle = "Display"
                            }
                        }

                        ColumnLayout {
                            id: displayTextColumn
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "Display"
                                color: Theme.primaryText
                                font.pointSize: 16
                            }
                            Text {
                                text: "Time format, dark theme, brightness"
                                color: Theme.secondaryText
                                font.pointSize: 12
                            }
                        }

                        // Right side: Navigation arrow
                        RowLayout {
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            // Navigation Arrow
                            Text {
                                text: "chevron_right" // > icon
                                font.family: materialFontFamily
                                font.pixelSize: 32
                                color: Theme.secondaryText
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.separator
                    }

                    // --- Sound Setting ---
                    Item {
                        Layout.fillWidth: true
                        height: Math.max(soundTextColumn.implicitHeight, 48) // Use fixed height for consistency

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SoundManager.playTouch()
                                currentSubPage = "sound"
                                subPageTitle = "Sound"
                            }
                        }

                        ColumnLayout {
                            id: soundTextColumn
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "Sound"
                                color: Theme.primaryText
                                font.pointSize: 16
                            }
                            Text {
                                text: "Touch sounds, volume"
                                color: Theme.secondaryText
                                font.pointSize: 12
                            }
                        }

                        // Right side: Navigation arrow
                        RowLayout {
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            // Navigation Arrow
                            Text {
                                text: "chevron_right" // > icon
                                font.family: materialFontFamily
                                font.pixelSize: 32
                                color: Theme.secondaryText
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.separator
                    }
                }
            }

            // --- Sub-Page Content Area ---
            SettingsPages.BluetoothDevices {
                Layout.fillWidth: true
                Layout.fillHeight: true
                wsClient: settingsRoot.wsClient // Pass wsClient to sub-page
                onBackRequested: settingsRoot.goBack()
                // Forward the signal from the child to the parent (this file)
                onOpenPairingDialog: settingsRoot.openPairingDialog()
                confirmationDialog: settingsRoot.confirmationDialog // Pass dialog to sub-page
            }

            // --- Display Sub-Page ---
            SettingsPages.Display {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onBackRequested: settingsRoot.goBack()
            }

            // --- Sound Sub-Page ---
            SettingsPages.Sound {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onBackRequested: settingsRoot.goBack()
            }

            // Add other sub-pages here in the future, but StackLayout only shows one at a time.
            // For more pages, a different logic for currentIndex would be needed.
        }
    }
}
