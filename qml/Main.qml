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
                case "Call":
                    callPage.processServerMessage(message)
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
                isPhoneConnected: callPage.isPhoneConnected
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
                                    ListElement { pageId: "Call"; icon: "call"; }
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

                        Pages.Call {
                            id: callPage
                            anchors.fill: parent
                            visible: currentPageId === "Call"
                            onNotify: (message, type) => showNotification(message, type)
                            onCallStateUpdated: (name, number, status) => {
                                // Just update the banner's data. Visibility is handled by bindings.
                                callBanner.callName = name
                                callBanner.callNumber = number
                                callBanner.callStatus = status
                            }
                            onCallEnded: {
                                // No longer need to explicitly hide banner. The binding on isInCall handles it.
                            }
                        }

                        Pages.Settings {
                            id: settingsPage
                            anchors.fill: parent
                            visible: currentPageId === "Settings"
                            wsClient: wsClient          // Pass the wsClient instance
                            confirmationDialog: confirmationDialog // Pass the dialog instance
                            onNotify: (message, type) => showNotification(message, type)
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

                        // --- Call Banner ---
                        Components.CallBanner {
                            id: callBanner
                            callName: callPage.callName
                            callNumber: callPage.callNumber
                            callStatus: callPage.callStatusText
                            // The banner is visible only when a call is active AND we are not on the Call page.
                            visible: callPage.isInCall && currentPageId !== "Call"

                            onBannerClicked: {
                                currentPageId = "Call"
                            }
                            onAccepted: {
                                // TODO: Send accept call command via WebSocket
                                console.log("Call accepted via banner")
                            }
                            onRejected: {
                                // TODO: Send reject call command via WebSocket
                                console.log("Call rejected via banner")
                            }
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
                            onDeviceSelected: (deviceName, deviceAddress) => {
                                if (!Theme.bluetoothEnabled) {
                                    showNotification("Cannot pair, Bluetooth is turned off.", "warning")
                                    return
                                }
                                if (wsClient && deviceAddress && wsClient.sendMessage({
                                    command: "pair_btdevice",
                                    data: {
                                        device_address: deviceAddress }})) {
                                    console.log("Sent pairing request for device:", deviceAddress)
                                    showNotification("Pairing with " + deviceName + "...", "info")
                                }
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

        // --- Brightness Overlay ---
        // This rectangle sits on top of all content and its opacity is adjusted
        // to simulate a brightness change.
        Rectangle {
            anchors.fill: parent
            color: "black"
            // The overlay is more opaque as brightnessLevel decreases.
            opacity: 1.0 - Theme.brightnessLevel
            // Ensure the overlay doesn't block mouse events from reaching the UI below.
            enabled: false
            // Set z-index to be above content but below popups like notifications (z=10) and screensaver (z=21).
            z: 9
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