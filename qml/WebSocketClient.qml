import QtQuick 6.4
import QtWebSockets 1.0

Item {
    id: root
    property url host: "ws://192.168.1.50:9000"
    property bool connected: false

    signal wsConnected()
    signal wsDisconnected()
    signal wsMessage(string message)

    WebSocket {
        id: socket
        url: host
        active: false

        onConnected: {
            root.connected = true
            root.wsConnected()
            console.log("WebSocket connected to", host)
        }
        onDisconnected: {
            root.connected = false
            root.wsDisconnected()
            console.log("WebSocket disconnected")
        }
        onTextMessageReceived: {
            root.wsMessage(text)
            console.log("WebSocket message:", text)
        }
    }

    function open() { socket.active = true }
    function close() { socket.active = false }
    function sendText(msg) { socket.sendTextMessage(msg) }
}
