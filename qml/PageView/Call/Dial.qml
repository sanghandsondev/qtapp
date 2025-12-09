import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0
import com.company.sound 1.0

Item {
    id: dialRoot

    property string dialedNumber: ""
    property int maxLen: 15
    property bool isPhoneConnected: false

    signal notify(string message, string type)

    // Function to handle button presses
    function appendDigit(digit) {
        SoundManager.playTouch()
        dialedNumber += digit
    }

    // Function to delete the last digit
    function backspace() {
        SoundManager.playTouch()
        if (dialedNumber.length > 0) {
            dialedNumber = dialedNumber.substring(0, dialedNumber.length - 1)
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 20
        anchors.margins: 20

        // --- Left Side: Display and Call Controls ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Display for the dialed number
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                Layout.alignment: Qt.AlignVCenter


                Text {
                    id: numberDisplay
                    text: {
                        if (dialRoot.dialedNumber.length > maxLen) {
                            return "..." + dialRoot.dialedNumber.slice(-(maxLen - 1));
                        }
                        return dialRoot.dialedNumber;
                    }
                    anchors.centerIn: parent
                    font.pointSize: dialRoot.dialedNumber.length > maxLen ? 26 : 32
                    color: Theme.primaryText
                }
            }

            Item { Layout.fillHeight: true } // Spacer

            // Call control buttons
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 50 // Increased spacing

                // Reject/End Call Button (Disabled state)
                Rectangle {
                    width: 70 // Smaller size
                    height: 70
                    radius: 35
                    color: Theme.tertiaryBg // Grayed out color

                    Text {
                        text: "call_end"
                        font.family: materialFontFamily
                        font.pixelSize: 36 // Smaller icon
                        color: Theme.secondaryText // Grayed out icon
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: false // Disabled for now
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // TODO: Handle end call
                        }
                    }
                }

                // Call Button (Green)
                Rectangle {
                    id: callButton
                    width: 80
                    height: 80
                    radius: 40
                    color: Theme.success // Green color

                    property bool isPressed: callMouseArea.pressed
                    scale: isPressed ? 1.1 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        text: "call"
                        font.family: materialFontFamily
                        font.pixelSize: 40
                        color: "white"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: callMouseArea
                        anchors.fill: parent
                        enabled: dialRoot.dialedNumber.length > 0
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            SoundManager.playTouch()
                            if (!dialRoot.isPhoneConnected) {
                                dialRoot.notify("Please connect bluetooth and Sync your phone to make calls.", "warning")
                                return
                            }
                            // TODO: Handle making a call
                            console.log("Calling " + dialRoot.dialedNumber)
                        }
                    }
                }

                // Backspace Button
                Rectangle {
                    width: 70 // Smaller size to match end call button
                    height: 70
                    radius: 35
                    color: "transparent" // No background
                    opacity: dialRoot.dialedNumber.length > 0 ? 1.0 : 0.4

                    Text {
                        text: "backspace"
                        font.family: materialFontFamily
                        font.pixelSize: 36 // Smaller icon
                        color: Theme.icon
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: dialRoot.dialedNumber.length > 0
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: dialRoot.backspace()
                    }
                }
            }

            Item { Layout.preferredHeight: 20 } // Small spacer at the bottom
        }

        // --- Right Side: Dial Pad ---
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.rightMargin: 20
            Layout.minimumWidth: (80 * 3) + (30 * 2) // 3 buttons * 80px + 2 spacings * 30px
            columns: 3
            columnSpacing: 30
            rowSpacing: 20

            Repeater {
                model: ListModel {
                    ListElement { main: "1"; sub: "" }
                    ListElement { main: "2"; sub: "A B C" }
                    ListElement { main: "3"; sub: "D E F" }
                    ListElement { main: "4"; sub: "G H I" }
                    ListElement { main: "5"; sub: "J K L" }
                    ListElement { main: "6"; sub: "M N O" }
                    ListElement { main: "7"; sub: "P Q R S" }
                    ListElement { main: "8"; sub: "T U V" }
                    ListElement { main: "9"; sub: "W X Y Z" }
                    ListElement { main: "*"; sub: "" }
                    ListElement { main: "0"; sub: "+" }
                    ListElement { main: "#"; sub: "" }
                }

                delegate: Rectangle {
                    id: dialButton
                    Layout.alignment: Qt.AlignCenter
                    implicitWidth: 90
                    implicitHeight: 90
                    radius: Math.min(width, height) / 2
                    color: isPressed ? Qt.darker(Theme.tertiaryBg, 1.3) : Theme.tertiaryBg

                    property bool isPressed: buttonMouseArea.pressed

                    scale: isPressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Behavior on color { ColorAnimation { duration: 100 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0

                        Text {
                            text: model.main
                            font.pointSize: 26
                            font.bold: true
                            color: Theme.primaryText
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: model.sub
                            font.pointSize: 10
                            color: Theme.secondaryText
                            opacity: model.sub === "" ? 0 : 1 // Use opacity to keep layout consistent
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: buttonMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dialRoot.appendDigit(model.main)
                    }
                }
            }
        }
    }
}
