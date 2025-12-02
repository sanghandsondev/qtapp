import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import com.company.style 1.0
import com.company.sound 1.0

Rectangle {
    id: dialogRoot
    anchors.fill: parent
    color: "#80000000" // Lớp phủ màu đen mờ
    visible: false
    z: 20 // Đảm bảo nó ở trên cùng

    property int dotCount: 1

    signal deviceSelected(string deviceName)
    signal rejected()

    // --- Functions ---
    function open() {
        dialogRoot.visible = true
        dialogRoot.opacity = 1
    }

    function close() {
        dialogRoot.opacity = 0
        // Reset state when closing
    }

    // --- Timers ---
    Timer {
        id: dotAnimationTimer
        interval: 800
        repeat: true
        running: true
        onTriggered: {
            dotCount = (dotCount % 3) + 1
        }
    }

    // --- Animations ---
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 50 } }
    onOpacityChanged: {
        if (opacity === 0) {
            visible = false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {} // "Tiêu thụ" sự kiện click
    }

    // --- Dialog Content ---
    Rectangle {
        id: dialogContent
        width: 480
        height: 500
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
                text: "Add a bluetooth device"
                color: Theme.primaryText
                font.pointSize: 16
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
            }

            // --- Scanning Text ---
            Text {
                text: "Scanning for devices " + ".".repeat(dotCount)
                color: Theme.secondaryText
                font.pointSize: 14
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                Layout.topMargin: 8
            }

            // --- Device List ---
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ListView {
                    id: deviceListView
                    width: parent.width
                    spacing: 8
                    model: ListModel {
                        ListElement { name: "WH-1000XM4" }
                        ListElement { name: "JBL Charge 5" }
                        ListElement { name: "AirPods Pro" }
                        ListElement { name: "Unknown Device" }
                        ListElement { name: "Unknown Device" }
                        ListElement { name: "Unknown Device" }
                        ListElement { name: "Unknown Device" }
                        ListElement { name: "Unknown Device" }
                        ListElement { name: "Unknown Device" }
                        ListElement { name: "Unknown Device" }
                        ListElement { name: "Unknown Device" }
                        ListElement { name: "Unknown Device" }
                    }

                    delegate: Rectangle {
                        width: deviceListView.width
                        height: 60
                        color: "transparent"

                        RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            spacing: 12

                            Text {
                                text: "bluetooth"
                                font.family: materialFontFamily
                                font.pixelSize: 24
                                color: Theme.icon
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: model.name
                                color: Theme.primaryText
                                font.pointSize: 14
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SoundManager.playTouch()
                                dialogRoot.deviceSelected(model.name)
                                dialogRoot.close()
                            }
                        }
                    }
                }
            }

            // --- Cancel Button ---
            Rectangle {
                Layout.topMargin: 10
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                height: 40
                color: Theme.tertiaryBg
                radius: 6
                border.color: Theme.buttonBorder
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
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
        }
    }
}
