import QtQuick 6.4
import QtQuick.Window 6.4

Item {
    width: 640
    height: 480

    Rectangle {
        anchors.fill: parent
        color: "#f0fff4"

        Rectangle {
            id: btn
            width: 160
            height: 48
            radius: 8
            color: "#e85353"
            anchors.centerIn: parent

            Text {
                anchors.centerIn: parent
                text: "Record"
                color: "white"
                font.pointSize: 16
            }

            MouseArea { anchors.fill: parent; onClicked: console.log("Record button clicked") }
        }
    }
}
