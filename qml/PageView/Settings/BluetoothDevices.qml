import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 // Import Controls for ScrollView
import com.company.style 1.0
import com.company.sound 1.0

Item {
    // Signal to notify the parent (Settings.qml) to go back
    signal backRequested()
    // Signal to notify the parent to toggle the bluetooth power
    signal togglePower()
    // Signal to request opening the pairing dialog
    signal openPairingDialog()

    // Property to hold the WebSocket client instance
    property var wsClient

    // Property to hold the confirmation dialog instance from Settings.qml
    property var confirmationDialog

    // This property is now the single source of truth for the toggle state.
    // The parent (Settings.qml) will have an alias to this.
    property bool isTogglingBluetooth: false
    property bool isScanning: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // --- Bluetooth On/Off Setting ---
        RowLayout {
            Layout.fillWidth: true
            height: Math.max(bluetoothTextColumn.implicitHeight, bluetoothToggle.implicitHeight)

            // Left side: Icon and text
            RowLayout {
                id: bluetoothTextColumn
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 10 // Add margin
                spacing: 12

                Text {
                    text: "bluetooth"
                    font.family: materialFontFamily
                    font.pixelSize: 28
                    color: Theme.icon
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "Bluetooth"
                        color: Theme.primaryText
                        font.pointSize: 16
                    }
                    Text {
                        text: Theme.bluetoothEnabled ? "Discoverable as \"raspberrypi\"" : "Bluetooth is turned off"
                        color: Theme.secondaryText
                        font.pointSize: 12
                    }
                }
            }

            Item { Layout.fillWidth: true } // Spacer to push content to the edges

            // Right side: On/Off text and toggle
            RowLayout {
                Layout.alignment: Qt.AlignVCenter
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
                    Layout.rightMargin: 20

                    text: Theme.bluetoothEnabled ? "toggle_on" : "toggle_off"
                    color: Theme.bluetoothEnabled ? Theme.toggleOn : Theme.toggleOff
                    opacity: isTogglingBluetooth ? 0.4 : 1.0
                    Behavior on opacity { NumberAnimation { duration: 50 } }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: !isTogglingBluetooth
                        onClicked: {
                            // Emit a signal to the parent to handle the logic
                            togglePower()
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

        // --- Add New Device Setting ---
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            height: 56 // Fixed height for consistency

            // Left side: Text
            Text {
                text: "Pair new device with \"raspberrypi\""
                color: Theme.primaryText
                font.pointSize: 16
                Layout.alignment: Qt.AlignVCenter
                // Layout.leftMargin: 12
            }

            Item { Layout.fillWidth: true } // Spacer

            // Right side: Button
            Rectangle {
                id: addDeviceButton
                width: 140
                height: 40
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 20
                color: "transparent"
                radius: 6
                border.color: Theme.buttonBorder
                border.width: 1

                // Control opacity based on Bluetooth status
                opacity: Theme.bluetoothEnabled ? 1.0 : 0.4
                Behavior on opacity { NumberAnimation { duration: 50 } }

                Text {
                    anchors.centerIn: parent
                    text: "Add device"
                    color: Theme.primaryText
                    font.pointSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: Theme.bluetoothEnabled // Disable clicks when Bluetooth is off
                    onClicked: {
                        SoundManager.playTouch()
                        if (isScanning) {
                            // If already scanning, just open the dialog
                            openPairingDialog()
                        } else {
                            // Otherwise, request a new scan
                            if (wsClient && wsClient.sendMessage({ command: "start_scan_btdevice", data: {} })) {
                                console.log("Requested to start scanning for Bluetooth devices")
                            }
                            openPairingDialog()
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

        // --- Paired Devices Section ---
        Text {
            text: "Bluetooth devices"
            color: Theme.primaryText
            font.pointSize: 16
            // Layout.leftMargin: 12
            Layout.topMargin: 16
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: pairedDevicesView
                width: parent.width
                spacing: 8
                model: ListModel {
                    id: pairedDevicesModel
                    ListElement { name: "WH-1000XM4"; icon: "headphones"; connected: true }
                    ListElement { name: "Pixel 7 Pro"; icon: "smartphone"; connected: false }
                    ListElement { name: "JBL Charge 5"; icon: "speaker"; connected: false }
                }

                delegate: Item {
                    width: pairedDevicesView.width
                    height: 64

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 20
                        spacing: 12

                        // Icon and Text
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 16

                            Text {
                                text: model.icon
                                font.family: materialFontFamily
                                font.pixelSize: 28
                                color: Theme.icon
                            }

                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: model.name
                                    color: Theme.primaryText
                                    font.pointSize: 16
                                }
                                Text {
                                    text: model.connected ? "Connected" : "Paired"
                                    color: Theme.secondaryText
                                    font.pointSize: 12
                                }
                            }
                        }

                        Item { Layout.fillWidth: true } // Spacer

                        // Buttons
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 12

                            // Connect Button
                            Rectangle {
                                id: connectButton
                                width: 120
                                height: 36
                                color: "transparent"
                                radius: 6
                                border.color: Theme.buttonBorder
                                border.width: 1
                                Behavior on border.color { ColorAnimation { duration: 50 } }

                                opacity: Theme.bluetoothEnabled ? 1.0 : 0.4
                                Behavior on opacity { NumberAnimation { duration: 50 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: model.connected ? "Disconnect" : "Connect"
                                    color: Theme.primaryText
                                    font.pointSize: 14
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: Theme.bluetoothEnabled
                                    onClicked: {
                                        SoundManager.playTouch()
                                        // Toggle connected state for this device
                                        // In a real app, you would also handle logic to ensure only one audio device is connected at a time.
                                        pairedDevicesModel.setProperty(model.index, "connected", !model.connected)
                                        // TODO: Add actual connect/disconnect logic
                                    }
                                }
                            }

                            // Remove Button (Icon)
                            Rectangle {
                                width: 36
                                height: 36
                                color: "transparent"
                                radius: 6
                                border.color: Theme.buttonBorder
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "close"
                                    font.family: materialFontFamily
                                    font.pixelSize: 22
                                    color: Theme.secondaryText
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        SoundManager.playTouch()
                                        if (confirmationDialog) {
                                            confirmationDialog.accepted.connect(function onAccepted() {
                                                console.log("Unpairing device:", model.name)
                                                // TODO: Add actual unpair logic via WebSocket
                                                confirmationDialog.accepted.disconnect(onAccepted) // Clean up connection
                                            })
                                            confirmationDialog.open(
                                                "Unpair Device",
                                                "Are you sure you want to unpair \"" + model.name + "\"?",
                                                "Unpair"
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // --- Separator ---
                    Rectangle {
                        // Don't show separator for the last item
                        visible: model.index < pairedDevicesView.model.count - 1
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 12
                        height: 1
                        color: Theme.separator
                    }
                }
            }
        }
    }
}
