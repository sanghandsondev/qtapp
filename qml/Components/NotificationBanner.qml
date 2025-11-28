import QtQuick 6.4
import com.company.style 1.0

Rectangle {
    id: banner
    width: 600 // Sử dụng width cố định thay vì parent.width
    height: 68
    // Đặt vị trí ban đầu ở ngoài màn hình bên phải
    x: parent ? parent.width : width
    y: topMargin // Y position is now fixed
    opacity: 0 // Ban đầu trong suốt
    color: Theme.bannerBg
    border.width: 3

    property string notificationText: ""
    property string notificationType: "info" // "success", "warning", "error"
    property int topMargin: 0

    // Timer để tự động ẩn
    Timer {
        id: hideTimer
        interval: 5000 // 5 giây
        repeat: false
        onTriggered: hide()
    }

    // Animation để hiển thị và ẩn
    Behavior on x {
        NumberAnimation { duration: 1000; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 500 }
    }

    // Cập nhật màu sắc dựa trên loại thông báo
    onNotificationTypeChanged: {
        switch (notificationType) {
            case "success":
                banner.border.color = "#4ade80"; // Lighter Green
                break;
            case "warning":
                banner.border.color = "#fb923c"; // Lighter Orange
                break;
            case "error":
                banner.border.color = "#f87171"; // Lighter Red
                break;
            default:
                banner.border.color = "#60a5fa"; // Lighter Blue
                break;
        }
    }

    Text {
        id: messageText
        anchors.centerIn: parent
        width: parent.width - 24 // Thêm padding
        text: banner.notificationText
        color: Theme.primaryText
        font.pointSize: 12 // Giảm kích thước font
        elide: Text.ElideRight // Thêm dấu "..." cho văn bản dài
        horizontalAlignment: Text.AlignHCenter // Căn giữa văn bản ngắn
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: hide()
    }

    // Hàm để hiển thị banner
    function show(text, type) {
        hideTimer.stop();
        // Đặt lại vị trí ra ngoài màn hình bên phải
        banner.x = parent.width;
        banner.opacity = 0;

        banner.notificationText = text;
        banner.notificationType = type;

        // Trượt vào trong màn hình, cách cạnh phải 8px
        banner.x = parent.width - banner.width - 8;
        banner.opacity = 1;
        hideTimer.start();
    }

    // Hàm để ẩn banner
    function hide() {
        hideTimer.stop();
        // Trượt ra ngoài màn hình bên phải
        banner.x = parent.width;
        banner.opacity = 0;
    }
}
