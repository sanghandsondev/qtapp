import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import com.company.style 1.0
import com.company.sound 1.0

Item {
    id: phoneBookRoot

    property bool isPhoneConnected: false
    property bool isSyncing: false

    property var contactList: []
    
    signal notify(string message, string type)

    // Function to get the section key (first letter of the name)
    function getSectionKey(name) {
        if (!name || name.length === 0) {
            return "#";
        }
        let firstChar = name[0].toUpperCase();
        let normalized = firstChar.normalize("NFD").replace(/[\u0300-\u036f]/g, "");

        // Special handling for 'Đ' which normalizes to 'D' but we want it as 'D'
        if (firstChar === 'Đ') {
            return 'D';
        }

        // If normalization results in a non-alphabetic character, group under '#'
        if (!/^[A-Z]$/.test(normalized)) {
            return "#";
        }

        return normalized;
    }

    // Function to process messages forwarded from Call.qml
    function processMessage(type, data) {
        switch (type) {
            case "pbap_phonebook_pull_start_noti":
                console.log("PhoneBook: Starting contact sync.")
                contactList = []
                phonebookModel.clear()
                break
            case "pbap_phonebook_pull_noti":
                // Add contact to cache
                contactList.push({
                                    name: data.contact_name,
                                    number: data.contact_number
                                })
                break
            case "pbap_phonebook_pull_end_noti":
                console.log("PhoneBook: Contact sync finished. Sorting and displaying.")
                // Sort the cache alphabetically by name
                contactList.sort(function(a, b) {
                    return a.name.localeCompare(b.name, 'vi')
                })
                // Populate the model from the sorted cache
                for (var i = 0; i < contactList.length; i++) {
                    phonebookModel.append({
                        name: contactList[i].name,
                        number: contactList[i].number,
                    })
                }
                // contactList = [] // Clear cache after use
                break
            case "pbap_session_end_noti":
                console.log("PhoneBook: PBAP session ended. Clearing data.")
                contactList = []
                phonebookModel.clear()
                break
            }
    }

    // The model for the ListView
    ListModel {
        id: phonebookModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // --- Search Bar ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: 8
            color: Theme.tertiaryBg
            opacity: 0.5 // Disabled appearance

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "search"
                    font.family: materialFontFamily
                    font.pixelSize: 24
                    color: Theme.secondaryText
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "Search..."
                    color: Theme.secondaryText
                    font.pointSize: 14
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: false // Disabled for now
                cursorShape: Qt.PointingHandCursor
            }
        }

        // --- Separator ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.separator
        }

        // --- Contact List ---
        ScrollView {
            id: contactScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: contactListView
                width: parent.width
                spacing: 8
                currentIndex: -1 // No item selected initially

                // The model is now the main phonebook model
                model: phonebookModel

                delegate: Item {
                    width: contactListView.width
                    height: 72
                    property bool isSelected: contactListView.currentIndex === index
                    property string sectionKey: getSectionKey(model.name)
                    property bool showLetter: index === 0 || sectionKey !== getSectionKey(phonebookModel.get(index - 1).name)

                    Rectangle {
                        anchors.fill: parent
                        color: isSelected ? Theme.secondaryBg : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SoundManager.playTouch()
                            contactListView.currentIndex = index
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 20
                        spacing: 16

                        // Letter Indicator
                        Text {
                            Layout.preferredWidth: 20
                            Layout.alignment: Qt.AlignVCenter
                            text: showLetter ? sectionKey : ""
                            font.pointSize: 14
                            font.bold: true
                            color: Theme.primaryText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Avatar Icon
                        Text {
                            text: "account_circle"
                            font.family: materialFontFamily
                            font.pixelSize: 40
                            color: Theme.icon
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Name and Phone Number
                        ColumnLayout {
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: model.name
                                color: Theme.primaryText
                                font.pointSize: 16
                            }
                            Text {
                                text: model.number
                                color: Theme.secondaryText
                                font.pointSize: 12
                            }
                        }

                        Item { Layout.fillWidth: true } // Spacer

                        // Call Button (visible when selected)
                        Rectangle {
                            id: callButton
                            width: 120
                            height: 40
                            radius: 20
                            color: Theme.success
                            Layout.alignment: Qt.AlignVCenter
                            visible: isSelected
                            opacity: isSelected ? 1.0 : 0.0
                            scale: callMouseArea.pressed ? 1.1 : 1.0
                            Behavior on visible { NumberAnimation { duration: 100 } }
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            Behavior on opacity { NumberAnimation { duration: 100 } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "call"
                                    font.family: materialFontFamily
                                    font.pixelSize: 22
                                    color: "white"
                                }
                                Text {
                                    text: "Call"
                                    font.pointSize: 16
                                    // font.bold: true
                                    color: "white"
                                }
                            }

                            MouseArea {
                                id: callMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SoundManager.playTouch()
                                    if (!phoneBookRoot.isPhoneConnected) {
                                        phoneBookRoot.notify("Please sync your phone to make calls.", "warning")
                                        return
                                    }
                                    console.log("Calling " + model.name + " at " + model.number)
                                    // TODO: Implement call functionality
                                    }
                                }
                            }
                        }

                    Rectangle {
                        visible: index < phonebookModel.count - 1
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 12 + 40 // Align with text
                        height: 1
                        color: Theme.separator
                    }
                }
            }
        }
    }

    // --- Loading Indicator ---
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12
        visible: isSyncing

        BusyIndicator {
            running: true
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: "Syncing contacts..."
            color: Theme.secondaryText
            font.pointSize: 14
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // --- "Not Connected" or "No Contacts" Message ---
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12
        visible: !isSyncing && (phonebookModel.count === 0 || !isPhoneConnected)

        Text {
            text: "folder_off"
            font.family: materialFontFamily
            font.pixelSize: 64
            color: Theme.secondaryText
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: isPhoneConnected ? "No contacts found" : "Contacts not available"
            color: Theme.secondaryText
            font.pointSize: 16
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            visible: !isPhoneConnected
            text: "Connect a phone via Bluetooth to sync contacts."
            color: Theme.secondaryText
            font.pointSize: 12
            Layout.alignment: Qt.AlignHCenter
        }
    }
}

