import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0
import com.company.utils 1.0
import QtQuick.Controls 2.15

Item {
    id: recordRoot
    width: parent.width
    height: parent.height

    property var wsClient // Property to receive the WebSocket client

    signal notify(string message, string type)

    property bool isRecording: false
    property int recordTime: 0 // in seconds

    // Function to handle messages from the server routed by Main.qml
    function processServerMessage(message) {
        console.log("RecordPage processing message:", JSON.stringify(message))
        var msgStatus = message.status === "success" ? true : false
        var msgType = message.data.msg
        var serverData = message.data.data

        switch (msgType) {
            case "start_record_noti":
                if(msgStatus){
                    isRecording = true
                } else {
                    isRecording = false;
                }
                recordTime = 0
                break
            case "stop_record_noti":
                if(msgStatus){
                    isRecording = false
                } else {
                    isRecording = false;
                }
                recordTime = 0
                break
            case "cancel_record_noti":
                if(msgStatus){
                    isRecording = false
                } else {
                    isRecording = false;
                }
                recordTime = 0
                break
            case "get_all_record_noti":
                if (msgStatus) {
                    // Replace the entire list with new data from the server
                    // TODO: Chưa cắt file path -> chỉ lấy tên file
                    recordListView.model.clear()
                    if (serverData && serverData.records) {
                        for (var i = 0; i < serverData.records.length; i++) {
                            var record = serverData.records[i]
                            recordListView.model.append({
                                recordId: record.id,
                                name: Utils.getFileName(record.file_path),
                                duration: record.duration_sec,
                                filepath: record.file_path
                            })
                        }
                    }
                
                } else {
                    console.warn("Failed to get all records from server.", msgType)
                }
                break
            case "insert_record_noti":
                if (msgStatus) {
                    // Insert the new record at the top of the list
                    if (serverData && serverData.record) {
                        recordListView.model.insert(0, {
                            recordId: serverData.record.id,
                            name: Utils.getFileName(serverData.record.file_path),
                            duration: serverData.record.duration_sec,
                            filepath: serverData.record.file_path
                        })
                    }
                } else {
                    console.warn("Failed to insert new record from server.", msgType)
                }
                break
            case "remove_record_noti":
                if(msgStatus) {
                    // Find and remove a specific record by its ID
                    if (serverData && serverData.id) {
                        for (var j = 0; j < recordListView.model.count; j++) {
                            if (recordListView.model.get(j).recordId === serverData.id) {
                                recordRoot.notify("Recording '" + recordListView.model.get(j).name + "' has been deleted.", "success")
                                recordListView.model.remove(j)
                                break
                            }
                        }
                    }
                } else {
                    console.warn("Failed to remove record from server.", msgType)
                }

            default:
                console.warn("RecordPage received unhandled message:", )
                break
        }
    }

    // Timer to update the recording duration
    Timer {
        id: recordTimer
        interval: 1000 // 1 second
        repeat: true
        running: isRecording
        onTriggered: {
            if (recordTime < 240) { // 4 minutes limit (4 * 60 = 240s)
                recordTime++
            } else {
                stopRecording() // Auto-stop at 4 minutes
                recordRoot.notify("Recording automatically saved after 4 minutes.", "info")
            }
        }
    }

    // Function to format time from seconds to MM:SS
    function formatTime(seconds) {
        var m = Math.floor(seconds / 60)
        var s = seconds % 60
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }

    // Function to start recording
    function startRecording() {
        if (wsClient && wsClient.sendMessage({ command: "start_record", data: {} })) {
            console.log("Start recording...")
        }
    }

    // Function to stop recording
    function stopRecording() {
        
        if (wsClient && wsClient.sendMessage({ command: "stop_record", data: {  } })) {
            console.log("Recording finished. Duration:", recordTime, "seconds.")
        }
    }

    // Function to cancel recording
    function cancelRecording() {
        if (wsClient && wsClient.sendMessage({ command: "cancel_record", data: {} })) {
            console.log("Recording cancelled.")
        }
    }

    // Function to remove a recording by ID
    function removeRecordingById(recordId) {
        if (wsClient && recordId && wsClient.sendMessage({ command: "remove_record", data: { id: recordId } })) {
            console.log("Removing recording with ID:", recordId)
        }
    }

    // Function to request all recordings from the server
    function getAllRecords() {
        if (wsClient && wsClient.sendMessage({ command: "get_all_record", data: {} })) {
            console.log("Requesting all records from server.")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // --- Header ---
        Text {
            text: "Record"
            color: Theme.primaryText
            font.pointSize: 20
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.separator
        }

        // --- New Record Section ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            // Record Button
            Rectangle {
                id: recordButton
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.minimumWidth: 48
                Layout.minimumHeight: 48
                radius: width / 2
                color: "transparent" // Nền ngoài trong suốt
                border.color: Theme.buttonBorder // Border màu mặc định
                border.width: 2

                Rectangle {
                    id: innerShape
                    anchors.centerIn: parent    
                    color: "#ef4444" // Màu đỏ cho hình bên trong

                    // Trạng thái khi không ghi âm: hình tròn lớn
                    // Trạng thái khi ghi âm: hình vuông bo góc nhỏ hơn
                    width: isRecording ? 24 : 36
                    height: isRecording ? 24 : 36
                    radius: isRecording ? 4 : 18 // 18 để thành hình tròn (36/2)

                    // Hiệu ứng chuyển đổi mượt mà
                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (isRecording) {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }
                }
            }

            // Timer Display
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: formatTime(recordTime) + " / 04:00"
                color: isRecording ? Theme.primaryText : Theme.secondaryText
                font.pointSize: 16
                font.family: "monospace" // Use a monospaced font for stable width
            }

            // Spacer to push trash icon to the right
            Item {
                Layout.fillWidth: true
            }

            // Cancel/Trash Icon - visible only when recording
            Text {
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 10 // Thêm margin bên phải cho icon
                text: "delete" // Material Symbols icon name
                font.family: materialFontFamily
                font.pixelSize: 40
                color: Theme.secondaryText
                opacity: isRecording ? 1.0 : 0.0 // Use opacity for smooth transition
                visible: opacity > 0 // Hide when not recording to prevent interaction

                Behavior on opacity { NumberAnimation { duration: 50 } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cancelRecording()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.separator
        }

        // --- Recordings List Header ---
        Text {
            text: "Saved Recordings"
            color: Theme.secondaryText
            font.pointSize: 14
        }

        // --- Recordings List (Scrollable) ---
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: recordListView
                width: parent.width
                spacing: 8
                model: ListModel {
                    // Model is now initially empty. It will be populated by the server.
                    // {model.recordId, model.name, model.duration, model.filepath}
                    ListElement {
                        recordId: "fake_id_1"
                        name: "My First Fake Recording"
                        duration: 155 // 2:35
                        filepath: "/path/to/recording1.mp3"
                    }
                    ListElement {
                        recordId: "fake_id_2"
                        name: "A very long recording name to test text eliding feature"
                        duration: 48 // 0:48
                        filepath: "/path/to/recording2.mp3"
                    }
                }

                delegate: Rectangle {
                    width: recordListView.width
                    height: 66
                    color: Theme.secondaryBg
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12 // Add spacing between elements

                        // Column for Name and Duration
                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                text: model.name
                                color: Theme.primaryText
                                font.pointSize: 16
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            // Duration Text as a sub-line
                            Text {
                                // Assumes model has 'duration' in seconds
                                text: formatTime(model.duration || 0)
                                color: Theme.secondaryText
                                font.pointSize: 12
                                font.family: "monospace"
                            }
                        }

                        // Spacer to push delete icon to the right
                        Item {
                            Layout.fillWidth: true
                        }

                        // Delete Icon - This now acts as a fixed-size anchor on the right
                        Text {
                            text: "delete" // Material Symbols icon name
                            font.family: materialFontFamily
                            font.pixelSize: 24
                            color: Theme.secondaryText
                            Layout.alignment: Qt.AlignVCenter

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -10    // Increase clickable area
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Open confirmation dialog
                                    confirmationDialog.open(
                                        "Delete Recording",
                                        "Are you sure you want to permanently delete '" + model.name + "'?",
                                        "Delete"
                                    )

                                    // Capture context for the callback
                                    // The model can have 'id' (from server) or 'recordId' (from fake ListElement)
                                    var recordId = model.id || model.recordId // Use the ID for deletion

                                    // Define the function to be called on acceptance
                                    var onAccepted = function() {
                                        // Send delete command to server.
                                        // The UI will update only when the server sends back a confirmation.
                                        removeRecordingById(recordId)
                                        // Disconnect this function from the signal (one-time signal)
                                        confirmationDialog.accepted.disconnect(onAccepted)
                                    }

                                    // Connect the signal to our function
                                    confirmationDialog.accepted.connect(onAccepted)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
