import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0
import QtQuick.Controls 2.15

Item {
    id: recordRoot
    width: parent.width
    height: parent.height

    property bool isRecording: false
    property int recordTime: 0 // in seconds

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
        console.log("Start recording...")
        recordTime = 0
        isRecording = true
    }

    // Function to stop recording
    function stopRecording() {
        console.log("Recording finished. Duration:", recordTime, "seconds.")
        isRecording = false
        // Here you would typically save the recording and add it to the list

        recordTime = 0;
    }

    // Function to cancel recording
    function cancelRecording() {
        console.log("Recording cancelled.")
        isRecording = false
        recordTime = 0
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
                    ListElement { name: "Meeting Notes 2023-10-27" }
                    ListElement { name: "Voice Memo - Idea" }
                    ListElement { name: "Interview with John Doe" }
                    ListElement { name: "Lecture Recording - Part 1" }
                    ListElement { name: "Ambient Sounds - Park" }
                    ListElement { name: "Guitar Riff Idea" }
                    ListElement { name: "Project Brainstorm" }
                    ListElement { name: "Family Gathering Clip" }
                    ListElement { name: "Podcast Intro Draft" }
                    ListElement { name: "Language Practice Session" }
                }

                delegate: Rectangle {
                    width: recordListView.width
                    height: 56
                    color: Theme.secondaryBg
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12 // Add spacing between name and icon

                        Text {
                            text: model.name
                            color: Theme.primaryText
                            font.pointSize: 14
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Delete Icon
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
                                    // Open confirmation dialog instead of deleting directly
                                    confirmationDialog.open(
                                        "Delete Recording",
                                        "Are you sure you want to permanently delete '" + model.name + "'?",
                                        "Delete"
                                    )

                                    // Capture context for the callback
                                    var listView = recordListView
                                    var itemIndex = index

                                    // Define the function to be called on acceptance
                                    var onAccepted = function() {
                                        // Use the captured context
                                        if (listView && listView.model && itemIndex >= 0) {
                                            listView.model.remove(itemIndex)
                                        }
                                        // Disconnect this function from the signal (one-time signal)
                                        confirmationDialog.accepted.disconnect(onAccepted)
                                    }

                                    // Connect the signal to our function (one-time signal)
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
