import QtQuick 6.4
import QtQuick.Window 6.4

Window {
    width: 900
    height: 600
    visible: true
    title: "IVI-style QML Demo"

    property string currentPage: "Home"

    Rectangle {
        anchors.fill: parent
        color: "#e9eef6"

        Row {
            anchors.fill: parent

            // Left vertical bar
            Rectangle {
                id: sidebar
                width: 96
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "#1f2937"

                Column {
                    anchors { left: parent.left; right: parent.right; horizontalCenter: parent.horizontalCenter }
                    spacing: 12
                    anchors.top: parent.top
                    anchors.topMargin: 20

                    Repeater {
                        model: [
                            {id: "Home", icon: "🏠"},
                            {id: "Settings", icon: "⚙️"},
                            {id: "Record", icon: "⏺️"}
                        ]

                        delegate: Rectangle {
                            width: parent.width
                            height: 72
                            color: currentPage === modelData.id ? "#374151" : "transparent"
                            radius: 8

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 28
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    text: modelData.id
                                    color: "#cbd5e1"
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea { anchors.fill: parent; onClicked: currentPage = modelData.id }
                        }
                    }
                }
            }

            // Right content area
            Rectangle {
                id: contentArea
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: sidebar.right
                anchors.right: parent.right
                color: "transparent"

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    source: "qrc:/" + currentPage + ".qml"
                }
            }
        }
    }
}