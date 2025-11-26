#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>
#include <QQuickWindow>
#include <QMediaPlayer>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    int fontId = QFontDatabase::addApplicationFont(":/assets/fonts/ttf/material-symbols-rounded-latin-500-normal.ttf");
    if (fontId == -1) {
        qWarning() << "Failed to load Material Symbols font.";
    }
    QString materialFontFamily = QFontDatabase::applicationFontFamilies(fontId).at(0);

    QQmlApplicationEngine engine;

    // Cung cấp tên font cho QML thông qua context property
    engine.rootContext()->setContextProperty("materialFontFamily", materialFontFamily);

#ifdef RASPBERRYPI_BUILD
    engine.rootContext()->setContextProperty("isPiBuild", true);
#else
    engine.rootContext()->setContextProperty("isPiBuild", false);
#endif

    // Đăng ký Theme singleton
    qmlRegisterSingletonType(QUrl("qrc:/qml/Theme.qml"), "com.company.style", 1, 0, "Theme");

    // Đăng ký Utils singleton
    qmlRegisterSingletonType(QUrl("qrc:/qml/Utils.qml"), "com.company.utils", 1, 0, "Utils");

    // Đăng ký SoundManager singleton
    qmlRegisterSingletonType(QUrl("qrc:/qml/SoundManager.qml"), "com.company.sound", 1, 0, "SoundManager");

    // Đăng ký WebSocketClient.qml để có thể sử dụng trong QML
    // với tên "WebSocketClient" trong module "com.company.ws" phiên bản 1.0
    qmlRegisterType(QUrl("qrc:/qml/WebSocketClient.qml"), "com.company.ws", 1, 0, "WebSocketClient");

    // Tải tệp QML ()
    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

#ifdef RASPBERRYPI_BUILD
        if (auto window = qobject_cast<QQuickWindow*>(obj)) {
            window->setVisibility(QWindow::FullScreen);
        }
#endif
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
