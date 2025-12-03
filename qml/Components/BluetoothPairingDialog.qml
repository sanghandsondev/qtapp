import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import com.company.style 1.0
import com.company.sound 1.0
import com.company.utils 1.0

Rectangle {
    id: dialogRoot
    anchors.fill: parent
    color: "#80000000" // Lớp phủ màu đen mờ
    visible: false
    z: 20 // Đảm bảo nó ở trên cùng

    property var wsClient
    property bool isScanning: false // Add this property
    property int dotCount: 1

    signal deviceSelected(string deviceName, string deviceAddress)
    signal rejected()

    // --- Functions ---
    function open() {
        dialogRoot.visible = true
        dialogRoot.opacity = 1
    }

    function close() {
        dialogRoot.opacity = 0
    }

    //  {"device_name", }, {"device_address",}, {"rssi", }, {"is_paired",}, {"is_connected", } {"icon"}
    
    function addNewScanBTDevice(deviceData) {
        // Do not show devices that are already paired or connected in the scanning list.
        if (deviceData.is_paired || deviceData.is_connected) {
            return
        }
        
        for(var i = 0; i < deviceListView.model.count; i++) {
            if (deviceListView.model.get(i).address === deviceData.device_address) {
                // Device already exists in the list
                return
            }
        }

        var deviceObject = {
            name: deviceData.device_name,
            address: deviceData.device_address,
            icon: deviceData.icon,
        }

        if (Utils.getIconForDevice(deviceData.icon) !== "bluetooth") {
            deviceListView.model.insert(0, deviceObject)
        } else {
            deviceListView.model.append(deviceObject)
        }
    }

    function deleteScanBTDevice(deviceAddress) {
        for (var i = 0; i < deviceListView.model.count; i++) {
            if (deviceListView.model.get(i).address === deviceAddress) {
                deviceListView.model.remove(i)
                break
            }
        }
    }

    // --- Timers ---
    Timer {
        id: dotAnimationTimer
        interval: 800
        repeat: true
        running: dialogRoot.visible && isScanning // Only run when visible and scanning
        onTriggered: {
            dotCount = (dotCount % 3) + 1
        }
    }

    // --- Animations ---
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 50 } }
    onOpacityChanged: {
        if (opacity === 0) {
            visible = false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {} // "Tiêu thụ" sự kiện click
    }

    // --- Dialog Content ---
    Rectangle {
        id: dialogContent
        width: 480
        height: 500
        anchors.centerIn: parent
        color: Theme.secondaryBg
        radius: 12
        border.color: Theme.separator
        border.width: 1

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // --- Title ---
            Text {
                text: "Add a bluetooth device"
                color: Theme.primaryText
                font.pointSize: 16
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
            }

            // --- Scanning Text ---
            Text {
                text: isScanning ? "Scanning for devices " + ".".repeat(dotCount) : "Select a device to pair"
                color: Theme.secondaryText
                font.pointSize: 14
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                Layout.topMargin: 8
            }

            // --- Device List ---
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ListView {
                    id: deviceListView
                    width: parent.width
                    spacing: 8
                    model: ListModel {
                        // ListElement { name: "WH-1000XM4" }
                        // ListElement { name: "JBL Charge 5" }
                        // ListElement { name: "AirPods Pro" }
                    }

                    delegate: Rectangle {
                        width: deviceListView.width
                        height: 60
                        color: "transparent"

                        RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            spacing: 12

                            Text {
                                text: Utils.getIconForDevice(model.icon)
                                font.family: materialFontFamily
                                font.pixelSize: 24
                                color: Theme.icon
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: model.name
                                color: Theme.primaryText
                                font.pointSize: 14
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SoundManager.playTouch()
                                // The stop scan logic is removed. The pairing request will be sent from the parent.
                                dialogRoot.deviceSelected(model.name, model.address)
                                dialogRoot.close()
                            }
                        }
                    }
                }
            }

            // --- Cancel Button ---
            Rectangle {
                Layout.topMargin: 10
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                height: 40
                color: Theme.tertiaryBg
                radius: 6
                border.color: Theme.buttonBorder
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: Theme.secondaryText
                    font.pointSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        SoundManager.playTouch()
                        if (isScanning) {
                            if (wsClient && wsClient.sendMessage({ command: "stop_scan_btdevice", data: {} })) {
                                console.log("Stop scan bluetooth device")
                            }
                        }
                        dialogRoot.rejected()
                        dialogRoot.close()
                    }
                }
            }
        }
    }
}
