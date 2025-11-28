import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import com.company.style 1.0
import com.company.sound 1.0

Item {
    anchors.fill: parent

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
        }
    }
}
