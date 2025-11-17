#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>

int main(int argc, char *argv[])
{
    // 1. Khởi tạo ứng dụng GUI
    QGuiApplication app(argc, argv);

    // 2. Khởi tạo QML Engine
    QQmlApplicationEngine engine;

    // 3. Tải tệp QML
    // Đường dẫn "qrc:/main.qml" trỏ đến tệp main.qml đã được nhúng (resources)
    const QUrl url(u"qrc:/main.qml"_qs);
    
    // Xử lý lỗi nếu việc tải tệp QML không thành công
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    // 4. Bắt đầu vòng lặp sự kiện của ứng dụng
    return app.exec();
}