import QtQuick 6.4
import QtQuick.Window 6.4
import QtWebSockets 1.0
import com.company.ws 1.0
import QtQuick.Layouts 1.15
import com.company.style 1.0

Window {
    width: 1024
    height: 600
    visible: true
    title: "Qt App"

    property string currentPageId: "Home"
    property url currentPageSource: "qrc:/qml/Home.qml"
    
    // Hàm để hiển thị thông báo
    function showNotification(text, type) {
        notificationBanner.show(text, type);
    }

    // Instantiate WebSocket client (default host points to your Pi server)
    WebSocketClient {
        id: wsClient
        // host: "ws://127.0.0.1:9000"

        // Handle signal 'wsMessage' to process incoming messages
        onWsMessage: {
            console.log("Received JSON from server:", JSON.stringify(message))

            // Example of how to process the message based on its content
            // if (message.type === "status_update") {
            //     console.log("Received a status update:", message.data)
            // }
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
                            ListElement { pageId: "Home"; icon: "home"; sourceUrl: "qrc:/qml/Home.qml" }
                            ListElement { pageId: "Record"; icon: "fiber_manual_record"; sourceUrl: "qrc:/qml/Record.qml" }
                            ListElement { pageId: "Media"; icon: "perm_media"; sourceUrl: "qrc:/qml/Media.qml" }
                            ListElement { pageId: "Camera"; icon: "photo_camera"; sourceUrl: "qrc:/qml/Camera.qml" }
                            ListElement { pageId: "Settings"; icon: "settings"; sourceUrl: "qrc:/qml/Settings.qml" }
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
                                    currentPageSource = model.sourceUrl
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

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    source: currentPageSource
                    onLoaded: {
                        // Pass the WebSocket client to the loaded page if it has a 'wsClient' property
                        if (item.hasOwnProperty("wsClient")) {
                            item.wsClient = wsClient
                        }
                    }
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