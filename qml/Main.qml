import QtQuick 6.4
import QtQuick.Window 6.4
import QtWebSockets 1.0
import com.company.ws 1.0
import QtQuick.Layouts 1.15
import com.company.style 1.0

// Import các trang con
import "qrc:/qml/" as Pages

Window {
    width: 1024
    height: 600
    visible: true
    title: "Qt App"

    property string currentPageId: "Home"

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
            return
        }

        if (message.status === "success") {
            if (message.data) {
                // Lấy ra message.data.component để xử lý tùy theo component
                switch (message.data.component) {
                    case "Settings":
                        settingsPage.processServerMessage(message.data)
                        break;
                    case "Record":
                        recordPage.processServerMessage(message.data)
                        break;
                    // case "Home":
                        // homePage.processServerMessage(message.data)
                        // break;
                    // case "Media":
                        // mediaPage.processServerMessage(message.data)
                        // break;
                    // case "Camera":
                        // cameraPage.processServerMessage(message.data)
                        // break;
                    default:
                        console.warn("Unknown component in server message:", message.data.component)
                        break;
                }
            }
        }
    }

    // Instantiate WebSocket client
    WebSocketClient {
        id: wsClient
        host: isPiBuild ? "ws://192.168.1.50:9000" : "ws://127.0.0.1:9000" 

        onWsMessage: {
            handleMessageFromServer(message)
        }

        onWsError: {
            showNotification(errorMessage, "error")
        }

        onWsStatusChanged: {
            switch(status) {
                case WebSocket.Open:
                    showNotification("WebSocket Server connected successfully.", "success");
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
                // Điều này giúp giữ trạng thái của các trang khi chuyển đổi.
                Pages.Home {
                    anchors.fill: parent
                    visible: currentPageId === "Home"
                }

                Pages.Record {
                    id: recordPage
                    anchors.fill: parent
                    visible: currentPageId === "Record"
                    onNotify: showNotification(message, type)   // slot để hiển thị thông báo
                    wsClient: wsClient // Truyền wsClient
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
                    wsClient: wsClient // Truyền wsClient
                }

                // --- Notification Banner ---
                NotificationBanner {
                    id: notificationBanner
                    anchors.horizontalCenter: parent.horizontalCenter
                    topMargin: 16 // Sử dụng thuộc tính topMargin thay cho anchors
                    width: 640 // Chiều rộng của banner
                    radius: 8
                    z: 10 // Đảm bảo nó hiển thị trên các thành phần khác
                }

                // --- Confirmation Dialog ---
                ConfirmationDialog {
                    id: confirmationDialog
                }
            }
        }
    }
}