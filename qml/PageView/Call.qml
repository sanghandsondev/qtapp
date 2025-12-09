import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0
import com.company.sound 1.0

import "qrc:/qml/PageView/Call/" as CallPages

Item {
    id: callRoot
    width: parent.width
    height: parent.height

    property string currentPage: "dial" // "dial", "phonebook", "history"
    property bool isPhoneConnected: false
    property bool isSyncingContacts: false
    property bool isSyncingHistory: false

    signal notify(string message, string type)

    // Reset to main dial view when the page becomes visible again.
    onVisibleChanged: {
        if (visible) {
            currentPage = "dial"
        }
    }

    // Function to process messages from the server
    function processServerMessage(message) {
        var msgStatus = message.status === "success" ? true : false
        var msgType = message.data.msg
        var serverData = message.data.data

        console.log("Call Page processing message:", msgType)

        switch (msgType) {
            case "pbap_session_end_noti":
                isPhoneConnected = false
                isSyncingContacts = false
                isSyncingHistory = false
                phoneBookPage.processMessage(msgType, serverData)
                historyPage.processMessage(msgType, serverData)
                break
            case "pbap_phonebook_pull_start_noti":
                if (msgStatus) {
                    isPhoneConnected = true
                    isSyncingContacts = true
                    phoneBookPage.processMessage(msgType, serverData)
                }
                break
            case "pbap_phonebook_pull_noti":
                if (msgStatus) {
                    phoneBookPage.processMessage(msgType, serverData)
                }
                break
            case "pbap_phonebook_pull_end_noti":
                if (msgStatus) {
                    isSyncingContacts = false
                    phoneBookPage.processMessage(msgType, serverData)
                }
                break
            case "call_history_pull_start_noti":
                if (msgStatus) {
                    isPhoneConnected = true
                    isSyncingHistory = true
                    historyPage.processMessage(msgType, serverData)
                }
                break
            case "call_history_pull_noti":
                if (msgStatus) {
                    historyPage.processMessage(msgType, serverData)
                }
                break
            case "call_history_pull_end_noti":
                if (msgStatus) {
                    isSyncingHistory = false
                    historyPage.processMessage(msgType, serverData)
                }
                break
            default:
                console.log("Call Page received unknown message type:", msgType)
                break
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- Header with navigation tabs ---
        RowLayout {
            id: headerTabs
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            Layout.maximumHeight: 60 // Explicitly constrain the height
            spacing: 0

            Repeater {
                model: ListModel {
                    ListElement { pageName: "dial"; icon: "dialpad"; text: "Dial" }
                    ListElement { pageName: "phonebook"; icon: "contacts"; text: "Phone Book" }
                    ListElement { pageName: "history"; icon: "history"; text: "History" }
                }

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    property bool isActive: currentPage === model.pageName

                    Rectangle {
                        anchors.fill: parent
                        color: isActive ? Theme.tertiaryBg : "transparent"
                        radius: 8
                        anchors.margins: 4
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: model.icon
                            font.family: materialFontFamily
                            font.pixelSize: 32
                            color: isActive ? Theme.blue : Theme.icon
                            Layout.alignment: Qt.AlignVCenter
                            Behavior on color { ColorAnimation { duration: 50 } }
                        }
                        Text {
                            text: model.text
                            font.pointSize: 14
                            color: isActive ? Theme.blue : Theme.secondaryText
                            Layout.alignment: Qt.AlignVCenter
                            Behavior on color { ColorAnimation { duration: 50 } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (currentPage !== model.pageName) {
                                SoundManager.playTouch()
                                currentPage = model.pageName
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.separator
        }

        // --- Content area for sub-pages ---
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            CallPages.Dial {
                anchors.fill: parent
                visible: currentPage === "dial"
                isPhoneConnected: callRoot.isPhoneConnected
                onNotify: (message, type) => callRoot.notify(message, type)
            }

            CallPages.PhoneBook {
                id: phoneBookPage
                anchors.fill: parent
                visible: currentPage === "phonebook"
                isPhoneConnected: callRoot.isPhoneConnected
                isSyncing: callRoot.isSyncingContacts
                onNotify: (message, type) => callRoot.notify(message, type)
            }

            CallPages.History {
                id: historyPage
                anchors.fill: parent
                visible: currentPage === "history"
                isPhoneConnected: callRoot.isPhoneConnected
                isSyncing: callRoot.isSyncingHistory
                onNotify: (message, type) => callRoot.notify(message, type)
            }
        }
    }
}
