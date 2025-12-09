import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 // For ScrollView
import com.company.style 1.0
import com.company.sound 1.0
import com.company.utils 1.0

Item {
    id: historyRoot

    property string currentFilter: "all" // "all", "missed"
    property bool isPhoneConnected: false
    property bool isSyncing: false

    property var historyList: []
    property var historyMissedList: []

    signal notify(string message, string type)

    onVisibleChanged: {
        if (visible) {
            currentFilter = "all"
            updateHistoryModel()
        }
    }

    function updateHistoryModel() {
        historyModel.clear()
        var sourceList = (currentFilter === "missed") ? historyMissedList : historyList
        for (var i = 0; i < sourceList.length; i++) {
            historyModel.append(sourceList[i])
        }
    }

    function processMessage(type, data) {
        switch (type) {
        case "call_history_pull_start_noti":
            console.log("History: Starting call history sync.")
            historyList = []
            historyMissedList = []
            historyModel.clear()
            break
        case "call_history_pull_noti":
            var callItem = {
                name: data.call_history_name,
                number: data.call_history_number,
                type: data.call_history_type,
                datetime: data.call_history_datetime
            }
            historyList.push(callItem)
            if (callItem.type === "missed") {
                historyMissedList.push(callItem)
            }
            break
        case "call_history_pull_end_noti":
            console.log("History: Call history sync finished. Populating model.")
            updateHistoryModel()
            break
        case "pbap_session_end_noti":
            console.log("History: PBAP session ended. Clearing data.")
            historyList = []
            historyMissedList = []
            historyModel.clear()
            break
        }
    }

    function getIconForCallType(type) {
        switch (type) {
        case "received": // ofono uses 'received'
            return "call_received"
        case "dialed": // ofono uses 'dialed'
            return "call_made"
        case "missed":
            return "call_missed"
        default:
            return "help"
        }
    }

    function getColorForCallType(type) {
        switch (type) {
        case "received":
            return Theme.success // Green
        case "dialed":
            return Theme.blue // Blue
        case "missed":
            return Theme.accent // Red
        default:
            return Theme.secondaryText
        }
    }

    ListModel {
        id: historyModel
        // Sample Data
        // ListElement { name: "Alice Johnson"; number: "+1-202-555-0181"; type: "received"; time: "10:30 AM" }
        // ListElement { name: "Charlie Brown"; number: "+1-415-555-0156"; type: "missed"; time: "Yesterday" }
        // ListElement { name: "Diana Miller"; number: "+1-646-555-0199"; type: "dialed"; time: "2 days ago" }
        // ListElement { name: "Ethan Davis"; number: "+44 20 7946 0958"; type: "received"; time: "Oct 15" }
        // ListElement { name: "Unknown"; number: "+44 1632 960123"; type: "missed"; time: "Oct 14" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- Filter Tabs ---
        RowLayout {
            id: filterTabs
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 20
            Layout.preferredHeight: 40
            Layout.maximumHeight: 40
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
                                updateHistoryModel()
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
                model: historyModel

                delegate: Item {
                    width: historyListView.width
                    height: 64

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

                            Text {
                                text: model.name
                                color: Theme.primaryText
                                font.pointSize: 15
                            }
                            Text {
                                text: model.number
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
                            text: Utils.formatHistoryTime(model.datetime)
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
            text: "Syncing call history..."
            color: Theme.secondaryText
            font.pointSize: 14
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // --- "Not Connected" or "No History" Message ---
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12
        visible: !isSyncing && (historyModel.count === 0 || !isPhoneConnected)

        Text {
            text: "history_toggle_off"
            font.family: materialFontFamily
            font.pixelSize: 64
            color: Theme.secondaryText
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: isPhoneConnected ? "No call history" : "History not available"
            color: Theme.secondaryText
            font.pointSize: 16
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            visible: !isPhoneConnected
            text: "Connect a phone via Bluetooth to sync call histories."
            color: Theme.secondaryText
            font.pointSize: 12
            Layout.alignment: Qt.AlignHCenter
        }
    }
}





