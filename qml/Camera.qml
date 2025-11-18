import QtQuick 6.4
import QtQuick.Window 6.4
import com.company.style 1.0

Item {
    width: parent.width
    height: parent.height

    Rectangle {
        anchors.fill: parent
        color: "transparent" // Nền trong suốt

        Rectangle {
            id: btn
            width: 160
            height: 48
            radius: 8
            color: Theme.tertiaryBg // Màu nút xám đậm
            anchors.centerIn: parent

            Text {
                anchors.centerIn: parent
                text: "Camera"
                color: Theme.primaryText
                font.pointSize: 16
            }

            MouseArea { anchors.fill: parent; onClicked: console.log("Camera button clicked") }
        }
    }
}
