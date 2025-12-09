import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 // For ScrollView
import com.company.style 1.0
import com.company.sound 1.0

Item {
    id: historyRoot

    property string currentFilter: "all" // "all" or "missed"

    signal notify(string message, string type)

    onVisibleChanged: {
        if (visible) {
            currentFilter = "all"
        }
    }

    function getIconForCallType(type) {
        switch (type) {
        case "incoming":
            return "call_received"
        case "outgoing":
            return "call_made"
        case "missed":
            return "call_missed"
        default:
            return ""
        }
    }

    function getColorForCallType(type) {
        switch (type) {
        case "incoming":
            return Theme.success // Green
        case "outgoing":
            return Theme.blue // Blue
        case "missed":
            return Theme.accent // Red
        default:
            return Theme.secondaryText
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- Filter Tabs ---
        RowLayout {
            id: filterTabs
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 20
            Layout.preferredHeight: 34
            spacing: 4

            Repeater {
                model: ListModel {
                    ListElement { filter: "all"; text: "All" }
                    ListElement { filter: "missed"; text: "Missed" }
                }

                delegate: Item {
                    Layout.preferredWidth: 120
                    Layout.fillHeight: true
                    property bool isActive: currentFilter === model.filter

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: 1
                        border.color: isActive ? Theme.secondaryText : "transparent"
                        radius: 8
                        anchors.margins: 4
                        Behavior on border.color { ColorAnimation { duration: 50 } }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: model.text
                            font.pointSize: 14
                            // font.bold: isActive
                            color: isActive ? Theme.primaryText : Theme.secondaryText
                            Behavior on color { ColorAnimation { duration: 50 } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        anchors.margins: -4
                        onClicked: {
                            if (currentFilter !== model.filter) {
                                SoundManager.playTouch()
                                currentFilter = model.filter
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

        // --- History List ---
        ScrollView {
            id: historyScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: historyListView
                width: parent.width
                spacing: 4
                model: ListModel {
                    id: historyModel
                    // Sample Data
                    ListElement { name: "Alice Johnson"; phone: "+1-202-555-0181"; type: "incoming"; time: "10:30 AM" }
                    ListElement { name: "Charlie Brown"; phone: "+1-415-555-0156"; type: "missed"; time: "Yesterday" }
                    ListElement { name: "Diana Miller"; phone: "+1-646-555-0199"; type: "outgoing"; time: "2 days ago" }
                    ListElement { name: "Ethan Davis"; phone: "+44 20 7946 0958"; type: "incoming"; time: "Oct 15" }
                    ListElement { name: "Unknown"; phone: "+44 1632 960123"; type: "missed"; time: "Oct 14" }
                }

                delegate: Item {
                    width: historyListView.width
                    height: 64
                    visible: currentFilter === 'all' || (currentFilter === 'missed' && model.type === 'missed')

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        // Call Type Icon
                        Text {
                            text: getIconForCallType(model.type)
                            font.family: materialFontFamily
                            font.pixelSize: 24
                            color: getColorForCallType(model.type)
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Name and Phone Number
                        ColumnLayout {
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter
                            // Layout.fillWidth: true // Remove this

                            Text {
                                text: model.name
                                color: Theme.primaryText
                                font.pointSize: 15
                            }
                            Text {
                                text: model.phone
                                color: Theme.secondaryText
                                font.pointSize: 12
                            }
                        }

                        // Spacer to push time to the right
                        Rectangle {
                            Layout.fillWidth: true
                            color: "transparent"
                        }

                        // Time
                        Text {
                            text: model.time
                            color: Theme.secondaryText
                            font.pointSize: 12
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // Separator line
                    Rectangle {
                        visible: index < historyModel.count - 1
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20 + 24 + 16 // Align with name text
                        height: 1
                        color: Theme.separator
                    }
                }
            }
        }
    }
}
