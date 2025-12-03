import QtQuick 6.4
import QtQuick.Window 6.4
import QtWebSockets 1.0
import com.company.ws 1.0
import QtQuick.Layouts 1.15
import com.company.style 1.0
import com.company.sound 1.0

// Import child components
import "qrc:/qml/PageView/" as Pages
import "qrc:/qml/Components/" as Components

Window {
    id: root
    width: 1024
    height: 600
    visible: true
    title: "Qt App"

    property string currentPageId: "Home"
    property var currentTime: new Date()

    // Global timer to update the current time for all components (e.g., Header, ScreenSaver)
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            root.currentTime = new Date()
        }
    }

    // Timer for ScreenSaver activation
    Timer {
        id: inactivityTimer
        interval: 300000 // 5 minutes in milliseconds
        running: true
        repeat: false // Will trigger once when interval is reached
        onTriggered: {
            screenSaver.visible = true
        }
    }

    // Hàm để hiển thị thông báo
    function showNotification(text, type) {
        notificationBanner.show(text, type);
    }

    // Handle signal 'wsMessage' to process incoming messages
    function handleMessageFromServer(message) {
        console.log("Received JSON from server:", JSON.stringify(message))

        if (message.status === "fail") {
            if (message.msg) {
                showNotification(message.msg, "error")
            }
        }

        if (message) {
            // Lấy ra message.data.component để xử lý tùy theo component
            switch (message.data.component) {
                case "Header":
                    header.processServerMessage(message)
                    break;
                case "Settings":
                    settingsPage.processServerMessage(message)
                    break;
                case "Record":
                    recordPage.processServerMessage(message)
                    break;
                default:
                    console.warn("Unknown component in server message:", message.data.component)
                    break;
                }
            }
    }

    // Instantiate WebSocket client
    WebSocketClient {
        id: wsClient
        host: isPiBuild ? "ws://192.168.1.50:9000" : "ws://127.0.0.1:9000" 

        onWsMessage: function(message) {
            handleMessageFromServer(message)
        }

        onWsError: function(errorMessage) {
            showNotification(errorMessage, "error")
        }

        onWsStatusChanged: {
            switch(status) {
                case WebSocket.Open:
                    showNotification("WebSocket Server connected successfully.", "success");
                    // Khi kết nối thành công, yêu cầu danh sách bản ghi
                    recordPage.getAllRecords();
                    break;
                case WebSocket.Connecting:
                    // Có thể không cần thông báo khi đang kết nối, hoặc chỉ là thông báo 'info'
                    // showNotification("Connecting to WebSocket...", "info");
                    break;
                case WebSocket.Closed:
                    showNotification("WebSocket Server disconnected.", "warning");
                    break;
                case WebSocket.Error:
                    showNotification("WebSocket Server connection error.", "error");
                    break;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.primaryBg // Nền chính màu xám đậm

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // --- Top Header ---
            Components.Header {
                id: header
                currentTime: root.currentTime
                // The properties fanSpeed and temperature will be updated
                // by the handleMessageFromServer function.
            }

            // This container holds the sidebar and content area
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Left vertical bar
                    Rectangle {
                        id: sidebar
                        Layout.preferredWidth: 120
                        Layout.fillHeight: true
                        color: Theme.secondaryBg

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4
                            spacing: 4

                            Repeater {
                                model: ListModel {
                                    id: pageModel
                                    ListElement { pageId: "Home"; icon: "home"; }
                                    ListElement { pageId: "Record"; icon: "fiber_manual_record"; }
                                    ListElement { pageId: "Media"; icon: "perm_media"; }
                                    ListElement { pageId: "Camera"; icon: "photo_camera"; }
                                    ListElement { pageId: "Settings"; icon: "settings"; }
                                }

                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 100
                                    color: currentPageId === model.pageId ? Theme.tertiaryBg : "transparent"
                                    radius: 8

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Text {
                                            text: model.icon
                                            font.pixelSize: 36
                                            font.family: materialFontFamily // Sử dụng font Material Symbols
                                            color: Theme.icon // Màu icon xám nhạt
                                            Layout.alignment: Qt.AlignHCenter // Căn giữa theo chiều ngang
                                        }

                                        Text {
                                            text: model.pageId
                                            color: Theme.iconSubtle
                                            font.pixelSize: 16
                                            Layout.alignment: Text.AlignHCenter // Căn giữa theo chiều ngang
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            SoundManager.playTouch()
                                            currentPageId = model.pageId
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Right content area
                    Rectangle {
                        id: contentArea
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        // Khởi tạo tất cả các trang và chỉ hiển thị trang hiện tại.
                        // Điều này giúp giữ lại trạng thái của các trang trước đó khi chuyển đổi.
                        Pages.Home {
                            anchors.fill: parent
                            visible: currentPageId === "Home"
                        }

                        Pages.Record {
                            id: recordPage
                            anchors.fill: parent
                            visible: currentPageId === "Record"
                            onNotify: (message, type) => showNotification(message, type)    // slot hiển thị thông báo từ Record page
                            wsClient: wsClient                      // Pass the wsClient instance
                            confirmationDialog: confirmationDialog  // Pass the dialog instance
                        }

                        Pages.Media {
                            anchors.fill: parent
                            visible: currentPageId === "Media"
                        }

                        Pages.Camera {
                            anchors.fill: parent
                            visible: currentPageId === "Camera"
                        }

                        Pages.Settings {
                            id: settingsPage
                            anchors.fill: parent
                            visible: currentPageId === "Settings"
                            wsClient: wsClient          // Pass the wsClient instance
                            confirmationDialog: confirmationDialog // Pass the dialog instance
                            onOpenPairingDialog: bluetoothPairingDialog.open()
                            onClosePairingDialog: bluetoothPairingDialog.close()
                            onAddNewScanBTDevice: function(deviceData) {
                                bluetoothPairingDialog.addNewScanBTDevice(deviceData)
                            }
                            onDeleteScanBTDevice: function(deviceAddress) {
                                bluetoothPairingDialog.deleteScanBTDevice(deviceAddress)
                            }
                        }

                        // --- Notification Banner ---
                        Components.NotificationBanner {
                            id: notificationBanner
                            anchors.top: parent.top
                            topMargin: 8
                            width: 640
                            radius: 8
                            z: 10     // Ensure it's on top of sidebar and content
                        }

                        // --- Confirmation Dialog ---
                        Components.ConfirmationDialog {
                            id: confirmationDialog
                        }

                        // --- Bluetooth Pairing Dialog ---
                        Components.BluetoothPairingDialog {
                            id: bluetoothPairingDialog
                            wsClient: wsClient // Pass the wsClient instance
                            isScanning: settingsPage.isScanning // Pass scanning state
                            onDeviceSelected: (deviceName) => {
                                showNotification("Pairing with " + deviceName + "...", "info")
                                // TODO: Add actual pairing logic via WebSocket
                            }
                        }
                    }
                }

                // --- Screen Saver ---
                Components.ScreenSaver {
                    id: screenSaver
                    anchors.fill: parent
                    visible: false
                    z: 21       // Ensure it's on top of all content (including Banner and Dialog)
                    currentTime: root.currentTime
                    onTouched: {
                        visible = false
                        inactivityTimer.restart()
                    }
                }
            }
        }

        // This MouseArea covers the whole window to detect activity
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true // Also reset on mouse move
            propagateComposedEvents: true // Allow events to pass to items below

            onPressed: (mouse) => {
                inactivityTimer.restart()
                mouse.accepted = false // Let other MouseAreas handle the click
            }

            onPositionChanged: (mouse) => {
                inactivityTimer.restart()
                mouse.accepted = false
            }
        }
    }
}