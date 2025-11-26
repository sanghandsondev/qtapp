import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0
import com.company.utils 1.0
import QtQuick.Controls 2.15
import QtMultimedia 6.4
import com.company.sound 1.0

Item {
    id: recordRoot
    width: parent.width
    height: parent.height

    property var wsClient // Property to receive the WebSocket client instance from Main.qml
    property var confirmationDialog // Property to receive the ConfirmationDialog instance

    signal notify(string message, string type)

    property bool isRecording: false
    property int recordTime: 0 // in seconds

    // --- Playback State ---
    property int nowPlayingIndex: -1 // Index of the item currently playing in the ListView
    property int playbackStatus: MediaPlayer.StoppedState
    property real playbackPosition: 0
    property real playbackDuration: 1

    // Function to handle media player errors
    function handleMediaError() {
        if (mediaPlayer.error !== MediaPlayer.NoError) {
            console.error("MediaPlayer Error:", mediaPlayer.errorString)
            recordRoot.notify("Error playing audio: " + mediaPlayer.errorString, "error")
            resetPlaybackState()
        }
    }

    // Function to reset playback state, typically for the item that was playing
    function resetPlaybackState() {
        mediaPlayer.stop()
        nowPlayingIndex = -1
        playbackStatus = MediaPlayer.StoppedState
        playbackPosition = 0
        playbackDuration = 1
    }

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
                    resetPlaybackState() // Stop playback when recording starts
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
                break

            default:
                console.warn("RecordPage received unhandled message:", msgType)
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
            // Stop any ongoing playback when starting a new recording
            resetPlaybackState()
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

    // --- Audio Output for Media Player ---
    MediaDevices {
        id: mediaDevices
    }

    AudioOutput {
        id: audioOutput
        volume: Theme.volume
        // device: 
    }

    // --- Central Media Player ---
    // https://doc.qt.io/qt-6/qml-qtmultimedia-mediaplayer.html#stop-method
    MediaPlayer {
        id: mediaPlayer
        audioOutput: audioOutput // Set the audio output
        onPlaybackStateChanged: function(playbackState) {
            recordRoot.playbackStatus = playbackState
            if (playbackState === MediaPlayer.StoppedState) {
                // When playback finishes or is stopped, reset position
                recordRoot.playbackPosition = 0
            }
        }
        // onPositionChanged: recordRoot.playbackPosition = position
        // onDurationChanged: recordRoot.playbackDuration = duration
        onPositionChanged: function(position) {
            recordRoot.playbackPosition = position
        }
        onDurationChanged: function(duration) {
            recordRoot.playbackDuration = duration
        }
        onErrorChanged: handleMediaError()
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
                        SoundManager.playTouch()
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
                    onClicked: {
                        SoundManager.playTouch()
                        cancelRecording()
                    }
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
                currentIndex: -1 // No item is selected initially

                model: ListModel {
                    ListElement {
                        recordId: 14132423
                        name: "My First Fake Recording"
                        duration: 155 // 2:35
                        filepath: "/path/to/recording1.mp3"
                    }
                    ListElement {
                        recordId: 43124515135
                        name: "A HandSome Man's Recording Example"
                        duration: 48 // 0:48
                        filepath: "/path/to/recording2.mp3"
                    }
                    ListElement {
                        recordId: 1234566
                        name: "A HandSome Man's Recording Example Anathor Level 2"
                        duration: 48 // 0:48
                        filepath: "/path/to/recording2.mp3"
                    }
                }

                delegate: Rectangle {
                    id: delegateRoot
                    width: recordListView.width
                    // Animate height change when expanding/collapsing
                    height: isExpanded ? 128 : 66
                    color: isExpanded ? Qt.darker(Theme.secondaryBg, 1.2) : Theme.secondaryBg
                    radius: 8

                    property bool isExpanded: recordListView.currentIndex === index
                    property bool isPlaying: recordRoot.nowPlayingIndex === index && recordRoot.playbackStatus === MediaPlayer.PlayingState
                    property bool isPaused: recordRoot.nowPlayingIndex === index && recordRoot.playbackStatus === MediaPlayer.PausedState

                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    Behavior on color { ColorAnimation { duration: 200 } }

                    // This MouseArea handles expand/collapse. It's placed behind the controls.
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (recordListView.currentIndex !== index) {
                                // If another item was playing, stop it and reset its state
                                if (recordRoot.nowPlayingIndex !== -1 && recordRoot.nowPlayingIndex !== index) {
                                    recordRoot.resetPlaybackState()
                                }
                                recordListView.currentIndex = index // Expand new item
                            }
                            // If already expanded, do nothing to prevent collapse
                        }
                    }

                    // The main content of the delegate is now in a ColumnLayout
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0 // No space between main row and expanded panel

                        // --- Collapsed View (Always Visible) ---
                        RowLayout {
                            id: mainInfoRow
                            Layout.fillWidth: true
                            Layout.preferredHeight: 66 // Fixed height for the main row
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            spacing: 12

                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                text: model.name
                                color: Theme.primaryText
                                font.pointSize: 16
                                elide: Text.ElideRight
                            }

                            // Delete Icon (moved here)
                            Text {
                                text: "delete"
                                font.family: materialFontFamily
                                Layout.topMargin: 4
                                font.pixelSize: 32
                                color: Theme.secondaryText
                                visible: isExpanded // Only visible when item is expanded
                                opacity: visible ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 150 } }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -8 // Larger click area
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        mouse.accepted = true // Prevent expand/collapse
                                        recordRoot.confirmationDialog.open(
                                            "Delete Recording",
                                            "Are you sure you want to permanently delete '" + model.name + "'?",
                                            "Delete"
                                        )
                                        var recordId = model.id || model.recordId
                                        var onAccepted = function() {
                                            removeRecordingById(recordId)
                                            confirmationDialog.accepted.disconnect(onAccepted)
                                        }
                                        confirmationDialog.accepted.connect(onAccepted)
                                    }
                                }
                            }
                        }

                        // --- Expanded Playback View (Conditionally Visible) ---
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: isExpanded
                            opacity: isExpanded ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            // The playback controls are now in a single RowLayout
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 12
                                Layout.alignment: Qt.AlignVCenter

                                // Play/Pause Button
                                Text {
                                    text: isPlaying ? "pause_circle" : "play_circle"
                                    font.family: materialFontFamily
                                    font.pixelSize: 44 // Bigger icon
                                    color: Theme.icon
                                    Layout.alignment: Qt.AlignVCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: (mouse) => {
                                            mouse.accepted = true // Prevent expand/collapse

                                            // If recording, cancel it first
                                            if (isRecording) {
                                                cancelRecording()
                                                return // Exit to wait for cancel confirmation, make sure no playback starts during recording
                                            }

                                            console.log("isPlaying:", isPlaying)
                                            console.log("isPause:", isPaused)
                                            console.log(recordRoot.nowPlayingIndex, index)
                                            console.log(recordRoot.playbackStatus)
                                            console.log(MediaPlayer.PlayingState)
                                            console.log(mediaPlayer.audioOutput.device)
                                            // console.log(PlayingState)

                                            if (isPlaying) {
                                                mediaPlayer.pause()
                                            } else {
                                                // If another track is selected or paused, or no track is selected
                                                // TODO: Xử lý logic sai, khi mà chơi xong mà bấm play thì nó ko vào if này nữa
                                                if (recordRoot.nowPlayingIndex !== index || isPaused) {
                                                    if (recordRoot.nowPlayingIndex !== index) {
                                                        mediaPlayer.source = "file://" + model.filepath
                                                        recordRoot.nowPlayingIndex = index
                                                    }

                                                    // Re-check for error before playing, in case the source was already bad
                                                    if (mediaPlayer.error !== MediaPlayer.NoError) {
                                                        handleMediaError()
                                                        return
                                                    }
                                                    console.log("tryToPlay()")
                                                    mediaPlayer.play()
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    // Show current position if playing/paused, otherwise "00:00"
                                    text: (isPlaying || isPaused) ? formatTime(Math.floor(recordRoot.playbackPosition / 1000)) : "00:00"
                                    color: Theme.secondaryText
                                    font.pointSize: 12
                                    font.family: "monospace"
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Slider {
                                    Layout.fillWidth: true
                                    from: 0
                                    to: (isPlaying || isPaused) ? recordRoot.playbackDuration : 1
                                    value: (isPlaying || isPaused) ? recordRoot.playbackPosition : 0
                                    enabled: (isPlaying || isPaused)

                                    onMoved: (value) => {
                                        mediaPlayer.seek(value)
                                    }
                                }

                                Text {
                                    text: formatTime(model.duration || 0)
                                    color: Theme.secondaryText
                                    font.pointSize: 12
                                    font.family: "monospace"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
