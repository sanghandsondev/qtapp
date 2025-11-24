import QtQuick 6.4
import QtQuick.Layouts 1.15
import com.company.style 1.0

Item {
    width: parent.width
    height: parent.height

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // --- Header ---
        Text {
            text: "Home"
            color: Theme.primaryText
            font.pointSize: 20
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.separator
        }

        // --- Page Content ---
        // Spacer to push content to the top
        Item {
            Layout.fillHeight: true
        }
    }
}
