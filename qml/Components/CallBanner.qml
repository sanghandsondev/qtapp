import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0
import com.company.sound 1.0
import com.company.utils 1.0


Rectangle {

    property string callName: ""
    property string callNumber: ""
    property string callStatus: ""

    property var wsClient
    property bool isCallProgress: false

    signal accepted()
    signal rejected()
    signal bannerClicked()

    // --- Functions ---
    // These functions are no longer needed for visibility but can be kept for updating data if needed.
    function show(name, number, status) {
        bannerRoot.callName = name
        bannerRoot.callNumber = number
        bannerRoot.callStatus = status
        bannerRoot.visible = true
    }

    function hide() {
        bannerRoot.visible = false
    }

    // --- Banner UI ---

    id: bannerRoot
    width: 480
    height: 100
    // Start position off-screen at the bottom
    y: parent ? parent.height : height
    anchors.horizontalCenter: parent.horizontalCenter
    opacity: 0
    color: Theme.secondaryBg
    radius: 16
    border.color: Theme.blue
    border.width: 2
    z: 15 // Above content, below dialogs

    // Animate in/out based on the 'visible' property
    states: [
        State {
            name: "Visible"
            when: bannerRoot.visible
            PropertyChanges { target: bannerRoot; y: parent.height - bannerRoot.height - 16; opacity: 1 }
        },
        State {
            name: "Hidden"
            when: !bannerRoot.visible
            PropertyChanges { target: bannerRoot; y: parent.height; opacity: 0 }
        }
    ]

    transitions: [
        Transition {
            from: "Hidden"; to: "Visible"
            NumberAnimation { properties: "y"; duration: 500; easing.type: Easing.OutCubic }
            NumberAnimation { properties: "opacity"; duration: 300 }
        },
        Transition {
            from: "Visible"; to: "Hidden"
            NumberAnimation { properties: "y"; duration: 500; easing.type: Easing.InCubic }
            NumberAnimation { properties: "opacity"; duration: 300 }
        }
    ]

    // --- Main Content ---
    MouseArea {
        id: bannerClickArea
        anchors.fill: parent
        onClicked: bannerRoot.bannerClicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 16

        // Call Info
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            // Caller Name
            Text {
                text: callName.length > 15 ? callName.substring(0, 15) + "..." : callName
                font.pointSize: 16
                font.bold: true
                color: Theme.primaryText
                elide: Text.ElideRight
            }

            // Caller Number
            Text {
                text: callNumber
                font.pointSize: 14
                color: Theme.secondaryText
            }

            // Call Status
            Text {
                text: Utils.formatCallStatus(callStatus)
                font.pointSize: 12
                color: Theme.blue
                // Layout.topMargin: 2
            }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // Action Buttons
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 20

            // Reject/End Call Button
            Rectangle {
                width: 60
                height: 60
                radius: 30
                color: Theme.accent

                Text {
                    text: "call_end"
                    font.family: materialFontFamily
                    font.pixelSize: 32
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: !bannerRoot.isCallProgress
                    onClicked: {
                        SoundManager.playTouch()
                        bannerRoot.rejected()
                    }
                    // Prevent clicks from propagating to the banner's main MouseArea
                    propagateComposedEvents: false
                }
            }

            // Accept Call Button
            Rectangle {
                width: 60
                height: 60
                radius: 30
                color: Theme.success
                visible: callStatus === "incoming" || callStatus === "waiting"

                Text {
                    text: "call"
                    font.family: materialFontFamily
                    font.pixelSize: 32
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: !bannerRoot.isCallProgress
                    onClicked: {
                        SoundManager.playTouch()
                        bannerRoot.accepted()
                    }
                    // Prevent clicks from propagating to the banner's main MouseArea
                    propagateComposedEvents: false
                }
            }
        }
    }
}
