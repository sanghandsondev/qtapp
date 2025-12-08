import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0
import com.company.sound 1.0

import "qrc:/qml/PageView/Call/" as CallPages

Item {
    width: parent.width
    height: parent.height

    property string currentPage: "dial" // "dial", "phonebook", "history"

    // Reset to main dial view when the page becomes visible again.
    onVisibleChanged: {
        if (visible) {
            currentPage = "dial"
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
            }

            CallPages.PhoneBook {
                anchors.fill: parent
                visible: currentPage === "phonebook"
            }

            CallPages.History {
                anchors.fill: parent
                visible: currentPage === "history"
            }
        }
    }
}
