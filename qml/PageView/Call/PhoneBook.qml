import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 // For ScrollView
import com.company.style 1.0
import com.company.sound 1.0

Item {
    id: phoneBookRoot

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

                // The model is now sorted by name
                model: ListModel {
                    id: contactModel
                    ListElement { name: "Alice Johnson"; phone: "+1-202-555-0181" }
                    ListElement { name: "charlie Brown"; phone: "+1-415-555-0156" }
                    ListElement { name: "diana Miller"; phone: "+1-646-555-0199" }
                    ListElement { name: "đavid Clark"; phone: "+1-212-555-0110" }
                    ListElement { name: "Ethan Davis"; phone: "+44 20 7946 0958" }
                    ListElement { name: "Emily White"; phone: "+44 20 7946 0231" }
                    ListElement { name: "Fiona Garcia"; phone: "+44 1632 960842" }
                    ListElement { name: "Frank Harris"; phone: "+44 1632 960123" }
                    ListElement { name: "George Rodriguez"; phone: "+1-773-555-0112" }
                    ListElement { name: "Grace Lee"; phone: "+1-312-555-0145" }
                    ListElement { name: "Hannah Martinez"; phone: "+1-214-555-0178" }
                    ListElement { name: "Henry Wilson"; phone: "+1-404-555-0199" }
                    ListElement { name: "Ian Taylor"; phone: "+1-512-555-0101" }
                    ListElement { name: "Isabella Moore"; phone: "+1-713-555-0123" }
                    ListElement { name: "Jack Anderson"; phone: "+1-901-555-0144" }
                    ListElement { name: "James Martin"; phone: "+1-215-555-0165" }
                    ListElement { name: "Kevin Thomas"; phone: "+1-602-555-0187" }
                    ListElement { name: "Laura Hernandez"; phone: "+1-818-555-0198" }
                    ListElement { name: "Liam Smith"; phone: "+1-408-555-0134" }
                    ListElement { name: "Michael Moore"; phone: "+1-206-555-0155" }
                    ListElement { name: "Mia Jones"; phone: "+1-305-555-0176" }
                    ListElement { name: "Nancy Martin"; phone: "+1-702-555-0191" }
                    ListElement { name: "Noah Brown"; phone: "+1-503-555-0122" }
                    ListElement { name: "Olivia Jackson"; phone: "+1-801-555-0143" }
                    ListElement { name: "Oliver Wilson"; phone: "+1-619-555-0164" }
                    ListElement { name: "Peter White"; phone: "+1-407-555-0185" }
                    ListElement { name: "Penelope Taylor"; phone: "+1-916-555-0117" }
                    ListElement { name: "Quincy Harris"; phone: "+1-210-555-0138" }
                    ListElement { name: "Rachel Thompson"; phone: "+1-813-555-0159" }
                    ListElement { name: "Robert Anderson"; phone: "+1-317-555-0180" }
                    ListElement { name: "Sam Clark"; phone: "+1-614-555-0111" }
                    ListElement { name: "Sophia Thomas"; phone: "+1-704-555-0133" }
                    ListElement { name: "Tom Lewis"; phone: "+1-919-555-0154" }
                    ListElement { name: "Ursula Robinson"; phone: "+1-414-555-0175" }
                    ListElement { name: "Victor Walker"; phone: "+1-402-555-0196" }
                    ListElement { name: "Victoria Hall"; phone: "+1-505-555-0127" }
                    ListElement { name: "Wendy Hall"; phone: "+1-918-555-0148" }
                    ListElement { name: "William Young"; phone: "+1-316-555-0169" }
                    ListElement { name: "Xavier Young"; phone: "+1-208-555-0190" }
                    ListElement { name: "Yara Allen"; phone: "+1-401-555-0121" }
                    ListElement { name: "Zoe King"; phone: "+1-203-555-0142" }
                    ListElement { name: "Zachary Lee"; phone: "+1-302-555-0163" }
                }

                delegate: Item {
                    width: contactListView.width
                    height: 72
                    property bool isSelected: contactListView.currentIndex === index
                    property string sectionKey: getSectionKey(model.name)
                    property bool showLetter: index === 0 || sectionKey !== getSectionKey(contactModel.get(index - 1).name)

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
                                text: model.phone
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
                                    console.log("Calling " + model.name + " at " + model.phone)
                                    // TODO: Implement call logic
                                }
                            }
                        }
                    }

                    // Separator line
                    Rectangle {
                        visible: index < contactModel.count - 1
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 12 + 40 + 16 + 40 // Align with name text (Letter + Icon + Spacing)
                        height: 1
                        color: Theme.separator
                    }
                }
            }
        }
    }
}
