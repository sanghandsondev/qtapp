import QtQuick 6.4
import QtWebSockets 1.0

Item {
    id: root
    property url host: "ws://192.168.1.50:9000"
    property bool autoConnect: true         // Auto connect WebSocket on component completion (Init loaded)

    // --- Thuộc tính (Properties) ---
    readonly property alias status: socket.status
    readonly property bool connected: socket.status === WebSocket.Open

    // --- Tín hiệu (Signals) ---
    signal wsMessage(variant message)
    signal wsStatusChanged()
    signal wsError(string errorMessage)

    // Tự động kết nối khi component được hoàn thành
    Component.onCompleted: {
        if (autoConnect) {
            open()
        }
    }

    WebSocket {
        id: socket
        url: host
        active: false

        // Cập nhật thuộc tính 'connected' khi trạng thái thay đổi
        onStatusChanged: function(status) {
            console.log("WebSocket status changed:", status)
            root.wsStatusChanged() // Phát tín hiệu khi status thay đổi
        }

        onTextMessageReceived: {
            console.log("WebSocket raw message:", message)
            try {
                var jsonObj = JSON.parse(message)
                root.wsMessage(jsonObj)
            } catch (e) {
                console.error("Error parsing JSON from WebSocket:", e)
            }
        }
        
        onErrorStringChanged: function() {
            if (socket.errorString) {
                console.error("WebSocket error:", socket.errorString)
            }
        }
    }

    function open() {
        if (socket.status === WebSocket.Open || socket.status === WebSocket.Connecting) {
            console.log("WebSocket is already open or connecting.")
            return
        }
        console.log("Try to connect WebSocket to", host)
        if (socket.active) {
            socket.active = false
        }
        socket.active = true
    }

    // Send a JSON object via WebSocket
    function sendMessage(jsonObject) {
        if (socket.status === WebSocket.Open) {
            var jsonString = JSON.stringify(jsonObject) // Convert object to JSON string
            console.log("Sending WebSocket message:", jsonString)
            socket.sendTextMessage(jsonString)
        } else {
            console.warn("Cannot send message, WebSocket is not open. Current status:", socket.status)
            root.wsError("Action failed: Not connected to the server.")
        }
    }
}
