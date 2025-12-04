import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import com.company.style 1.0
import com.company.sound 1.0
import com.company.utils 1.0

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
                            text: "Volume: " + Math.round(Theme.volumeLevel * 100) + " %"
                            color: Theme.secondaryText
                            font.pointSize: 12
                        }
                    }
                }

                Item { Layout.fillWidth: true } // Spacer

                // Right side: Volume slider
                Item {
                    id: volumeControl
                    // Layout.preferredWidth: parent.width / 2
                    Layout.preferredWidth: 420
                    height: 40
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 20

                    Slider {
                        id: volumeSlider
                        anchors.fill: parent
                        from: 0.0
                        to: 1.0
                        value: Theme.volumeLevel
                        stepSize: 0.01 // Allow fine-grained control

                        onValueChanged: {
                            if (pressed) { // Only update when user is interacting
                                Theme.setVolumeLevel(value)
                            }
                        }

                        onPressedChanged: {
                            if (!pressed) { // User has just released the slider
                                // Play sound when user finishes sliding
                                SoundManager.playTouch()
                            }
                        }

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: volumeSlider.availableWidth
                            height: 6 // Thicker bar
                            radius: 3
                            color: Theme.tertiaryBg

                            Rectangle {
                                width: volumeSlider.visualPosition * parent.width
                                height: parent.height
                                radius: 3
                                color: Theme.toggleOn
                            }
                        }

                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: 24 // Larger handle
                            height: 24
                            radius: 12
                            color: Theme.primaryText
                            border.color: Theme.buttonBorder
                            border.width: 1
                            visible: true
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
                            // Layout.preferredWidth: parent.width / 2
                            Layout.preferredWidth: 420
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
                                        // Hide the text when the dropdown is open
                                        visible: !outputDeviceLayout.expanded
                                    }

                                    // Spacer to push the arrow to the right when the text is hidden
                                    Item {
                                        Layout.fillWidth: true
                                        visible: outputDeviceLayout.expanded
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
                                            height: 54 // Increased height
                                            color: isCurrent ? Theme.separator : (deviceMouseArea.hovered ? Theme.hover : "transparent")
                                            Behavior on color { ColorAnimation { duration: 150 } }

                                            property bool isDevice: typeof modelData !== "string"
                                            property bool isCurrent: isDevice && modelData.description === SoundManager.audioOutput.device.description

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 12
                                                anchors.rightMargin: 8
                                                spacing: 8

                                                Text {
                                                    text: isDevice ? Utils.getIconForAudioDevice(modelData) : "speaker" // Use new function for dynamic icon
                                                    font.family: materialFontFamily
                                                    font.pixelSize: 24
                                                    color: Theme.icon
                                                    Layout.alignment: Qt.AlignVCenter
                                                    visible: isDevice
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignVCenter
                                                    text: isDevice ? modelData.description : modelData
                                                    color: isDevice ? Theme.primaryText : Theme.secondaryText
                                                    font.pointSize: 14
                                                    elide: Text.ElideRight
                                                }

                                                // Spacer to push the indicator to the right
                                                Item { Layout.fillWidth: true }

                                                // --- Selection Indicator ---
                                                Text {
                                                    text: "circle" // Solid circle icon
                                                    font.family: materialFontFamily
                                                    font.pixelSize: 16
                                                    color: Theme.toggleOn // Use a distinct color
                                                    Layout.alignment: Qt.AlignVCenter
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
