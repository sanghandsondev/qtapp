import QtQuick 6.4
import com.company.style 1.0

Rectangle {
    id: banner
    width: parent.width
    height: 80 // Tăng chiều cao
    y: -height // Ban đầu ẩn phía trên màn hình
    opacity: 0 // Ban đầu trong suốt
    color: Theme.bannerBg // Màu nền xám giống nút được chọn
    border.width: 4 // Độ dày viền

    property string notificationText: ""
    property string notificationType: "info" // "success", "warning", "error"
    property int topMargin: 0 // Thêm thuộc tính topMargin

    // Timer để tự động ẩn
    Timer {
        id: hideTimer
        interval: 5000 // 5 giây
        repeat: false
        onTriggered: hide()
    }

    // Animation để hiển thị và ẩn
    Behavior on y {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 300 }
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
        text: banner.notificationText
        color: Theme.primaryText // Đổi màu chữ thành trắng
        font.pointSize: 16 // Giảm kích thước font
        // font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: hide()
    }

    // Hàm để hiển thị banner
    function show(text, type) {
        hideTimer.stop(); // Dừng timer cũ nếu có
        banner.notificationText = text;
        banner.notificationType = type;
        banner.y = topMargin; // Trượt xuống vị trí có margin
        banner.opacity = 1; // Hiện rõ
        hideTimer.start(); // Bắt đầu timer mới
    }

    // Hàm để ẩn banner
    function hide() {
        hideTimer.stop();
        banner.y = -(banner.height + topMargin); // Trượt lên hoàn toàn
        banner.opacity = 0; // Mờ dần
    }
}
