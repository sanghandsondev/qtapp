import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0
import com.company.sound 1.0

Rectangle {
    id: dialogRoot
    anchors.fill: parent
    color: "#80000000" // Lớp phủ màu đen mờ
    visible: false
    z: 20 // Đảm bảo nó ở trên cùng

    property string title: "Confirm Action"
    property string message: "Are you sure you want to proceed?"
    property string confirmButtonText: "OK"
    property string cancelButtonText: "Cancel"

    signal accepted()
    signal rejected()

    // --- Functions ---
    function open(titleText, msg, confirmText) {
        dialogRoot.title = titleText || "Confirm Action"
        dialogRoot.message = msg || "Are you sure you want to proceed?"
        dialogRoot.confirmButtonText = confirmText || "OK"
        dialogRoot.visible = true
        dialogRoot.opacity = 1
    }

    function close() {
        dialogRoot.opacity = 0
    }

    // --- Animations ---
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 50 } } // Changed duration from 200 to 50
    onOpacityChanged: {
        if (opacity === 0) {
            visible = false
        }
    }

    // Ngăn các cú nhấp chuột đi qua nội dung phía sau
    MouseArea {
        anchors.fill: parent
        onClicked: {} // Không làm gì cả, chỉ "tiêu thụ" sự kiện click
    }

    // --- Dialog Content ---
    Rectangle {
        id: dialogContent
        width: 400
        height: contentColumn.implicitHeight + 40 // Add vertical padding
        anchors.centerIn: parent
        color: Theme.secondaryBg
        radius: 12
        border.color: Theme.separator
        border.width: 1

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // --- Title ---
            Text {
                text: dialogRoot.title
                color: Theme.primaryText
                font.pointSize: 16
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // --- Message ---
            Text {
                text: dialogRoot.message
                color: Theme.secondaryText
                font.pointSize: 14
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // --- Buttons ---
            RowLayout {
                Layout.topMargin: 10
                Layout.fillWidth: true
                spacing: 12

                // Cancel Button
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: Theme.tertiaryBg
                    radius: 6
                    border.color: Theme.buttonBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: dialogRoot.cancelButtonText
                        color: Theme.secondaryText
                        font.pointSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            dialogRoot.rejected()
                            dialogRoot.close()
                        }
                    }
                }

                // Confirm/Delete Button
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: Theme.accent // Use theme accent color
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: dialogRoot.confirmButtonText
                        color: Theme.primaryText
                        font.pointSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SoundManager.playTouch()
                            dialogRoot.accepted()
                            dialogRoot.close()
                        }
                    }
                }
            }
        }
    }
}
