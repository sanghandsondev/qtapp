import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0
import com.company.utils 1.0

Rectangle {
    id: screenSaverRoot
    color: Theme.primaryBg // Use the main background color

    property var currentTime
    
    signal clicked()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        // Time Display
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Text {
                text: {
                    if (Theme.is24HourFormat) {
                        return Qt.formatDateTime(screenSaverRoot.currentTime, "HH:mm");
                    } else {
                        var hours = screenSaverRoot.currentTime.getHours();
                        var minutes = screenSaverRoot.currentTime.getMinutes();
                        var displayHours = hours % 12;
                        if (displayHours === 0) displayHours = 12;
                        return (displayHours < 10 ? "0" : "") + displayHours + ":" + (minutes < 10 ? "0" : "") + minutes;
                    }
                }
                color: Theme.primaryText
                font.pointSize: 40
                font.bold: true
            }

            Text {
                text: {
                    if (Theme.is24HourFormat) {
                        return "";
                    } else {
                        return screenSaverRoot.currentTime.getHours() >= 12 ? "PM" : "AM";
                    }
                }
                visible: !Theme.is24HourFormat
                color: Theme.primaryText
                font.pointSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 6
            }
        }

        // Date Display
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(currentTime, "dddd, MMMM d, yyyy")
            color: Theme.secondaryText
            font.pointSize: 20
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: screenSaverRoot.clicked()
    }
}
