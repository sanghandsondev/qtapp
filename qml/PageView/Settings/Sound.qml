import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import com.company.style 1.0
import com.company.sound 1.0

Item {
    // Signal to notify the parent (Settings.qml) to go back
    signal backRequested()

    ScrollView {
        id: soundScrollView
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            width: soundScrollView.width
            spacing: 16

            // --- Sound Touch Setting ---
            RowLayout {
                Layout.fillWidth: true
                height: Math.max(soundTouchTextColumn.implicitHeight, soundTouchToggle.implicitHeight)

                // Left side: Icon and text
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 10
                    spacing: 12

                    Text {
                        text: "touch_app" // Touch icon
                        font.family: materialFontFamily
                        font.pixelSize: 28
                        color: Theme.icon
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        id: soundTouchTextColumn
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "Sound Touch"
                            color: Theme.primaryText
                            font.pointSize: 16
                        }
                        Text {
                            text: "Play a sound on touch interactions"
                            color: Theme.secondaryText
                            font.pointSize: 12
                        }
                    }
                }

                Item { Layout.fillWidth: true } // Spacer

                // Right side: On/Off text and toggle
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    Text {
                        text: Theme.soundTouchEnabled ? "On" : "Off"
                        color: Theme.secondaryText
                        font.pointSize: 14
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        id: soundTouchToggle
                        font.family: materialFontFamily
                        font.pixelSize: 48
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 20

                        text: Theme.soundTouchEnabled ? "toggle_on" : "toggle_off"
                        color: Theme.soundTouchEnabled ? Theme.toggleOn : Theme.toggleOff

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SoundManager.playTouch()
                                Theme.toggleSoundTouch()
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

            // --- System Volume Setting ---
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                height: Math.max(volumeTextColumn.implicitHeight, volumeControl.implicitHeight)

                // Left side: Icon and text
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 10
                    spacing: 12

                    Text {
                        text: "volume_up" // Volume icon
                        font.family: materialFontFamily
                        font.pixelSize: 28
                        color: Theme.icon
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        id: volumeTextColumn
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "System Volume"
                            color: Theme.primaryText
                            font.pointSize: 16
                        }
                        Text {
                            text: "Volume: " + Theme.volumeLevel*20 + " %"
                            color: Theme.secondaryText
                            font.pointSize: 12
                        }
                    }
                }

                Item { Layout.fillWidth: true } // Spacer

                // Right side: Volume level selector
                RowLayout {
                    id: volumeControl
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 20
                    spacing: 16

                    Text {
                        text: "remove"
                        font.family: materialFontFamily
                        font.pixelSize: 32
                        color: Theme.volumeLevel > 0 ? Theme.icon : Theme.tertiaryBg
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10
                            cursorShape: Qt.PointingHandCursor
                            enabled: Theme.volumeLevel > 0
                            onClicked: {
                                SoundManager.playTouch()
                                Theme.setVolumeLevel(Theme.volumeLevel - 1)
                            }
                        }
                    }

                    RowLayout {
                        spacing: 4
                        Repeater {
                            model: 5
                            delegate: Rectangle {
                                width: 24
                                height: 14
                                radius: 2
                                color: index < Theme.volumeLevel ? Theme.toggleOn : Theme.tertiaryBg
                                border.color: Theme.separator
                                border.width: 1
                            }
                        }
                    }

                    Text {
                        text: "add"
                        font.family: materialFontFamily
                        font.pixelSize: 32
                        color: Theme.volumeLevel < 5 ? Theme.icon : Theme.tertiaryBg
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10
                            cursorShape: Qt.PointingHandCursor
                            enabled: Theme.volumeLevel < 5
                            onClicked: {
                                SoundManager.playTouch()
                                Theme.setVolumeLevel(Theme.volumeLevel + 1)
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

            // --- Output Device Setting ---
            Item {
                Layout.fillWidth: true
                // The height will be just the button's height. The dropdown will appear on top of other elements.
                height: 64
                z: outputDeviceLayout.expanded ? 1 : 0 // Bring to front when expanded

                ColumnLayout {
                    id: outputDeviceLayout
                    width: parent.width

                    property bool expanded: false

                    onExpandedChanged: {
                        if (expanded) {
                            deviceList.forceLayout()
                        }
                    }

                    // --- Main Row for Output Device ---
                    RowLayout {
                        width: parent.width
                        height: 64

                        // Left side: Icon and text
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: 10
                            spacing: 12

                            Text {
                                text: "speaker" // Speaker icon
                                font.family: materialFontFamily
                                font.pixelSize: 28
                                color: Theme.icon
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: "Output Device"
                                    color: Theme.primaryText
                                    font.pointSize: 16
                                }
                                Text {
                                    text: "Choose where to play sound"
                                    color: Theme.secondaryText
                                    font.pointSize: 12
                                }
                            }
                        }

                        Item { Layout.fillWidth: true } // Spacer

                        // Right side: Dropdown-like button and the dropdown list itself
                        Item {
                            id: dropdownContainer
                            width: 250
                            height: 40
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: 20

                            Rectangle {
                                id: deviceButton
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: 40
                                color: Theme.tertiaryBg
                                border.color: Theme.buttonBorder
                                border.width: 1

                                // Cover the bottom border when expanded
                                Rectangle {
                                    width: parent.width - (2 * parent.border.width)
                                    height: parent.border.width
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    color: parent.color
                                    visible: outputDeviceLayout.expanded
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 8

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        text: SoundManager.audioOutput.device.description
                                        color: Theme.primaryText
                                        font.pointSize: 14
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: "arrow_drop_down"
                                        font.family: materialFontFamily
                                        font.pixelSize: 28
                                        color: Theme.icon
                                        rotation: outputDeviceLayout.expanded ? 180 : 0
                                        Behavior on rotation { RotationAnimation { duration: 200 } }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        SoundManager.playTouch()
                                        outputDeviceLayout.expanded = !outputDeviceLayout.expanded
                                    }
                                }
                            }

                            // --- Expanded List of Devices ---
                            Rectangle {
                                width: deviceButton.width
                                height: outputDeviceLayout.expanded ? Math.min(deviceList.contentHeight, 170) : 0
                                clip: true
                                color: Theme.tertiaryBg
                                border.color: Theme.buttonBorder
                                border.width: 1
                                // Hide top border by moving it up by 1 pixel when expanded
                                y: deviceButton.height - (outputDeviceLayout.expanded ? 1 : 0)

                                Behavior on height { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
                                Behavior on y { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }

                                ScrollView {
                                    anchors.fill: parent
                                    clip: true
                                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                                    ListView {
                                        id: deviceList
                                        width: parent.width
                                        spacing: 2
                                        model: SoundManager.mediaDevices.audioOutputs.length > 0 ? SoundManager.mediaDevices.audioOutputs : ["No output devices found"]

                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 40
                                            color: "transparent"
                                            property bool isDevice: typeof modelData !== "string"
                                            property bool isCurrent: isDevice && modelData.description === SoundManager.audioOutput.device.description

                                            Rectangle {
                                                anchors.fill: parent
                                                color: Theme.accent
                                                opacity: isCurrent ? 0.2 : (deviceMouseArea.hovered ? 0.1 : 0)
                                                Behavior on opacity { NumberAnimation { duration: 100 } }
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 8
                                                anchors.rightMargin: 8

                                                Text {
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignVCenter
                                                    text: isDevice ? modelData.description : modelData
                                                    color: isDevice ? Theme.primaryText : Theme.secondaryText
                                                    font.pointSize: 14
                                                    elide: Text.ElideRight
                                                }
                                                Text {
                                                    text: "check"
                                                    font.family: materialFontFamily
                                                    font.pixelSize: 24
                                                    color: Theme.accent
                                                    visible: isCurrent
                                                }
                                            }

                                            MouseArea {
                                                id: deviceMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: isDevice ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                enabled: isDevice
                                                onClicked: {
                                                    SoundManager.playTouch()
                                                    Theme.setAudioOutputDevice(modelData.description)
                                                    outputDeviceLayout.expanded = false // Use the id to access expanded property
                                                }
                                            }
                                        }
                                    }
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

            // Add some padding at the bottom of the scroll view
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                color: "transparent"
            }
        }
    }
}
