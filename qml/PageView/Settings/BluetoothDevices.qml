import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 // Import Controls for ScrollView
import com.company.style 1.0
import com.company.sound 1.0

Item {
    // anchors.fill: parent // This is needed again to fill the space provided by StackLayout

    // Signal to notify the parent (Settings.qml) to go back
    signal backRequested()

    ScrollView {
        id: bluetoothScrollView // Give the ScrollView an id
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            width: bluetoothScrollView.width // Bind width to the ScrollView's width
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
                            text: Theme.bluetoothEnabled ? "Discoverable as \"RaspberryPi\"" : "Bluetooth is turned off"
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

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SoundManager.playTouch()
                                Theme.toggleBluetooth()
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

            // --- Content for Bluetooth & Devices ---
            // (Currently empty as per request)
            Text {
                Layout.fillWidth: true
                text: "Bluetooth & Devices contents will be here."
                color: Theme.secondaryText
                font.pointSize: 14
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
