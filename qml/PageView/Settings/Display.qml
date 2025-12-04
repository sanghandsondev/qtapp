import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import com.company.style 1.0
import com.company.sound 1.0

Item {
    // Signal to notify the parent (Settings.qml) to go back
    signal backRequested()

    ScrollView {
        id: displayScrollView
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            width: displayScrollView.width
            spacing: 16

            // --- Time Format Setting ---
            RowLayout {
                Layout.fillWidth: true
                height: Math.max(timeFormatTextColumn.implicitHeight, timeFormatToggle.implicitHeight)

                // Left side: Icon and text
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 10
                    spacing: 12

                    Text {
                        text: "schedule" // Clock icon
                        font.family: materialFontFamily
                        font.pixelSize: 28
                        color: Theme.icon
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        id: timeFormatTextColumn
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "Time Format"
                            color: Theme.primaryText
                            font.pointSize: 16
                        }
                        Text {
                            text: Theme.is24HourFormat ? "24:00" : "12:00 AM/PM"
                            color: Theme.secondaryText
                            font.pointSize: 12
                        }
                    }
                }

                Item { Layout.fillWidth: true } // Spacer

                // Right side: Toggle
                Text {
                    id: timeFormatToggle
                    font.family: materialFontFamily
                    font.pixelSize: 48
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 20

                    text: Theme.is24HourFormat ? "toggle_on" : "toggle_off"
                    color: Theme.is24HourFormat ? Theme.toggleOn : Theme.toggleOff

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SoundManager.playTouch()
                            Theme.toggleTimeFormat()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.separator
            }

            // --- Dark Mode Setting ---
            RowLayout {
                Layout.fillWidth: true
                height: Math.max(themeTextColumn.implicitHeight, themeToggle.implicitHeight)

                // Left side: Icon and text
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 10
                    spacing: 12

                    Text {
                        text: "palette" // Color palette icon
                        font.family: materialFontFamily
                        font.pixelSize: 28
                        color: Theme.icon
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        id: themeTextColumn
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "Theme"
                            color: Theme.primaryText
                            font.pointSize: 16
                        }
                        Text {
                            text: "This will apply to all pages"
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
                        text: Theme.isDark ? "Dark" : "Light"
                        color: Theme.secondaryText
                        font.pointSize: 14
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        id: themeToggle
                        font.family: materialFontFamily
                        font.pixelSize: 48
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 20

                        text: Theme.isDark ? "toggle_on" : "toggle_off"
                        color: Theme.isDark ? Theme.toggleOn : Theme.toggleOff

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SoundManager.playTouch()
                                Theme.toggle()
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

            // --- Brightness Setting ---
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                height: Math.max(brightnessTextColumn.implicitHeight, brightnessControl.implicitHeight)

                // Left side: Icon and text
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 10
                    spacing: 12

                    Text {
                        text: "brightness_medium" // Brightness icon
                        font.family: materialFontFamily
                        font.pixelSize: 28
                        color: Theme.icon
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        id: brightnessTextColumn
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "Brightness"
                            color: Theme.primaryText
                            font.pointSize: 16
                        }
                        Text {
                            text: "Brightness: " + Math.round(Theme.brightnessLevel * 100) + " %"
                            color: Theme.secondaryText
                            font.pointSize: 12
                        }
                    }
                }

                Item { Layout.fillWidth: true } // Spacer

                // Right side: Brightness slider
                Item {
                    id: brightnessControl
                    Layout.preferredWidth: 420
                    height: 40
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 20

                    Slider {
                        id: brightnessSlider
                        anchors.fill: parent
                        from: 0.6 // Minimum brightness
                        to: 1.0
                        value: Theme.brightnessLevel
                        stepSize: 0.01

                        onValueChanged: {
                            if (pressed) { // Only update when user is interacting
                                Theme.setBrightnessLevel(value)
                            }
                        }

                        onPressedChanged: {
                            if (!pressed) { // User has just released the slider
                                SoundManager.playTouch()
                            }
                        }

                        background: Rectangle {
                            x: brightnessSlider.leftPadding
                            y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                            width: brightnessSlider.availableWidth
                            height: 6 // Thicker bar
                            radius: 3
                            color: Theme.tertiaryBg

                            Rectangle {
                                width: brightnessSlider.visualPosition * parent.width
                                height: parent.height
                                radius: 3
                                color: Theme.toggleOn
                            }
                        }

                        handle: Rectangle {
                            x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                            y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
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

            // Add some padding at the bottom of the scroll view
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                color: "transparent"
            }
        }
    }
}