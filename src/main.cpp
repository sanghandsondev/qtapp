#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>
#include <QQuickWindow>
#include <QMediaPlayer>

#include "SettingsManager.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MyCompany");
    app.setApplicationName("QtApp");

    QQmlApplicationEngine engine;

    // Đăng ký font Material Symbols -> QML
    int fontId = QFontDatabase::addApplicationFont(":/assets/fonts/ttf/material-symbols-rounded-latin-500-normal.ttf");
    if (fontId == -1) {
        qWarning() << "Failed to load Material Symbols font.";
    }
    QString materialFontFamily = QFontDatabase::applicationFontFamilies(fontId).at(0);
    
    engine.rootContext()->setContextProperty("materialFontFamily", materialFontFamily);

    // Đăng ký biến "isPiBuild" -> QML
#ifdef RASPBERRYPI_BUILD
    engine.rootContext()->setContextProperty("isPiBuild", true);
#else
    engine.rootContext()->setContextProperty("isPiBuild", false);
#endif

    // Đăng ký SettingsManager (C++-based) -> QML
    qmlRegisterType<SettingsManager>("com.company.settings", 1, 0, "SettingsManager");

    // Đăng ký WebSocketClient type (QObject-based)
    qmlRegisterType(QUrl("qrc:/qml/WebSocketClient.qml"), "com.company.ws", 1, 0, "WebSocketClient");

    // Đăng ký Theme singleton (QObject-based) -> QML
    qmlRegisterSingletonType(QUrl("qrc:/qml/Theme.qml"), "com.company.style", 1, 0, "Theme");

    // Đăng ký Utils singleton (QObject-based)
    qmlRegisterSingletonType(QUrl("qrc:/qml/Utils.qml"), "com.company.utils", 1, 0, "Utils");

    // Đăng ký SoundManager singleton (QObject-based)
    qmlRegisterSingletonType(QUrl("qrc:/qml/SoundManager.qml"), "com.company.sound", 1, 0, "SoundManager");

    // Load main QML file
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
